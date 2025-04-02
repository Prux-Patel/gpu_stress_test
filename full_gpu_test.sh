#!/bin/bash

# Define log file
LOG_FILE="benchmark_results.txt"

# Function to log results with timestamps
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Start logging
log "Benchmark started"

# 1. Measure Throughput (inferences per second)
log "Measuring throughput..."
START_TIME=$(date +%s)
for i in {1..100}; do
  ollama run mistral "Describe the benefits of artificial intelligence." &
done
wait
END_TIME=$(date +%s)
DIFF=$((END_TIME - START_TIME))
THROUGHPUT=$(echo "scale=2; 100/$DIFF" | bc)
log "Throughput: $THROUGHPUT inferences per second"

# 2. Measure Memory Usage using nvidia-smi
log "Measuring GPU memory usage..."
MEMORY_USAGE=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
log "GPU Memory Usage: $MEMORY_USAGE MB"

# 3. Measure Latency for individual requests
log "Measuring latency..."
LATENCY_SUM=0
for i in {1..10}; do
  LATENCY=$( (time ollama run mistral "Explain the concept of black holes.") 2>&1 | grep real | awk '{print $2}')
  LATENCY_SECONDS=$(echo $LATENCY | sed 's/m/ /; s/s//')
  LATENCY_SUM=$(echo "$LATENCY_SUM + $LATENCY_SECONDS" | bc)
done
AVERAGE_LATENCY=$(echo "scale=2; $LATENCY_SUM / 10" | bc)
log "Average Latency: $AVERAGE_LATENCY seconds"

# 4. Measure GPU Utilization using nvidia-smi
log "Measuring GPU utilization..."
GPU_UTILIZATION=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
log "GPU Utilization: $GPU_UTILIZATION%"

# 5. Optional: Measure Power Consumption
log "Measuring GPU power consumption..."
GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits)
log "GPU Power Consumption: $GPU_POWER W"

# 6. Stress Test with Multiple Inference Requests (Batch)
log "Running batch inference for stress testing..."
START_TIME_BATCH=$(date +%s)
for i in {1..20}; do
  ollama run mistral "Summarize the key principles of machine learning." &
done
wait
END_TIME_BATCH=$(date +%s)
DIFF_BATCH=$((END_TIME_BATCH - START_TIME_BATCH))
BATCH_THROUGHPUT=$(echo "scale=2; 20/$DIFF_BATCH" | bc)
log "Batch Throughput: $BATCH_THROUGHPUT inferences per second"

# End logging
log "Benchmark completed"

# Display log content
cat $LOG_FILE
