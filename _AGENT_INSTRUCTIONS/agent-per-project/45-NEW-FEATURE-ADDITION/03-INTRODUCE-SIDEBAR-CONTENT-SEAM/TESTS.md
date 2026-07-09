---
tier: project
scope: test-plan
owner: agent-per-project
last_reviewed: 2026-07-07
source_of_truth: draft
status: proposed
---

# Sidebar Content Seam Test Plan

## Automated Tests

### Payload Default Test

Verify that cassette payloads default to no content-start anchor unless
explicitly declared.

Expected:

- ordinary info cassettes do not become content-start candidates
- grouped controls do not become content-start candidates
- action cassettes do not become content-start candidates

### Search Heatmap Anchor Test

Verify that the Search All Messages heatmap payload declares the preferred
content-start anchor.

Expected:

- search info cassette is not a content-start candidate
- search heatmap cassette is a content-start candidate

### Sidebar Seam Layout Test

For a synthetic cassette chain:

```text
app control
info cassette
content-start cassette
later cassette
```

verify that:

- app control remains first
- spacer is inserted before the content-start cassette when a seam contract is
  supplied
- later cassettes remain after the content-start cassette
- no spacer is inserted when no seam contract is supplied

### No Candidate Test

Verify current behavior is preserved when no cassette declares a content-start
candidate.

## Manual Verification

### Search All Messages

Confirm:

- top selector aligns visually with center/right identity row
- heatmap begins at shared content-start level
- short orientation text appears above heatmap
- heatmap footer/guidance remains readable
- search results continue to render and scroll normally

### Contacts

Confirm:

- contact hero card remains stable
- handle controls continue to work
- heatmap remains responsive
- no unexpected spacer appears unless that surface explicitly opts in later

### Conversations

Confirm:

- Favourites/Browse mode remains stable
- conversation list still scrolls normally
- no unexpected spacer appears unless that surface explicitly opts in later

### From Unfamiliar Sources

Confirm:

- selector and filters remain usable
- handle list remains dense and scrollable
- no unexpected spacer appears unless that surface explicitly opts in later

## Deferred Tests

Autonomous middle-zone fit/promotion behavior is explicitly deferred. Do not
write tests for dynamic height promotion until that behavior is designed.

