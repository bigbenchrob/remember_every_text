USE CASE ILLUSTRATIONS — NARRATIVE SPEC SYSTEM

Purpose

This folder captures real-world observations, tester feedback, and product behaviors as structured narrative artifacts.

These artifacts serve as a reusable source of truth for:

* website content
* onboarding flows
* feature explanations
* product positioning
* agent-authored documentation
* future marketing materials

The goal is to preserve not just what happened, but why it matters.

⸻

Core Principles

1. Evidence is preserved separately from interpretation
    Raw screenshots, tester quotes, and logs are never overwritten or summarized in place.
2. Each meaningful story becomes a structured artifact
    If something demonstrates clear user value, it should be promoted to a USE_CASE.
3. Narrative is treated as a spec
    USE_CASE.md files are not casual notes—they are structured inputs for downstream surfaces.
4. One story per folder
    Each folder represents a single coherent narrative.

⸻

Folder Structure

archive/legacy-use-case-illustrations/
README.md
early-user-feedback.md        ← append-only raw feedback log

01-/
USE_CASE.md                 ← structured narrative spec
02-/
USE_CASE.md
⸻

File Roles

early-user-feedback.md

* Append-only
* Raw tester quotes and observations
* No editing, summarizing, or restructuring
* Source material for future USE_CASEs

USE_CASE.md

* Structured narrative spec
* Interprets one real-world situation
* Designed for reuse across product and marketing surfaces

⸻

USE CASE SPEC (v1)

Each USE_CASE.md should follow this structure:

title:
Human-readable title

slug:
Stable identifier (kebab-case)

status:
One of:

* draft
* observed
* tester-reported
* verified
* inferred

category:
Primary domain (e.g. preservation, search, onboarding, diagnostics)

tags:

* short keywords for indexing

summary:
Short paragraph describing what happened and why it matters

trigger:
What event exposed this situation

before:
What the user experienced before MessageLens

after:
What changed with MessageLens

problem:
The deeper user problem (not just symptoms)

solution:
How MessageLens addressed the problem

key_insight:
Most important takeaway

user_value:
Plain-English value statement

proof:
Concrete supporting evidence (screenshots, quotes, logs)

visual_assets:
List of associated files

source_material:
Links to raw inputs (feedback log, notes, etc.)

candidate_copy:
Reusable messaging lines (homepage, onboarding, etc.)

implications:
Why this matters for product or strategy

related_features:
Relevant parts of MessageLens

related_use_cases:
Links to other narrative specs

notes:
Freeform

⸻

Status Definitions

draft
Not fully formed yet

observed
Seen directly during development

tester-reported
Reported by a user but not deeply verified

verified
Confirmed with clear evidence (screenshots, reproducible behavior)

inferred
Strong interpretation based on patterns, not directly observed

⸻

When to Create a USE CASE

Create a USE_CASE when:

* something surprising happens
* a user expresses a clear before/after shift
* MessageLens succeeds where Apple Messages fails
* a feature demonstrates real-world value
* a pattern emerges across multiple users

Do NOT create a USE_CASE for:

* minor UI tweaks
* routine behavior
* purely technical implementation details

⸻

Philosophy

This system treats narrative as a first-class part of the product.

MessageLens is not only a tool—it is a system for preserving and rediscovering personal history.

These artifacts document how that value manifests in real use.
