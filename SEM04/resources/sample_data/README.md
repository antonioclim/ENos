# Deterministic demonstration fixtures

These small synthetic datasets support `SEM04/tests/test_*.sh`. They contain no
student records or empirical observations. They are separate from the personalised
homework data and from the `demo_sem4/data` schema used by the autograder.

Run `bash SEM04/tests/run_all_tests.sh` from any directory. The checks verify the
included grep, sed and awk examples against these fixed inputs. They do not assess
a student submission or constitute acceptance of the full teaching environment.
