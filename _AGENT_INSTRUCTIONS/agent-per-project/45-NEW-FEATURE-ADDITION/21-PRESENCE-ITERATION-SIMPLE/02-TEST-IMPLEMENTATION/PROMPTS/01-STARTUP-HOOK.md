We are now leaving the PRESENCE laboratory.

This folder:

45-NEW-FEATURE-ADDITION/
21-PRESENCE-ITERATION-SIMPLE/
01-ITERATIONS/
02-TEST-IMPLEMENTATION/

begins the first real workflow implementation.

Presence itself is no longer the focus.

Onboarding is.

The purpose is to replace the current onboarding control/progress panel with a Journey built using the Presence components already proven in the laboratory.

Do not redesign onboarding.

Do not redesign startup.

Do not introduce new Presence abstractions.

First determine exactly where the current application decides that onboarding should begin.

Read the existing startup flow.

Find:

- where database readiness is checked;
- where onboarding currently starts;
- what object currently owns that decision;
- what UI currently becomes visible.

Do not modify code.

Create:

00-ONBOARDING-STORY.md

Describe only the user experience beginning:

Application launches...

and ending:

...the first import begins.

Then create:

10-STARTUP-HOOK.md

Identify:

- the existing startup decision point;
- the owning class;
- the owning method;
- the data currently examined;
- why this location is the natural place to request the onboarding Journey.

Do not propose architectural changes.

Do not propose providers.

Do not propose refactors.

This task is observational.

We are discovering where the first real Journey should enter the existing application.
