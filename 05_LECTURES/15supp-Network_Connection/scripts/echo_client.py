<!-- RO: TRADUS ȘI VERIFICAT -->
#!/usr/bin/env python3
"""
TCP Echo Client - BSD Socket Model Demonstration
Operating Systems | ASE Bucharest - CSIE | 2025-2026

Concepts illustrated:
- Connecting to a TCP server
- Client lifecycle: socket() → connect() → send/recv → close()
- Timeout and connection error handling

Usage:
    python3 echo_client.py [host] [port]
    
Examples:
    python3 echo_client.py                    # localhost:9000
    python3 echo_client.py 192.168.1.100      # 192.168.1.100:9000
    python3 echo_client.py 192.168.1.100 8080 # 192.168.1.100:8080
"""

import socket
import sys
from datetime import datetime

# Default configuration
DEFAULT_HOST = '127.0.0.1'
DEFAULT_PORT = 9000
BUFFER_SIZE = 4096
CONNECT_TIMEOUT = 10  # seconds


def log_message(level: str, message: str) -> None:
    """Display message with timestamp."""
    timestamp = datetime.now().strftime('%H:%M:%S')
    print(f"[{timestamp}] [{level}] {message}")


def run_client(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT) -> None:
    """
    Interactive TCP client for testing the echo server.
    
    Connects to the specified server and allows sending
    interactive messages from the console.
    
    Args:
        host: Server IP address
        port: Server port
    """
    log_message("INFO", f"Connecting to {host}:{port}...")
    
    # Create TCP socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Set connection timeout
    client_socket.settimeout(CONNECT_TIMEOUT)
    
    try:
        # Initiate TCP connection (three-way handshake)
        client_socket.connect((host, port))
        
        # After connecting, remove timeout for interactive operations
        client_socket.settimeout(None)
        
        # Get connection information
        local_addr = client_socket.getsockname()
        log_message("CONN", f"Connected! Local endpoint: {local_addr[0]}:{local_addr[1]}")
        
        print("\n" + "=" * 60)
        print("  INTERACTIVE ECHO CLIENT")
        print("  Enter messages to send them to the server.")
        print("  Type 'quit' or 'exit' to finish.")
        print("  Type 'stats' for connection statistics.")
        print("=" * 60 + "\n")
        
        messages_sent = 0
        bytes_sent = 0
        bytes_received = 0
        
        while True:
            try:
                # Read user input
                user_input = input(">>> ")
                
                # Special commands
                if user_input.lower() in ('quit', 'exit', 'q'):
                    log_message("INFO", "Closing connection...")
                    break
                    
                if user_input.lower() == 'stats':
                    print(f"\n  Connection statistics:")
                    print(f"  - Messages sent: {messages_sent}")
                    print(f"  - Bytes sent: {bytes_sent}")
                    print(f"  - Bytes received: {bytes_received}")
                    print()
                    continue
                
                if not user_input:
                    continue
                
                # Encode and send
                data = user_input.encode('utf-8')
                client_socket.sendall(data)
                bytes_sent += len(data)
                messages_sent += 1
                
                log_message("SEND", f"Sent {len(data)} bytes")
                
                # Wait for response
                response = client_socket.recv(BUFFER_SIZE)
                
                if not response:
                    log_message("WARN", "Server closed the connection")
                    break
                
                bytes_received += len(response)
                
                # Decode and display response
                response_text = response.decode('utf-8', errors='replace')
                log_message("RECV", f"Echo: \"{response_text}\" ({len(response)} bytes)")
                
            except KeyboardInterrupt:
                print()  # New line after ^C
                log_message("INFO", "User interrupt")
                break
                
    except socket.timeout:
        log_message("ERR", f"Connection timeout ({CONNECT_TIMEOUT}s)")
        sys.exit(1)
    except ConnectionRefusedError:
        log_message("ERR", f"Connection refused - server not running on {host}:{port}")
        sys.exit(1)
    except ConnectionResetError:
        log_message("ERR", "Connection reset by server")
        sys.exit(1)
    except OSError as e:
        log_message("ERR", f"Network error: {e}")
        sys.exit(1)
    finally:
        client_socket.close()
        log_message("INFO", "Connection closed")
        print(f"\nSummary: {messages_sent} messages, {bytes_sent} bytes sent, {bytes_received} bytes received")


def main():
    """Main entry point with argument parsing."""
    host = DEFAULT_HOST
    port = DEFAULT_PORT
    
    # Parse arguments
    if len(sys.argv) >= 2:
        host = sys.argv[1]
    
    if len(sys.argv) >= 3:
        try:
            port = int(sys.argv[2])
            if not (1 <= port <= 65535):
                raise ValueError("Port outside range 1-65535")
        except ValueError as e:
            print(f"Error: invalid port - {e}")
            print(f"Usage: {sys.argv[0]} [host] [port]")
            sys.exit(1)
    
    run_client(host, port)


if __name__ == '__main__':
    main()
