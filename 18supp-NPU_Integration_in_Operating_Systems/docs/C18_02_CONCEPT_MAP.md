# Concept Map — NPU Integration

```
              ┌──────────────────┐
              │       NPU        │
              │(Neural Processing│
              │     Unit)        │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Hardware │     │   Linux     │     │Userspace│
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│Intel VPU│     │Accel subsys │     │OpenVINO │
│AMD XDNA │     │/dev/accel/* │     │ONNX RT  │
│Qualcomm │     │DRM/KMS      │     │TensorRT │
│NPU      │     │Firmware load│     │(NVIDIA) │
└─────────┘     └─────────────┘     └─────────┘

CPU vs GPU vs NPU:
┌─────────────────────────────────────────────────┐
│           CPU       GPU        NPU              │
│  Cores    8-64    1000s      Specialised        │
│  Power    65-250W  150-450W   1-15W            │
│  Use      General  Graphics+AI AI inference     │
│           purpose  training   optimised         │
│                                                 │
│  Best for: NPU wins for sustained AI inference │
│            with power efficiency               │
└─────────────────────────────────────────────────┘
```
