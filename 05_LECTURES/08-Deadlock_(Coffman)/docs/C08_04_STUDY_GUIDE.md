<!-- RO: TRADUS ȘI VERIFICAT -->
# Study Guide — Deadlock

## Coffman Conditions (all necessary)
1. **Mutual Exclusion**: Non-shareable resource
2. **Hold and Wait**: Hold and wait
3. **No Preemption**: Cannot be forcibly taken
4. **Circular Wait**: Waiting cycle

## Strategies

### Prevention
- Eliminate one of the conditions
- E.g.: Global resource ordering → eliminates circular wait

### Avoidance (Banker)
- Check safe state before allocation
- Requires a priori knowledge of requirements

### Detection + Recovery
- Allow deadlock
- Detect periodically (RAG/algorithm)
- Recovery: kill process or rollback
