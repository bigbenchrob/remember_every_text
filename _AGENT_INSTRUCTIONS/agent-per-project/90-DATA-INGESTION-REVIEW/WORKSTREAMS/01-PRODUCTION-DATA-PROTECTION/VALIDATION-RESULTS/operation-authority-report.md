# Operation Authority Report

Date: 2026-07-27

One reentrant archive mutation coordinator now covers live graph updates, graph
builds, onboarding, automatic recovery, reset, historical archive operations,
attachment maintenance, destructive maintenance, and local-account identity
reconciliation.

Tests verify:

- competing owners are denied;
- same-owner nested work is admitted;
- exceptions release authority;
- reset cannot overlap live graph update;
- historical import cannot overlap graph build;
- provider disposal does not strand a completing operation;
- database reopen/read-availability state derives from admitted operation
  state;
- high-risk production work requires verified checkpoint evidence.
