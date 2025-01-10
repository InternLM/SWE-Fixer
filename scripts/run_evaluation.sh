#!/bin/bash

# Default values
RETRIEVAL_MODEL_DIR="./model/retrieval_model"
EDITING_MODEL_DIR="./model/editing_model"
EVAL_DATA_DIR="./eval_data"
DATASET_TYPE="lite"
PORT=8000
MODE=""
CONDA_ENV="SWE_Fixer"
CURRENT_DIR=$(cd "$(dirname "$0")" && pwd)

export PYTHONPATH="$CURRENT_DIR:$PYTHONPATH"
# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Required Options:"
    echo "  --mode TYPE          Mode type: retrieval or editing"
    echo ""
    echo "Optional Arguments:"
    echo "  --conda-env NAME      Conda environment name (default: SWE_Fixer)"
    echo "  --retrieval-model DIR Path to retrieval model (default: ./model/retrieval_model)"
    echo "  --editing-model DIR   Path to editing model (default: ./model/editing_model)"
    echo "  --eval-data DIR       Evaluation data directory (default: ./eval_data)"
    echo "  --dataset TYPE        Dataset type: lite or verified (default: lite)"
    echo "  --port PORT           Port for both models (default: 8000)"
    echo "  --help               Display this help message"
    echo ""
    echo "Example:"
    echo "  $0 --mode retrieval --conda-env my_env --retrieval-model /path/to/model"
}

# Function to check if conda environment exists
check_conda_env() {
    local env_name=$1
    conda info --envs | grep -q "^$env_name "
    return $?
}

# Parse command line arguments
while [ $# -gt 0 ]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --retrieval-model)
            RETRIEVAL_MODEL_DIR="$2"
            shift 2
            ;;
        --editing-model)
            EDITING_MODEL_DIR="$2"
            shift 2
            ;;
        --eval-data)
            EVAL_DATA_DIR="$2"
            shift 2
            ;;
        --dataset)
            DATASET_TYPE="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --conda-env)
            CONDA_ENV="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate mode
if [ "$MODE" != "retrieval" ] && [ "$MODE" != "editing" ]; then
    echo "Error: Mode must be specified as either 'retrieval' or 'editing'"
    usage
    exit 1
fi

# Validate dataset type
if [ "$DATASET_TYPE" != "lite" ] && [ "$DATASET_TYPE" != "verified" ]; then
    echo "Error: Dataset type must be either 'lite' or 'verified'"
    exit 1
fi

# Validate conda environment
if ! check_conda_env "$CONDA_ENV"; then
    echo "Error: Conda environment '$CONDA_ENV' not found"
    echo "Available environments:"
    conda env list
    exit 1
fi

# Function to wait for a port to be available
wait_for_port() {
    local port=$1
    local timeout=30
    local count=0
    while ! (echo > /dev/tcp/localhost/$port) >/dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
        if [ $count -eq $timeout ]; then
            echo "Timeout waiting for port $port"
            return 1
        fi
    done
    return 0
}

# Start tmux server if not running
tmux start-server


tmux kill-session -t retrieval_model 2>/dev/null
tmux kill-session -t retrieval_pipeline 2>/dev/null
tmux kill-session -t editing_model 2>/dev/null
tmux kill-session -t editing_pipeline 2>/dev/null

# Start model based on mode
if [ "$MODE" = "retrieval" ]; then
    echo "Starting retrieval model with environment: ${CONDA_ENV}..."
    # Create new session for model
    tmux new-session -s retrieval_model -n model -d
    tmux send-keys -t retrieval_model "conda activate ${CONDA_ENV}" Enter
    tmux send-keys -t retrieval_model "sh scripts/launch_model/retrieval_model.sh ${RETRIEVAL_MODEL_DIR} ${PORT}" Enter
    
    # Wait for retrieval model to start
    echo "Waiting for retrieval model to be ready..."
    sleep 30
    if ! wait_for_port ${PORT}; then
        echo "Failed to start retrieval model"
        exit 1
    fi
    
    # Run retrieval pipeline in a new tmux session
    echo "Running retrieval pipeline for ${DATASET_TYPE} dataset..."
    tmux new-session -s retrieval_pipeline -n pipeline -d
    tmux send-keys -t retrieval_pipeline "conda activate ${CONDA_ENV}" Enter
    tmux send-keys -t retrieval_pipeline "export PYTHONPATH="$CURRENT_DIR:$PYTHONPATH"" Enter
    if [ "$DATASET_TYPE" = "lite" ]; then
        tmux send-keys -t retrieval_pipeline "sh scripts/pipeline/run_pipeline_test.sh retrieval ${RETRIEVAL_MODEL_DIR} ${EVAL_DATA_DIR}" Enter
    else
        tmux send-keys -t retrieval_pipeline "sh scripts/pipeline/run_pipeline_test.sh retrieval ${RETRIEVAL_MODEL_DIR} ${EVAL_DATA_DIR} verified" Enter
    fi
else
    echo "Starting editing model with environment: ${CONDA_ENV}..."
    # Create new session for model
    tmux new-session -s editing_model -n model -d
    tmux send-keys -t editing_model "conda activate ${CONDA_ENV}" Enter
    tmux send-keys -t editing_model "sh scripts/launch_model/editing_model.sh ${EDITING_MODEL_DIR} ${PORT}" Enter
    
    # Wait for editing model to start
    echo "Waiting for editing model to be ready..."
    sleep 150
    if ! wait_for_port ${PORT}; then
        echo "Failed to start editing model"
        exit 1
    fi
    
    # Run editing pipeline in a new tmux session
    echo "Running editing pipeline for ${DATASET_TYPE} dataset..."
    tmux new-session -s editing_pipeline -n pipeline -d
    tmux send-keys -t editing_pipeline "conda activate ${CONDA_ENV}" Enter
    tmux send-keys -t editing_pipeline "export PYTHONPATH="$CURRENT_DIR:$PYTHONPATH"" Enter
    if [ "$DATASET_TYPE" = "lite" ]; then
        tmux send-keys -t editing_pipeline "sh scripts/pipeline/run_pipeline_test.sh editing ${EDITING_MODEL_DIR} ${EVAL_DATA_DIR}" Enter
    else
        tmux send-keys -t editing_pipeline "sh scripts/pipeline/run_pipeline_test.sh editing ${EDITING_MODEL_DIR} ${EVAL_DATA_DIR} verified" Enter
    fi
fi

echo "Evaluation started! You can check the progress in tmux sessions:"
if [ "$MODE" = "retrieval" ]; then
    echo "  - Model: 'tmux attach -t retrieval_model'"
    echo "  - Pipeline: 'tmux attach -t retrieval_pipeline'"
else
    echo "  - Model: 'tmux attach -t editing_model'"
    echo "  - Pipeline: 'tmux attach -t editing_pipeline'"
fi
echo "Results will be saved in the result directory."
