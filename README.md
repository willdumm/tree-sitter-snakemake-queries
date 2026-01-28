# tree-sitter-snakemake-queries

Tree-sitter queries for Snakemake syntax highlighting in [kak-tree-sitter](https://sr.ht/~hadronized/kak-tree-sitter/).

## Why this repo exists

kak-tree-sitter does not support the `; inherits: python` directive used by tree-sitter-snakemake's queries. This repo provides merged Python + Snakemake highlight queries that work with kak-tree-sitter.

## Attribution

This repo combines queries from two sources:

### Python queries

The Python highlight queries (and other `.scm` files) are sourced from the [Helix editor](https://github.com/helix-editor/helix) via kak-tree-sitter's runtime queries.

- **License:** MPL-2.0
- **Source:** https://github.com/helix-editor/helix

### Snakemake-specific queries

The Snakemake-specific portions of the highlight queries are adapted from [tree-sitter-snakemake](https://github.com/osthomas/tree-sitter-snakemake) by osthomas.

- **License:** MIT
- **Source:** https://github.com/osthomas/tree-sitter-snakemake

Note: Some query predicates (e.g., `#has-ancestor?`) have been removed or commented out because they are not supported by kak-tree-sitter.

## Setup

### 1. kak-tree-sitter configuration

Add the following to `~/.config/kak-tree-sitter/config.toml`:

```toml
# Snakemake grammar
[grammar.snakemake]
source = { git = { url = "https://github.com/osthomas/tree-sitter-snakemake", pin = "68010430c3e51c0e84c1ce21c6551df0e2469f51" } }
path = "src"
compile_args = ["-c", "-fpic", "../scanner.c", "../parser.c", "-I", ".."]
link_args = ["-shared", "-fpic", "scanner.o", "parser.o", "-o", "snakemake.so"]

# Snakemake language
[language.snakemake]
grammar = "snakemake"

[language.snakemake.queries]
source = { git = { url = "https://github.com/willdumm/tree-sitter-snakemake-queries", pin = "09f72d8704ea1a4eddc3ec26dfb5b311897ec58f" } }
path = "queries/snakemake"
```

### 2. Kakoune configuration

Add the following to your `kakrc`:

```kak
# Snakemake filetype detection and tree-sitter integration
hook global BufCreate .*[Ss]nakefile[^/]*$ %{ set-option buffer filetype snakemake }
hook global BufCreate .*\.(snakefile|snakemake|smk)$ %{ set-option buffer filetype snakemake }
declare-option -hidden bool kts_snakemake_loaded false
hook global WinSetOption filetype=snakemake %{
    # Reload kts config once per session to load snakemake grammar
    evaluate-commands %sh{
        if [ "$kak_opt_kts_snakemake_loaded" = "false" ]; then
            echo "set-option global kts_snakemake_loaded true"
            echo "kak-tree-sitter-req-reload"
        fi
    }
    set-option buffer tree_sitter_lang snakemake
    tree-sitter-buffer-metadata
    tree-sitter-buffer-update
}
```

The `kak-tree-sitter-req-reload` is needed because kak-tree-sitter doesn't load custom grammars until explicitly reloaded. The hidden option ensures this only happens once per session.
