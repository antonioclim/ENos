# OS_lecture18suppl: NPU Integration in Operating Systems — Heterogeneous Scheduling and Memory Management for AI Inference

> **Advanced Supplementary Module** | Operating Systems  
> by Revolvix | ASE Bucharest - CSIE | Year I, Semester 2 | 2025-2026

---

## Table of Contents

1. [Objectives and Competencies](#1-objectives-and-competencies)
2. [Motivation: Why NPU in 2025-2026?](#2-motivation-why-npu-in-2025-2026)
3. [Heterogeneous Systems Architecture CPU+GPU+NPU](#3-heterogeneous-systems-architecture-cpugpunpu)
4. [Heterogeneous Scheduling: From Big.LITTLE to Thread Director](#4-heterogeneous-scheduling-from-biglittle-to-thread-director)
5. [Memory Management for AI Inference](#5-memory-management-for-ai-inference)
6. [Architectural Comparison: Apple vs Intel vs AMD vs Qualcomm](#6-architectural-comparison-apple-vs-intel-vs-amd-vs-qualcomm)
7. [Operating System Level Integration](#7-operating-system-level-integration)
8. [NPU Driver Model](#8-npu-driver-model)
9. [Isolation and Security for AI Workloads](#9-isolation-and-security-for-ai-workloads)
10. [Practical Demonstrations](#10-practical-demonstrations)
11. [Architectural Trade-offs](#11-architectural-trade-offs)
12. [Exercises and Challenges](#12-exercises-and-challenges)
13. [References and Further Reading](#13-references-and-further-reading)

---

## 1. Objectives and Competencies

### 1.1. Learning Objectives

Upon completion of this module, the student will be able to:

1. **Explain the architecture of heterogeneous systems** with CPU, GPU and NPU, identifying the role of each component and how they cooperate

2. **Analyse heterogeneous scheduling mechanisms** implemented in modern processors (Intel Thread Director, Apple AMX scheduling, AMD XDNA)

3. **Compare memory management strategies** for AI inference: unified memory vs discrete memory, DMA for NPU, zero-copy buffers

4. **Evaluate architectural trade-offs** between different approaches (Apple, Intel, AMD, Qualcomm) from the perspective of performance, energy efficiency and programmability

5. **Understand the driver model** for NPU in Linux (accel subsystem) and Windows (MCDM - Microsoft Compute Driver Model)

6. **Identify implications for isolation and security** when AI workloads access shared resources

### 1.2. Transversal Competencies

- **Systems thinking**: understanding complex interactions between CPU, GPU, NPU and memory
- **Comparative analysis**: critical evaluation of different architectural approaches
- **Evolutionary perspective**: understanding how traditional OS concepts adapt to new paradigms

### 1.3. Prerequisites

- Scheduling (Lecture 4) — scheduling algorithms, preemption, priorities
- Memory Management (Lectures 9-10) — paging, TLB, DMA
- Drivers and Kernel Modules (Lecture 17) — user space/kernel space interaction

---

## 2. Motivation: Why NPU in 2025-2026?

### 2.1. Context: AI on the Edge

Starting from 2024, **all mainstream processors** include dedicated units for AI inference:

- **Intel Core Ultra** (Meteor Lake, Lunar Lake, Arrow Lake) — NPU based on Movidius technology
- **Apple M-series** (M1-M4) — integrated Neural Engine
- **AMD Ryzen AI** (Phoenix, Hawk Point, Strix Point) — XDNA NPU
- **Qualcomm Snapdragon X** — Hexagon NPU

This convergence is not accidental — it reflects a fundamental shift in application requirements:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              EVOLUTION OF COMPUTATIONAL REQUIREMENTS                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1980-2000: Single-Core CPU                                                 │
│  └── Sequential workloads, frequency scaling                               │
│                                                                             │
│  2000-2010: Multi-Core CPU                                                  │
│  └── Explicit parallelism, threading, SMP                                  │
│                                                                             │
│  2010-2020: CPU + GPU                                                       │
│  └── GPGPU for graphics and intensive compute                              │
│                                                                             │
│  2020-present: CPU + GPU + NPU                                              │
│  └── On-device AI inference, local language models                         │
│      Copilot, Apple Intelligence, Windows Recall                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2. The Problem for Operating Systems

The introduction of NPUs raises fundamental questions for OS design:

1. **Scheduling**: How do we decide what runs on CPU vs GPU vs NPU?
2. **Memory**: How do we manage data transfer between processing units?
3. **Isolation**: How do we prevent one process from accessing another process's AI model?
4. **Drivers**: What driver model is suitable for AI accelerators?
5. **Energy**: How do we optimise consumption when we have 3 types of processors?

### 2.3. Definition of "AI PC" / "Copilot+ PC"

Microsoft has defined **Copilot+ PC** as a system that meets:

- **NPU with ≥40 TOPS** (Tera Operations Per Second)
- **≥16 GB RAM**
- **≥256 GB SSD storage**
- Support for Windows AI Foundry APIs

This hardware definition has direct implications for the OS — Windows 11 24H2 includes features that *require* NPU:

- **Windows Recall** — continuous semantic capture and indexing
- **Live Captions** — real-time transcription
- **Cocreator in Paint** — local image generation
- **Windows Studio Effects** — real-time video processing

---

## 3. Heterogeneous Systems Architecture CPU+GPU+NPU

### 3.1. Physical Topology

Modern systems integrate multiple processing units on the same die or package:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MODERN SoC TOPOLOGY (example: Intel Lunar Lake)          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         COMPUTE TILE                                 │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   P-Core 1   │  │   P-Core 2   │  │   P-Core 3   │  ...         │   │
│  │  │   (Lion)     │  │   (Lion)     │  │   (Lion)     │              │   │
│  │  │  + Thread    │  │  + Thread    │  │  + Thread    │              │   │
│  │  │   Director   │  │   Director   │  │   Director   │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  │                                                                     │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   E-Core 1   │  │   E-Core 2   │  │   E-Core 3   │  ...         │   │
│  │  │ (Skymont LP) │  │ (Skymont LP) │  │ (Skymont LP) │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                              Ring Interconnect                              │
│                                    │                                        │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │   GPU TILE      │    │   NPU TILE      │    │   SOC TILE      │        │
│  │   (Xe2-LPG)     │    │   (NPU 4)       │    │   (I/O, Media)  │        │
│  │   8 Xe cores    │    │   6 NCE units   │    │   USB, PCIe     │        │
│  │   67 TOPS       │    │   48 TOPS       │    │   Display       │        │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘        │
│                                    │                                        │
│                           Memory Controller                                 │
│                                    │                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         LPDDR5X (On-Package)                         │   │
│  │                         32GB @ 8533 MT/s                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2. Characteristics of Each Processing Unit

```
┌───────────────────────────────────────────────────────────────────────────────┐
│           COMPARISON: CPU vs GPU vs NPU                                        │
├──────────────┬──────────────────┬──────────────────┬──────────────────────────┤
│   Aspect     │       CPU        │       GPU        │          NPU             │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Paradigm     │ Sequential       │ SIMT (Single     │ Dataflow /               │
│              │ (pipelining)     │ Instruction,     │ Systolic Array           │
│              │                  │ Multiple Thread) │                          │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Optimised    │ Complex control  │ Massive          │ Matrix multiplication    │
│ for          │ flow,            │ throughput,      │ (GEMM), convolutions     │
│              │ low latency      │ wide SIMD        │                          │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Typical      │ FP64, FP32       │ FP32, FP16,      │ INT8, INT4, FP16         │
│ precision    │                  │ BF16, TF32       │ (quantised)              │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Memory       │ Hierarchical     │ Dedicated VRAM   │ Software-managed         │
│              │ cache (L1/L2/L3) │ or unified       │ scratchpad + DMA         │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Energy       │ ~0.1 TOPS/W      │ ~1 TOPS/W        │ ~5-10 TOPS/W             │
│ efficiency   │                  │                  │                          │
├──────────────┼──────────────────┼──────────────────┼──────────────────────────┤
│ Typical      │ Application      │ ML training,     │ On-device inference,     │
│ use case     │ logic, OS, I/O   │ rendering        │ always-on AI             │
└──────────────┴──────────────────┴──────────────────┴──────────────────────────┘
```

### 3.3. Programming Model

The fundamental difference between CPU, GPU and NPU from a programmer's perspective:

```python
# === CPU: Explicit control, sequential instructions ===
def matmul_cpu(A, B):
    C = np.zeros((A.shape[0], B.shape[1]))
    for i in range(A.shape[0]):
        for j in range(B.shape[1]):
            for k in range(A.shape[1]):
                C[i,j] += A[i,k] * B[k,j]
    return C

# === GPU: SIMT parallelism, kernel launch ===
# (CUDA pseudocode)
@cuda.jit
def matmul_gpu(A, B, C):
    i, j = cuda.grid(2)
    if i < C.shape[0] and j < C.shape[1]:
        tmp = 0.0
        for k in range(A.shape[1]):
            tmp += A[i, k] * B[k, j]
        C[i, j] = tmp

# === NPU: Graph-based, runtime dispatch ===
# (ONNX Runtime / CoreML / OpenVINO)
model = onnxruntime.InferenceSession("model.onnx", 
                                      providers=['NPUExecutionProvider'])
output = model.run(None, {"input": input_tensor})
# The runtime decides how to map operations to NPU
```

**Critical observation**: NPUs are not programmed directly — you specify a *computation graph* (ONNX, CoreML, TensorFlow) and the runtime (OpenVINO, CoreML, DirectML) compiles and optimises for the specific hardware.

---

## 4. Heterogeneous Scheduling: From Big.LITTLE to Thread Director

### 4.1. Evolution of Asymmetric Scheduling

Traditional schedulers assumed identical cores. The introduction of asymmetric architectures forced fundamental changes:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EVOLUTION OF ASYMMETRIC SCHEDULING                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  2011: ARM big.LITTLE                                                       │
│  ├── First commercial asymmetric architecture                              │
│  ├── Scheduler in firmware (IKS - In-Kernel Switcher)                      │
│  └── Migration at cluster level, not per-thread                            │
│                                                                             │
│  2014: ARM GTS (Global Task Scheduling)                                     │
│  ├── All cores visible to OS                                               │
│  ├── Scheduler decides on which core each thread runs                      │
│  └── Linux EAS (Energy Aware Scheduling) — kernel 4.10+                    │
│                                                                             │
│  2021: Intel Alder Lake + Thread Director                                   │
│  ├── Hardware monitors workload characteristics                            │
│  ├── Provides hints to OS through HFI (Hardware Feedback Interface)        │
│  └── Scheduling remains the OS decision, but with precise information      │
│                                                                             │
│  2024: Intel Lunar Lake + Containment Zones                                 │
│  ├── Microsoft collaboration for "containment zones"                       │
│  ├── Lightweight workloads remain on E-cores by default                    │
│  └── 35% power reduction for typical applications                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2. Intel Thread Director in Detail

Thread Director is a hardware unit that continuously monitors thread execution and classifies workloads:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     THREAD DIRECTOR ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    HARDWARE MONITORING                              │   │
│  │                                                                      │   │
│  │   For each active thread, the following is analysed:                │   │
│  │   • Instruction mix (INT, FP, vector, branch)                       │   │
│  │   • Cache miss rate (L1, L2, L3)                                    │   │
│  │   • Memory dependencies (memory-bound vs compute-bound)             │   │
│  │   • Vector unit utilisation (AVX-512, AMX)                          │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    WORKLOAD CLASSIFICATION                          │   │
│  │                                                                      │   │
│  │   Detected classes:                                                 │   │
│  │   • Background/Idle — E-core optimal                                │   │
│  │   • I/O intensive — E-core optimal                                  │   │
│  │   • Integer compute — E-core efficient                              │   │
│  │   • FP/Vector — P-core required                                     │   │
│  │   • AI/Matrix (AMX) — P-core with AMX                               │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                 HARDWARE FEEDBACK INTERFACE (HFI)                    │   │
│  │                                                                      │   │
│  │   Per-core table exposed to OS:                                     │   │
│  │   ┌───────────┬────────────────────┬─────────────────────┐          │   │
│  │   │  Core ID  │  Performance Score │  Efficiency Score   │          │   │
│  │   ├───────────┼────────────────────┼─────────────────────┤          │   │
│  │   │  P-core 0 │        100         │         45          │          │   │
│  │   │  P-core 1 │        100         │         45          │          │   │
│  │   │  E-core 0 │         36         │        100          │          │   │
│  │   │  E-core 1 │         36         │        100          │          │   │
│  │   └───────────┴────────────────────┴─────────────────────┘          │   │
│  │                                                                      │   │
│  │   Scores are updated dynamically (thermal throttling, etc.)         │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    OS SCHEDULER (Windows/Linux)                      │   │
│  │                                                                      │   │
│  │   Uses HFI to decide thread placement:                              │   │
│  │   • High priority + FP-heavy → P-core                               │   │
│  │   • Background tasks → E-core                                       │   │
│  │   • Thermal throttling → migration to E-cores                       │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3. NPU Scheduling — A Different Paradigm

**NPUs are not scheduled directly by the OS scheduler!** This is a fundamental difference from CPU:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                CPU SCHEDULING vs NPU SCHEDULING                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CPU SCHEDULING (traditional)                                               │
│  ────────────────────────────                                               │
│                                                                             │
│   [Thread A] [Thread B] [Thread C]                                         │
│        │          │          │                                              │
│        └──────────┼──────────┘                                              │
│                   ▼                                                         │
│        ┌─────────────────────┐                                              │
│        │   OS Scheduler      │ ◄── Context switch ~1-10μs                  │
│        │   (preemptive)      │                                              │
│        └─────────────────────┘                                              │
│                   │                                                         │
│     ┌─────────────┼─────────────┐                                           │
│     ▼             ▼             ▼                                           │
│  [Core 0]     [Core 1]     [Core 2]                                        │
│                                                                             │
│                                                                             │
│  NPU SCHEDULING (queue-based)                                               │
│  ────────────────────────────                                               │
│                                                                             │
│   [App A]         [App B]         [App C]                                  │
│      │               │               │                                      │
│      │   ┌───────────┼───────────┐   │                                      │
│      │   │           │           │   │                                      │
│      ▼   ▼           ▼           ▼   ▼                                      │
│   ┌─────────────────────────────────────────┐                               │
│   │     User-space Runtime                   │                               │
│   │     (OpenVINO, CoreML, DirectML)         │                               │
│   │     - Graph compilation → NPU instructions│                              │
│   │     - Memory management                  │                               │
│   │     - Queue management                   │                               │
│   └─────────────────────────────────────────┘                               │
│                      │                                                      │
│                      ▼                                                      │
│   ┌─────────────────────────────────────────┐                               │
│   │     Kernel Driver (intel_vpu, amdxdna)  │                               │
│   │     - Submit commands to hardware       │                               │
│   │     - DMA memory allocation             │                               │
│   │     - Isolation between contexts        │                               │
│   └─────────────────────────────────────────┘                               │
│                      │                                                      │
│                      ▼                                                      │
│   ┌─────────────────────────────────────────┐                               │
│   │            NPU Hardware                  │                               │
│   │     - Command queue (FIFO/prioritised)  │                               │
│   │     - Non-preemptive execution          │ ◄── Coarse interruption      │
│   │       (layer completion or checkpoint)  │     or none at all           │
│   └─────────────────────────────────────────┘                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.4. Priority Inversion in Heterogeneous Systems

The classic priority inversion problem takes new forms when NPU is involved:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                PRIORITY INVERSION WITH NPU                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Scenario:                                                                  │
│  • Task L (low priority) — starts NPU inference (duration 100ms)           │
│  • Task M (medium priority) — CPU intensive                                │
│  • Task H (high priority) — needs NPU for urgent inference                 │
│                                                                             │
│  Problem:                                                                   │
│                                                                             │
│  t=0ms    [L] submit job NPU ─────────────────────────────────────►        │
│  t=10ms   [M] preempts L on CPU                                            │
│  t=20ms   [H] needs NPU, but NPU busy with L!                              │
│           │                                                                 │
│           ▼                                                                 │
│           H waits... (inversion!)                                          │
│           Although H > M > L, H cannot run                                 │
│                                                                             │
│  t=100ms  NPU finishes L's job                                             │
│  t=100ms  H can finally use NPU                                            │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  Proposed solutions:                                                       │
│                                                                             │
│  1. Layer-level preemption (checkpoint after GEMM)                         │
│     - Implementation: PREMA scheduler (research)                           │
│     - Overhead: save/restore state (~1-5% of execution time)               │
│                                                                             │
│  2. Priority inheritance for NPU resources                                 │
│     - L inherits H's priority while holding NPU                            │
│     - Limited implementation in current drivers                            │
│                                                                             │
│  3. Time-slicing with small quantum                                        │
│     - Large jobs are fragmented into sub-graphs                            │
│     - Significant NPU context switch overhead                              │
│                                                                             │
│  4. Separate queues per priority                                           │
│     - Intel NPU implementation: multiple contexts with priorities          │
│     - Limit: ~6-16 concurrent contexts                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Memory Management for AI Inference

### 5.1. Memory Challenges for AI

AI workloads have distinct memory characteristics:

| Characteristic | Traditional Workload | AI Inference Workload |
|----------------|---------------------|----------------------|
| Access pattern | Random / mixed sequential | Predictable streaming |
| Working set size | KB - MB | MB - GB (models) |
| Data reuse | Variable | High (weights reused) |
| Latency critical | Variable | Yes (real-time) |
| Bandwidth required | Moderate | Very high |

### 5.2. Unified Memory vs Discrete Memory

```
┌─────────────────────────────────────────────────────────────────────────────┐
│             UNIFIED MEMORY vs DISCRETE MEMORY                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  UNIFIED MEMORY (Apple M-series, Qualcomm, Intel on-package LPDDR)         │
│  ══════════════════════════════════════════════════════════════            │
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐                                    │
│   │   CPU   │  │   GPU   │  │   NPU   │                                    │
│   └────┬────┘  └────┬────┘  └────┬────┘                                    │
│        │            │            │                                          │
│        └────────────┼────────────┘                                          │
│                     │                                                       │
│              Memory Controller                                              │
│                     │                                                       │
│        ┌────────────┴────────────┐                                          │
│        │     UNIFIED DRAM        │  ← Same physical pool                   │
│        │  (LPDDR5X, 128GB max)   │                                          │
│        └─────────────────────────┘                                          │
│                                                                             │
│   Advantages:                                                              │
│   ✓ Zero-copy: CPU prepares tensor, NPU reads it directly                  │
│   ✓ Low latency: no PCIe transfer                                          │
│   ✓ Energy efficiency: single controller                                   │
│   ✓ Simplified programming: pointers valid everywhere                      │
│                                                                             │
│   Disadvantages:                                                           │
│   ✗ Limited bandwidth (max ~500 GB/s LPDDR5X)                              │
│   ✗ Capacity limited by package size                                       │
│   ✗ Contention between CPU/GPU/NPU                                         │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  DISCRETE MEMORY (NVIDIA datacenter, AMD dGPU)                             │
│  ═══════════════════════════════════════════                               │
│                                                                             │
│   ┌─────────┐                    ┌─────────────────────┐                   │
│   │   CPU   │                    │       GPU           │                   │
│   └────┬────┘                    │  ┌──────────────┐   │                   │
│        │                         │  │   HBM/GDDR   │   │                   │
│   ┌────┴────┐                    │  │   (VRAM)     │   │                   │
│   │ System  │◄═══ PCIe 5.0 ═════►│  │   96GB HBM3  │   │                   │
│   │  DRAM   │     64 GB/s        │  │   ~3 TB/s    │   │                   │
│   └─────────┘                    │  └──────────────┘   │                   │
│                                  └─────────────────────┘                   │
│                                                                             │
│   Advantages:                                                              │
│   ✓ Very high bandwidth (HBM3: 3+ TB/s)                                    │
│   ✓ Large, scalable capacity                                               │
│   ✓ Natural isolation                                                      │
│                                                                             │
│   Disadvantages:                                                           │
│   ✗ Explicit CPU↔GPU transfer required                                     │
│   ✗ PCIe latency ~1-2μs                                                    │
│   ✗ Higher power consumption                                               │
│   ✗ Complex programming (explicit memory management)                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3. Zero-Copy and DMA for NPU

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ZERO-COPY BUFFER FLOW                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WITHOUT Zero-Copy (high overhead):                                        │
│  ═══════════════════════════════════                                        │
│                                                                             │
│  [User Buffer]  ──copy──►  [Kernel Buffer]  ──DMA──►  [NPU Scratchpad]    │
│       ↑                          ↑                           ↑             │
│   malloc()              kmalloc(GFP_DMA)               Internal SRAM       │
│   user space              kernel space                  hardware           │
│                                                                             │
│  Overhead: 2 copies + syscall overhead                                     │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  WITH Zero-Copy (optimal):                                                 │
│  ═══════════════════════                                                    │
│                                                                             │
│  [User Buffer]  ────────── direct DMA ──────────►  [NPU Scratchpad]       │
│       ↑                                                    ↑               │
│   mmap() on                                         Internal SRAM          │
│   contiguous                                        hardware               │
│   physical memory                                                          │
│                                                                             │
│  Implementation (Linux):                                                   │
│  ┌────────────────────────────────────────────────────────────────────┐   │
│  │  // DMA-capable buffer allocation                                   │   │
│  │  dma_addr_t dma_handle;                                             │   │
│  │  void *buf = dma_alloc_coherent(dev, size, &dma_handle, GFP_KERNEL);│   │
│  │                                                                      │   │
│  │  // Map to user space for zero-copy                                 │   │
│  │  vm_area->vm_page_prot = pgprot_noncached(vm_area->vm_page_prot);   │   │
│  │  remap_pfn_range(vm_area, vaddr, PFN(dma_handle), size, prot);      │   │
│  │                                                                      │   │
│  │  // User space writes directly → NPU reads via DMA                  │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.4. Scratchpad Memory vs Hierarchical Cache

NPUs predominantly use **scratchpad memory** (SPM) instead of traditional cache:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              CACHE vs SCRATCHPAD MEMORY                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CACHE (traditional CPU/GPU)                                               │
│  ═══════════════════════════                                                │
│                                                                             │
│   • Hardware-managed: CPU decides what stays in cache                      │
│   • Transparent to programmer                                              │
│   • Replacement policy: LRU, pseudo-LRU                                    │
│   • Good for unpredictable patterns                                        │
│                                                                             │
│   Problem for AI: unwanted eviction of weights during inference            │
│                                                                             │
│  ──────────────────────────────────────────────────────────────────────    │
│                                                                             │
│  SCRATCHPAD (NPU, DSP)                                                     │
│  ═════════════════════                                                      │
│                                                                             │
│   • Software-managed: programmer controls what data is present             │
│   • Explicit DMA: load_tile(addr, size, scratchpad_offset)                │
│   • No "miss" — programming error if data is not there                     │
│   • Perfect predictability for scheduling                                  │
│                                                                             │
│   AMD XDNA example:                                                        │
│   ┌────────────────────────────────────────────────────────────────────┐  │
│   │                                                                    │  │
│   │    AI Engine Tile                                                  │  │
│   │    ┌──────────────────┐                                            │  │
│   │    │  Vector Unit     │                                            │  │
│   │    │  128 MACs/cycle  │                                            │  │
│   │    └────────┬─────────┘                                            │  │
│   │             │                                                      │  │
│   │    ┌────────┴─────────┐                                            │  │
│   │    │  Local Memory    │ ◄── 64KB scratchpad per tile              │  │
│   │    │  (Scratchpad)    │                                            │  │
│   │    └────────┬─────────┘                                            │  │
│   │             │ DMA                                                  │  │
│   │    ┌────────┴─────────┐                                            │  │
│   │    │  Memory Tile     │ ◄── 512KB shared L2                       │  │
│   │    └────────┬─────────┘                                            │  │
│   │             │                                                      │  │
│   │    ┌────────┴─────────┐                                            │  │
│   │    │   System DRAM    │ ◄── LPDDR5X                               │  │
│   │    └──────────────────┘                                            │  │
│   │                                                                    │  │
│   └────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.5. PagedAttention: Virtual Memory for KV-Cache

A recent innovation applies virtual memory concepts to LLM memory management:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PagedAttention (vLLM)                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Problem: KV-Cache for LLM grows with context length                       │
│  ═════════════════════════════════════════════════════════════              │
│                                                                             │
│  7B model, 4K token context:                                               │
│  KV-Cache = 32 layers × 32 heads × 4096 tokens × 128 dims × 2 (K+V)       │
│           ≈ 4GB per request!                                               │
│                                                                             │
│  Traditional allocation: pre-allocate for max_tokens → 60-80% memory       │
│  wasted when requests have variable lengths                                │
│                                                                             │
│  PagedAttention solution (analogy with OS paging):                         │
│  ════════════════════════════════════════════════                           │
│                                                                             │
│   OS Paging              │    PagedAttention                               │
│   ──────────────────────────────────────────────────                       │
│   Page = 4KB             │    Block = 16 tokens                            │
│   Page Table             │    Block Table                                  │
│   Virtual Address        │    Logical Block Index                          │
│   Physical Frame         │    Physical GPU Memory Block                    │
│   Demand Paging          │    Allocate on Generate                         │
│   COW (fork)             │    Shared KV for Beam Search                    │
│                                                                             │
│   ┌──────────────────────────────────────────────────────────────────┐    │
│   │                                                                  │    │
│   │   Request 1 Block Table:     Physical Memory:                    │    │
│   │   ┌───┬───┬───┬───┐         ┌─────────────────────────┐         │    │
│   │   │ 0 │ 1 │ 2 │ 3 │         │ Block 7 │ [Request 1]   │         │    │
│   │   └─┬─┴─┬─┴─┬─┴─┬─┘         │ Block 2 │ [Request 2]   │         │    │
│   │     │   │   │   │           │ Block 9 │ [Request 1]   │         │    │
│   │     │   │   │   └──────────►│ Block 4 │ [FREE]        │         │    │
│   │     │   │   └──────────────►│ Block 1 │ [Request 1]   │         │    │
│   │     │   └──────────────────►│ Block 6 │ [Request 2]   │         │    │
│   │     └──────────────────────►│ Block 3 │ [Request 1]   │         │    │
│   │                             └─────────────────────────┘         │    │
│   │                                                                  │    │
│   │   Result: wasted memory < 4% (vs 60-80% traditional)            │    │
│   │   Throughput: 2-4x higher for LLM serving                       │    │
│   │                                                                  │    │
│   └──────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Architectural Comparison: Apple vs Intel vs AMD vs Qualcomm

### 6.1. Detailed Comparison Table

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                    NPU COMPARISON: APPLE vs INTEL vs AMD vs QUALCOMM              │
├─────────────┬──────────────┬──────────────┬──────────────┬────────────────────────┤
│   Aspect    │  Apple M4    │ Intel Lunar  │ AMD Strix    │ Qualcomm Snapdragon   │
│             │  Neural Eng  │  Lake NPU    │  Point XDNA  │  X Elite Hexagon      │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ TOPS        │ 38           │ 48           │ 50           │ 45                     │
│ (INT8)      │              │              │              │                        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Architecture│ 16 Neural    │ 2×Movidius   │ 4×8 AI      │ 4-wide VLIW +          │
│             │ Engine cores │ cores + 6    │ Engine tile │ 6-way SMT +            │
│             │              │ NCE units    │ array       │ Tensor coprocessor     │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Memory      │ Unified      │ Unified      │ Unified     │ Unified LPDDR5X        │
│             │ (up to       │ LPDDR5X      │ LPDDR5X     │ (up to 64GB)           │
│             │ 128GB)       │ (32GB max)   │             │                        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Precision   │ FP16, INT8   │ FP16, INT8   │ BF16, INT8, │ FP16, INT8, INT4       │
│             │              │              │ INT4        │ INT2 (experimental)    │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ API/        │ CoreML       │ OpenVINO,    │ ROCm,       │ Qualcomm AI Engine     │
│ Framework   │ (exclusive)  │ DirectML     │ DirectML    │ (QNN), DirectML        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ OS Support  │ macOS only   │ Windows,     │ Windows,    │ Windows on ARM         │
│             │              │ Linux        │ Linux       │ (native required)      │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Programming │ Walled       │ Semi-open    │ Open        │ Semi-open              │
│             │ garden       │ (OpenVINO)   │ (ROCm/XRT)  │ (SDK required)         │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Concurrency │ Undocumented │ ~6 contexts  │ 6-16        │ Multiple queues        │
│             │              │              │ contexts    │                        │
├─────────────┼──────────────┼──────────────┼──────────────┼────────────────────────┤
│ Efficiency  │ ~2.5         │ ~2.8         │ ~1.9        │ ~1.9-2.0               │
│ (TOPS/W)    │              │              │             │                        │
└─────────────┴──────────────┴──────────────┴──────────────┴────────────────────────┘
```

### 6.2. Apple Architecture Analysis

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    APPLE NEURAL ENGINE (M4)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Philosophy: "It just works" — tight integration, complete control         │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │      Developer                                                      │   │
│  │         │                                                           │   │
│  │         ▼                                                           │   │
│  │   ┌──────────────┐                                                  │   │
│  │   │   CoreML     │ ◄── Proprietary model format (.mlmodel)         │   │
│  │   │   Framework  │                                                  │   │
│  │   └──────┬───────┘                                                  │   │
│  │          │                                                           │   │
│  │          ▼                                                           │   │
│  │   ┌──────────────┐                                                  │   │
│  │   │   Compiler   │ ◄── Automatic hardware optimisation              │   │
│  │   │   (private)  │     Graph partitioning, fusion                   │   │
│  │   └──────┬───────┘                                                  │   │
│  │          │                                                           │   │
│  │     ┌────┼────┬────────────┐                                        │   │
│  │     ▼    ▼    ▼            ▼                                        │   │
│  │   [ANE] [GPU] [CPU]    [AMX]                                        │   │
│  │                                                                     │   │
│  │   Runtime automatically decides where each operation runs          │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Advantages:                                                               │
│  ✓ Zero-copy between all units (unified memory)                           │
│  ✓ End-to-end optimisation by Apple                                       │
│  ✓ Excellent energy efficiency                                             │
│  ✓ Simplified developer experience                                         │
│                                                                             │
│  Disadvantages:                                                            │
│  ✗ No direct programmability of Neural Engine                              │
│  ✗ Lock-in to Apple ecosystem                                              │
│  ✗ Unsupported operations → fallback to GPU/CPU                            │
│  ✗ Limited debugging                                                       │
│                                                                             │
│  Apple Intelligence (2024):                                                │
│  • ~3B parameter model, quantised to 2-4 bits                              │
│  • 30 tokens/s on iPhone 15 Pro                                            │
│  • Private Cloud Compute for complex queries                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3. Intel Architecture Analysis

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INTEL NPU (Lunar Lake - NPU 4)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Philosophy: Industry standard, broad compatibility                        │
│                                                                             │
│  Internal architecture:                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │    ┌──────────────────────────────────────────────────────────┐    │   │
│  │    │              Command & Scheduling Unit                   │    │   │
│  │    │    2× Movidius LEON cores (SPARC-based)                  │    │   │
│  │    └──────────────────────────┬───────────────────────────────┘    │   │
│  │                               │                                     │   │
│  │    ┌──────────────────────────┴───────────────────────────────┐    │   │
│  │    │              Neural Compute Engine (NCE)                 │    │   │
│  │    │    • 6 NCE units in Lunar Lake                           │    │   │
│  │    │    • 4096 MAC units per NCE                              │    │   │
│  │    │    • 1.4 GHz max frequency                               │    │   │
│  │    │    • INT8: 2 ops/cycle, FP16: 1 op/cycle                 │    │   │
│  │    └──────────────────────────────────────────────────────────┘    │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Software Stack:                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   [Application]                                                     │   │
│  │        │                                                            │   │
│  │        ▼                                                            │   │
│  │   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐        │   │
│  │   │   OpenVINO    │   │   DirectML    │   │   ONNX RT     │        │   │
│  │   │   (Intel)     │   │   (Microsoft) │   │   (Cross)     │        │   │
│  │   └───────┬───────┘   └───────┬───────┘   └───────┬───────┘        │   │
│  │           │                   │                   │                 │   │
│  │           └───────────────────┼───────────────────┘                 │   │
│  │                               ▼                                     │   │
│  │                    ┌───────────────────┐                            │   │
│  │                    │   Level Zero API  │                            │   │
│  │                    └─────────┬─────────┘                            │   │
│  │                              │                                      │   │
│  │           ┌──────────────────┼──────────────────┐                   │   │
│  │           ▼                  ▼                  ▼                   │   │
│  │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐           │   │
│  │   │ Linux Driver │   │  Windows     │   │  Chrome OS   │           │   │
│  │   │  (intel_vpu) │   │  MCDM Driver │   │   Driver     │           │   │
│  │   └──────────────┘   └──────────────┘   └──────────────┘           │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Linux Driver details:                                                     │
│  • Mainline since kernel 6.2                                               │
│  • Device: /dev/accel/accel0                                               │
│  • Firmware: /lib/firmware/intel/vpu/                                      │
│  • Cache: ~/.cache/ze_intel_npu_cache/                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.4. AMD XDNA Architecture Analysis

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AMD XDNA (Strix Point)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Philosophy: Spatial dataflow — computation as flow through tile array     │
│  Origin: Xilinx AI Engine (2022 acquisition)                               │
│                                                                             │
│  Tile Array Architecture (4×8 = 32 tiles on Strix Point):                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │   │
│  │   │ AIE │ │ AIE │ │ AIE │ │ AIE │ │ MEM │ │ MEM │ │ MEM │ │ MEM │ │   │
│  │   └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘ │   │
│  │      │       │       │       │       │       │       │       │    │   │
│  │   ┌──┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴──┐ │   │
│  │   │              Configurable Switch Network                    │ │   │
│  │   └──┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬──┘ │   │
│  │      │       │       │       │       │       │       │       │    │   │
│  │   ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ ┌──┴──┐ │   │
│  │   │ AIE │ │ AIE │ │ AIE │ │ AIE │ │ MEM │ │ MEM │ │ MEM │ │ MEM │ │   │
│  │   └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ └─────┘ │   │
│  │     ...     ...     ...     ...     ...     ...     ...     ...   │   │
│  │                                                                     │   │
│  │   AIE = AI Engine (VLIW + SIMD vector unit)                        │   │
│  │   MEM = Memory Tile (L2 shared)                                    │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Unique characteristics:                                                   │
│  • Spatial partitioning: array can be divided between workloads           │
│  • Determinism: programmatic DMA, not cache → predictable latency         │
│  • Scalability: design scales with number of tiles                        │
│                                                                             │
│  Linux Driver (amdxdna):                                                   │
│  • Mainline Linux 6.14                                                     │
│  • Spatial partitioning at column granularity                             │
│  • PASID (Process Address Space ID) for hardware isolation                │
│  • XRT (Xilinx Runtime) for management                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.5. Qualcomm Hexagon Architecture Analysis

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    QUALCOMM HEXAGON NPU (Snapdragon X Elite)                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Philosophy: Mobile-first, extreme energy efficiency                       │
│  Heritage: 15+ years of DSP in smartphones                                 │
│                                                                             │
│  Hexagon Architecture:                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  Hexagon Scalar Core                        │  │   │
│  │   │    • 4-wide VLIW (4 instructions/cycle)                    │  │   │
│  │   │    • 6-way SMT (simultaneous multithreading)               │  │   │
│  │   │    • Control flow, gather/scatter                          │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  HVX (Hexagon Vector Extensions)            │  │   │
│  │   │    • 32 × 1024-bit vector registers                        │  │   │
│  │   │    • Predicated execution                                  │  │   │
│  │   │    • Sliding window operations                             │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  Tensor Coprocessor (HTP)                   │  │   │
│  │   │    • 16K MAC ops/cycle                                     │  │   │
│  │   │    • INT8, INT4, INT2 precision                            │  │   │
│  │   │    • Fused depthwise convolutions                          │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                              │                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────┐  │   │
│  │   │                  8MB TCM (Tightly Coupled Memory)           │  │   │
│  │   │    • Software-managed scratchpad                           │  │   │
│  │   │    • DMA scatter-gather                                    │  │   │
│  │   └─────────────────────────────────────────────────────────────┘  │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Remarkable efficiency:                                                    │
│  • AI tasks: 1/28 power vs CPU equivalent                                  │
│  • Battery life: 21-27 hours for laptops                                   │
│                                                                             │
│  Critical limitation for Windows:                                          │
│  • NPU acceleration ONLY for native ARM64 applications                     │
│  • x86 emulation (Prism) CANNOT access NPU                                 │
│  • Implication: requires application recompilation                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Operating System Level Integration

### 7.1. Windows AI Foundry

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WINDOWS AI STACK (2025)                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        Applications                                  │  │
│   │    Paint Cocreator │ Windows Recall │ Live Captions │ Copilot      │  │
│   └───────────────────────────────┬─────────────────────────────────────┘  │
│                                   │                                        │
│   ┌───────────────────────────────┴─────────────────────────────────────┐  │
│   │                    Windows AI Foundry APIs                           │  │
│   │                                                                      │  │
│   │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │  │
│   │   │  Windows ML  │  │    Phi       │  │  Semantic    │             │  │
│   │   │  (ONNX RT)   │  │  Silica SLM  │  │   Index      │             │  │
│   │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │  │
│   │          │                 │                 │                      │  │
│   └──────────┼─────────────────┼─────────────────┼──────────────────────┘  │
│              │                 │                 │                        │
│   ┌──────────┴─────────────────┴─────────────────┴──────────────────────┐  │
│   │                    ONNX Runtime                                      │  │
│   │    Execution Provider auto-discovery                                │  │
│   └───────────────────────────────┬─────────────────────────────────────┘  │
│                                   │                                        │
│              ┌────────────────────┼────────────────────┐                   │
│              ▼                    ▼                    ▼                   │
│   ┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐       │
│   │   QNN EP          │ │   OpenVINO EP     │ │   DirectML EP     │       │
│   │   (Qualcomm)      │ │   (Intel)         │ │   (Generic)       │       │
│   │   ↓               │ │   ↓               │ │   ↓               │       │
│   │   Qualcomm NPU    │ │   Intel NPU       │ │   GPU fallback    │       │
│   └───────────────────┘ └───────────────────┘ └───────────────────┘       │
│                                   │                                        │
│   ┌───────────────────────────────┴─────────────────────────────────────┐  │
│   │                    MCDM (Microsoft Compute Driver Model)             │  │
│   │                                                                      │  │
│   │    • Derived from WDDM (display driver model)                       │  │
│   │    • Memory management for compute devices                          │  │
│   │    • Multi-tasking with inter-context security                      │  │
│   │    • ETW events for performance monitoring                          │  │
│   │    • Task Manager NPU utilisation                                   │  │
│   │                                                                      │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2. Linux Compute Acceleration Subsystem

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LINUX ACCEL SUBSYSTEM                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  History:                                                                  │
│  • Pre-2022: NPU drivers → DRM subsystem (improper)                       │
│  • 2022: Proposal for dedicated accelerator subsystem                      │
│  • Linux 6.2+: /dev/accel/* with major number 261                         │
│                                                                             │
│  Kernel structure:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │   drivers/accel/                                                    │   │
│  │   ├── accel_drv.c          # Core accel framework                  │   │
│  │   ├── ivpu/                # Intel VPU/NPU driver                  │   │
│  │   │   ├── ivpu_drv.c                                               │   │
│  │   │   ├── ivpu_gem.c       # Memory management                     │   │
│  │   │   ├── ivpu_job.c       # Job submission                        │   │
│  │   │   └── ivpu_mmu.c       # IOMMU integration                     │   │
│  │   ├── habanalabs/          # Intel Gaudi (datacenter)              │   │
│  │   └── amdxdna/             # AMD XDNA driver (6.14+)               │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Device nodes:                                                             │
│  • /dev/accel/accel0      (first accelerator)                             │
│  • /dev/accel/accel1      (second, etc.)                                  │
│                                                                             │
│  Differences from DRM GPU:                                                 │
│  • DRIVER_COMPUTE_ACCEL flag (mutually exclusive with DRIVER_RENDER)      │
│  • Does not expose KMS (display) interfaces                                │
│  • Focus on compute workloads                                              │
│                                                                             │
│  User-space stack:                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │   Application (Python ML, C++ inference)                            │   │
│  │        │                                                            │   │
│  │        ▼                                                            │   │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │   │
│  │   │   OpenVINO   │  │   PyTorch    │  │  TensorFlow  │             │   │
│  │   │              │  │   (ONNX)     │  │   Lite       │             │   │
│  │   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │   │
│  │          │                 │                 │                      │   │
│  │          └─────────────────┼─────────────────┘                      │   │
│  │                            ▼                                        │   │
│  │                 ┌───────────────────┐                               │   │
│  │                 │   Level Zero API  │ ◄── Intel oneAPI              │   │
│  │                 └─────────┬─────────┘                               │   │
│  │                           │                                         │   │
│  │                           ▼                                         │   │
│  │                 ┌───────────────────┐                               │   │
│  │                 │  /dev/accel/accel0│                               │   │
│  │                 │  (ioctl interface)│                               │   │
│  │                 └───────────────────┘                               │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. NPU Driver Model

### 8.1. NPU Driver Components

A complete NPU driver must manage:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NPU DRIVER COMPONENTS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. DEVICE INITIALISATION                                                  │
│     • PCI/ACPI enumeration                                                 │
│     • Firmware loading                                                     │
│     • Hardware reset and power-up sequence                                 │
│                                                                             │
│  2. MEMORY MANAGEMENT                                                      │
│     • GEM (Graphics Execution Manager) objects                             │
│     • DMA buffer allocation (contiguous physical memory)                   │
│     • IOMMU/SMMU mapping for isolation                                     │
│     • mmap() for user-space access                                         │
│                                                                             │
│  3. COMMAND SUBMISSION                                                     │
│     • Command buffer parsing and validation                                │
│     • Job queue management                                                 │
│     • Dependency tracking between jobs                                     │
│     • Fence/sync objects for completion notification                       │
│                                                                             │
│  4. CONTEXT MANAGEMENT                                                     │
│     • Per-process context isolation                                        │
│     • PASID (Process Address Space ID) support                            │
│     • Resource limits per context                                          │
│                                                                             │
│  5. POWER MANAGEMENT                                                       │
│     • Runtime PM (suspend/resume)                                          │
│     • DVFS (Dynamic Voltage Frequency Scaling)                            │
│     • Thermal throttling response                                          │
│                                                                             │
│  6. ERROR HANDLING                                                         │
│     • Hardware error detection                                             │
│     • Context recovery                                                     │
│     • Fault reporting to user-space                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2. Example: Intel NPU Driver (ivpu)

```c
/* Simplified from drivers/accel/ivpu/ivpu_drv.c */

static int ivpu_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
    struct ivpu_device *vdev;
    int ret;

    /* 1. Allocate device structure */
    vdev = devm_kzalloc(&pdev->dev, sizeof(*vdev), GFP_KERNEL);
    
    /* 2. Map PCI BARs */
    vdev->regb = pcim_iomap(pdev, 0, 0);  /* Control registers */
    vdev->regv = pcim_iomap(pdev, 2, 0);  /* VPU registers */
    
    /* 3. Configure IOMMU */
    ret = ivpu_mmu_init(vdev);
    
    /* 4. Load firmware */
    ret = ivpu_fw_load(vdev);
    
    /* 5. Initialise job scheduler */
    ret = ivpu_job_init(vdev);
    
    /* 6. Register in accel subsystem */
    ret = drm_dev_register(&vdev->drm, 0);
    /* Creates /dev/accel/accel0 */
    
    return 0;
}

/* Job submission flow */
static int ivpu_job_submit(struct ivpu_context *ctx, 
                           struct ivpu_job *job)
{
    /* Validate commands */
    ret = ivpu_cmdq_validate(job->cmdq);
    
    /* Pin memory buffers */
    ret = ivpu_gem_pin_pages(job->buffers);
    
    /* Map in IOMMU for NPU access */
    ret = ivpu_mmu_map(ctx, job->buffers);
    
    /* Submit to hardware queue */
    ivpu_cmdq_submit(ctx->hw_queue, job);
    
    /* Create fence for completion */
    job->fence = ivpu_fence_create(ctx);
    
    return 0;
}
```

---

## 9. Isolation and Security for AI Workloads

### 9.1. NPU-Specific Attack Vectors

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NPU ATTACK VECTORS                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. MODEL EXTRACTION                                                       │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Attacker: Malicious process on same system                   │     │
│     │  Target: Victim's AI model weights                            │     │
│     │  Method:                                                       │     │
│     │  • Side-channel on shared cache/memory bus                     │     │
│     │  • Timing analysis on shared NPU                               │     │
│     │  • Memory snooping if isolation is weak                        │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. INPUT/OUTPUT INFERENCE                                                 │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Attacker: Another process                                     │     │
│     │  Target: Inference input/output data                          │     │
│     │  Method:                                                       │     │
│     │  • DMA buffer snooping                                         │     │
│     │  • Memory remanence after deallocation                         │     │
│     │  • Shared memory timing                                        │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  3. DENIAL OF SERVICE                                                      │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Attacker: Process with NPU access                             │     │
│     │  Target: NPU availability for other users                     │     │
│     │  Method:                                                       │     │
│     │  • Permanent NPU occupation with large jobs                    │     │
│     │  • Memory exhaustion for DMA buffers                           │     │
│     │  • Firmware crash through malformed input                      │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  4. PRIVILEGE ESCALATION                                                   │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │  Attacker: User with limited access                            │     │
│     │  Target: Kernel or other process access                       │     │
│     │  Method:                                                       │     │
│     │  • NPU firmware bug → arbitrary code execution                 │     │
│     │  • IOMMU bypass                                                │     │
│     │  • Driver vulnerability (ioctl parsing)                        │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2. Protection Mechanisms

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NPU ISOLATION MECHANISMS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. IOMMU (Input-Output Memory Management Unit)                            │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │   Process A          Process B          NPU                    │     │
│     │   VA space           VA space           DMA                    │     │
│     │      │                  │                 │                    │     │
│     │      ▼                  ▼                 ▼                    │     │
│     │   ┌──────┐          ┌──────┐         ┌──────┐                 │     │
│     │   │ PT A │          │ PT B │         │IOMMU │                 │     │
│     │   │(CPU) │          │(CPU) │         │  PT  │                 │     │
│     │   └──┬───┘          └──┬───┘         └──┬───┘                 │     │
│     │      │                 │                │                     │     │
│     │      └─────────────────┼────────────────┘                     │     │
│     │                        ▼                                      │     │
│     │              ┌─────────────────┐                              │     │
│     │              │  Physical RAM   │                              │     │
│     │              │                 │                              │     │
│     │              │ ┌─────┐ ┌─────┐ │                              │     │
│     │              │ │ A's │ │ B's │ │                              │     │
│     │              │ │data │ │data │ │                              │     │
│     │              │ └─────┘ └─────┘ │                              │     │
│     │              └─────────────────┘                              │     │
│     │                                                                │     │
│     │   NPU can ONLY access pages mapped in IOMMU PT               │     │
│     │   for current context                                         │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. PASID (Process Address Space ID) — AMD XDNA                            │
│     • Each process receives a unique ID                                    │
│     • NPU hardware checks PASID on every access                            │
│     • Isolation without full context switch                                │
│                                                                             │
│  3. SPATIAL PARTITIONING — AMD XDNA                                        │
│     • Tile array can be physically partitioned                            │
│     • Process A: columns 0-3, Process B: columns 4-7                      │
│     • Complete hardware isolation                                          │
│                                                                             │
│  4. MEMORY ZEROING                                                         │
│     • DMA buffers are cleared (zeroed) on deallocation                    │
│     • Prevents memory remanence attacks                                    │
│     • Performance overhead (acceptable for security)                       │
│                                                                             │
│  5. FIRMWARE VERIFICATION                                                  │
│     • Secure boot for NPU firmware                                         │
│     • Signature verification before load                                   │
│     • Rollback protection                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 10. Practical Demonstrations

### 10.1. NPU Verification on Linux

```bash
#!/bin/bash
# npu_check.sh - NPU presence and status verification

echo "=== NPU Detection Script ==="
echo ""

# 1. Check accel devices
echo "[1] Accel devices:"
if ls /dev/accel/accel* 2>/dev/null; then
    ls -la /dev/accel/
else
    echo "    No /dev/accel/* present - NPU driver not loaded or absent"
fi
echo ""

# 2. Check Intel NPU
echo "[2] Intel NPU (ivpu):"
if lsmod | grep -q ivpu; then
    echo "    ✓ ivpu driver loaded"
    lspci | grep -i "VPU\|NPU" || echo "    (device not in lspci output)"
else
    echo "    ✗ ivpu driver not loaded"
    # Try loading
    # sudo modprobe intel_vpu
fi
echo ""

# 3. Check AMD XDNA
echo "[3] AMD XDNA (amdxdna):"
if lsmod | grep -q amdxdna; then
    echo "    ✓ amdxdna driver loaded"
else
    echo "    ✗ amdxdna driver not loaded"
fi
echo ""

# 4. OpenVINO device query
echo "[4] OpenVINO devices (if installed):"
if command -v benchmark_app &> /dev/null; then
    benchmark_app -d AVAILABLE | head -20
else
    echo "    OpenVINO not installed"
    echo "    Install: pip install openvino"
fi
echo ""

# 5. Firmware check
echo "[5] NPU Firmware:"
if ls /lib/firmware/intel/vpu/*.bin 2>/dev/null; then
    echo "    Intel VPU firmware present:"
    ls /lib/firmware/intel/vpu/*.bin
else
    echo "    Intel VPU firmware not found"
fi
```

### 10.2. NPU vs CPU vs GPU Benchmark

```python
#!/usr/bin/env python3
"""
npu_benchmark.py - NPU vs CPU vs GPU inference comparison
Requires: pip install openvino onnxruntime torch torchvision
"""

import time
import numpy as np

def benchmark_inference(provider_name, session, input_data, iterations=100):
    """Benchmark inference latency"""
    # Warmup
    for _ in range(10):
        session.run(None, input_data)
    
    # Measure
    latencies = []
    for _ in range(iterations):
        start = time.perf_counter()
        session.run(None, input_data)
        latencies.append((time.perf_counter() - start) * 1000)  # ms
    
    return {
        'provider': provider_name,
        'mean_ms': np.mean(latencies),
        'std_ms': np.std(latencies),
        'p50_ms': np.percentile(latencies, 50),
        'p99_ms': np.percentile(latencies, 99),
    }

def main():
    import onnxruntime as ort
    
    print("=== NPU vs CPU vs GPU Benchmark ===\n")
    
    # Download test model (MobileNetV2)
    model_path = "mobilenetv2-7.onnx"
    
    # Check available providers
    print("Available Execution Providers:")
    for ep in ort.get_available_providers():
        print(f"  - {ep}")
    print()
    
    # Test input
    input_data = {"input": np.random.randn(1, 3, 224, 224).astype(np.float32)}
    
    results = []
    
    # CPU Benchmark
    print("Testing CPU...")
    sess_cpu = ort.InferenceSession(model_path, providers=['CPUExecutionProvider'])
    results.append(benchmark_inference("CPU", sess_cpu, input_data))
    
    # GPU Benchmark (CUDA if available)
    if 'CUDAExecutionProvider' in ort.get_available_providers():
        print("Testing GPU (CUDA)...")
        sess_gpu = ort.InferenceSession(model_path, providers=['CUDAExecutionProvider'])
        results.append(benchmark_inference("GPU (CUDA)", sess_gpu, input_data))
    
    # NPU Benchmark (OpenVINO)
    if 'OpenVINOExecutionProvider' in ort.get_available_providers():
        print("Testing NPU (OpenVINO)...")
        sess_npu = ort.InferenceSession(model_path, 
            providers=['OpenVINOExecutionProvider'],
            provider_options=[{'device_type': 'NPU'}])
        results.append(benchmark_inference("NPU (OpenVINO)", sess_npu, input_data))
    
    # DirectML (Windows)
    if 'DmlExecutionProvider' in ort.get_available_providers():
        print("Testing DirectML...")
        sess_dml = ort.InferenceSession(model_path, providers=['DmlExecutionProvider'])
        results.append(benchmark_inference("DirectML", sess_dml, input_data))
    
    # Display results
    print("\n" + "=" * 60)
    print(f"{'Provider':<20} {'Mean (ms)':<12} {'P50 (ms)':<12} {'P99 (ms)':<12}")
    print("=" * 60)
    for r in results:
        print(f"{r['provider']:<20} {r['mean_ms']:<12.2f} {r['p50_ms']:<12.2f} {r['p99_ms']:<12.2f}")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### 10.3. NPU Utilisation Monitoring

```bash
#!/bin/bash
# npu_monitor.sh - Real-time NPU monitoring (Intel)

# Check for intel_gpu_top presence (from intel-gpu-tools)
if ! command -v intel_gpu_top &> /dev/null; then
    echo "Install: sudo apt install intel-gpu-tools"
    exit 1
fi

# For NPU, use sysfs (if exposed by driver)
NPU_SYSFS="/sys/class/accel/accel0"

if [ -d "$NPU_SYSFS" ]; then
    echo "=== NPU Status ==="
    
    while true; do
        clear
        echo "$(date)"
        echo ""
        
        # Device info
        if [ -f "$NPU_SYSFS/device/power/runtime_status" ]; then
            echo "Power state: $(cat $NPU_SYSFS/device/power/runtime_status)"
        fi
        
        # Memory usage (if available)
        if [ -f "$NPU_SYSFS/device/mem_info" ]; then
            echo "Memory: $(cat $NPU_SYSFS/device/mem_info)"
        fi
        
        # Jobs in flight
        if [ -f "$NPU_SYSFS/device/job_count" ]; then
            echo "Active jobs: $(cat $NPU_SYSFS/device/job_count)"
        fi
        
        echo ""
        echo "Press Ctrl+C to exit"
        sleep 1
    done
else
    echo "NPU sysfs not available at $NPU_SYSFS"
    echo "Trying dmesg for NPU activity..."
    dmesg | grep -i "ivpu\|vpu\|npu" | tail -20
fi
```

---

## 11. Architectural Trade-offs

### 11.1. Trade-offs Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FUNDAMENTAL TRADE-OFFS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. PERFORMANCE vs ENERGY EFFICIENCY                                       │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Maximum performance (datacenter):                            │     │
│     │  • NPU at maximum frequency, unlimited TDP                    │     │
│     │  • Low TOPS/W (~1-2)                                          │     │
│     │                                                                │     │
│     │  Maximum efficiency (mobile/laptop):                          │     │
│     │  • Aggressive DVFS, power gating                              │     │
│     │  • High TOPS/W (~5-10)                                        │     │
│     │  • Higher latency (wake-up delay)                             │     │
│     │                                                                │     │
│     │  Apple M-series: optimised for laptop, good compromise        │     │
│     │  Intel Lunar Lake: containment zones for efficiency           │     │
│     │  Qualcomm: most efficient, but ARM-only                       │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. PROGRAMMABILITY vs PERFORMANCE                                         │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Maximum programmability (GPU):                               │     │
│     │  • CUDA/OpenCL allows any algorithm                           │     │
│     │  • Overhead: scheduling, memory management                    │     │
│     │                                                                │     │
│     │  Maximum performance (fixed-function NPU):                    │     │
│     │  • Hardware optimised for GEMM, convolutions                  │     │
│     │  • Limited: only supported operations                         │     │
│     │  • Fallback to GPU/CPU for rest                               │     │
│     │                                                                │     │
│     │  AMD XDNA: balance (programmable spatial dataflow)            │     │
│     │  Apple ANE: most restrictive, but most optimised              │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  3. UNIFIED MEMORY vs DISCRETE MEMORY                                      │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Unified (Apple, Qualcomm):                                   │     │
│     │  ✓ Zero-copy, simple programming                              │     │
│     │  ✓ Energy efficiency                                          │     │
│     │  ✗ Limited bandwidth (~500 GB/s LPDDR5X)                      │     │
│     │  ✗ Limited capacity                                           │     │
│     │                                                                │     │
│     │  Discrete (NVIDIA datacenter):                                │     │
│     │  ✓ Enormous bandwidth (HBM: 3+ TB/s)                          │     │
│     │  ✓ Scalable capacity                                          │     │
│     │  ✗ Transfer overhead                                          │     │
│     │  ✗ Complex programming                                        │     │
│     │                                                                │     │
│     │  Intel Lunar Lake: on-package LPDDR (compromise)              │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  4. LATENCY vs THROUGHPUT                                                  │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │                                                                │     │
│     │  Minimum latency (real-time inference):                       │     │
│     │  • NPU always-on, no wake-up delay                            │     │
│     │  • Small models, batch size 1                                 │     │
│     │  • Use case: voice assistant, camera effects                  │     │
│     │                                                                │     │
│     │  Maximum throughput (batch processing):                       │     │
│     │  • Batching multiple requests                                 │     │
│     │  • Amortising kernel launch overhead                          │     │
│     │  • Use case: image processing pipeline, server inference      │     │
│     │                                                                │     │
│     │  Tension: NPU optimised for throughput, but main use case     │     │
│     │  on laptop/phone is latency-sensitive                         │     │
│     │                                                                │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 12. Exercises and Challenges

### 12.1. Comprehension Exercises

**E1. [REMEMBER]** List the 3 main types of processing units in a modern SoC and the primary characteristic of each.

**E2. [UNDERSTAND]** Explain why Thread Director provides *hints* to the OS instead of scheduling directly. What are the advantages of this approach?

**E3. [UNDERSTAND]** Compare the "unified" memory model (Apple) with "discrete" (NVIDIA datacenter). For what types of workloads is each more suitable?

**E4. [ANALYSE]** A high-priority process needs to execute inference on NPU, but a low-priority process has already started a large job. Analyse the problem and propose 2 possible solutions.

### 12.2. Practical Exercises

**P1. [LAB]** Using the `npu_check.sh` script, verify if your system has an NPU and what driver is loaded. Document the output.

**P2. [LAB]** Modify the `npu_benchmark.py` script to test a different model (for example, ResNet-50). Compare the results with MobileNetV2.

**P3. [PROJECT]** Implement a script that monitors NPU utilisation in real-time and generates a graph (using matplotlib) with inference latency over 1 minute.

### 12.3. Reflection Questions

**R1.** Why do you think Apple chose not to expose Neural Engine for direct programming, whilst Intel and AMD allow access through standard APIs?

**R2.** How should the Linux scheduler evolve to optimally manage workloads on CPU+GPU+NPU? What information should the scheduler have?

**R3.** What are the security implications of running AI models locally on the user's device vs in the cloud?

---

## Self-Assessment

### Verification Questions

1. **[REMEMBER]** What is an NPU and how does it differ from a CPU and GPU? What are the units of measurement for NPU performance?

2. **[UNDERSTAND]** Explain the Intel Thread Director mechanism. Why is hardware-software collaboration needed for heterogeneous scheduling?

3. **[ANALYSE]** Compare Apple's approaches (unified memory + exclusive CoreML) and Intel's (OpenVINO + multiple backends). What are the trade-offs of each approach from an AI application developer's perspective?

### Mini-Challenge (optional)

Using `lspci`, `lsmod` and Intel/AMD documentation, identify if your system has an NPU. If so, verify the firmware version and driver status. Document the steps and results.

---


---


---

## Recommended Reading

### Mandatory Resources

**Framework Documentation**
- [Apple Core ML Documentation](https://developer.apple.com/documentation/coreml) — Neural Engine on Apple Silicon
- [ONNX Runtime](https://onnxruntime.ai/docs/) — Cross-platform runtime for inference
- [OpenVINO](https://docs.openvino.ai/) — Intel NPU support

**Vendor Documentation**
- [Intel NPU Plugin](https://docs.openvino.ai/latest/openvino_docs_OV_UG_supported_plugins_NPU.html)
- [Qualcomm AI Engine Direct SDK](https://developer.qualcomm.com/software/ai-engine-direct-sdk)

### Recommended Resources

**Articles and Reports**
- Jouppi et al. (2017): "In-Datacenter Performance Analysis of a Tensor Processing Unit" — Google TPU paper
- Reuther et al. (2022): "AI and ML Accelerator Survey and Trends" — Updated survey

**Courses and Tutorials**
- MIT 6.5940: "TinyML and Efficient Deep Learning" — Hardware-aware ML
- Stanford CS231n: Section on deployment on edge devices

### Video Resources

- **Hot Chips Conference** — Annual presentations on NPUs and accelerators
- **Apple WWDC** — Sessions on Neural Engine and Core ML
- **tinyML Summit** — Conference dedicated to ML on edge

### Projects for Study

- [ONNX Model Zoo](https://github.com/onnx/models) — Pre-trained models for testing
- [MLPerf Inference](https://mlcommons.org/en/inference-datacenter-10/) — Standard benchmarks for accelerators

## Nuances and Special Cases

### What We Did NOT Cover (didactic limitations)

- **NPU memory management**: Unified memory vs dedicated memory, DMA transfers.
- **Model compilation**: How compilers (XLA, TVM) transform ML graphs into NPU instructions.
- **Power management for NPU**: Dynamic frequency scaling, power states.

### Common Mistakes to Avoid

1. **Assuming NPU is always faster**: For small models, transfer overhead cancels out the benefits.
2. **Ignoring warmup latency**: The first inference is slower due to model loading.
3. **Quantisation without validation**: Quantisation can significantly degrade accuracy for some models.

### Open Questions Remaining

- Will there be a universal standard for programming NPUs (like CUDA for GPU)?
- How will operating systems manage scheduling for hybrid CPU+GPU+NPU workloads?

## Looking Ahead

**End of the Supplementary Lecture Series**

This is the final module in the Operating Systems lecture series. You have progressed from OS fundamentals to cutting-edge technologies such as eBPF and neural processors.

**Recommendations for continuation:**
- Review concepts from lectures 1-14 for the exam
- Explore open-source projects: Linux kernel, Docker, containerd
- Contribute to documentation or bug fixes in OS-related projects

## Visual Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│           WEEK 18: NPU INTEGRATION IN OS — RECAP                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  HETEROGENEOUS SYSTEMS (2025)                                               │
│  ├── CPU: Control flow, low latency, general code                          │
│  ├── GPU: Massive throughput, SIMT, training + rendering                   │
│  └── NPU: AI inference, INT8/INT4, maximum energy efficiency               │
│                                                                             │
│  HETEROGENEOUS SCHEDULING                                                   │
│  ├── Intel Thread Director: HFI hints + containment zones                  │
│  ├── NPU scheduling: Queue-based, non-preemptive (vs preemptive CPU)       │
│  └── Priority inversion: Solutions via checkpointing or partitioning       │
│                                                                             │
│  MEMORY FOR AI                                                              │
│  ├── Unified memory: Zero-copy, efficient, limited bandwidth               │
│  ├── Scratchpad: Software-managed, predictable, explicit DMA               │
│  └── PagedAttention: VM concepts applied to LLM KV-cache                   │
│                                                                             │
│  VENDOR COMPARISON                                                          │
│  ├── Apple: Tight integration, walled garden, ~38 TOPS                     │
│  ├── Intel: Standard APIs, OpenVINO, ~48 TOPS                              │
│  ├── AMD: Spatial dataflow (XDNA), open source, ~50 TOPS                   │
│  └── Qualcomm: Mobile heritage, max efficiency, ~45 TOPS (ARM only!)       │
│                                                                             │
│  OS INTEGRATION                                                             │
│  ├── Windows: AI Foundry + MCDM driver model                               │
│  ├── Linux: /dev/accel/* subsystem (kernel 6.2+)                           │
│  └── macOS: CoreML exclusive, no direct NPU access                         │
│                                                                             │
│  💡 TAKEAWAY: NPU transforms classic OS concepts (scheduling,               │
│     memory management, drivers) for the on-device AI era                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 13. References and Further Reading

### 13.1. Official Documentation

1. **Intel NPU**
   - [Intel NPU Driver (Linux)](https://github.com/intel/linux-npu-driver)
   - [OpenVINO Documentation](https://docs.openvino.ai/)
   - [Thread Director Technical Brief](https://www.intel.com/content/www/us/en/gaming/resources/how-hybrid-design-works.html)

2. **AMD XDNA**
   - [AMD XDNA Driver](https://github.com/amd/xdna-driver)
   - [Xilinx AI Engine Architecture](https://docs.xilinx.com/r/en-US/am020-versal-aie-ml)

3. **Qualcomm**
   - [Qualcomm AI Engine Direct SDK](https://developer.qualcomm.com/software/qualcomm-ai-engine-direct-sdk)

4. **Microsoft**
   - [Copilot+ PC Developer Guide](https://learn.microsoft.com/en-us/windows/ai/npu-devices/)
   - [DirectML Documentation](https://learn.microsoft.com/en-us/windows/ai/directml/dml)

### 13.2. Academic and Technical Articles

1. Lam, C. "Qualcomm's Hexagon DSP, and now, NPU" - Chips and Cheese, 2024
2. "PREMA: Predictive Multi-task NPU Scheduler" - arXiv, 2023
3. "PagedAttention: Efficient Memory Management for LLM Serving" - vLLM, 2023

### 13.3. Video Resources

1. Intel Tech Tour 2024: "Lunar Lake Power Management and Thread Director Innovations"
2. Hot Chips 2023: "Qualcomm Hexagon Tensor Processor"

---

*Materials developed for the Operating Systems course — by Revolvix*  
*ASE Bucharest, CSIE — Year I, Semester 2, 2025-2026*
