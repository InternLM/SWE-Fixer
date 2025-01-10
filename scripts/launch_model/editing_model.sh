# Path to the editing model
MODEL_PATH=$1
PORT=$2
lmdeploy serve api_server $MODEL_PATH --server-name 0.0.0.0 --server-port $PORT --tp 4 --session-len 65536  --log-level INFO --chat-template qwen
