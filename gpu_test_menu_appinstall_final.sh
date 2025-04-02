#!/bin/bash

clear
LOG_FILE="gpu_test_log.txt"
REPORT_FILE="benchmark_report.txt"

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function for installation
install_dependencies() {
  log "Starting installation of dependencies..."
  
  echo "Updating and upgrading system packages..."
  sudo apt update && sudo apt upgrade -y

  echo "Installing required packages..."
  sudo apt install -y python3-pip nvidia-cuda-toolkit

  echo "Installing PyTorch with CUDA 12.1 support..."
  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

  echo "Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh

  echo "Installing yq (YAML processor)..."
  snap install yq

  echo "Downloading Ollama models..."
  ollama pull mistral
  ollama pull llama3
  ollama pull gemma3

  log "Installation completed."
}

# Function to run LLM test with benchmarking (2 parallel inferences)
run_llm_test() {
  MODEL=$1
  PROMPT=$2
  CSV_FILE="${MODEL}_benchmark.csv"

  log "Starting $MODEL test..."
  
  # Define test parameters
  LOG_INTERVAL=120  # Log every 2 minutes
  TOTAL_DURATION=600  # 10-minute test
  NUM_PARALLEL=2  # Run 2 parallel inferences
  START_TIME=$(date +%s)
  END_TIME=$((START_TIME + TOTAL_DURATION))
  
  # Create CSV file with headers
  echo "Timestamp,Inference Count,GPU Memory (MB),GPU Utilization (%),Temperature (C),Throughput (inferences/sec)" > $CSV_FILE

  INFERENCE_COUNT=0
  MEMORY_SUM=0
  UTILIZATION_SUM=0
  TEMPERATURE_SUM=0
  LOG_COUNT=0

  while [ $(date +%s) -lt $END_TIME ]; do
    CURRENT_TIME=$(date +%s)

    # Run multiple parallel inferences
    for ((i=1; i<=NUM_PARALLEL; i++)); do
      ollama run $MODEL "$PROMPT" > /dev/null &
    done
    wait  # Ensures all inferences complete before continuing

    # Increment inference count
    INFERENCE_COUNT=$((INFERENCE_COUNT + NUM_PARALLEL))

    # Get GPU metrics
    MEMORY_USAGE=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
    GPU_UTILIZATION=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

    # Accumulate data for averaging
    MEMORY_SUM=$((MEMORY_SUM + MEMORY_USAGE))
    UTILIZATION_SUM=$((UTILIZATION_SUM + GPU_UTILIZATION))
    TEMPERATURE_SUM=$((TEMPERATURE_SUM + GPU_TEMP))
    LOG_COUNT=$((LOG_COUNT + 1))

    # Calculate throughput (inferences per second)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    if [ $ELAPSED -gt 0 ]; then
      THROUGHPUT=$(echo "scale=2; $INFERENCE_COUNT / $ELAPSED" | bc)
    else
      THROUGHPUT=0
    fi

    # Save to CSV
    echo "$(date '+%H:%M:%S'),$INFERENCE_COUNT,$MEMORY_USAGE,$GPU_UTILIZATION,$GPU_TEMP,$THROUGHPUT" >> $CSV_FILE

    # Live progress update
    PERCENTAGE=$((ELAPSED * 100 / TOTAL_DURATION))
    echo -ne "\r⏳ $PERCENTAGE% | Inferences: $INFERENCE_COUNT | GPU: $GPU_UTILIZATION% |
