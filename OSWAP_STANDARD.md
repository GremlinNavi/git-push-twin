# OSWAP Standard

SPDX-License-Identifier: Apache-2.0

Version: 0.2.1
Project: Open-Source World Access Project (OSWAP)

This document is normative for OSWAP code and documentation. New OSWAP implementations SHOULD conform to this standard unless a later version explicitly supersedes it.

## 1. Language boundary

OSWAP is a domain-specific language (DSL). OSWAP syntax is not PowerShell syntax.

PowerShell is a supported host, launcher, implementation environment, and human-facing prompt surface. PowerShell grammar does not redefine OSWAP grammar.

OSWAP implementations MUST parse OSWAP expressions themselves and MUST NOT use `Invoke-Expression`, shell `eval`, or equivalent arbitrary-code evaluation for OSWAP arithmetic or OSWAP semantic operators.

## 2. Arithmetic grammar

OSWAP arithmetic supports:

- decimal numbers;
- parentheses;
- exponentiation with `^`;
- multiplication with `*`;
- division with `/`;
- addition with `+`;
- subtraction with `-`;
- unary `+` and `-`.

Precedence is:

1. parentheses;
2. exponentiation;
3. unary sign;
4. multiplication and division;
5. addition and subtraction.

Example:

```text
oswap push twin=4*(15-(2^3-5))+18/3^2
```

resolves to `50`.

The host language's interpretation of `^` is irrelevant. Within OSWAP, `^` means exponentiation.

### 2.1 Ordered OR/AND semantic token

OSWAP reserves the ordered token `|&` as the OR/AND logic gate.

The textual order is normative: `|&` means OR/AND. An implementation MUST NOT rename it AND/OR, reverse its stated order, or silently treat `&|` as an equivalent token.

Example experimental form:

```text
twin|&joker=N
```

This is an OSWAP semantic expression, not a PowerShell pipeline followed by a PowerShell call operator. A host such as PowerShell may tokenize `|` and `&` separately; an OSWAP parser MUST recognize OSWAP syntax before host-language execution.

The detailed evaluation truth table and execution profile for `|&` remain experimental and are not defined by OSWAP Standard 0.2.1. Implementations MUST NOT invent state-changing behavior for this token and claim conformance until a later normative profile defines that behavior.

## 3. Twin replication factors

`oswap push twin=<expression>` expresses a replication factor, not a PowerShell expression.

A positive non-integer result is valid.

For replication factor `n + f`, where `n = floor(value)` and `0 <= f < 1`:

- `n` complete destination pushes are guaranteed;
- one additional complete destination is selected with probability `f`;
- destinations are selected without replacement from the configured eligible `twin` push URL pool;
- selection is semi-random and MUST be disclosed before final publication confirmation;
- the implementation MUST refuse a factor that cannot be represented by the available destination pool.

Example:

```text
oswap push twin=(4+3)/2
```

resolves to `3.5`: three destinations are guaranteed and a fourth destination is selected with 50% probability.

A fractional replication factor never means a partial repository or partial file.

## 4. Preview, consent, and publication

Repository publication is preview-first.

Before any remote write, OSWAP MUST:

1. show the current branch or state being published;
2. show the eligible destination pool;
3. resolve and display the replication factor;
4. show the selected destinations for the executing operation;
5. require an explicit PowerShell confirmation.

OSWAP MUST NOT force-push, reset, clean, rewrite history, or silently commit unrelated work as part of `push twin`.

## 5. PowerShell prompt standard

Human-facing OSWAP safety workflows MUST use PowerShell/terminal prompts rather than requiring sensitive data in command-line arguments.

Secrets, survivor names, case descriptions, decryption passphrases, private notes, and other sensitive content MUST NOT be placed in process command lines, Git remote names, branch names, repository names, or commit messages by OSWAP.

Prompts MUST be explicit about side effects and MUST preserve cancellation as a normal outcome.

### 5.1 Y/N authorization input standard

When an OSWAP workflow exposes a `Y/N` prompt, the input is an authorization gate, not an authentication or credential prompt.

A conforming Y/N authorization gate MUST follow these rules:

- `Y` means the user authorizes an attempt to perform only the action explicitly described immediately before the prompt;
- `N` means the user declines that action, and cancellation MUST be treated as a normal outcome;
- `Y` MUST NOT be interpreted as a password, token, API key, signing secret, identity proof, or substitute for provider authentication;
- the Y/N input surface MUST NOT request or accept account credentials, decryption secrets, private tokens, or other authentication material;
- credentials MUST remain within the authenticated provider, connector, operating-system credential store, secret store, or other designated authentication boundary;
- a `Y` response authorizes an attempt but does not prove that execution occurred or succeeded; and
- parsing, authorization, execution, and verification SHOULD be represented as separate auditable states.

If provider authorization, authentication, network access, validation, or execution fails after `Y`, the implementation MUST report the failure as a later-stage failure. It MUST NOT reinterpret the original `Y` as a credential or as proof of successful execution.

OSWAP implementations MAY use a more specific confirmation phrase instead of Y/N where a workflow requires stronger operator attention. Such a phrase remains an authorization input and does not become a credential.

## 6. Preservation standard

OSWAP preservation functionality exists to preserve user-controlled information against accidental loss, deletion, coercive deletion, platform failure, and institutional failure.

For sensitive material:

- preserve the original bytes without editing the source;
- generate SHA-256 integrity information;
- keep descriptive metadata inside the protected package;
- encrypt before remote replication;
- use generic package identifiers outside the encrypted package;
- keep decryption secrets separate from replicated ciphertext;
- never equate preservation with publication;
- never promise invisibility from spyware, privileged monitoring, or a compromised device;
- never disable operating-system security, antimalware, logging, or monitoring controls in order to appear hidden;
- warn users to move to a trusted device when compromise is suspected.

Remote publication of sensitive material MUST contain ciphertext only. A failure before encryption MUST fail closed and MUST NOT publish plaintext.

## 7. Survivor and whistleblower autonomy

OSWAP is infrastructure, not an authority.

The person controlling the material decides whether, when, and to whom it is disclosed. Preservation MUST NOT require police involvement, legal action, public disclosure, or transfer of custody to an OSWAP maintainer.

OSWAP SHOULD support maintaining a personal incident record and preservation history even when no legal process is contemplated.

## 8. Intent and non-goals

OSWAP is intended to:

- lower technical barriers to open-source software stewardship;
- make redundant repository preservation understandable and accessible;
- reduce unnecessary dependence on a single platform, institution, or jurisdiction;
- preserve public knowledge while minimizing unnecessary exposure of private identity;
- support defensive preservation of sensitive records under user control;
- keep implementation inspectable and forkable.

OSWAP is not intended to:

- gain unauthorized access to another person's accounts or devices;
- deploy spyware, stalkerware, persistence, or credential theft;
- evade antivirus or endpoint security;
- alter evidence to make it appear more persuasive;
- guarantee legal admissibility or a particular legal outcome;
- guarantee anonymity on a compromised device.

## 9. Licensing

OSWAP-authored code and documentation in repositories that adopt this standard MUST remain compatible with the repository's Apache License 2.0 terms. New OSWAP-authored source files SHOULD carry an SPDX identifier:

```text
SPDX-License-Identifier: Apache-2.0
```

External dependencies retain their own licenses.

## 10. Source of truth

This file is the project-level source of truth for the OSWAP Standard 0.2.1. Command schemas, PowerShell implementations, tests, and intent documentation should be kept consistent with it.
