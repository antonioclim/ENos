# C02_02_CONCEPT_MAP.md
# Concept Map — Basic OS Concepts

> Operating Systems | ASE Bucharest - CSIE | 2025-2026  
> Week 2 | by Revolvix

---

## Interrupts - Main Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           INTERRUPTS                                    │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
         ┌──────────────────────┴──────────────────────┐
         │                                             │
         ▼                                             ▼
┌─────────────────┐                         ┌─────────────────┐
│    HARDWARE     │                         │    SOFTWARE     │
│  (Asynchronous) │                         │  (Synchronous)  │
└────────┬────────┘                         └────────┬────────┘
         │                                           │
    ┌────┴────┐                                 ┌────┴────┐
    ▼         ▼                                 ▼         ▼
┌───────┐ ┌───────┐                       ┌───────┐ ┌───────┐
│ Timer │ │  I/O  │                       │ Trap  │ │ Fault │
│  IRQ  │ │ Ready │                       │(syscall)│ │(error)│
└───────┘ └───────┘                       └───────┘ └───────┘
```

---

## Interrupt Handling Flow

```
    NORMAL EXECUTION                       INTERRUPT HANDLER
    ────────────────                       ─────────────────
         │
         │  ←──── Interrupt arrives
         ▼
    ┌─────────────┐
    │ Save State  │ ◄── PC, registers, flags
    │ (auto by HW)│     onto stack
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │ Lookup IVT  │ ◄── Vector → Handler address
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │   Handler   │ ◄── Handle interrupt
    │  Execution  │     (kernel mode)
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │  Restore    │ ◄── IRET: restore PC, flags
    │   State     │
    └──────┬──────┘
           │
           ▼
    CONTINUE EXECUTION
```

---

## Polling vs Interrupts vs DMA

```
┌─────────────────┬─────────────────┬─────────────────┐
│     POLLING     │   INTERRUPTS    │       DMA       │
├─────────────────┼─────────────────┼─────────────────┤
│                 │                 │                 │
│   CPU ──────►   │   CPU           │   CPU           │
│   │  check      │    ▲            │    │            │
│   │  check      │    │ IRQ        │    │ setup      │
│   │  check      │    │            │    ▼            │
│   │  DATA!      │   DATA!         │   DMA ◄──► I/O  │
│   ▼             │                 │    │            │
│  process        │   handler       │    │ done IRQ   │
│                 │                 │    ▼            │
│                 │                 │   process       │
├─────────────────┼─────────────────┼─────────────────┤
│ CPU busy        │ CPU free        │ CPU free        │
│ Low latency     │ Medium latency  │ Low latency     │
│ Simple          │ Complex         │ More complex    │
│ Inefficient     │ Efficient       │ Very efficient  │
└─────────────────┴─────────────────┴─────────────────┘
```

---

## Priorities and Nested Interrupts

```
Priority
    ▲
    │  ┌─────────────────────────────────────────┐
  5 │  │ NMI (Non-Maskable Interrupt)            │ ◄── Cannot be disabled
    │  └─────────────────────────────────────────┘
  4 │  ┌─────────────────────────────────────────┐
    │  │ Hardware Errors                          │
    │  └─────────────────────────────────────────┘
  3 │  ┌─────────────────────────────────────────┐
    │  │ Timer Interrupt                          │ ◄── Scheduling
    │  └─────────────────────────────────────────┘
  2 │  ┌─────────────────────────────────────────┐
    │  │ Disk I/O Complete                        │
    │  └─────────────────────────────────────────┘
  1 │  ┌─────────────────────────────────────────┐
    │  │ Keyboard / Mouse                         │
    │  └─────────────────────────────────────────┘
    └──────────────────────────────────────────────►
```

---

*Concept map for individual study*
