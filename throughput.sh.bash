START_TIME=$(date +%s)
for i in {1..100}; do
  ollama run mistral "Describe the benefits of artificial intelligence." &
done
wait
END_TIME=$(date +%s)
DIFF=$((END_TIME - START_TIME))
THROUGHPUT=$(echo "scale=2; 100/$DIFF" | bc)
echo "Throughput: $THROUGHPUT inferences per second"