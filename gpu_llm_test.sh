#!/bin/bash

# Define log and CSV files
LOG_FILE="benchmark_results.txt"
RAW_DATA_FILE="benchmark_data.csv"
LOG_INTERVAL=600   # Interval in seconds (10 minutes)
TOTAL_DURATION=3600 # Total duration for the test (1 hour)

# Get GPU Model
GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits)
echo "Detected GPU: $GPU_MODEL"
echo "GPU Model: $GPU_MODEL" > $LOG_FILE  # Log GPU model at the beginning

# Initialize counters and accumulators
INFERENCE_COUNT=0
MEMORY_SUM=0
UTILIZATION_SUM=0
TEMP_SUM=0
LOG_COUNT=0

# Create CSV header for raw data
echo "Timestamp,GPU Model,Inference Count,GPU Memory (MB),GPU Utilization (%),GPU Temperature (°C)" > $RAW_DATA_FILE

# Function to log results
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

log "Benchmark started"

# Get start time
START_TIME=$(date +%s)
END_TIME=$((START_TIME + TOTAL_DURATION))

# Loop for 1 hour (3600 seconds), logging every 10 minutes
while [ $(date +%s) -lt $END_TIME ]; do
  # Run LLM inference
  ollama run gemma3 "Explain the principles of deep learning in AI." > /dev/null & 

  # Increment inference count
  INFERENCE_COUNT=$((INFERENCE_COUNT + 1))

  # Get GPU metrics
  MEMORY_USAGE=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
  GPU_UTILIZATION=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
  GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

  # Update accumulators for averaging later
  MEMORY_SUM=$((MEMORY_SUM + MEMORY_USAGE))
  UTILIZATION_SUM=$((UTILIZATION_SUM + GPU_UTILIZATION))
  TEMP_SUM=$((TEMP_SUM + GPU_TEMP))
  LOG_COUNT=$((LOG_COUNT + 1))

  # Log data for graph plotting
  echo "$(date '+%H:%M:%S'),$GPU_MODEL,$INFERENCE_COUNT,$MEMORY_USAGE,$GPU_UTILIZATION,$GPU_TEMP" >> $RAW_DATA_FILE

  # Log periodic updates
  log "Timestamp: $(date '+%H:%M:%S') - Inference #$INFERENCE_COUNT - GPU Memory: $MEMORY_USAGE MB - Utilization: $GPU_UTILIZATION% - Temp: $GPU_TEMP°C"

  # Sleep for 10 minutes
  sleep $LOG_INTERVAL
done

# Calculate averages
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
THROUGHPUT=$(echo "scale=2; $INFERENCE_COUNT / $DURATION" | bc)
AVG_MEMORY=$(echo "scale=2; $MEMORY_SUM / $LOG_COUNT" | bc)
AVG_UTILIZATION=$(echo "scale=2; $UTILIZATION_SUM / $LOG_COUNT" | bc)
AVG_TEMP=$(echo "scale=2; $TEMP_SUM / $LOG_COUNT" | bc)

# Log final results
log "Benchmark completed"
log "GPU Model: $GPU_MODEL"
log "Total Inferences: $INFERENCE_COUNT"
log "Total duration: $DURATION seconds"
log "Average Throughput: $THROUGHPUT inferences per second"
log "Average GPU Memory Usage: $AVG_MEMORY MB"
log "Average GPU Utilization: $AVG_UTILIZATION%"
log "Average GPU Temperature: $AVG_TEMP°C"

# Print summary
echo -e "\nBenchmark Summary:"
echo "GPU Model: $GPU_MODEL"
echo "Total Inferences: $INFERENCE_COUNT"
echo "Total Duration: $DURATION seconds"
echo "Average Throughput: $THROUGHPUT inferences per second"
echo "Average GPU Memory Usage: $AVG_MEMORY MB"
echo "Average GPU Utilization: $AVG_UTILIZATION%"
echo "Average GPU Temperature: $AVG_TEMP°C"

# Display log content
cat $LOG_FILE
