# Study Guide — Kernel Programming

## Module Commands
```bash
insmod module.ko     # Load
rmmod module         # Unload
modprobe module      # With dependencies
lsmod                # List
dmesg                # View printk output
```

## Character Device Driver
```c
static struct file_operations fops = {
    .owner = THIS_MODULE,
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
};

// Registration
register_chrdev(MAJOR, "mydev", &fops);
```

## Differences: Kernel vs Userspace
| Kernel | Userspace |
|--------|-----------:|
| printk() | printf() |
| kmalloc() | malloc() |
| No libc | Full libc |
| No floating point | FP OK |
| Crash = panic | Crash = segfault |

## eBPF
- Sandboxed programs in kernel
- Verified before loading
- Use cases: tracing, networking, security
