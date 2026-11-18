# A02: Interactive Shell Extension

> **Level:** ADVANCED | **Estimated time:** 40-50 hours | **Components:** Bash + C

---

## Description

Extension for interactive shell: advanced command completion, syntax highlighting, intelligent history search and command suggestions. The C component provides efficient parsing and libreadline integration.

---

## Why C?

The C component provides:
- **Fast parsing** for real-time syntax highlighting
- **Trie data structure** for efficient autocomplete
- **Readline integration** for professional input handling
- **Performance** - processing without perceptible lag

---

## Learning Objectives

- Libreadline and custom completions
- Parsing and tokenisation (simple lexer)
- Trie for prefix matching
- ANSI escape codes for colours
- Terminal I/O and raw mode

---

## Functional Requirements

### Mandatory (Bash)
1. **Custom prompt** - informative (user, host, dir, git branch)
2. **Aliases and functions** - management and persistence
3. **History enhancement** - search, deduplication
4. **Directory bookmarks** - quick jump to locations
5. **Command hooks** - pre/post execution
6. **Environment management** - profiles, export

### C Component (Mandatory for ADVANCED)
7. **Syntax highlighter** - real-time colouring
8. **Smart completion** - trie-based, context-aware
9. **Command validator** - syntax check before execution

### Optional
10. **Fuzzy matching** - approximate completion
11. **Command suggestions** - based on history
12. **Plugin system** - extensibility

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Interactive Shell                     │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Prompt      │  │  Highlighter │  │  Completer   │  │
│  │  (Bash)      │  │  (C + Bash)  │  │  (C)         │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  History     │  │  Bookmarks   │  │  Hooks       │  │
│  │  Manager     │  │  Manager     │  │  System      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
├─────────────────────────────────────────────────────────┤
│                    libshellext.so (C)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Lexer/      │  │  Trie        │  │  Readline    │  │
│  │  Tokeniser   │  │  Completion  │  │  Integration │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
A02_Interactive_Shell_Extension/
├── README.md
├── Makefile
├── src/
│   ├── bash/
│   │   ├── shellext.sh          # Main loader
│   │   ├── prompt.sh            # Custom prompt
│   │   ├── history.sh           # History enhancements
│   │   ├── bookmarks.sh         # Directory bookmarks
│   │   ├── hooks.sh             # Pre/post hooks
│   │   └── aliases.sh           # Alias management
│   └── c/
│       ├── shellext.h           # Public header
│       ├── lexer.c              # Tokeniser
│       ├── highlighter.c        # Syntax highlighting
│       ├── trie.c               # Trie for completion
│       ├── completer.c          # Completion engine
│       └── readline_ext.c       # Readline integration
├── etc/
│   └── shellext.conf
├── tests/
│   ├── test_lexer.c
│   ├── test_trie.c
│   └── test_integration.sh
└── docs/
    └── INTEGRATION.md
```

---

## C Component - Implementation

### Main Header (shellext.h)

```c
#ifndef SHELLEXT_H
#define SHELLEXT_H

#include <stddef.h>
#include <stdbool.h>

/* Token types for syntax highlighting */
typedef enum {
    TOKEN_WORD,         /* Regular word */
    TOKEN_COMMAND,      /* Executable command */
    TOKEN_BUILTIN,      /* Shell builtin */
    TOKEN_KEYWORD,      /* if, then, else, fi, etc. */
    TOKEN_STRING,       /* "..." or '...' */
    TOKEN_VARIABLE,     /* $VAR or ${VAR} */
    TOKEN_OPERATOR,     /* |, &, >, <, etc. */
    TOKEN_COMMENT,      /* # comment */
    TOKEN_NUMBER,       /* Numeric literal */
    TOKEN_PATH,         /* File path */
    TOKEN_OPTION,       /* -flag or --option */
    TOKEN_ERROR,        /* Syntax error */
    TOKEN_END
} TokenType;

/* Token structure */
typedef struct {
    TokenType type;
    const char *start;
    size_t length;
    int error_code;     /* For TOKEN_ERROR */
} Token;

/* ANSI colour codes */
typedef struct {
    const char *command;    /* Bold green */
    const char *builtin;    /* Cyan */
    const char *keyword;    /* Bold yellow */
    const char *string;     /* Yellow */
    const char *variable;   /* Blue */
    const char *operator_;  /* Magenta */
    const char *comment;    /* Grey */
    const char *number;     /* Cyan */
    const char *path;       /* Underline */
    const char *option;     /* Green */
    const char *error;      /* Red */
    const char *reset;      /* Reset */
} ColourScheme;

