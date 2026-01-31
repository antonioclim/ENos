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

## OpenVINO Workflow
```python
from openvino.runtime import Core

core = Core()
model = core.read_model("model.xml")
compiled = core.compile_model(model, "NPU")
result = compiled([input_data])
```

## Comparative Efficiency
| Device | Performance | Power | TOPS/W |
|--------|-------------|-------|--------|
| CPU | ~10 TOPS | 65W | 0.15 |
| GPU | ~100 TOPS | 200W | 0.5 |
| NPU | ~10 TOPS | 5W | 2.0 |

NPU: Fewer total TOPS but much more efficient per watt!
