#!/bin/bash

clear
LOG_FILE="gpu_test_log.txt"
REPORT_FILE="benchmark_report.txt"
EMAIL="prakash.patel@cudoventures.com"

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function for installation
install_dependencies() {
  echo"----------------------------------------"
  log "Starting installation of dependencies..."
  echo"----------------------------------------"

  echo"------------------------------------------"
  echo "Updating and upgrading system packages..."
  echo"------------------------------------------"
  sudo apt update && sudo apt upgrade -y

  echo"--------------------------------"
  echo "Installing required packages..."
  echo"--------------------------------"
  sudo apt install -y python3-pip nvidia-cuda-toolkit mailx

  echo"---------------------------------------------"
  echo "Installing PyTorch with CUDA 12.1 support..."
  echo"---------------------------------------------"
  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

  echo"---------------------"
  echo "Installing Ollama..."
  echo"---------------------"
  curl -fsSL https://ollama.com/install.sh | sh

  echo"----------------------------------"
  echo "Installing yq (YAML processor)..."
  echo"----------------------------------"
  snap install yq

  echo"-----------------------------"
  echo "Downloading Ollama models..."
  echo"-----------------------------"
  echo ""
  echo"-------------"
  ollama pull mistral
  echo"-------------"
  ollama pull llama3
  echo"-------------"
  ollama pull gemma3
  echo"-------------"
  ech ""
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
    echo -ne "\r⏳ $PERCENTAGE% | Inferences: $INFERENCE_COUNT | GPU: $GPU_UTILIZATION% | Mem: $MEMORY_USAGE MB | Temp: $GPU_TEMP°C | Throughput: $THROUGHPUT inferences/sec    "

    # Log progress
    log "Inference #$INFERENCE_COUNT - GPU Memory: $MEMORY_USAGE MB - Utilization: $GPU_UTILIZATION% - Temp: $GPU_TEMP°C - Throughput: $THROUGHPUT inferences/sec"

    # Sleep before next log
    sleep $LOG_INTERVAL
  done

  # Compute final averages
  DURATION=$((CURRENT_TIME - START_TIME))
  if [ $DURATION -gt 0 ]; then
    FINAL_THROUGHPUT=$(echo "scale=2; $INFERENCE_COUNT / $DURATION" | bc)
  else
    FINAL_THROUGHPUT=0
  fi
  AVG_MEMORY=$(echo "scale=2; $MEMORY_SUM / $LOG_COUNT" | bc)
  AVG_UTILIZATION=$(echo "scale=2; $UTILIZATION_SUM / $LOG_COUNT" | bc)
  AVG_TEMP=$(echo "scale=2; $TEMPERATURE_SUM / $LOG_COUNT" | bc)

  # Log final results
  log "$MODEL Test Completed"
  log "Total Inferences: $INFERENCE_COUNT"
  log "Total Duration: $DURATION seconds"
  log "Average GPU Memory Usage: $AVG_MEMORY MB"
  log "Average GPU Utilization: $AVG_UTILIZATION%"
  log "Average GPU Temperature: $AVG_TEMP°C"
  log "Final Throughput: $FINAL_THROUGHPUT inferences/sec"

  # Append to Benchmark Report
  echo "===================================" >> $REPORT_FILE
  echo "      GPU Benchmark Report        " >> $REPORT_FILE
  echo "===================================" >> $REPORT_FILE
  echo "Model Tested: $MODEL" >> $REPORT_FILE
  echo "Total Inferences: $INFERENCE_COUNT" >> $REPORT_FILE
  echo "Total Duration: $DURATION seconds" >> $REPORT_FILE
  echo "Average GPU Memory Usage: $AVG_MEMORY MB" >> $REPORT_FILE
  echo "Average GPU Utilization: $AVG_UTILIZATION%" >> $REPORT_FILE
  echo "Average GPU Temperature: $AVG_TEMP°C" >> $REPORT_FILE
  echo "Final Throughput: $FINAL_THROUGHPUT inferences/sec" >> $REPORT_FILE
  echo "===================================\n" >> $REPORT_FILE
}

# Function to email results
#send_email() {
 # log "Sending email with benchmark results..."
  #mailx -s "GPU Benchmark Results" -a $LOG_FILE -a $REPORT_FILE -a mistral_benchmark.csv -a llama3_benchmark.csv -a gemma3_benchmark.csv $EMAIL < $REPORT_FILE
  #log "Email sent successfully."
#}

# Run all tests sequentially
install_dependencies
run_llm_test "mistral" "Summarize the impact of AI in healthcare."
run_llm_test "llama3" "Describe the history of neural networks."
run_llm_test "gemma3" "Discuss the ethical implications of AI in business."

# Send email after tests complete
python3 /root/send_email.py

echo "✅ All tests completed and results emailed to $EMAIL."
