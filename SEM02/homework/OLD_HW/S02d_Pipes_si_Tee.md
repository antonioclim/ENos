# S02_TC03 - Pipes și Tee

> **Sisteme de Operare** | ASE București - CSIE  
> Material de laborator - Seminar 2 (NOU - Redistribuit)

---

> 🚨 **ÎNAINTE DE A ÎNCEPE TEMA**
>
> 1. Descarcă și configurează pachetul `002HWinit` (vezi GHID_STUDENT_RO.md)
> 2. Deschide un terminal și navighează în `~/HOMEWORKS`
> 3. Pornește înregistrarea cu:
>    ```bash
>    python3 record_homework_tui_RO.py
>    ```
>    sau varianta Bash:
>    ```bash
>    ./record_homework_RO.sh
>    ```
> 4. Completează datele cerute (nume, grupă, nr. temă)
> 5. **ABIA APOI** începe să rezolvi cerințele de mai jos

---

## Obiective

La finalul acestui laborator, studentul va fi capabil să:
- Înțeleagă filozofia Unix „Do one thing and do it well"
- Construiască pipeline-uri eficiente cu operatorul `|`
- Folosească `tee` pentru ramificarea output-ului
- Aplice subshell-uri în contexte practice
- Diagnosticheze probleme în pipeline-uri cu `PIPESTATUS`

---


## 2. Operatorul Pipe `|`

### 2.1 Conectare stdout → stdin

```bash
# Pipe standard: stdout (fd 1) → stdin (fd 0)
ls -la | grep ".txt"

# stderr NU trece prin pipe implicit!
ls /nonexistent | wc -l
# Eroarea apare pe ecran, wc primește 0 linii
```

### 2.2 Pipe pentru stderr `|&`

```bash
# Bash 4+: |& trimite și stderr prin pipe
ls /nonexistent |& grep "No such"

# Echivalent cu:
ls /nonexistent 2>&1 | grep "No such"
```

### 2.3 Pipeline-uri Complexe

```bash
# Analiză log-uri - pattern clasic
cat access.log | \
    grep "POST" | \
    awk '{print $1}' | \
    sort | \
    uniq -c | \
    sort -rn | \
    head -10

# Rezultat: Top 10 IP-uri cu cereri POST
```

---

## 3. Comanda `tee` - Ramificarea Output-ului

### 3.1 Conceptul T-Splitter

`tee` scrie simultan la stdout ȘI într-un fișier:

```
                    ┌──► fișier
stdin ──► [tee] ────┤
                    └──► stdout ──► următoarea comandă
```

```bash
# Sintaxă
comanda | tee fisier.txt

# Cu append
comanda | tee -a fisier.txt
```

### 3.2 Cazuri de Utilizare

```bash
# 1. Logging și afișare simultană
./script.sh | tee output.log

# 2. Checkpoint în pipeline lung
cat data.csv | \
    grep "2024" | \
    tee checkpoint1.txt | \
    sort | \
    tee checkpoint2.txt | \
    uniq -c

# 3. Scriere în mai multe fișiere
echo "mesaj" | tee file1.txt file2.txt file3.txt

# 4. Scriere cu sudo (trick clasic)
echo "linie nouă" | sudo tee -a /etc/hosts
```

### 3.3 tee și /dev/null

```bash
# Salvează în fișier, nu afișa
comanda | tee fisier.txt > /dev/null

# Afișează, nu salva (rar util, dar posibil)
comanda | tee /dev/null
```

---

## 4. Subshell-uri și Grupări

### 4.1 Subshell cu `( )`

```bash
# Comenzile din () rulează într-un subshell
(cd /tmp && ls)
pwd  # Suntem tot în directorul original

# Pipeline într-un subshell
(cat file1; cat file2) | sort | uniq
```

### 4.2 Grupare cu `{ }`

```bash
# Grupare FĂRĂ subshell (rulează în shell-ul curent)
{ echo "start"; cat file; echo "end"; } | wc -l

# ATENȚIE: spațiu și ; obligatorii
{ cmd1; cmd2; }   # Corect
{cmd1;cmd2}       # GREȘIT
```

### 4.3 Diferența Practică

```bash
# Cu subshell - variabila nu persistă
(VAR="test"); echo $VAR  # gol

# Cu grupare - variabila persistă
{ VAR="test"; }; echo $VAR  # "test"
```

---

## 5. PIPESTATUS și Diagnosticare

### 5.1 Problema Exit Code în Pipeline

```bash
# Exit code-ul unui pipeline = ultima comandă
false | true | true
echo $?  # 0 (de la ultimul true)

# Dar prima comandă a eșuat!
```

### 5.2 Array-ul PIPESTATUS

```bash
# PIPESTATUS conține exit codes pentru TOATE comenzile
cmd1 | cmd2 | cmd3
echo "${PIPESTATUS[@]}"  # ex: "0 1 0"
echo "${PIPESTATUS[0]}"  # exit code cmd1
echo "${PIPESTATUS[1]}"  # exit code cmd2
echo "${PIPESTATUS[2]}"  # exit code cmd3
```

