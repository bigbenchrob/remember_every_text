# UI Review Process

This process should be followed for every review.

---

# 1. Navigate Naturally

Use the application exactly as a normal user would.

Do not think about implementation.

---

# 2. Understand the Purpose

Before critiquing anything, identify:

- Why does this surface exist?
- What task is the user trying to accomplish?

If the purpose is unclear, that is itself a UX issue.

---

# 3. Evaluate the Experience

Ask the following questions.

## Orientation

- Is it obvious where I am?
- Is it obvious why I am here?

## Information

- Is the information useful?
- Is anything missing?
- Is anything unnecessary?

## Interaction

- What is the obvious next action?
- Does anything require unnecessary thought?
- Are extra clicks required?

## Consistency

- Does this behave like similar UI elsewhere?
- Does it follow MessageLens conventions?

## Visual Design

- Is the layout balanced?
- Is spacing consistent?
- Is visual hierarchy clear?

---

# 4. Record Findings

Document:

- strengths
- weaknesses
- opportunities for improvement

Avoid discussing implementation unless necessary.

---

# 5. Define Acceptance Criteria

Describe the desired user experience.

Acceptance criteria should describe observable behaviour rather than implementation details.

---

# 6. Hand Off

When the review is complete, create an implementation plan using ACTION_PLAN_TEMPLATE.md.

Codex should implement the agreed improvements.

---

# 7. Verify

After implementation, verify the result in the app against the review's
acceptance criteria.

If implementation differs from the review, update the review document so it
accurately records the final decision.

---

# 8. Archive Implemented Reviews

Once a review has been implemented and verified, move it out of the active
review tree and into `99-IMPLEMENTED/`.

Preserve the active folder hierarchy inside `99-IMPLEMENTED/`.

Example:

```text
10-Messages-Sidebar/Conversations/
```

becomes:

```text
99-IMPLEMENTED/10-Messages-Sidebar/Conversations/
```

If the working parent folder becomes empty, leave it in place when it provides
useful context for nearby active review folders.

Implemented reviews should remain available as design history.

---

# Philosophy

Review the application from the user's perspective rather than the developer's.

The objective is not to build more software.

The objective is to build better software.
