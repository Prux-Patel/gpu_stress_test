for i in {1..10}; do
  time ollama run mistral "Explain the concept of black holes."
done

LATENCY_SUM=0
for i in {1..10}; do
  LATENCY=$( (time ollama run mistral "Explain the theory of relativity.") 2>&1 | grep real | awk '{print $2}')
  LATENCY_SECONDS=$(echo $LATENCY | sed 's/m/ /; s/s//')
  LATENCY_SUM=$(echo "$LATENCY_SUM + $LATENCY_SECONDS" | bc)
done
AVERAGE_LATENCY=$(echo "scale=2; $LATENCY_SUM / 10" | bc)
echo "Average Latency: $AVERAGE_LATENCY seconds"