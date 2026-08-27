---
name: refine-task
description: Definition-of-Ready audit for a task.md — checks required sections, measurability of acceptance criteria, verified data sources and unlabeled assumptions; returns ordered findings. Use before delivering any task, or when a developer bounces one back.
---

# Refine a task (Definition of Ready)

Audit the given `tasks/*.md` against the checklist. Return findings ordered
by severity; a task with any **blocker** is not deliverable.

## Checklist

**Blockers**

- A required template section is missing or empty (context, scope, acceptance
  criteria, how-to-test, DoD; data sources when data is involved).
- An acceptance criterion is not checkable ("should work well", "user
  friendly", "fast" without a number).
- A data reference (db/schema/table/column) has no "verified on" date, or
  contradicts [db-catalog.md](../../../docs/db-catalog.md).
- An assumption is stated as fact instead of listed under "Open questions".
- Real customer data / PII appears anywhere in the task.

**Warnings**

- Scope has no **Out** list.
- How-to-test misses the edge/error cases the criteria imply.
- The task bundles more than one deliverable — propose the split.
- An open question has no owner.
- UI task without UI/i18n notes.

## Output

One line per finding: `section · blocker|warning · issue · concrete fix`.
Then the verdict: **READY** or **NOT READY (n blockers)**. Offer to apply the
mechanical fixes; the analyst answers the substantive ones.
