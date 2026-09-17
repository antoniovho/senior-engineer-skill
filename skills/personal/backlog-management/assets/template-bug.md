# Bug Template

```markdown
---
name: "🐞 Bug SPEC"
about: "Detailed specification for a Bug."
title: "<insert_title_here>"
assignees: ""
labels: kind/bug
type: "Bug"
---
## 📝 Summary
Short explanation of what is broken (1-2 sentences).

## 🧾 Description of the Bug
A clear explanation of the defect.

**Scope**: Which product capabilities are affected and what is NOT touched (1 sentence).

**Root cause** (if known): Brief description of why the bug happens (1-2 sentences).

**Impact**: Who is affected and how severely (1-2 sentences).

## 🧪 Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## 💥 Expected Behavior
Describe what should have happened — concrete enough to verify, not just "it should work correctly."

## ✅ Acceptance Criteria
Each criterion must be a behavioral outcome verifiable by a person or automated test. Use the pattern: *"When [situation], then [observable outcome]."*
- [ ] Bug can be consistently reproduced
- [ ] Fix eliminates the issue
- [ ] Tests added/updated

## 🔗 Dependencies
Other work required before fixing (if any).
- External system/team dependencies: name specifically

## 📝 Additional Details
Screenshots, logs, stack traces, etc. Anything that can help understand and reproduce the issue.

## 🔗 Related Issues / PRs
Links to related stories, epics, bugs and/or PRs.
```
