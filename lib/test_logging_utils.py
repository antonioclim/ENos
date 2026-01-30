#!/usr/bin/env python3
"""
test_logging_utils.py — Comprehensive Tests for ENos Logging Utilities

Operating Systems | ASE Bucharest — CSIE
Author: ing. dr. Antonio Clim
Version: 1.0 | January 2025

Run with: pytest -v test_logging_utils.py
"""

import logging
import sys
import tempfile
from io import StringIO
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest

# Import the module under test
from logging_utils import setup_logging, get_logger, ColouredFormatter


# =============================================================================
# Test Fixtures
# =============================================================================

@pytest.fixture(autouse=True)
def reset_logging():
    """Reset logging state before each test to prevent handler accumulation."""
    # Store original handlers
    root_logger = logging.getLogger()
    original_handlers = root_logger.handlers[:]
    
    yield
    
    # Clean up all loggers created during tests
    loggers_to_clean = [name for name in logging.Logger.manager.loggerDict 
                        if name.startswith('test_')]
    for logger_name in loggers_to_clean:
        logger = logging.getLogger(logger_name)
        logger.handlers.clear()
        logger.setLevel(logging.NOTSET)


@pytest.fixture
def temp_log_file(tmp_path):
    """Provide a temporary log file path."""
    return tmp_path / "test_output.log"


# =============================================================================
# TestColouredFormatter
# =============================================================================

class TestColouredFormatter:
    """Test suite for the ColouredFormatter class."""
    
    def test_colour_mapping_exists_for_all_standard_levels(self):
        """Verify colour mappings exist for DEBUG, INFO, WARNING, ERROR, CRITICAL."""
        formatter = ColouredFormatter('[%(levelname)s] %(message)s')
        
        expected_levels = [
            logging.DEBUG,
            logging.INFO,
            logging.WARNING,
            logging.ERROR,
            logging.CRITICAL
        ]
        
        for level in expected_levels:
            assert level in formatter.COLOURS, f"Missing colour for level {level}"
    
    def test_reset_code_is_defined(self):
        """Verify RESET ANSI code is defined."""
        formatter = ColouredFormatter('[%(levelname)s] %(message)s')
        assert hasattr(formatter, 'RESET')
        assert formatter.RESET == '\033[0m'
    
    def test_format_without_tty_produces_plain_output(self):
        """When stdout is not a TTY, output should not contain ANSI codes."""
        formatter = ColouredFormatter('[%(levelname)s] %(message)s')
        record = logging.LogRecord(
            name='test_logger',
            level=logging.INFO,
            pathname='test.py',
            lineno=1,
            msg='Test message',
            args=(),
            exc_info=None
        )
        
        with patch.object(sys.stdout, 'isatty', return_value=False):
            formatted = formatter.format(record)
        
        # Should not contain ANSI escape codes
        assert '\033[' not in formatted
        assert 'INFO' in formatted
        assert 'Test message' in formatted
    
    def test_format_with_tty_produces_coloured_output(self):
        """When stdout is a TTY, output should contain ANSI colour codes."""
        formatter = ColouredFormatter('[%(levelname)s] %(message)s')
        record = logging.LogRecord(
            name='test_logger',
            level=logging.ERROR,
            pathname='test.py',
            lineno=1,
            msg='Error occurred',
            args=(),
            exc_info=None
        )
        
        with patch.object(sys.stdout, 'isatty', return_value=True):
            formatted = formatter.format(record)
        
        # Should contain ANSI escape codes for red (ERROR)
        assert '\033[0;31m' in formatted or '\033[' in formatted
        assert 'Error occurred' in formatted


# =============================================================================
# TestSetupLogging
# =============================================================================

