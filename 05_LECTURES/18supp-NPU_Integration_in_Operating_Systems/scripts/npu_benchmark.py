#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════════
npu_benchmark.py - NPU vs CPU vs GPU Inference Comparison
OS Lecture 18supp - NPU Integration in Operating Systems

Requires: pip install openvino onnxruntime numpy
Optional: pip install onnxruntime-gpu (for CUDA)
═══════════════════════════════════════════════════════════════════════════════
"""

from __future__ import annotations

import sys
import time
from pathlib import Path
from typing import Any

import numpy as np

# ═══════════════════════════════════════════════════════════════════════════════
# CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

MODEL_URL = "https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx"
MODEL_PATH = Path("mobilenetv2-7.onnx")
DEFAULT_ITERATIONS = 100
WARMUP_ITERATIONS = 10


# ═══════════════════════════════════════════════════════════════════════════════
# DOWNLOAD MODEL
# ═══════════════════════════════════════════════════════════════════════════════

def download_model() -> str:
    """Download a test model (MobileNetV2) if not present."""
    if MODEL_PATH.exists():
        return str(MODEL_PATH)

    print("Downloading MobileNetV2 model...")
    try:
        import urllib.request
        urllib.request.urlretrieve(MODEL_URL, MODEL_PATH)
        print(f"  Downloaded: {MODEL_PATH}")
    except Exception as e:
        print(f"  Error downloading: {e}")
        print("  Please download manually from ONNX Model Zoo")
        sys.exit(1)

    return str(MODEL_PATH)


# ═══════════════════════════════════════════════════════════════════════════════
# STATISTICS
# ═══════════════════════════════════════════════════════════════════════════════

def compute_stats(provider: str, latencies: list[float]) -> dict[str, Any]:
    """Compute statistics from latencies."""
    return {
        'provider': provider,
        'mean_ms': np.mean(latencies),
        'std_ms': np.std(latencies),
        'p50_ms': np.percentile(latencies, 50),
        'p99_ms': np.percentile(latencies, 99),
        'min_ms': np.min(latencies),
        'max_ms': np.max(latencies),
    }


# ═══════════════════════════════════════════════════════════════════════════════
# ONNX RUNTIME BENCHMARK
# ═══════════════════════════════════════════════════════════════════════════════

def benchmark_onnxruntime(model_path: str, provider: str, iterations: int) -> dict:
    """Benchmark using ONNX Runtime."""
    import onnxruntime as ort

    try:
        sess = ort.InferenceSession(model_path, providers=[provider])
    except Exception as e:
        return {'provider': provider, 'error': str(e)}

    input_name = sess.get_inputs()[0].name
    input_shape = [1 if isinstance(d, str) else d for d in sess.get_inputs()[0].shape]
    input_data = {input_name: np.random.randn(*input_shape).astype(np.float32)}

    for _ in range(WARMUP_ITERATIONS):
        sess.run(None, input_data)

    latencies = []
    for _ in range(iterations):
        start = time.perf_counter()
        sess.run(None, input_data)
        latencies.append((time.perf_counter() - start) * 1000)

    return compute_stats(provider, latencies)


# ═══════════════════════════════════════════════════════════════════════════════
# OPENVINO BENCHMARK
# ═══════════════════════════════════════════════════════════════════════════════

def _run_openvino_inference(compiled, input_data: np.ndarray, iterations: int) -> list:
    """Execute OpenVINO inference and return latencies."""
    for _ in range(WARMUP_ITERATIONS):
        compiled([input_data])

    latencies = []
    for _ in range(iterations):
        start = time.perf_counter()
        compiled([input_data])
        latencies.append((time.perf_counter() - start) * 1000)
    return latencies


def benchmark_openvino(model_path: str, device: str, iterations: int) -> dict:
    """Benchmark using OpenVINO."""
    provider = f'OpenVINO-{device}'
    try:
        import openvino as ov
        core = ov.Core()

        if device not in core.available_devices:
            return {'provider': provider, 'error': f'Device {device} not available'}

        model = core.read_model(model_path)
        compiled = core.compile_model(model, device)
        input_shape = [1 if d == -1 else d for d in model.input().shape]
        input_data = np.random.randn(*input_shape).astype(np.float32)

        latencies = _run_openvino_inference(compiled, input_data, iterations)
        return compute_stats(provider, latencies)

    except Exception as e:
        return {'provider': provider, 'error': str(e)}


# ═══════════════════════════════════════════════════════════════════════════════
# DISPLAY RESULTS
# ═══════════════════════════════════════════════════════════════════════════════

def print_header() -> None:
    """Display the programme header."""
    print("╔═══════════════════════════════════════════════════════════════════╗")
    print("║            NPU vs CPU vs GPU Inference Benchmark                  ║")
    print("╚═══════════════════════════════════════════════════════════════════╝")
    print()


def print_results_table(results: list[dict]) -> None:
    """Print benchmark results in a nice table."""
    print("\n" + "=" * 80)
    print(f"{'Provider':<25} {'Mean (ms)':<12} {'P50 (ms)':<12} {'P99 (ms)':<12} {'Std':<10}")
    print("=" * 80)

    for r in results:
        if 'error' in r:
            print(f"{r.get('provider', 'Unknown'):<25} ERROR: {r['error'][:40]}")
        else:
            print(f"{r['provider']:<25} {r['mean_ms']:<12.2f} {r['p50_ms']:<12.2f} "
                  f"{r['p99_ms']:<12.2f} {r['std_ms']:<10.2f}")

    print("=" * 80)


def print_fastest(results: list[dict]) -> None:
    """Display the fastest provider."""
    valid = [r for r in results if 'error' not in r]
    if valid:
        fastest = min(valid, key=lambda x: x['mean_ms'])
        print(f"\n🏆 Fastest: {fastest['provider']} ({fastest['mean_ms']:.2f} ms)")


# ═══════════════════════════════════════════════════════════════════════════════
# BENCHMARK RUNNERS
# ═══════════════════════════════════════════════════════════════════════════════

def run_onnx_benchmarks(model_path: str, iterations: int) -> list[dict]:
    """Run ONNX Runtime benchmarks."""
    results = []
    print("Running ONNX Runtime benchmarks...")

    try:
        import onnxruntime as ort
        print(f"  ONNX Runtime version: {ort.__version__}")
        print(f"  Available providers: {ort.get_available_providers()}")

        print("  Testing CPU...")
        results.append(benchmark_onnxruntime(model_path, 'CPUExecutionProvider', iterations))

        if 'CUDAExecutionProvider' in ort.get_available_providers():
            print("  Testing CUDA GPU...")
            results.append(benchmark_onnxruntime(model_path, 'CUDAExecutionProvider', iterations))

        if 'DmlExecutionProvider' in ort.get_available_providers():
            print("  Testing DirectML...")
            results.append(benchmark_onnxruntime(model_path, 'DmlExecutionProvider', iterations))

    except ImportError:
        print("  ONNX Runtime not installed")

    return results


def run_openvino_benchmarks(model_path: str, iterations: int) -> list[dict]:
    """Run OpenVINO benchmarks."""
    results = []
    print("\nRunning OpenVINO benchmarks...")

    try:
        import openvino as ov
        core = ov.Core()
        print(f"  OpenVINO version: {ov.__version__}")
        print(f"  Available devices: {core.available_devices}")

        for device in core.available_devices:
            print(f"  Testing {device}...")
            results.append(benchmark_openvino(model_path, device, iterations))

    except ImportError:
        print("  OpenVINO not installed (pip install openvino)")

    return results


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> int:
    """Main entry point."""
    print_header()

    model_path = download_model()
    print(f"Model: {model_path}\n")

    results = []
    results.extend(run_onnx_benchmarks(model_path, DEFAULT_ITERATIONS))
    results.extend(run_openvino_benchmarks(model_path, DEFAULT_ITERATIONS))

    print_results_table(results)
    print_fastest(results)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
