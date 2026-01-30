# Changelog - SEM03 System Administration

All notable changes for this seminar are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.2.0] - 2025-01-29

### Added
- `quiz_runner.py` - finally! Students had been asking for two semesters for an 
  interactive version instead of that JSON file nobody ever opened
- `.shellcheckrc` with adapted rules - got tired of explaining why we have 
  intentional warnings in demos
- Verification Challenges section in homework - anti-ChatGPT measures
- Trap questions in quiz.yaml - the "obvious" answer is wrong
- Code Archaeology exercise - debugging legacy code rather than generating new
- Reflection prompts in Self-Assessment - genuine metacognitive questions
- Lessons Learnt in README - what worked and what did not plus student feedback
- Troubleshooting for instructors - the weird cases I have encountered

### Changed
- S03_00 renamed for consistency with other seminars
- Instructor Guide: added personal notes from classroom experience
- LLM-Aware Exercises: strengthened with exercises that cannot be solved with AI alone
- Validator: more detailed comments and improved error handling
- README: added ASE-specific context and correlations with other courses

### Removed
- Duplicate RO/EN files from homework/ (kept only English version)
- `__pycache__/` - should not have been in the archive in the first place

### Lessons Learnt
Feedback from cohort 23 was brutal but useful:
> "The LLM exercises are fine but I can still cheat anyway"

So I added practical verifications: screenshots with timestamp, 
live debugging at the lab and oral explanations. Let us see how they cheat now.

---

## [1.1.0] - 2025-01-15

### Added
- SVG diagrams in `docs/images/` - permissions_matrix.svg was a hit
- Structure aligned with ENos convention (homework, tests and presentations)
- PP-06 and PP-07 in lo_traceability.md
- British English consistent throughout (yes it matters at academic level)

### Changed  
- Makefile adapted to new directory structure
- Minor spelling fixes

### Note
Abandoned the idea of including ACL exercises. 
Too much for semester 3 as students barely digested chmod.
Perhaps for an optional advanced seminar.

---

## [1.0.0] - 2025-01-08

### First Stable Version
- 4 complete modules: find/xargs, getopts, permissions and cron
- Brown & Wilson framework integrated
- Tested on Ubuntu 24.04 LTS in the Dorobanti lab
- 35+ misconceptions documented from previous sessions

### Known Issues
- Cron demo does not work in WSL without `sudo service cron start`
- Some students have macOS and complain that find is different
  (it is not a bug but a feature - GNU vs BSD)

---

## [0.9.0] - 2024-12-20 (internal beta)

### For Testing
- Drafts for all documents
- Functional scripts but without polish
- Tested only on my machine

### TODO for v1.0
- [x] Peer Instruction questions
- [x] Parsons Problems  
- [x] LLM-aware exercises
- [x] Complete validator
- [x] Python autograder

---

## Development Notes

### Why This Structure?
Tried several variants before landing here:
1. One large PDF - nobody read it
2. Separate files without prefix - chaos when sorting
3. Current structure with S03_XX_ - works

### Versioning Conventions
- MAJOR: complete restructure or breaking changes
- MINOR: new content and significant improvements  
- PATCH: bugfixes, typos and minor adjustments

### How to Contribute
Open an issue on GitHub or send me an email directly.
Pull requests are welcome but go through review.

---

*Maintained by ing. dr. Antonio Clim | ASE-CSIE Bucharest*
