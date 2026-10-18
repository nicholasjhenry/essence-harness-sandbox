# Essence Shortner — Agents

## The session starts with the initialization of the essence

### Rules

- **R1.** The start of a session in this repository must apply the `initialization-reads-the-system-and-local-essence-in-order` rule in `.essence/system/rules/`.
  - **Classification:** behavioral
  - **Enforced:** at the start of each session, before the first request is acted on
  - **Violation response:** the agent stops the work of the session. It reads the initialization rule, and then each item of its R1 in its order.

### Facts

- **system essence**, **local essence** — the `initialization-reads-the-system-and-local-essence-in-order` rule, in `.essence/system/rules/`

### Examples

- ❌ The agent acts on the first request, and reads the rules later — breaks R1. The agent then applies the rules from memory, or not at all.
- ✅ The agent reads `.essence/system/rules/initialization-reads-the-system-and-local-essence-in-order.md`. Then it reads each item of its R1 in its order, before the first request is acted on.

### Rationale

The agent applies only the rules that it has read. This file is the only file that the agent reads at the start of a session without a request.

This repository installs the harness. The system essence is in `.essence/system/`, and the local essence is in `.essence/local/`.

### Related

- the initialization-reads-the-system-and-local-essence-in-order rule — the read that the session starts with

---

Authored by Nicholas Henry on Sat Oct 17 2026 at 9:57:50 PM EDT
