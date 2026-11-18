# Study Guide — NPU Integration

## NPU Architecture
- Specialised MAC (Multiply-Accumulate) units
- Optimised for tensor operations
- Lower precision (INT8, FP16) for efficiency
- On-chip memory for reduced bandwidth

## Linux Accel Subsystem
```bash
# Check for NPU
ls /dev/accel/

# Intel NPU driver
lsmod | grep ivpu

# Firmware location
ls /lib/firmware/intel/vpu/
```

## OpenVINO workflow (2026 API)

Install a compatible runtime and NPU driver in an authorised lab, record their versions and confirm `NPU` is present in `Core().available_devices`. Use an existing model whose licence/provenance you have checked. The IR example requires both `model.xml` and its matching `model.bin`, plus an `.npy` tensor with the model's exact shape, dtype and preprocessing.

```python
from pathlib import Path
import numpy as np
from openvino import Core

core = Core()
if 'NPU' not in core.available_devices:
    raise RuntimeError('NPU unavailable; check supported hardware/runtime/driver')
model_path = Path('model.xml')
if not model_path.is_file() or not model_path.with_suffix('.bin').is_file():
    raise FileNotFoundError('Provide the matching model.xml and model.bin')
model = core.read_model(model_path)
input_data = np.load('input.npy', allow_pickle=False)
if len(model.inputs) != 1 or model.input().partial_shape.is_dynamic:
    raise ValueError('This example requires one static input')
if tuple(input_data.shape) != tuple(model.input().shape):
    raise ValueError('Input shape does not match model')
if input_data.dtype != np.dtype(model.input().element_type.to_dtype()):
    raise ValueError('Input dtype does not match model')
compiled = core.compile_model(model, 'NPU')
result = compiled([input_data])
```

Model conversion, preprocessing and correctness against a known output are prerequisites; timings alone do not validate inference. This route has not been executed on NPU hardware in this revision. [Official OpenVINO inference workflow](https://docs.openvino.ai/2026/openvino-workflow/running-inference.html).

## Hypothetical efficiency arithmetic — not hardware measurements
| Device | Performance | Power | TOPS/W |
|--------|-------------|-------|--------|
| CPU | ~10 TOPS | 65W | 0.15 |
| GPU | ~100 TOPS | 200W | 0.5 |
| NPU | ~10 TOPS | 5W | 2.0 |

These retained illustrative numbers show division by watts only. Comparable TOPS/W requires the same operation counting, precision, workload and power measurement boundary. The table establishes no general hardware ranking.
