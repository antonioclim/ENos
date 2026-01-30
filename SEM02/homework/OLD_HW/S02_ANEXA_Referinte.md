# S02_ANEXA - Referințe Seminar 2 (Redistribuit)

> **Sisteme de Operare** | ASE București - CSIE  
> Material suplimentar

---

## Diagrame ASCII Suplimentare

### Fluxul de Date cu Pipe-uri

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PIPELINE: cat file | grep error | wc -l      │
└──────────────────────────────────────────────────────────────────────┘

  ┌─────────┐      PIPE       ┌─────────────┐      PIPE       ┌────────┐
  │   cat   │ ──────────────► │    grep     │ ──────────────► │   wc   │
  │  file   │    stdout│stdin │   error     │    stdout│stdin │   -l   │
  └─────────┘                 └─────────────┘                 └────────┘
       │                            │                              │
       │                            │                              │
       ▼                            ▼                              ▼
  Citește tot                 Filtrează linii              Numără linii
  conținutul                  cu "error"                   rămase
  din file

  DETALIU TEHNIC:
  ┌────────────────────────────────────────────────────────────────────┐
  │  Proces 1 (cat)           Proces 2 (grep)         Proces 3 (wc)   │
  │  ┌─────────────┐          ┌─────────────┐         ┌─────────────┐ │
  │  │ stdin  = 0 │          │ stdin  = 0 │◄────────│ stdin  = 0 │ │
  │  │ stdout = 1 │──────────►│ stdout = 1 │──────────►│ stdout = 1 │ │
  │  │ stderr = 2 │          │ stderr = 2 │         │ stderr = 2 │ │
  │  └─────────────┘          └─────────────┘         └─────────────┘ │
  │       │                        │                        │        │
  │       │        KERNEL PIPE BUFFER (64KB default)        │        │
  │       └────────────────────────┴────────────────────────┘        │
  └────────────────────────────────────────────────────────────────────┘
```

### Operatori de Control

```
┌──────────────────────────────────────────────────────────────────────┐
│                      OPERATORI DE CONTROL BASH                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 ; cmd2              SECVENȚIAL                                │
│  ┌─────┐     ┌─────┐                                                │
│  │cmd1 │ ──► │cmd2 │     Execută cmd2 ÎNTOTDEAUNA după cmd1        │
│  └─────┘     └─────┘     (indiferent de exit code)                  │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 && cmd2             AND (SHORT-CIRCUIT)                       │
│  ┌─────┐                                                            │
│  │cmd1 │──┬── exit 0 ──► ┌─────┐                                    │
│  └─────┘  │              │cmd2 │  Execută cmd2 DOAR dacă cmd1 OK    │
│           │              └─────┘                                    │
│           └── exit ≠0 ──► STOP                                      │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 || cmd2             OR (SHORT-CIRCUIT)                        │
│  ┌─────┐                                                            │
│  │cmd1 │──┬── exit 0 ──► STOP                                       │
│  └─────┘  │                                                         │
│           └── exit ≠0 ──► ┌─────┐                                   │
│                           │cmd2 │  Execută cmd2 DOAR dacă cmd1 FAIL │
│                           └─────┘                                   │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd &                    BACKGROUND                                 │
│  ┌─────┐                                                            │
│  │ cmd │ ──► Rulează în background, shell continuă imediat          │
│  └─────┘     PID afișat: [1] 12345                                  │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  cmd1 | cmd2              PIPE                                       │
│  ┌─────┐     ┌─────┐                                                │
│  │cmd1 │────►│cmd2 │     stdout(cmd1) → stdin(cmd2)                 │
│  └─────┘     └─────┘     Rulează SIMULTAN                           │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Redirecționare I/O Completă

