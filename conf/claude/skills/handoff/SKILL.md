---
name: handoff
description: Summarize the current conversation into a handoff document (saved to disk) that a fresh agent session can use to continue the work.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the folder Claude was invoked from in this session.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead. If the path is on the local machine, use absolute URLs.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

Name the document `Handoff-<timestamp>.md`, where `<timestamp>` is the current date and time formatted as `YYYYMMDD-HHMMSS` (seconds precision, no milliseconds/microseconds, no colons — colons aren't safe in filenames on all platforms).

Example: `Handoff-20260730-143022.md`
