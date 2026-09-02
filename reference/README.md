# Reference implementation

`expression_parser.py` is a small side-effect-free reference parser for the draft OSWAP Expression Addressing grammar.

It exists to make parser behavior concrete and to support conformance work across future PowerShell, Python, Rust, JavaScript, or other implementations.

It does not:

- call Git;
- access a network;
- read credentials;
- execute PowerShell;
- evaluate arbitrary Python;
- resolve real repository endpoints.

Example:

```text
python reference/expression_parser.py "IX/III"
```

Expected logical result:

```text
raw=IX/III
canonical=(9/3)
value=3
```

Production code should treat this as a reference implementation, not as an authorization or Git-transport layer.