```
┌──────────────────────────────────────────────────────────────────────┐
│                      FILE DESCRIPTORS                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐                                                    │
│  │   PROCES    │                                                    │
│  ├─────────────┤                                                    │
│  │ FD 0: stdin │◄──── tastatura / pipe / fișier                     │
│  │ FD 1: stdout│────► terminal / pipe / fișier                      │
│  │ FD 2: stderr│────► terminal / fișier                             │
│  │ FD 3+: alte │────► fișiere deschise explicit                     │
│  └─────────────┘                                                    │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                      REDIRECȚIONĂRI                                  │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STDOUT (FD 1):                                                      │
│  cmd > file       Suprascrie fișierul                               │
│  cmd >> file      Adaugă la fișier                                  │
│  cmd 1> file      Explicit FD 1                                      │
│                                                                      │
│  STDERR (FD 2):                                                      │
│  cmd 2> file      Redirecționează erorile                           │
│  cmd 2>> file     Adaugă erorile                                    │
│  cmd 2>&1         Stderr → Stdout                                   │
│                                                                      │
│  AMBELE:                                                             │
│  cmd &> file      Stdout + Stderr → file (Bash)                     │
│  cmd > file 2>&1  Echivalent (portabil)                             │
│                                                                      │
│  STDIN (FD 0):                                                       │
│  cmd < file       Citește din fișier                                │
│  cmd << EOF       Here document                                      │
│  cmd <<< "str"    Here string                                       │
│                                                                      │
│  AVANSAT:                                                            │
│  cmd 3> file      Deschide FD 3 pentru scriere                      │
│  cmd 3< file      Deschide FD 3 pentru citire                       │
│  exec 3>&-        Închide FD 3                                      │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Exerciții Rezolvate Complet

### Exercițiul 1: Pipeline Complet pentru Analiză Log

**Cerință:** Analizează un fișier de log pentru a găsi top 5 IP-uri cu cele mai multe erori.

```bash
# Creează un log de test
cat > /tmp/access.log << 'EOF'
192.168.1.100 - - [10/Jan/2025:10:00:01] "GET /page1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:00:02] "GET /page2" 404 567
192.168.1.100 - - [10/Jan/2025:10:00:03] "GET /page3" 500 890
10.0.0.50 - - [10/Jan/2025:10:00:04] "GET /page1" 200 1234
192.168.1.101 - - [10/Jan/2025:10:00:05] "POST /api" 500 234
192.168.1.100 - - [10/Jan/2025:10:00:06] "GET /page1" 404 567
10.0.0.50 - - [10/Jan/2025:10:00:07] "GET /page2" 500 890
192.168.1.101 - - [10/Jan/2025:10:00:08] "GET /page3" 500 1234
192.168.1.102 - - [10/Jan/2025:10:00:09] "GET /page1" 200 567
192.168.1.100 - - [10/Jan/2025:10:00:10] "GET /page2" 500 890
EOF

# Soluție pas cu pas:

# Pas 1: Filtrează doar erorile (status 4xx și 5xx)
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log
# Output: 7 linii cu erori

# Pas 2: Extrage doar IP-urile (primul câmp)
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1
# Output: IP-uri, câte unul pe linie

# Pas 3: Sortează pentru a grupa IP-urile identice
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort

# Pas 4: Numără apariițile fiecărui IP
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort | uniq -c

# Pas 5: Sortează descrescător după număr
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn

# Pas 6: Ia doar primele 5
grep -E ' (4[0-9]{2}|5[0-9]{2}) ' /tmp/access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -5

# Output final:
# 3 192.168.1.100
# 3 192.168.1.101
# 1 10.0.0.50

# Cleanup
rm /tmp/access.log
```

### Exercițiul 2: Script cu Bucle și Condiții

**Cerință:** Creează un script care procesează fișiere și raportează statistici.

```bash
#!/bin/bash
# file_stats.sh - Analizează fișierele dintr-un director