### 5.3 Verificare Pipeline Complet

```bash
# Pattern pentru verificare
cat file.txt | grep "pattern" | wc -l
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    echo "Eroare la citirea fișierului"
elif [[ ${PIPESTATUS[1]} -ne 0 ]]; then
    echo "Pattern negăsit"
fi
```

### 5.4 set -o pipefail

```bash
# Cu pipefail, pipeline returnează primul exit code non-zero
set -o pipefail

false | true | true
echo $?  # 1 (de la false)

# RECOMANDAT pentru scripturi!
set -euo pipefail
```

---

## 6. Pattern-uri Avansate

### 6.1 Process Substitution `<()` și `>()`

```bash
# <() - tratează output ca fișier
diff <(ls dir1) <(ls dir2)

# Compară output-uri fără fișiere temporare
diff <(sort file1) <(sort file2)

# >() - tratează input ca fișier pentru scriere
tee >(gzip > backup.gz) >(md5sum > checksum.txt)
```

### 6.2 Named Pipes (FIFO)

```bash
# Creare named pipe
mkfifo /tmp/mypipe

# Terminal 1 (citește)
cat /tmp/mypipe

# Terminal 2 (scrie)
echo "mesaj" > /tmp/mypipe

# Cleanup
rm /tmp/mypipe
```

### 6.3 Pipeline cu xargs

```bash
# Combinație puternică: pipe + xargs
find . -name "*.log" | xargs grep "ERROR"

# Cu -I pentru substituție
ls *.txt | xargs -I{} cp {} backup/
```

---

## 7. Best Practices

### 7.1 Eficiență

```bash
# EVITĂ - Useless Use of Cat (UUOC)
cat file | grep pattern  # NU

# PREFERĂ
grep pattern file        # DA

# EVITĂ - Pipe-uri excesive
cat file | sort | uniq  # NU

# PREFERĂ
sort -u file            # DA
```

### 7.2 Debugging Pipeline

```bash
# Adaugă tee pentru inspecție
complex_cmd | tee /dev/stderr | next_cmd

# Sau cu numerotare
cmd1 | nl | cmd2  # Adaugă numere de linie pentru debug
```

### 7.3 Error Handling

```bash
#!/bin/bash
set -euo pipefail

# Pipeline sigur cu logging
process_data() {
    cat "$1" 2>/dev/null | \
        grep -v "^#" | \
        sort | \
        uniq -c | \
        tee "$2"
    
    # Verificare PIPESTATUS
    local status=("${PIPESTATUS[@]}")
    if [[ ${status[0]} -ne 0 ]]; then
        echo "Eroare: fișierul nu există" >&2
        return 1
    fi
}
```

---

## 8. Exerciții Practice

### Exercițiul 1: Pipeline de Bază
Creați un pipeline care:
1. Listează toate fișierele din `/var/log`
2. Filtrează doar fișierele `.log`
3. Numără câte sunt

### Exercițiul 2: Tee pentru Logging
Scrieți o comandă care:
1. Afișează procesele curente
2. Salvează în `procese.txt`
3. Afișează pe ecran doar primele 10

### Exercițiul 3: Analiza cu PIPESTATUS
Scrieți un script care:
1. Citește un fișier
2. Caută un pattern
3. Raportează care pas a eșuat (dacă e cazul)

### Exercițiul 4: Process Substitution
Comparați conținutul sortat a două directoare folosind `diff` și `<()`.

---

## 9. Troubleshooting

| Problemă | Cauză | Soluție |
|----------|-------|---------|
| `Broken pipe` | Comanda din dreapta s-a terminat | Normal pentru `head`, `tail -n` |
| stderr pe ecran | `|` nu redirecționează stderr | Folosește `|&` sau `2>&1 |` |
| Exit code 0 dar erori | Pipeline returnează ultimul | Folosește `set -o pipefail` |
| Date incomplete | Buffer-ing | Adaugă `stdbuf -oL` pentru line-buffered |

---

## Referințe

- `man bash` - secțiunea PIPELINES
- `man tee`
- [GNU Coreutils - tee](https://www.gnu.org/software/coreutils/manual/html_node/tee-invocation.html)
- [Bash Pitfalls - Pipes](https://mywiki.wooledge.org/BashPitfalls)

---

## 📤 Finalizare și Trimitere

După ce ai terminat toate cerințele:

1. **Oprește înregistrarea** tastând:
   ```bash
   STOP_tema
   ```
   sau apasă `Ctrl+D`

2. **Așteaptă** - scriptul va:
   - Genera semnătura criptografică
   - Încărca automat fișierul pe server

3. **Verifică mesajul final**:
   - ✅ `ÎNCĂRCARE REUȘITĂ!` - tema a fost trimisă
   - ❌ Dacă upload-ul eșuează, fișierul `.cast` este salvat local - trimite-l manual mai târziu cu comanda afișată

> ⚠️ **NU modifica fișierul `.cast`** după generare - semnătura devine invalidă!

---

*By Revolvix for OPERATING SYSTEMS class | restricted licence 2017-2030*
