# Concept Map — Networking

```
              ┌──────────────────┐
              │     SOCKETS      │
              │  (Network I/O)   │
              └────────┬─────────┘
                       │
    ┌──────────────────┼──────────────────┐
    ▼                  ▼                  ▼
┌─────────┐     ┌─────────────┐     ┌─────────┐
│  TCP    │     │    UDP      │     │Multiplex│
└────┬────┘     └──────┬──────┘     └────┬────┘
     │                 │                 │
┌────┴────┐     ┌──────┴──────┐     ┌────┴────┐
│Connected│     │Connectionless│    │ select  │
│Reliable │     │Best-effort  │     │ poll    │
│Ordered  │     │Datagrams    │     │ epoll   │
│Stream   │     │Low latency  │     │ kqueue  │
└─────────┘     └─────────────┘     └─────────┘

TCP SERVER FLOW:
┌─────────────────────────────────────────────────┐
│  socket() → bind() → listen() → accept()        │
│                                    │            │
│                            ┌───────┴───────┐    │
│                            │   Per-client  │    │
│                            │   recv/send   │    │
│                            │   close()     │    │
│                            └───────────────┘    │
│                                                 │
│  TCP CLIENT:                                    │
│  socket() → connect() → send/recv → close()    │
└─────────────────────────────────────────────────┘
```
