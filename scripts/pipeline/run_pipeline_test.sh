#!/bin/bash

# piplin.sh
# A script to run the pipeline.py file for processing instances.

# Determine mode (default to "lite")
METHOD=$1
MODEL_PATH=$2
DATASET_PATH=$3  # Path to the dataset
# Determine mode (default to "lite")
MODE=${4:-lite}  # Use the first argument, default to "lite"

echo "MODE: $MODE"

# Set flags based on user input
if [ "$METHOD" = "retrieval" ]; then
    RUN_RETRIEVAL=true
    RUN_EDITING=false
    echo "Running retrieval method..."
elif [ "$METHOD" = "editing" ]; then
    RUN_RETRIEVAL=false
    RUN_EDITING=true
    echo "Running editing method..."
else
    echo "Invalid input. Please choose either 'retrieval' or 'editing'"
    exit 1
fi

# Set your parameters here
TOKENIZER_PATH=$MODEL_PATH  # Path to the tokenizer
RESULT_PATH="./results/${MODE}"
[ ! -d "$RESULT_PATH" ] && mkdir -p "$RESULT_PATH"

API_KEY="token-abc123"  # API key for OpenAI
BASE_URL="http://localhost:8000/v1"  # Base URL for OpenAI API

INSTANCE_FILE_PATH="$DATASET_PATH/swe_bench/$MODE/swe_bench_${MODE}.jsonl"
CODE_STRUCTURE_PATH="$DATASET_PATH/swe_bench_test_code_structure"
BM25_TRAIN_FILES="$DATASET_PATH/retrieval_data/swe_bench_${MODE}_retrieval_data.jsonl"

BM25_INPUT_DATASET="$RESULT_PATH/bm25_${MODE}_input_dataset.jsonl"
BM25_RESULTS_FILE="$RESULT_PATH/bm25_${MODE}_results.json"
EDITING_DATASET_PATH="$RESULT_PATH/editing_${MODE}_dataset.jsonl"
EDITING_RESULT_PATH="$RESULT_PATH/editing_${MODE}_results.jsonl"

POST_PROCESS=true  # Enable post-processing (true/false)

# Run the script
python pipeline/pipeline.py \
  --api_key "$API_KEY" \
  --base_url "$BASE_URL" \
  --tokenizer_path "$TOKENIZER_PATH" \
  --instance_file_path "$INSTANCE_FILE_PATH" \
  --code_structure_path "$CODE_STRUCTURE_PATH" \
  --bm25_retrieval_files "$BM25_TRAIN_FILES" \
  --bm25_input_dataset "$BM25_INPUT_DATASET" \
  --bm25_results_file "$BM25_RESULTS_FILE" \
  --editing_dataset_path "$EDITING_DATASET_PATH" \
  --editing_result_path "$EDITING_RESULT_PATH" \
  $( [ "$POST_PROCESS" = true ] && echo "--post_process" ) \
  $( [ "$RUN_RETRIEVAL" = true ] && echo "--run_retrieval" ) \
  $( [ "$RUN_EDITING" = true ] && echo "--run_editing" )