# Scripts for Lecture 18supp: NPU Integration in OS

## Contents

### 1. `npu_check.sh`
Bash script for checking NPU presence and status on the system.

**Checks:**
- `/dev/accel/*` devices (Linux 6.2+)
- Intel NPU driver (ivpu)
- AMD XDNA driver
- Intel NPU firmware
- OpenVINO installation
- Relevant kernel messages

**Usage:**
```bash
chmod +x npu_check.sh
./npu_check.sh
```

### 2. `npu_benchmark.py`
Python script for benchmarking inference on different devices.

**Tests:**
- CPU (ONNX Runtime)
- CUDA GPU (if available)
- DirectML (Windows)
- Intel NPU (via OpenVINO)
- Other OpenVINO devices

**Requirements:**
```bash
pip install openvino onnxruntime numpy
# For GPU: pip install onnxruntime-gpu
```

**Usage:**
```bash
python3 npu_benchmark.py
```

## Exemplu Output

```
╔═══════════════════════════════════════════════════════════════════╗
║            NPU vs CPU vs GPU Inference Benchmark                  ║
╚═══════════════════════════════════════════════════════════════════╝

================================================================================
Provider                  Mean (ms)    P50 (ms)     P99 (ms)     Std       
================================================================================
CPUExecutionProvider      45.23        44.89        52.34        3.21      
OpenVINO-CPU              38.45        37.92        45.67        2.89      
OpenVINO-NPU              8.34         8.12         9.45         0.67      
================================================================================

🏆 Fastest: OpenVINO-NPU (8.34 ms)
```
