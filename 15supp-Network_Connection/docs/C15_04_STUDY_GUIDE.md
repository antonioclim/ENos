# Study Guide — Networking

## Socket API (C)
```c
// Server
int sockfd = socket(AF_INET, SOCK_STREAM, 0);
bind(sockfd, (struct sockaddr*)&addr, sizeof(addr));
listen(sockfd, backlog);
int client = accept(sockfd, NULL, NULL);
recv(client, buf, size, 0);
send(client, buf, size, 0);
close(client);

// Client
int sockfd = socket(AF_INET, SOCK_STREAM, 0);
connect(sockfd, (struct sockaddr*)&addr, sizeof(addr));
send(sockfd, buf, size, 0);
recv(sockfd, buf, size, 0);
close(sockfd);
```

## TCP vs UDP
| TCP | UDP |
|-----|-----|
| Connection-oriented | Connectionless |
| Reliable | Best-effort |
| Ordered | Unordered |
| Stream | Datagrams |
| Higher latency | Lower latency |

## I/O Multiplexing
- **select**: Portable, limited (1024 FDs)
- **poll**: No FD limit, still O(n)
- **epoll**: Linux-specific, O(1), scalable
