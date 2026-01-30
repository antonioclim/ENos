# Study Guide — Memory Management P1

## Key Concepts

### Paging
- Logical memory: pages (fixed size)
- Physical memory: frames (same size)
- Page Table: page → frame mapping
- Eliminates external fragmentation

### Segmentation
- Logical units: code, data, stack
- Variable sizes
- External fragmentation possible

### Page Table Entry (PTE)
- Frame number
- Valid/invalid bit
- Protection bits (rwx)
- Dirty bit
- Reference bit

## Formulae
- Offset bits = log₂(page_size)
- Page number bits = address_bits - offset_bits
- Max pages = 2^(page_number_bits)