class TestSetupLogging:
    """Test suite for the setup_logging function."""
    
    def test_returns_logger_instance(self):
        """setup_logging should return a logging.Logger instance."""
        logger = setup_logging('test_returns_instance')
        assert isinstance(logger, logging.Logger)
    
    def test_logger_has_correct_name(self):
        """Logger should have the exact name passed to setup_logging."""
        logger = setup_logging('test_correct_name_12345')
        assert logger.name == 'test_correct_name_12345'
    
    def test_default_level_is_info(self):
        """Default logging level should be INFO when not specified."""
        logger = setup_logging('test_default_info_level')
        assert logger.level == logging.INFO
    
    def test_custom_level_debug(self):
        """Custom DEBUG level should be applied correctly."""
        logger = setup_logging('test_debug_level', level=logging.DEBUG)
        assert logger.level == logging.DEBUG
    
    def test_custom_level_warning(self):
        """Custom WARNING level should be applied correctly."""
        logger = setup_logging('test_warning_level', level=logging.WARNING)
        assert logger.level == logging.WARNING
    
    def test_custom_level_error(self):
        """Custom ERROR level should be applied correctly."""
        logger = setup_logging('test_error_level', level=logging.ERROR)
        assert logger.level == logging.ERROR
    
    def test_no_duplicate_handlers_on_repeated_calls(self):
        """Calling setup_logging twice with same name should not add duplicate handlers."""
        logger1 = setup_logging('test_no_duplicates_unique')
        handler_count1 = len(logger1.handlers)
        
        # Call again with same name
        logger2 = setup_logging('test_no_duplicates_unique')
        handler_count2 = len(logger2.handlers)
        
        assert logger1 is logger2, "Should return the same logger instance"
        assert handler_count1 == handler_count2, "Handler count should not increase"
    
    def test_has_stream_handler(self):
        """Logger should have at least one StreamHandler for console output."""
        logger = setup_logging('test_stream_handler')
        stream_handlers = [h for h in logger.handlers 
                          if isinstance(h, logging.StreamHandler)]
        assert len(stream_handlers) >= 1
    
    def test_file_handler_created_when_log_file_specified(self, temp_log_file):
        """FileHandler should be added when log_file parameter is provided."""
        logger = setup_logging('test_file_handler', log_file=temp_log_file)
        file_handlers = [h for h in logger.handlers 
                        if isinstance(h, logging.FileHandler)]
        assert len(file_handlers) >= 1
    
    def test_file_handler_writes_to_correct_file(self, temp_log_file):
        """FileHandler should write logs to the specified file."""
        logger = setup_logging('test_file_write', log_file=temp_log_file)
        logger.info("Test message for file")
        
        # Flush handlers
        for handler in logger.handlers:
            handler.flush()
        
        assert temp_log_file.exists()
        content = temp_log_file.read_text()
        assert "Test message for file" in content
    
    def test_file_log_does_not_contain_ansi_codes(self, temp_log_file):
        """File output should never contain ANSI colour codes."""
        logger = setup_logging('test_file_no_ansi', log_file=temp_log_file)
        logger.error("Error message")
        
        for handler in logger.handlers:
            handler.flush()
        
        content = temp_log_file.read_text()
        assert '\033[' not in content, "File should not contain ANSI codes"
    
    def test_log_format_includes_timestamp(self, temp_log_file):
        """Log format should include timestamp in ISO-like format."""
        logger = setup_logging('test_timestamp', log_file=temp_log_file)
        logger.info("Timestamp test")
        
        for handler in logger.handlers:
            handler.flush()
        
        content = temp_log_file.read_text()
        # Check for date pattern like [2025-01-30
        import re
        assert re.search(r'\[\d{4}-\d{2}-\d{2}', content), "Should contain date"
    
    def test_log_format_includes_level_name(self, temp_log_file):
        """Log format should include the level name."""
        logger = setup_logging('test_level_name', log_file=temp_log_file)
        logger.warning("Level test")
        
        for handler in logger.handlers:
            handler.flush()
        
        content = temp_log_file.read_text()
        assert 'WARNING' in content
    
    def test_log_format_includes_logger_name(self, temp_log_file):
        """Log format should include the logger name."""
        logger = setup_logging('test_logger_name_in_format', log_file=temp_log_file)
        logger.info("Name test")
        
        for handler in logger.handlers:
            handler.flush()
        
        content = temp_log_file.read_text()
        assert 'test_logger_name_in_format' in content
    
    def test_use_colours_false_disables_colour_formatter(self):
        """Setting use_colours=False should use plain Formatter."""
        logger = setup_logging('test_no_colours', use_colours=False)
        
        # Check that no handler uses ColouredFormatter
        for handler in logger.handlers:
            if isinstance(handler, logging.StreamHandler):
                assert not isinstance(handler.formatter, ColouredFormatter)


# =============================================================================
# TestGetLogger
# =============================================================================

class TestGetLogger:
    """Test suite for the get_logger convenience function."""
    
    def test_returns_logger_instance(self):
        """get_logger should return a logging.Logger instance."""
        logger = get_logger('test_get_returns_instance')
        assert isinstance(logger, logging.Logger)
    
    def test_returns_configured_logger(self):
        """get_logger should return a logger with INFO level (default)."""
        logger = get_logger('test_get_configured')
        assert logger.level == logging.INFO
    
    def test_same_name_returns_same_logger(self):
        """Calling get_logger twice with same name should return same instance."""
        logger1 = get_logger('test_get_same_instance')
        logger2 = get_logger('test_get_same_instance')
        assert logger1 is logger2
    
    def test_different_names_return_different_loggers(self):
        """Different names should return different logger instances."""
        logger1 = get_logger('test_get_different_1')
        logger2 = get_logger('test_get_different_2')
        assert logger1 is not logger2
        assert logger1.name != logger2.name


# =============================================================================
# Integration Tests
# =============================================================================

class TestLoggingIntegration:
    """Integration tests for complete logging workflows."""
    
    def test_complete_workflow_console_and_file(self, temp_log_file):
        """Test complete logging workflow with both console and file output."""
        logger = setup_logging(
            'test_integration_workflow',
            level=logging.DEBUG,
            log_file=temp_log_file,
            use_colours=False
        )
        
        # Log at all levels
        logger.debug("Debug message")
        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")
        
        # Flush
        for handler in logger.handlers:
            handler.flush()
        
        # Verify file contains all messages
        content = temp_log_file.read_text()
        assert "Debug message" in content
        assert "Info message" in content
        assert "Warning message" in content
        assert "Error message" in content
        assert "Critical message" in content
    
    def test_exception_logging(self, temp_log_file):
        """Test that exceptions are properly logged with traceback."""
        logger = setup_logging('test_exception', log_file=temp_log_file)
        
        try:
            raise ValueError("Test exception")
        except ValueError:
            logger.exception("An error occurred")
        
        for handler in logger.handlers:
            handler.flush()
        
        content = temp_log_file.read_text()
        assert "An error occurred" in content
        assert "ValueError" in content
        assert "Test exception" in content


# =============================================================================
# Entry Point
# =============================================================================

if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
