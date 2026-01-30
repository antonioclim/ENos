#!/usr/bin/env python3
"""
ENos Educational Kit — Shared Logging Utilities

Provides consistent, structured logging across all Python scripts.
Supports both console output (with colours) and file logging.

Author: ing. dr. Antonio Clim, ASE-CSIE
"""

import logging
import sys
from pathlib import Path
from typing import Optional

# British English in comments and docstrings
# American English preserved in Python stdlib (logging.WARNING, etc.)


class ColouredFormatter(logging.Formatter):
    """Formatter that adds ANSI colours to log levels for terminal output."""
    
    COLOURS = {
        logging.DEBUG: '\033[0;36m',    # Cyan
        logging.INFO: '\033[0;32m',     # Green
        logging.WARNING: '\033[0;33m',  # Yellow
        logging.ERROR: '\033[0;31m',    # Red
        logging.CRITICAL: '\033[1;31m', # Bold Red
    }
    RESET = '\033[0m'
    
    def format(self, record: logging.LogRecord) -> str:
        """Format log record with colour coding if terminal supports it."""
        if sys.stdout.isatty():
            colour = self.COLOURS.get(record.levelno, self.RESET)
            record.levelname = f"{colour}{record.levelname}{self.RESET}"
        return super().format(record)


def setup_logging(
    name: str,
    level: int = logging.INFO,
    log_file: Optional[Path] = None,
    use_colours: bool = True
) -> logging.Logger:
    """
    Configure structured logging with consistent format.
    
    Args:
        name: Logger name (typically __name__)
        level: Logging level (default: INFO)
        log_file: Optional path for file logging
        use_colours: Whether to use coloured output (default: True)
    
    Returns:
        Configured logger instance
    
    Example:
        >>> logger = setup_logging(__name__)
        >>> logger.info("Processing started")
        [2025-01-30 10:00:00] [INFO] module_name: Processing started
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Avoid duplicate handlers on repeated calls
    if logger.handlers:
        return logger
    
    # Console handler with colours
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(level)
    
    if use_colours and sys.stdout.isatty():
        console_formatter = ColouredFormatter(
            '[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
    else:
        console_formatter = logging.Formatter(
            '[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
    
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)
    
    # Optional file handler (no colours)
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        file_formatter = logging.Formatter(
            '[%(asctime)s] [%(levelname)s] %(name)s: %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
    
    return logger


def get_logger(name: str) -> logging.Logger:
    """Get or create a logger with default ENos configuration."""
    return setup_logging(name)
