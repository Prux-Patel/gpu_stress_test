#!/bin/bash
clear
# Get GPU Model
GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits)
echo "GPU Model: $GPU_MODEL" > $LOG_FILE  # Log GPU model at the beginning

# Define log files
LOG_FILE="gpu_stress_benchmark.txt"
RAW_DATA_FILE="gpu_stress_data.csv"

# Test parameters
LOG_INTERVAL=120    		# Log every 2 minutes
TOTAL_DURATION=600 		# 10-minute test
NUM_PARALLEL=2    			# Run 2 parallel inference requests

# Initialize counters
INFERENCE_COUNT=0
MEMORY_SUM=0
UTILIZATION_SUM=0
TEMPERATURE_SUM=0
LOG_COUNT=0

# Start time
START_TIME=$(date +%s)
END_TIME=$((START_TIME + TOTAL_DURATION))

# Create CSV header
echo "Timestamp,Inference Count,GPU Memory (MB),GPU Utilization (%),Temperature (C)" > $RAW_DATA_FILE

# Function to log results
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "GPU Stress Test Started" 
echo "Detected GPU: $GPU_MODEL"

# Ensure real-time updates
export STDBUF_FORCE_L=1

# Start test loop
while [ $(date +%s) -lt $END_TIME ]; do
  CURRENT_TIME=$(date +%s)

  # Run multiple parallel inferences and ensure completion
  for ((i=1; i<=NUM_PARALLEL; i++)); do
    stdbuf -oL ollama run llama3 "Explain deep learning in detail." > /dev/null & 
  done
  wait  # Ensures all processes complete before proceeding

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

  # Save to CSV
  echo "$(date '+%H:%M:%S'),$INFERENCE_COUNT,$MEMORY_USAGE,$GPU_UTILIZATION,$GPU_TEMP" >> $RAW_DATA_FILE

  # Live progress update (real-time)
  ELAPSED=$((CURRENT_TIME - START_TIME))
  PERCENTAGE=$((ELAPSED * 100 / TOTAL_DURATION))
  echo -ne "\r⏳ $PERCENTAGE% | Inferences: $INFERENCE_COUNT | GPU: $GPU_UTILIZATION% | Mem: $MEMORY_USAGE MB | Temp: $GPU_TEMP°C    "

  # Log progress
  log "Inference #$INFERENCE_COUNT - GPU Memory: $MEMORY_USAGE MB - Utilization: $GPU_UTILIZATION% - Temp: $GPU_TEMP°C"

  # Sleep before next log
  sleep $LOG_INTERVAL
done

# Compute averages
DURATION=$((CURRENT_TIME - START_TIME))
THROUGHPUT=$(echo "scale=2; $INFERENCE_COUNT / $DURATION" | bc)
AVG_MEMORY=$(echo "scale=2; $MEMORY_SUM / $LOG_COUNT" | bc)
AVG_UTILIZATION=$(echo "scale=2; $UTILIZATION_SUM / $LOG_COUNT" | bc)
AVG_TEMP=$(echo "scale=2; $TEMPERATURE_SUM / $LOG_COUNT" | bc)

# Clear progress bar and print final results
echo "$GPU_MODEL"
echo -e "\n✅ GPU Stress Test Completed!"
log "GPU Stress Test Completed"
log "Total Inferences: $INFERENCE_COUNT"
log "Total Duration: $DURATION seconds"
log "Average Throughput: $THROUGHPUT inferences per second"
log "Average GPU Memory Usage: $AVG_MEMORY MB"
log "Average GPU Utilization: $AVG_UTILIZATION%"
log "Average GPU Temperature: $AVG_TEMP°C"

# Print summary
echo "$GPU_MODEL"
echo -e "\nGPU Stress Test Summary:"
echo "Total Inferences: $INFERENCE_COUNT"
echo "Total Duration: $DURATION seconds"
echo "Average Throughput: $THROUGHPUT inferences per second"
echo "Average GPU Memory Usage: $AVG_MEMORY MB"
echo "Average GPU Utilization: $AVG_UTILIZATION%"
echo "Average GPU Temperature: $AVG_TEMP°C"

# Display log
cat $LOG_FILE