/* Lexer functions */
void lexer_init(const char *input);
Token lexer_next_token(void);
void lexer_reset(void);

/* Highlighter functions */
void highlighter_init(const ColourScheme *colours);
char *highlight_line(const char *line);
void highlighter_free(char *highlighted);

/* Trie for completion */
typedef struct TrieNode TrieNode;

TrieNode *trie_create(void);
int trie_insert(TrieNode *root, const char *word); /* 0 success, -1 error */
char **trie_complete(TrieNode *root, const char *prefix, int *count);
void trie_free_results(char **results, int count);
void trie_destroy(TrieNode *root);

/* Completion engine */
int completer_init(void);
void completer_add_command(const char *cmd);
void completer_add_path(const char *path);
char **completer_complete(const char *prefix, int *count);
void completer_cleanup(void);

/* Readline integration */
int readline_setup(void);
char *readline_highlight(const char *prompt);

/* Validation */
int validate_syntax(const char *line, char *error_msg, size_t error_size);

#endif /* SHELLEXT_H */
```

### Lexer/Tokeniser (lexer.c)

This byte-oriented teaching lexer recognises simple words, standalone quoted
strings, basic variables, options and command separators. It is not a Bash grammar
or a syntax validator: here-documents, substitutions, assignments before commands,
compound statements and quoted/unquoted word concatenation require further work.
`TOKEN_ERROR` identifies an unmatched standalone quote/brace; it does not certify
all other input as syntactically valid. The `validate_syntax` API remains a student
exercise and must not claim full Bash acceptance on the strength of colouring.

```c
#include "shellext.h"
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

static const char *input_buffer = NULL;
static size_t input_pos = 0;
static size_t input_len = 0;

/* Shell keywords */
static const char *keywords[] = {
    "if", "then", "else", "elif", "fi",
    "case", "esac", "for", "while", "until",
    "do", "done", "in", "function",
    "select", "time", "coproc",
    NULL
};

/* Shell builtins */
static const char *builtins[] = {
    "cd", "echo", "exit", "export", "source",
    "alias", "unalias", "read", "printf", "test",
    "set", "unset", "shift", "return", "break",
    "continue", "eval", "exec", "trap", "wait",
    "jobs", "fg", "bg", "kill", "pwd", "history",
    NULL
};

static bool is_keyword(const char *word, size_t len) {
    for (int i = 0; keywords[i]; i++) {
        if (strlen(keywords[i]) == len && 
            strncmp(word, keywords[i], len) == 0) {
            return true;
        }
    }
    return false;
}

static bool is_builtin(const char *word, size_t len) {
    for (int i = 0; builtins[i]; i++) {
        if (strlen(builtins[i]) == len && 
            strncmp(word, builtins[i], len) == 0) {
            return true;
        }
    }
    return false;
}

static bool is_operator_char(char c) {
    return c != '\0' && strchr("|&;<>()\n", c) != NULL;
}

void lexer_init(const char *input) {
    input_buffer = input;
    input_pos = 0;
    input_len = input ? strlen(input) : 0;
}

void lexer_reset(void) {
    input_pos = 0;
}

static char peek(void) {
    if (input_pos >= input_len) return '\0';
    return input_buffer[input_pos];
}

static char advance(void) {
    if (input_pos >= input_len) return '\0';
    return input_buffer[input_pos++];
}