# Verificare argumente
if [ $# -eq 0 ]; then
    echo "Utilizare: $0 <director>"
    exit 1
fi

DIR="$1"

# Verificare director
if [ ! -d "$DIR" ]; then
    echo "Eroare: '$DIR' nu este un director valid"
    exit 1
fi

# Inițializare contori
total_files=0
total_dirs=0
total_size=0
declare -A ext_count  # Array asociativ pentru extensii (Bash 4+)

# Procesare recursivă
while IFS= read -r -d '' item; do
    if [ -f "$item" ]; then
        ((total_files++))
        
        # Dimensiune
        size=$(stat -c %s "$item" 2>/dev/null || echo 0)
        ((total_size += size))
        
        # Extensie
        filename=$(basename "$item")
        if [[ "$filename" == *.* ]]; then
            ext="${filename##*.}"
            ((ext_count[$ext]++))
        else
            ((ext_count["no_ext"]++))
        fi
        
    elif [ -d "$item" ]; then
        ((total_dirs++))
    fi
done < <(find "$DIR" -print0 2>/dev/null)

# Raport
echo "=== Raport pentru: $DIR ==="
echo ""
echo "Total fișiere: $total_files"
echo "Total directoare: $total_dirs"
echo "Dimensiune totală: $(numfmt --to=iec $total_size 2>/dev/null || echo "$total_size bytes")"
echo ""
echo "Distribuție pe extensii:"
for ext in "${!ext_count[@]}"; do
    printf "  .%-10s %d fișiere\n" "$ext" "${ext_count[$ext]}"
done | sort -t: -k2 -rn
```

### Exercițiul 3: Utilizare Variabile și Substituție

**Cerință:** Demonstrează toate tipurile de substituție și manipulare variabile.

```bash
#!/bin/bash
# variable_demo.sh - Demonstrație completă variabile

# === DEFINIRE VARIABILE ===
name="John Doe"
number=42
path="/home/user/documents/report.txt"
empty=""

echo "=== Variabile de Bază ==="
echo "name: $name"
echo "number: $number"
echo "path: $path"

echo ""
echo "=== Manipulare String ==="

# Lungime
echo "Lungime name: ${#name}"              # 8

# Substring
echo "Substring path[0:5]: ${path:0:5}"    # /home
echo "Substring path[6:]: ${path:6}"       # user/documents/report.txt

# Înlocuire
echo "Înlocuire prima: ${path/user/admin}" # /home/admin/documents/report.txt
echo "Înlocuire toate: ${path//o/O}"       # /hOme/user/dOcuments/repOrt.txt

# Ștergere pattern (de la început)
echo "Fără prefix: ${path#*/}"             # home/user/documents/report.txt
echo "Fără tot până la /: ${path##*/}"     # report.txt (basename)

# Ștergere pattern (de la sfârșit)
echo "Fără sufix: ${path%/*}"              # /home/user/documents (dirname)
echo "Fără tot de la /: ${path%%/*}"       # (gol, începe cu /)

echo ""
echo "=== Valori Default ==="

# ${var:-default} - folosește default dacă var e gol sau nedefinită
echo "Cu default: ${undefined:-valoare_default}"
echo "Empty cu default: ${empty:-gol_inlocuit}"

# ${var:=default} - setează și returnează default
echo "Setare default: ${newvar:=setat_acum}"
echo "newvar este acum: $newvar"

# ${var:+alternate} - folosește alternate doar dacă var e setată
echo "Dacă setat: ${name:+SETAT}"
echo "Dacă gol: ${empty:+SETAT}"

# ${var:?error} - eroare dacă var e gol
# ${undefined:?Variabila trebuie setată} # Ar produce eroare

echo ""
echo "=== Case Modification (Bash 4+) ==="
text="Hello World"
echo "UPPERCASE: ${text^^}"                # HELLO WORLD
echo "lowercase: ${text,,}"                # hello world
echo "First upper: ${text^}"               # Hello World
echo "First lower: ${text,}"               # hello World

echo ""
echo "=== Arrays ==="
fruits=("apple" "banana" "cherry" "date")

echo "Toate elementele: ${fruits[@]}"
echo "Primul element: ${fruits[0]}"
echo "Lungime array: ${#fruits[@]}"
echo "Indici: ${!fruits[@]}"
echo "Slice [1:2]: ${fruits[@]:1:2}"

# Adăugare
fruits+=("elderberry")
echo "După adăugare: ${fruits[@]}"

# Iterare
echo "Iterare:"
for fruit in "${fruits[@]}"; do
    echo "  - $fruit"
done

echo ""
echo "=== Command Substitution ==="
current_date=$(date +%Y-%m-%d)
file_count=$(ls -1 | wc -l)
echo "Data: $current_date"
echo "Fișiere în dir curent: $file_count"

echo ""
echo "=== Arithmetic ==="
a=10
b=3
echo "a + b = $((a + b))"
echo "a - b = $((a - b))"
echo "a * b = $((a * b))"
echo "a / b = $((a / b))"
echo "a % b = $((a % b))"
echo "a ** 2 = $((a ** 2))"

# Increment/Decrement
((a++))
echo "a++ = $a"
```

---

## Referințe Utile

### Tabel Filtre Comune

| Comandă | Funcție | Exemplu |
|---------|---------|---------|
| `sort` | Sortează linii | `sort -n -r file` |
| `uniq` | Elimină duplicate | `sort file \| uniq -c` |
| `cut` | Extrage coloane | `cut -d: -f1 /etc/passwd` |
| `tr` | modifică caractere | `tr 'a-z' 'A-Z'` |
| `wc` | Numără linii/cuvinte | `wc -l file` |
| `head` | Primele N linii | `head -20 file` |
| `tail` | Ultimele N linii | `tail -f log` (follow) |
| `tee` | Duplică output | `cmd \| tee file` |
| `xargs` | Construiește argumente | `find . \| xargs rm` |

---
*Material suplimentar pentru cursul de Sisteme de Operare | ASE București - CSIE*
-e 

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
