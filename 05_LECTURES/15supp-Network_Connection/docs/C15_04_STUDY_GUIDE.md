<!-- RO: TRADUS ȘI VERIFICAT -->
# Study Guide — Networking

## Socket API (C): accepted-connection echo fragment

The following Linux/POSIX fragment handles an already accepted stream descriptor. Listener setup (`socket`, `bind`, `listen`, `accept`) and the client are separate programmes; each must check its own return values. A successful `connect` can precede application `accept`, because the kernel queues established connections.

```c
#include <sys/socket.h>
#include <unistd.h>
#include <errno.h>
int echo_connection(int client) {
    char buf[4096];
    for (;;) {
        ssize_t n = recv(client, buf, sizeof buf, 0);
        if (n == 0) return 0; /* peer closed its sending direction */
        if (n < 0) { if (errno == EINTR) continue; return -1; }
        ssize_t done = 0;
        while (done < n) {
            ssize_t sent = send(client, buf + done, (size_t)(n - done), MSG_NOSIGNAL);
            if (sent < 0 && errno == EINTR) continue;
            if (sent <= 0) return -1;
            done += sent;
        }
    }
}
```

The caller closes the descriptor on every completion/error path. Only the `n` bytes actually received are sent. `MSG_NOSIGNAL` is Linux-specific; portable programmes need an explicit SIGPIPE policy. TCP carries a byte stream: message framing (fixed length, length prefix, delimiter or connection close) belongs to the application. The Python echo client reads exactly the encoded request length before decoding UTF-8.

## TCP vs UDP
| TCP | UDP |
|-----|-----|
| Connection-oriented | Connectionless |
| Ordered reliable byte stream, or connection failure | Best-effort datagrams; applications may add reliability |
| Ordered | Unordered |
| Stream | Datagrams |
| Reliability and congestion-control behaviour depends on path/workload | Lower fixed header cost does not guarantee lower application latency |

## I/O Multiplexing
- **select**: Portable; the common Linux/glibc fd_set limits descriptor values to less than FD_SETSIZE (usually 1024)
- **poll**: Avoids fd_set’s fixed descriptor-number bound; resource limits still apply and the array is scanned
- **epoll**: Linux-specific readiness interface; costs depend on interest-set changes and the ready events returned, not a universal O(1) total operation