Token lexer_next_token(void) {
    Token token = {TOKEN_END, NULL, 0, 0};
    
    /* Skip whitespace */
    while (input_pos < input_len && peek() != '\n' && isspace((unsigned char)peek())) {
        advance();
    }
    
    if (input_pos >= input_len) {
        return token;
    }
    
    token.start = &input_buffer[input_pos];
    char c = peek();
    
    /* Comment */
    if (c == '#') {
        token.type = TOKEN_COMMENT;
        while (peek() && peek() != '\n') {
            advance();
        }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* String (double quotes) */
    if (c == '"') {
        token.type = TOKEN_STRING;
        advance();
        while (peek() && peek() != '"') {
            if (peek() == '\\') advance();
            advance();
        }
        if (peek() == '"') advance();
        else { token.type = TOKEN_ERROR; token.error_code = 1; }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* String (single quotes) */
    if (c == '\'') {
        token.type = TOKEN_STRING;
        advance();
        while (peek() && peek() != '\'') {
            advance();
        }
        if (peek() == '\'') advance();
        else { token.type = TOKEN_ERROR; token.error_code = 1; }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Variable */
    if (c == '$') {
        token.type = TOKEN_VARIABLE;
        advance();
        if (peek() == '{') {
            advance();
            while (peek() && peek() != '}') advance();
            if (peek() == '}') advance();
            else { token.type = TOKEN_ERROR; token.error_code = 2; }
        } else {
            while (isalnum((unsigned char)peek()) || peek() == '_') advance();
        }
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Operator */
    if (is_operator_char(c)) {
        token.type = TOKEN_OPERATOR;
        advance();
        /* Handle multi-char operators */
        if ((c == '|' || c == '&') && peek() == c) advance();
        if ((c == '>' || c == '<') && peek() == c) advance();
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Option */
    if (c == '-') {
        token.type = TOKEN_OPTION;
        advance();
        if (peek() == '-') advance();
        while (isalnum((unsigned char)peek()) || peek() == '-') advance();
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Number */
    if (isdigit((unsigned char)c)) {
        token.type = TOKEN_NUMBER;
        while (isdigit((unsigned char)peek())) advance();
        token.length = &input_buffer[input_pos] - token.start;
        return token;
    }
    
    /* Word (command, builtin, keyword, or path) */
    token.type = TOKEN_WORD;
    while (peek() && !isspace((unsigned char)peek()) && !is_operator_char(peek())) {
        advance();
    }
    token.length = &input_buffer[input_pos] - token.start;
    
    /* Classify word */
    if (is_keyword(token.start, token.length)) {
        token.type = TOKEN_KEYWORD;
    } else if (is_builtin(token.start, token.length)) {
        token.type = TOKEN_BUILTIN;
    } else if (memchr(token.start, '/', token.length)) {
        token.type = TOKEN_PATH;
    }
    
    return token;
}
```

### Syntax Highlighter (highlighter.c)

```c
#include "shellext.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

static ColourScheme colours = {
    .command   = "\033[1;32m",    /* Bold green */
    .builtin   = "\033[36m",      /* Cyan */
    .keyword   = "\033[1;33m",    /* Bold yellow */
    .string    = "\033[33m",      /* Yellow */
    .variable  = "\033[34m",      /* Blue */
    .operator_ = "\033[35m",      /* Magenta */
    .comment   = "\033[90m",      /* Grey */
    .number    = "\033[36m",      /* Cyan */
    .path      = "\033[4m",       /* Underline */
    .option    = "\033[32m",      /* Green */
    .error     = "\033[31m",      /* Red */
    .reset     = "\033[0m"
};

void highlighter_init(const ColourScheme *custom_colours) {
    if (custom_colours) {
        colours = *custom_colours;
    }
}

/* The scheme strings are borrowed; they must remain valid during highlighting.
 * NULL fields are equivalent to empty strings. Append checks actual byte counts. */
static int append_bytes(char **buffer, size_t *used, size_t *capacity, const char *text, size_t length) {
    if (length > SIZE_MAX - *used - 1) return -1;
    size_t need = *used + length + 1;
    if (need > *capacity) {
        size_t next = *capacity;
        while (next < need) {
            if (next > SIZE_MAX/2) { next = need; break; }
            next *= 2;
        }
        char *grown = realloc(*buffer, next);
        if (!grown) return -1;
        *buffer = grown; *capacity = next;
    }
    if (length) memcpy(*buffer + *used, text, length);
    *used += length; (*buffer)[*used] = '\0';
    return 0;
}

char *highlight_line(const char *line) {
    if (!line) return NULL;
    size_t capacity = 64, used = 0;
    char *result = malloc(capacity);
    if (!result) return NULL;
    result[0] = '\0'; lexer_init(line);
    const char *last_end = line;
    Token token;
    bool first_word = true;
    while ((token = lexer_next_token()).type != TOKEN_END) {
        if (append_bytes(&result, &used, &capacity, last_end, (size_t)(token.start-last_end)) < 0) goto fail;
        const char *colour = NULL;
        switch (token.type) {
            case TOKEN_KEYWORD:  colour = colours.keyword; break;
            case TOKEN_BUILTIN:  colour = first_word ? colours.builtin : NULL; break;
            case TOKEN_STRING:   colour = colours.string; break;
            case TOKEN_VARIABLE: colour = colours.variable; break;
            case TOKEN_OPERATOR: colour = colours.operator_; break;
            case TOKEN_COMMENT:  colour = colours.comment; break;
            case TOKEN_NUMBER:   colour = colours.number; break;
            case TOKEN_PATH:     colour = colours.path; break;
            case TOKEN_OPTION:   colour = colours.option; break;
            case TOKEN_ERROR:    colour = colours.error; break;
            case TOKEN_WORD:    colour = first_word ? colours.command : NULL; break;
            default: break;
        }
        if (token.type == TOKEN_OPERATOR) {
            if (strchr("|;&\n(", token.start[0])) first_word = true;
        } else if (token.type != TOKEN_COMMENT) {
            first_word = false; /* Includes builtins and path commands. */
        }
        if (colour && append_bytes(&result, &used, &capacity, colour, strlen(colour)) < 0) goto fail;
        if (append_bytes(&result, &used, &capacity, token.start, token.length) < 0) goto fail;
        if (colour && colours.reset && append_bytes(&result, &used, &capacity, colours.reset, strlen(colours.reset)) < 0) goto fail;
        last_end = token.start + token.length;
    }
    if (append_bytes(&result, &used, &capacity, last_end, strlen(last_end)) < 0) goto fail;
    return result;
fail:
    free(result); return NULL;
}

void highlighter_free(char *highlighted) {
    free(highlighted);
}
```

### Trie for Completion (trie.c)

```c
#include "shellext.h"
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>

/* Opaque non-NUL byte keys (including UTF-8), ordered by byte value.
 * This is not Unicode normalisation or locale-aware collation. */
#define ALPHABET_SIZE 256
#define MAX_TRIE_KEY 1024

struct TrieNode {
    struct TrieNode *children[ALPHABET_SIZE];
    bool is_end;
    char *word;
};

TrieNode *trie_create(void) { return calloc(1, sizeof(TrieNode)); }

int trie_insert(TrieNode *root, const char *word) {
    if (!root || !word || strlen(word) > MAX_TRIE_KEY) { errno = EINVAL; return -1; }
    TrieNode *node = root;
    for (const unsigned char *p = (const unsigned char *)word; *p; ++p) {
        if (!node->children[*p]) {
            TrieNode *created = trie_create();
            if (!created) return -1; /* Existing words and ownership remain valid. */
            node->children[*p] = created;
        }
        node = node->children[*p];
    }
    if (node->is_end) return 0; /* Duplicate insertion is idempotent. */
    char *copy = strdup(word);
    if (!copy) return -1;
    node->word = copy; node->is_end = true;
    return 0;
}

static int collect_words(TrieNode *node, char ***results, int *count, int *capacity) {
    if (node->is_end && node->word) {
        if (*count == *capacity) {
            if (*capacity > INT_MAX/2 || (size_t)*capacity > SIZE_MAX/(2*sizeof(char *))) { errno = EOVERFLOW; return -1; }
            int next = *capacity * 2;
            char **grown = realloc(*results, (size_t)next * sizeof(char *));
            if (!grown) return -1;
            *results = grown; *capacity = next;
        }
        char *copy = strdup(node->word);
        if (!copy) return -1;
        (*results)[(*count)++] = copy;
    }
    for (int i = 0; i < ALPHABET_SIZE; ++i)
        if (node->children[i] && collect_words(node->children[i], results, count, capacity) < 0) return -1;
    return 0;
}

char **trie_complete(TrieNode *root, const char *prefix, int *count) {
    if (!count) { errno = EINVAL; return NULL; }
    *count = 0; errno = 0;
    if (!root || !prefix || strlen(prefix) > MAX_TRIE_KEY) { errno = EINVAL; return NULL; }
    TrieNode *node = root;
    for (const unsigned char *p = (const unsigned char *)prefix; *p; ++p) {
        if (!node->children[*p]) return NULL; /* count=0 and errno=0: no match. */
        node = node->children[*p];
    }
    int capacity = 16;
    char **results = malloc((size_t)capacity * sizeof(char *));
    if (!results) return NULL;
    if (collect_words(node, &results, count, &capacity) < 0) {
        int saved = errno;
        trie_free_results(results, *count); *count = 0; errno = saved;
        return NULL;
    }
    return results;
}

void trie_free_results(char **results, int count) {
    if (!results) return;
    for (int i = 0; i < count; i++) {
        free(results[i]);
    }
    free(results);
}

void trie_destroy(TrieNode *root) {
    if (!root) return;
    
    for (int i = 0; i < ALPHABET_SIZE; i++) {
        if (root->children[i]) {
            trie_destroy(root->children[i]);
        }
    }
    
    free(root->word);
    free(root);
}
```

---

## Makefile

```makefile
CC = gcc
CFLAGS = -std=c11 -D_POSIX_C_SOURCE=200809L -Wall -Wextra -O2 -fPIC
LDFLAGS = -lreadline

SRC_DIR = src/c
BUILD_DIR = build

LIB_SOURCES = $(SRC_DIR)/lexer.c $(SRC_DIR)/highlighter.c \
              $(SRC_DIR)/trie.c $(SRC_DIR)/completer.c $(SRC_DIR)/readline_ext.c
LIB_TARGET = $(BUILD_DIR)/libshellext.so

.PHONY: all clean test install

all: $(LIB_TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LIB_TARGET): $(LIB_SOURCES) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

test: $(LIB_TARGET)
	$(CC) $(CFLAGS) -o $(BUILD_DIR)/test_lexer tests/test_lexer.c \
		-L$(BUILD_DIR) -lshellext -Wl,-rpath,$(BUILD_DIR)
	./$(BUILD_DIR)/test_lexer

clean:
	rm -rf $(BUILD_DIR)

install: $(LIB_TARGET)
	install -d /usr/local/lib /usr/local/share/shellext
	cp $(LIB_TARGET) /usr/local/lib/
	cp src/bash/*.sh /usr/local/share/shellext/
	ldconfig
```

---

## Bash Integration

### Main Loader (shellext.sh)

`libshellext.so` exposes a C API; exporting `LD_PRELOAD` does not load it into an
already-running Bash. A `PROMPT_COMMAND` callback runs at prompt boundaries and is
not a live editing hook. The loader below therefore requires a **student-supplied
Bash loadable builtin bridge**, with Bash development headers matching the target
Bash ABI. Its `shellext_install` builtin must install a readline redisplay/completion
hook, retain the previous hooks and handle cursor/display escape widths;
`shellext_uninstall` must restore them before unloading. Build
`build/shellext_bash.so` from a separate `src/c/bash_builtin.c` module linked to the
shown library. Do not link a second, incompatible readline into Bash.

The bridge, completer and readline module are intentionally student work. The
Makefile builds the C library only once those source files exist; it does not
produce the Bash bridge automatically. Tests of lexer/trie/highlight output do not
prove live editing integration. A standalone readline front end is another design,
but it is a separate executable and must not be described as changing the current
Bash editing session. The loader reports incomplete integration explicitly and
never installs a no-op prompt hook or changes future processes through LD_PRELOAD.

```bash
#!/usr/bin/env bash
# Source in an interactive Bash. Bash modules and the C bridge are distinct stages.
_shellext_load() {
    [[ $- == *i* ]] || { printf 'Interactive Bash required\n' >&2; return 2; }
    local module script_root project_root
    script_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || return 1
    project_root=$(cd -- "$script_root/../.." && pwd) || return 1
    for module in prompt history bookmarks hooks aliases; do
        [[ -r "$script_root/$module.sh" ]] || { printf 'Missing Bash module: %s\n' "$module" >&2; return 1; }
    done
    for module in prompt history bookmarks hooks aliases; do source "$script_root/$module.sh" || return 1; done
    printf 'Bash modules loaded; C/readline integration is not verified.\n'
    # Student-supplied Bash loadable builtin, compiled for this Bash ABI.
    local bridge="$project_root/build/shellext_bash.so"
    [[ -f $bridge ]] || { printf 'Live highlighting unavailable: build the Bash bridge first.\n' >&2; return 2; }
    enable -f "$bridge" shellext_install || return 1
    enable -f "$bridge" shellext_uninstall || { enable -d shellext_install; return 1; }
    if ! shellext_install; then
        enable -d shellext_uninstall; enable -d shellext_install
        return 1
    fi
    printf 'Readline bridge installed. Validate editing and restoration interactively.\n'
}
_shellext_load
# Removal after a successful installation:
# shellext_uninstall && enable -d shellext_install && enable -d shellext_uninstall
```

---

## Specific Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Syntax highlighting | 25% | Correct lexer, colours |
| Completion engine | 20% | Trie, context-aware |
| Prompt & history | 15% | Informative, search |
| Bookmarks & hooks | 15% | Functional |
| Readline integration | 15% | Smooth UX |
| Code quality | 5% | Clean, documented |
| Documentation | 5% | README, examples |

---

## Resources

- GNU Readline documentation
- ANSI escape codes reference
- "Writing Your Own Shell" tutorials
- Seminar 4-5 - Text processing, regex

---

*ADVANCED Project | Operating Systems | ASE-CSIE*
