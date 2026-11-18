# Lecture 18supp — NPU Integration in Operating Systems

## Learning and demonstration materials

- [Lecture Plan](docs/C18_01_LECTURE_PLAN.md)
- [Concept Map](docs/C18_02_CONCEPT_MAP.md)
- [Discussion Questions](docs/C18_03_DISCUSSION_QUESTIONS.md)
- [Study Guide](docs/C18_04_STUDY_GUIDE.md)
- [18ex1 - Heterogeneous Computing](docs/18ex1_-_Heterogeneous_Computing.html)
- [18ex2 - CPU GPU NPU Comparator](docs/18ex2_-_CPU_GPU_NPU_Comparator.html)
- [Formative question bank](docs/C18_05_FORMATIVE_ASSESSMENT.yaml)

- [All lecture resources and launch instructions](docs/RUNhere.md)
- [Demonstration script guide](scripts/README.md)
- [Lecture quiz format and runner](../FORMATIVE_QUIZ_FORMAT.md)

## Demonstration script reference

The retained script guide below assumes the **`scripts/` working directory**. From this lecture directory, run `cd scripts` first. Native experiments and interactive HTML models provide different kinds of evidence.

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

## Illustrative output (not a benchmark result from this revision)

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


## Runtime and model prerequisites

The API route is `from openvino import Core` (OpenVINO 2026); the old `openvino.runtime` import is not used. See the [study guide](docs/C18_04_STUDY_GUIDE.md) for explicit model/input requirements. Record the installed runtime, driver, processor SKU, model hash, tensor shape/dtype, warm-up and repeated measurements before interpreting timings. The supplied script may download its example model if it is absent; that network action needs separate authorisation in a controlled lab. No NPU hardware acceptance is claimed by a syntax check.
