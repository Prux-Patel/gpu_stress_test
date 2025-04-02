# gpu_stress_test
Fully automated and scalable test script to benchmark various GPU configurations consistently.
1. Introduction
This document defines a structured test plan to analyse GPU utilization and Large Language Model (LLM) performance across the Cudo Compute infrastructure. The goal is to develop a fully automated and scalable test suite to benchmark various GPU configurations consistently.

2. Prerequisites
2.1 Hardware Requirements
Ensure access to the following hardware configurations before running the test suite:
Component
Specification
Compute
Cudo Compute instances
CPU
16 vCPUs or higher
Memory
Minimum 64 GB
Storage
Minimum 1 TB SSD
Network
10 Gbps or higher
GPU
At least one NVIDIA GPU
2.2 Software Requirements
The test environment should have the following software stack installed:
    • Operating System: Ubuntu 22.04 
    • GPU Drivers: NVIDIA v550+ 
    • Development & Runtime Frameworks: 
        ◦ Docker 
        ◦ PyTorch 
        ◦ Ollama (for LLM testing) 
        ◦ Python 3.9+ 
        ◦ CUDA Toolkit 12.1 
2.3 Access & Permissions
    • Cudo Compute Account with administrative privileges 
    • SSH Access to instances 
    • Pre-configured SSH keys for authentication (optional)
    • Sufficient quota for GPU-enabled instances 

3. Objectives
The primary objectives of this test plan are to:
    • Evaluate GPU performance across different hardware configurations on the Cudo Compute platform. 
    • Ensure test consistency across all environments. 
    • Execute benchmarking tests and systematically collect results. 
    • Present findings in a clear and understandable format for decision-making. 

4. Test Environment
The Cudo Compute environment will be configured as follows:
4.1 Hardware Configuration
Component
Specification
CPU
12 vCPUs
Memory
48 GB
Storage
500 GB SSD
Network
10 Gbps
GPU
NVIDIA (various models)
4.2 Software Stack
    • Operating System: Ubuntu 22.04 
    • NVIDIA Drivers: v550+ 
    • Development & Runtime Frameworks: 
        ◦ Docker 
        ◦ PyTorch 
        ◦ Ollama (for LLM testing) 
        ◦ Python 3.9+ 
        ◦ CUDA Toolkit 12.1 
        ◦ yq - a command-line YAML parser) to read the values.

5. Test Methodology
The testing framework will focus on GPU benchmarking and LLM performance evaluation using a combination of industry-standard tools and custom scripts.
5.1 Benchmarking Framework
    • Utilize PyTorch scripts to measure: 
        ◦ Inference time 
        ◦ Memory usage 
        ◦ Throughput 
    • Implement automated test execution to ensure consistency. 
5.2 LLM Performance Testing
    • Deploy and test LLM model
                • llama3 
        ◦ 2 parallel inferences 
5.3 GPU Utilization Metrics
    • Collect key performance indicators using: 
        ◦ nvidia-smi for real-time monitoring 
        ◦ Logging tools for post-execution analysis 
5.4 Script – What is it actually doing? / Expected outcomes
    • What is it actually doing? 
This Bash script performs a GPU stress test by running Ollama's gemma3 model in cycles of 2-minute inference runs for a total of 10 minutes. It monitors GPU performance, logging memory usage, utilization, and temperature at regular intervals. The script dynamically detects the GPU model and ensures safe execution by limiting parallel inference processes and GPU memory allocation to prevent crashes. The test results, including inference counts and system metrics, are logged to a file for analysis. This helps evaluate GPU performance under sustained AI workload conditions.
    • Expected Outcomes 
When running the test, the expected outcomes include:
	Sustained GPU Load
        ◦ The GPU utilization should increase and remain consistently high (e.g., 70-100%).
        ◦ If utilization fluctuates significantly, the test may not be stressing the GPU effectively.
	Stable GPU Memory Usage
        ◦ The script logs GPU memory usage at intervals (e.g., 6000MB+ depending on the model size).
        ◦ If memory usage grows uncontrollably, it may indicate a memory leak.
	Gradual Increase in Temperature
        ◦ GPU temperature should rise but stay within safe limits (e.g., 45-80°C).
        ◦ If the GPU overheats (above 90°C), it may throttle performance or shut down.
	Successful Inferences Without Errors
        ◦ The script should execute Ollama inferences continuously without crashing.
        ◦ Errors like "GGML_ASSERT failed" or out of memory issues indicate instability.
	Consistent Inference Count Growth
        ◦ The total number of inferences should increase over time.
        ◦ Lower inference count than expected suggests bottlenecks (e.g., VRAM exhaustion, CPU limits).
	Completion Without System Instability
        ◦ If the system freezes, crashes, or restarts, it suggests excessive GPU stress.
        ◦ Lowering NUM_PARALLEL inferences may be needed to avoid overload.
	Log File with Detailed Metrics
        ◦ The test generates a log file (gpu_stress_benchmark.txt) containing timestamps, GPU stats, and inference counts.
        ◦ This data can be used for performance analysis and hardware diagnostics.
5.5 Why the Test Runs for 10 Minutes with 2-Minute Intervals
    • The 10-minute test duration with 2-minute cycles provides an optimal balance of stress testing, monitoring, and stability, ensuring that the GPU is tested thoroughly but safely under real AI workloads.
    • Restarting inference every 2 minutes ensures the system can free up memory and remain stable
    • If the GPU starts overheating or memory usage spikes, we can detect it early and adjust parameters accordingly.
    • Instead of running a single long inference session, the script restarts inference jobs every 2 minutes.

6. Test Execution
The following steps will be carried out to execute the test suite:
    1. Set up a GPU-enabled instance on the Cudo Compute platform. 
    2. Install required software and drivers (NVIDIA drivers, CUDA, etc.). 
    3. Execute automated benchmark scripts to measure GPU performance. 
    4. Collect and store performance data for analysis. 
    5. Generate comprehensive reports summarizing test outcomes. 

7. Test Cases
Each test case is designed to measure a specific aspect of GPU and LLM performance.
Test Case ID
Description
Expected Outcome
TC-001
Run a simple LLM inference task
The GPU should execute inference within expected latency.
TC-002
Measure GPU memory usage during inference
Memory consumption should be logged.
TC-003
Compare throughput across different GPUs
Performance variations should be recorded.
TC-004
Conduct a stress test under continuous load
Ensure GPU stability under sustained load.

8. Results and Reporting
8.1 Data Collection & Storage
    • Formats: Raw data will be stored in CSV format and result report.
    • Visualization: Performance metrics will be presented using: 
        ◦ Heat maps 
        ◦ Bar charts 
        ◦ Tables 
8.2 Report Presentation
    • Summary of results highlighting key trends and anomalies. 
    • Comparison of GPU performances across different models. 
    • Recommendations on the most efficient GPU configurations for specific workloads. 
