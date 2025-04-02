#!/bin/bash

clear
LOG_FILE="gpu_test_log.txt"

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

# Function for application tests
run_application_tests() {
  log "Running application tests..."
  echo "Testing application functionality..."
  ollama run llama3 "Explain deep learning in simple terms."
  log "Application tests completed."
}

# Function for Mistral test
run_mistral_test() {
  log "Running Mistral model test..."
  ollama run mistral "Summarize the impact of AI in healthcare."
  log "Mistral test completed."
}

# Function for Llama3 test
run_llama3_test() {
  log "Running Llama3 model test..."
  ollama run llama3 "Describe the history of neural networks."
  log "Llama3 test completed."
}

# Function for Gemma3 test
run_gemma3_test() {
  log "Running Gemma3 model test..."
  ollama run gemma3 "Discuss the ethical implications of AI in business."
  log "Gemma3 test completed."
}

# Main menu
while true; do
  clear
  echo "==============================="
  echo " GPU Test & Benchmark Menu "
  echo "==============================="
  echo "1. Install Dependencies"
  echo "2. Run Application Tests"
  echo "3. Run Mistral Test"
  echo "4. Run Llama3 Test"
  echo "5. Run Gemma3 Test"
  echo "6. Exit"
  echo "==============================="
  read -p "Enter your choice: " choice

  case $choice in
    1) install_dependencies ;;
    2) run_application_tests ;;
    3) run_mistral_test ;;
    4) run_llama3_test ;;
    5) run_gemma3_test ;;
    6) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid choice. Please try again." ;;
  esac

  read -p "Press Enter to continue..."
done
