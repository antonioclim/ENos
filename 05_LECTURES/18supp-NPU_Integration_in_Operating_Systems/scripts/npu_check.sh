#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# npu_check.sh - NPU Presence and Status Check
# OS Lecture 18supp - NPU Integration in Operating Systems
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail
IFS=$'\n\t'

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

print_header() {
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║               NPU Detection & Status Script                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo ""
}

check_accel_subsystem() {
    echo "[1] Accel Subsystem (/dev/accel/*):"
    if ls /dev/accel/accel* &>/dev/null; then
        echo "    ✓ Accel devices found:"
        ls -la /dev/accel/ 2>/dev/null | grep accel || true
    else
        echo "    ✗ No /dev/accel/* devices"
        echo "      (NPU driver not loaded or kernel < 6.2)"
    fi
    echo ""
}

check_intel_npu() {
    echo "[2] Intel NPU (ivpu driver):"
    if lsmod 2>/dev/null | grep -qE "^ivpu|^intel_vpu"; then
        echo "    ✓ Intel VPU/NPU driver loaded"
        lsmod | grep -E "ivpu|intel_vpu" || true
        
        echo "    Device info:"
        lspci 2>/dev/null | grep -i "VPU\|Neural\|AI" | sed 's/^/      /' || true
        
        if [[ -d "/sys/class/accel/accel0" ]]; then
            echo "    Sysfs path: /sys/class/accel/accel0"
        fi
    else
        echo "    ✗ Intel ivpu driver not loaded"
        echo "      Try: sudo modprobe intel_vpu (if available)"
    fi
    echo ""
}

check_amd_xdna() {
    echo "[3] AMD XDNA NPU (amdxdna driver):"
    if lsmod 2>/dev/null | grep -q "amdxdna"; then
        echo "    ✓ AMD XDNA driver loaded"
        lsmod | grep amdxdna || true
    else
        echo "    ✗ AMD XDNA driver not loaded"
        echo "      Requires: Linux 6.14+ or out-of-tree driver"
    fi
    echo ""
}

check_intel_firmware() {
    local fw_path="/lib/firmware/intel/vpu"
    
    echo "[4] Intel NPU Firmware:"
    if [[ -d "$fw_path" ]]; then
        echo "    ✓ Firmware directory exists: $fw_path"
        echo "    Fișiers:"
        ls -lh "$fw_path"/*.bin 2>/dev/null | awk '{print "      "$NF" ("$5")"}' || echo "      (no .bin files found)"
    else
        echo "    ✗ Firmware not found at $fw_path"
    fi
    echo ""
}

check_openvino() {
    echo "[5] OpenVINO Runtime:"
    if python3 -c "import openvino" 2>/dev/null; then
        echo "    ✓ OpenVINO installed"
        python3 -c "import openvino; print('      Version:', openvino.__version__)" || true
        
        echo "    Available devices:"
        python3 << 'PYEOF' 2>/dev/null | sed 's/^/      /' || echo "      (could not list devices)"
import openvino as ov
core = ov.Core()
for device in core.available_devices:
    print(f"- {device}")
PYEOF
    else
        echo "    ✗ OpenVINO not installed"
        echo "      Install: pip install openvino"
    fi
    echo ""
}

check_kernel_messages() {
    echo "[6] Recent kernel messages (NPU related):"
    local messages
    messages=$(dmesg 2>/dev/null | grep -i "ivpu\|vpu\|npu\|xdna\|neural" | tail -10 || true)
    
    if [[ -n "$messages" ]]; then
        echo "$messages" | sed 's/^/    /'
    else
        echo "    (no NPU-related messages or insufficient permissions)"
    fi
    echo ""
}

print_footer() {
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "Done. For detailed NPU benchmarks, run: python3 npu_benchmark.py"
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

main() {
    print_header
    check_accel_subsystem
    check_intel_npu
    check_amd_xdna
    check_intel_firmware
    check_openvino
    check_kernel_messages
    print_footer
}

main "$@"
