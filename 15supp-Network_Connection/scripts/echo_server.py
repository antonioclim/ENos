#!/usr/bin/env python3
"""
TCP Echo Server - BSD Socket Model Demonstration
Operating Systems | ASE Bucharest - CSIE | 2025-2026

Concepts illustrated:
- Creating and configuring TCP sockets
- Lifecycle: socket() → bind() → listen() → accept() → recv/send → close()
- Socket options (SO_REUSEADDR)
- Handling multiple connections sequentially

Usage:
    python3 echo_server.py [port]
    
Testing:
    nc localhost 9000
    # or
    python3 echo_client.py
"""

import socket
import sys
import signal
from datetime import datetime
from typing import Tuple

# Default configuration
DEFAULT_HOST = '0.0.0.0'  # Listen on all interfaces
DEFAULT_PORT = 9000
BUFFER_SIZE = 4096
BACKLOG = 5  # Maximum number of connections in the waiting queue


def log_message(level: str, message: str) -> None:
    """Display message with timestamp."""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] [{level}] {message}")


def handle_client(client_socket: socket.socket, client_addr: Tuple[str, int]) -> None:
    """
    Process client connection.
    
    Receives data from the client and retransmits it (echo).
    Continues until the client closes the connection.
    
    Args:
        client_socket: Socket for communication with the client
        client_addr: Tuple (IP, port) identifying the client
    """
    client_ip, client_port = client_addr
    log_message("CONN", f"Connection accepted from {client_ip}:{client_port}")
    
    bytes_received = 0
    messages_count = 0
    
    try:
        while True:
            # Receive data
            # recv() blocks until data is available or connection closes
            data = client_socket.recv(BUFFER_SIZE)
            
            if not data:
                # Connection closed by client (recv returns empty bytes)
                log_message("DISC", f"Client {client_ip}:{client_port} disconnected")
                break
            
            bytes_received += len(data)
            messages_count += 1
            
            # Decode for display (assuming UTF-8)
            try:
                message = data.decode('utf-8').strip()
                log_message("RECV", f"From {client_ip}: \"{message}\" ({len(data)} bytes)")
            except UnicodeDecodeError:
                log_message("RECV", f"From {client_ip}: <binary data> ({len(data)} bytes)")
            
            # Echo: retransmit received data
            # sendall() guarantees complete transmission (unlike send())
            client_socket.sendall(data)
            log_message("SEND", f"Echo sent to {client_ip}")
            
    except ConnectionResetError:
        log_message("WARN", f"Connection reset by {client_ip}:{client_port}")
    except BrokenPipeError:
        log_message("WARN", f"Broken pipe for {client_ip}:{client_port}")
    finally:
        log_message("STAT", f"Statistics {client_ip}: {messages_count} messages, {bytes_received} bytes")


def run_server(host: str = DEFAULT_HOST, port: int = DEFAULT_PORT) -> None:
    """
    Start TCP echo server.
    
    Creates a socket, binds it to the specified address and enters
    the main loop for accepting connections.
    
    Args:
        host: IP address to listen on
        port: Port to listen on
    """
    # Create TCP socket
    # AF_INET = IPv4 address family
    # SOCK_STREAM = connection-oriented socket (TCP)
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # SO_REUSEADDR allows immediate port reuse after closing
    # Without this option, the port remains in TIME_WAIT state (~60s)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        # Bind socket to address and port
        server_socket.bind((host, port))
        
        # Enable listening mode
        # backlog specifies the length of the pending connections queue
        server_socket.listen(BACKLOG)
        
        log_message("INFO", f"Echo server started on {host}:{port}")
        log_message("INFO", f"Backlog: {BACKLOG} connections, Buffer: {BUFFER_SIZE} bytes")
        log_message("INFO", "Press Ctrl+C to stop")
        
        # Main loop
        while True:
            try:
                # accept() blocks until a connection is available
                # Returns a NEW socket for communication and the client address
                # The original socket continues listening for new connections
                client_socket, client_addr = server_socket.accept()
                
                # Context manager ensures proper socket closure
                with client_socket:
                    handle_client(client_socket, client_addr)
                    
            except KeyboardInterrupt:
                raise  # Re-raise for handling in finally
                
    except OSError as e:
        log_message("ERR", f"Socket error: {e}")
        sys.exit(1)
    finally:
        server_socket.close()
        log_message("INFO", "Server stopped")


def signal_handler(signum, frame):
    """Handler for termination signals."""
    log_message("INFO", "Termination signal received")
    sys.exit(0)


def main():
    """Main entry point."""
    # Register handler for SIGINT (Ctrl+C) and SIGTERM
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Parse optional port argument
    port = DEFAULT_PORT
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
            if not (1 <= port <= 65535):
                raise ValueError("Port outside valid range")
        except ValueError as e:
            print(f"Error: invalid port - {e}")
            print(f"Usage: {sys.argv[0]} [port]")
            sys.exit(1)
    
    run_server(port=port)


if __name__ == '__main__':
    main()
