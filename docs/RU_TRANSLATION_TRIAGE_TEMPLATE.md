# RU Translation Triage Template

Use one block per unknown string candidate.

---

## Entry

- Raw unknown string:
- Screen/context:
- Repro steps:
- Classification: `static` / `dynamic` / `noise`
- Planned handler: `cnItems` / `cnRegReplace` / `cnPrefix` / `cnPostfix` / `exclude`
- Proposed patch snippet:
- Validation result:
- Notes/follow-up:

---

## Example (dynamic)

- Raw unknown string: `+12.5% global speed per level`
- Screen/context: Singularity skill tooltip
- Repro steps:
  - Open Singularity tab
  - Hover specific skill node
- Classification: `dynamic`
- Planned handler: `cnRegReplace`
- Proposed patch snippet:
  - `/^\+([\d\.]+)\% global speed per level$/ -> "+$1% ..."`
- Validation result:
  - RU text rendered correctly
  - numeric value unchanged
- Notes/follow-up:
  - Check same phrase variants for yield/SP

---

## Example (noise)

- Raw unknown string: `(`
- Screen/context: Mixed symbol-only log spam
- Repro steps:
  - Enable debug mode and open multiple tabs
- Classification: `noise`
- Planned handler: `exclude`
- Proposed patch snippet:
  - Add symbol-only exclusion regex in `cnExcludeWhole`
- Validation result:
  - Noise reduced, no visible UI text loss
- Notes/follow-up:
  - Re-check that valid short strings are not hidden
