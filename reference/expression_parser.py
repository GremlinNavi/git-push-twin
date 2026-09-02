"""Reference parser for the OSWAP Expression Addressing draft specification.

This module is intentionally small and side-effect free. It does not invoke Git,
PowerShell, the network, or arbitrary Python evaluation.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
import re
from typing import Iterable

MAX_EXPRESSION_LENGTH = 256
MAX_TOKENS = 128
MAX_DEPTH = 32
MAX_ABS_INTEGER = 10**12

_ROMAN_RE = re.compile(
    r"^(?=[IVXLCDM]+$)M{0,3}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$",
    re.I,
)
_TOKEN_RE = re.compile(r"\s*(?:(\d+(?:\.\d+)?)|([IVXLCDM]+)|([()+\-*/]))", re.I)


@dataclass(frozen=True)
class Node:
    kind: str
    value: str | None = None
    left: "Node | None" = None
    right: "Node | None" = None


@dataclass(frozen=True)
class ParseResult:
    raw: str
    canonical: str
    ast: Node
    value: Fraction


def roman_to_int(text: str) -> int:
    token = text.upper()
    if not _ROMAN_RE.fullmatch(token):
        raise ValueError(f"invalid canonical Roman numeral: {text!r}")

    values = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
    total = 0
    previous = 0
    for char in reversed(token):
        current = values[char]
        if current < previous:
            total -= current
        else:
            total += current
            previous = current
    return total


def tokenize(expression: str) -> list[tuple[str, str]]:
    if len(expression) > MAX_EXPRESSION_LENGTH:
        raise ValueError("expression exceeds maximum length")

    tokens: list[tuple[str, str]] = []
    position = 0

    while position < len(expression):
        match = _TOKEN_RE.match(expression, position)
        if not match:
            if expression[position:].strip() == "":
                break
            raise ValueError(f"unsupported token near offset {position}")

        decimal, roman, operator = match.groups()

        if decimal is not None:
            value = Fraction(decimal)
            if abs(value.numerator) > MAX_ABS_INTEGER or value.denominator > MAX_ABS_INTEGER:
                raise ValueError("numeric literal exceeds configured bound")
            canonical = decimal.rstrip("0").rstrip(".") if "." in decimal else decimal
            tokens.append(("NUMBER", canonical))
        elif roman is not None:
            value = roman_to_int(roman)
            tokens.append(("NUMBER", str(value)))
        else:
            tokens.append((operator, operator))

        position = match.end()
        if len(tokens) > MAX_TOKENS:
            raise ValueError("expression exceeds maximum token count")

    if not tokens:
        raise ValueError("empty expression")
    return tokens


class Parser:
    def __init__(self, tokens: Iterable[tuple[str, str]]):
        self.tokens = list(tokens)
        self.index = 0

    def parse(self) -> Node:
        node = self._expression(0)
        if self.index != len(self.tokens):
            raise ValueError("unexpected trailing token")
        return node

    def _peek(self) -> tuple[str, str] | None:
        if self.index >= len(self.tokens):
            return None
        return self.tokens[self.index]

    def _take(self) -> tuple[str, str]:
        token = self._peek()
        if token is None:
            raise ValueError("unexpected end of expression")
        self.index += 1
        return token

    def _expression(self, depth: int) -> Node:
        if depth > MAX_DEPTH:
            raise ValueError("expression nesting exceeds maximum depth")
        node = self._term(depth + 1)
        while self._peek() and self._peek()[0] in {"+", "-"}:
            op = self._take()[0]
            node = Node(op, left=node, right=self._term(depth + 1))
        return node

    def _term(self, depth: int) -> Node:
        node = self._factor(depth + 1)
        while self._peek() and self._peek()[0] in {"*", "/"}:
            op = self._take()[0]
            node = Node(op, left=node, right=self._factor(depth + 1))
        return node

    def _factor(self, depth: int) -> Node:
        if depth > MAX_DEPTH:
            raise ValueError("expression nesting exceeds maximum depth")

        token = self._take()

        if token[0] == "NUMBER":
            return Node("NUMBER", value=token[1])

        if token[0] == "-":
            return Node("NEGATE", left=self._factor(depth + 1))

        if token[0] == "(":
            node = self._expression(depth + 1)
            if self._take()[0] != ")":
                raise ValueError("missing closing parenthesis")
            return node

        raise ValueError(f"unexpected token: {token[1]!r}")


def evaluate(node: Node) -> Fraction:
    if node.kind == "NUMBER":
        return Fraction(node.value)
    if node.kind == "NEGATE":
        return -evaluate(node.left)

    left = evaluate(node.left)
    right = evaluate(node.right)

    if node.kind == "+":
        return left + right
    if node.kind == "-":
        return left - right
    if node.kind == "*":
        return left * right
    if node.kind == "/":
        if right == 0:
            raise ZeroDivisionError("division by zero")
        return left / right

    raise ValueError(f"unknown AST node kind: {node.kind}")


def canonicalize(node: Node) -> str:
    if node.kind == "NUMBER":
        return node.value
    if node.kind == "NEGATE":
        return f"(-{canonicalize(node.left)})"
    return f"({canonicalize(node.left)}{node.kind}{canonicalize(node.right)})"


def parse(expression: str) -> ParseResult:
    ast = Parser(tokenize(expression)).parse()
    value = evaluate(ast)

    if abs(value.numerator) > MAX_ABS_INTEGER or value.denominator > MAX_ABS_INTEGER:
        raise ValueError("resolved rational exceeds configured bound")

    return ParseResult(
        raw=expression,
        canonical=canonicalize(ast),
        ast=ast,
        value=value,
    )


if __name__ == "__main__":
    import argparse

    cli = argparse.ArgumentParser(
        description="Resolve a restricted OSWAP arithmetic expression."
    )
    cli.add_argument("expression")
    args = cli.parse_args()

    result = parse(args.expression)
    print(f"raw={result.raw}")
    print(f"canonical={result.canonical}")
    print(f"value={result.value}")
