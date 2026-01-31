# Concept Map — Kernel Programming

```
              ┌──────────────────┐
              │  KERNEL MODULE   │
              │ (loadable code)  │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│Lifecycle│     │   Types     │     │  eBPF   │
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│init_mod │     │Char device  │     │Sandboxed│
│exit_mod │     │Block device │     │Verified │
│insmod   │     │Net driver   │     │Tracing  │
│rmmod    │     │Filesystem   │     │Networking
└─────────┘     └─────────────┘     └─────────┘

KERNEL MODULE STRUCTURE:
┌─────────────────────────────────────────────────┐
│  #include <linux/module.h>                      │
│  #include <linux/kernel.h>                      │
│                                                 │
│  static int __init my_init(void) {              │
│      printk(KERN_INFO "Module loaded\n");       │
│      return 0;                                  │
│  }                                              │
│                                                 │
│  static void __exit my_exit(void) {             │
│      printk(KERN_INFO "Module unloaded\n");     │
│  }                                              │
│                                                 │
│  module_init(my_init);                          │
│  module_exit(my_exit);                          │
│  MODULE_LICENSE("GPL");                         │
└─────────────────────────────────────────────────┘
```
