#!/usr/bin/env python3
"""
Unit tests for SEM03 quiz functionality.

Author: ing. dr. Antonio Clim, ASE-CSIE
"""

import pytest
import yaml
from pathlib import Path

QUIZ_PATH = Path(__file__).parent.parent / "formative" / "quiz.yaml"


class TestQuizStructure:
    """Verify quiz.yaml structure and content."""
    
    @pytest.fixture
    def quiz_data(self) -> dict:
        """Load quiz data."""
        with open(QUIZ_PATH) as f:
            return yaml.safe_load(f)
    
    def test_quiz_file_exists(self) -> None:
        """Quiz file must exist."""
        assert QUIZ_PATH.exists()
    
    def test_quiz_has_questions(self, quiz_data: dict) -> None:
        """Quiz must have questions."""
        assert "questions" in quiz_data
        assert len(quiz_data["questions"]) > 0
    
    def test_questions_have_required_fields(self, quiz_data: dict) -> None:
        """Each question must have required fields."""
        required = {"id", "type", "bloom", "text", "options", "correct"}
        for i, q in enumerate(quiz_data["questions"]):
            missing = required - set(q.keys())
            assert not missing, f"Question {i+1} ({q.get('id', 'unknown')}) missing: {missing}"
    
    def test_bloom_levels_valid(self, quiz_data: dict) -> None:
        """Bloom levels must be valid."""
        valid_levels = {"remember", "understand", "apply", "analyse", "evaluate", "create"}
        for i, q in enumerate(quiz_data["questions"]):
            level = q.get("bloom", "").lower()
            assert level in valid_levels, f"Question {i+1} has invalid bloom level: {level}"
    
    def test_correct_index_valid(self, quiz_data: dict) -> None:
        """Correct answer index must be within options range."""
        for i, q in enumerate(quiz_data["questions"]):
            options = q.get("options", [])
            correct = q.get("correct")
            if isinstance(correct, int):
                assert 0 <= correct < len(options), \
                    f"Question {i+1} ({q.get('id')}) has invalid correct index: {correct}"
    
    def test_metadata_exists(self, quiz_data: dict) -> None:
        """Quiz must have metadata section."""
        assert "metadata" in quiz_data
        assert "seminar" in quiz_data["metadata"]
        assert "title" in quiz_data["metadata"]


class TestQuizContent:
    """Verify quiz content quality."""
    
    @pytest.fixture
    def quiz_data(self) -> dict:
        """Load quiz data."""
        with open(QUIZ_PATH) as f:
            return yaml.safe_load(f)
    
    def test_questions_have_explanations(self, quiz_data: dict) -> None:
        """Questions should have explanations for pedagogical value."""
        questions_with_explanations = sum(
            1 for q in quiz_data["questions"] if q.get("explanation")
        )
        total = len(quiz_data["questions"])
        # At least 80% should have explanations
        assert questions_with_explanations >= total * 0.8, \
            f"Only {questions_with_explanations}/{total} questions have explanations"
    
    def test_bloom_distribution(self, quiz_data: dict) -> None:
        """Verify Bloom taxonomy distribution is reasonable."""
        bloom_counts: dict = {}
        for q in quiz_data["questions"]:
            level = q.get("bloom", "unknown").lower()
            bloom_counts[level] = bloom_counts.get(level, 0) + 1
        
        # Should have at least 3 different Bloom levels
        assert len(bloom_counts) >= 3, \
            f"Quiz should cover multiple Bloom levels, found: {list(bloom_counts.keys())}"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
