# Software similarity: local evidence and external tools

MOSS and JPlag compare source material. They do not determine why it is similar. Numerical cutoffs and interview demeanour are not calibrated proof of misconduct or AI authorship. Review highlighted code, required templates, ordinary idioms, task constraints, cited sources and the student's explanation under the approved assessment process.

## MOSS

The [official Stanford service page](https://theory.stanford.edu/~aiken/moss/) lists supported languages; Bash is absent. ENos rejects a `bash` route. Python/C/Java source can use an explicitly chosen supported adapter; using another lexer for Bash requires a separately justified method and validation, not an automatic substitution.

For a separately authorised account request, the official registration body is:

```text
registeruser
mail your-authorised-address@example.org
```

The supplied account-specific client is not bundled. Keep its account information out of public commits. `run_moss.sh` prints a local plan by default, accepts explicit base files and preserves file names in its argument array. Only `--send` runs the client. No email, registration or upload is performed by this documentation workflow.

MOSS reports contain submitted code and are accessible to holders of the report URL. The service describes deletion typically after 14 days, sometimes earlier; this is not a retention guarantee. Decide disclosure, permitted data, retention and access before upload. Similarity does not establish an academic offence; Stanford explicitly requires human interpretation.

## JPlag: pinned example contract

This example is pinned to **JPlag 6.2.0 / JDK 21**, as recorded by the [official release](https://github.com/jplag/JPlag/releases/tag/v6.2.0). Obtain the release JAR through the official channel in an authorised setup, record its SHA-256 and run its help locally. Do not replace it with an unreviewed `latest` JAR or image.

```bash
java -version
java -jar jplag-6.2.0-jar-with-dependencies.jar --help
# Explicit local Python-language example, after verifying that release's help:
java -jar jplag-6.2.0-jar-with-dependencies.jar --mode run \
    -l python3 -r review.jplag -bc /path/to/base /path/to/submissions
```

The current [official CLI documentation](https://github.com/jplag/JPlag/wiki/1.-How-to-Use-JPlag) defines `-r` as a result **file**, `.jplag` as the report extension and `--mode run` as comparison without launching the viewer. The language inventory has no Bash parser. A deliberate text comparison is a weaker, different method; choose and calibrate it explicitly. No `jplag/jplag:latest` image availability, native JAR execution or universal offline behaviour is asserted here. Inspect version-check/network behaviour of the selected release in the target environment.

## Interpretation and workflow

Use [the local adapter](RUNhere.md) first on owned synthetic fixtures, retain exact tool versions and input hashes, then review actual matched passages. Keep analysis completeness separate from absence of observations. A zero-match completed run establishes only what that method searched. A failure, unsupported language or empty corpus establishes no all-clear.

An oral explanation can demonstrate current understanding. Nervousness, English fluency, defensive demeanour or a code style change do not identify a source or prove misconduct. Use observable task-specific prompts, record the answer and allow the student to explain sources and collaboration. Any penalty, data upload or institutional referral remains subject to the author's approved process; this kit does not invent that policy.

## Decision still required

Choose local-only analysis or an institutionally approved external service. Local-only work reduces disclosure but still needs access/retention rules; external analysis adds third-party processing and report-sharing consequences. Recommendation: retain local descriptive review until the institution and author define permitted data, access and retention, then validate the exact selected language/tool/version with known positive and negative fixtures.
