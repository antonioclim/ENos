<!-- RO: TRADUS ȘI VERIFICAT -->
# Concept Map — Filesystem P2

```
             ┌─────────────────────┐
             │  SPACE ALLOCATION   │
             └──────────┬──────────┘
                        │
    ┌───────────────────┼───────────────────┐
    ▼                   ▼                   ▼
┌─────────┐      ┌─────────────┐      ┌─────────┐
│Contiguous│     │   Linked    │      │ Indexed │
└────┬────┘      └──────┬──────┘      └────┬────┘
     │                  │                  │
Pro: Fast        Pro: No ext       Pro: Both
     sequential        frag              benefits
Con: Ext frag    Con: Random      Con: Index
     Compaction        access slow       overhead

```

## Journaling: full-data redo teaching model

1. Write a transaction record containing the intended metadata and data to the journal.
2. Make its records durable, then make the commit record durable.
3. Checkpoint the committed changes to their home locations.
4. Reclaim journal space only after the relevant checkpoint is durable.

A crash **before a valid durable commit** leaves this transaction uncommitted: recovery discards its records and does not replay them. A crash **after commit but before checkpoint** replays the committed redo records, idempotently, to complete the home updates. An incomplete checkpoint is not an incomplete transaction.

For example, a logged create operation without its commit leaves the file absent. The same record with a durable commit reconstructs its inode, directory entry, allocation bitmap and data after a crash. The interactive journal demonstration uses this explicit full-data model. Metadata-only journaling provides different guarantees for file contents; ordering modes and storage flush semantics must be stated separately.

Reference: [Linux ext4 journal documentation](https://docs.kernel.org/filesystems/ext4/journal.html).
