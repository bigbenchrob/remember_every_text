# The Museum Tour Analogy

Presence can feel abstract when described only in architectural terms. A
guided museum tour provides a more intuitive way to understand how its parts
work together.

This analogy does not define Presence. The canonical architecture remains in
the parent Presence documents. Its purpose is to make that architecture easier
to picture.

## Begin With the Durable Clipboard

Imagine that the museum runs a scheduled tour:

> Saturday, 10:00 AM — West Wing Tour — Group 17

In the tour office, the tour manager maintains a durable clipboard for this
specific undertaking. It records:

- the tour identity;
- the group's current position;
- accepted decisions, such as the chosen language or route;
- the current obligation;
- whether the group is moving, waiting, or paused;
- whether the tour is complete.

That clipboard is the **Journey**.

The guide is not the Journey. The guests are not the Journey. The museum is not
the Journey. The Journey is the authoritative coordination record for this one
tour.

This distinction matters when the original guide becomes ill halfway through
the visit. A replacement guide can take over without creating a new tour. The
clipboard still identifies the same undertaking, preserves the decisions
already made, and says exactly where the group should resume.

The person presenting the tour has changed. The Journey has not.

## The Coordinator Remains in the Tour Office

Now imagine that the **Coordinator** is the tour manager sitting in the office
with the clipboard.

The Coordinator does not walk through the galleries or deliver the tour. It
receives reports, checks them against the current clipboard and museum facts,
and decides what should happen next.

Reports might establish that:

- the welcome received its required acknowledgement;
- admission was verified by the ticket system;
- the group returned from a bathroom break;
- the group reached the next gallery;
- the selected route became unavailable.

The guide can report an observation or convey a guest interaction. The guide
does not independently turn the clipboard to the next page. Only the
Coordinator commits a Journey transition.

This remains true even when one museum employee happens to perform several
jobs. A guide might also be the authorized person who verifies a headcount.
Conceptually, presenting the tour and establishing the headcount are still
different responsibilities.

## The Guide Presents the Active Episode

The **Renderer** is the part of the system that presents the current
interaction. In the museum, it may be:

- the human guide;
- an audio headset;
- an information display;
- an accessible transcript;
- some combination of these.

The one interaction currently presented is the **Active Episode**.

The Renderer decides how to communicate that Episode clearly. It may adapt
volume, pacing, layout, language, or accessibility treatment according to
**Presentation Policy**. It does not change what the Episode means, what can
truthfully complete it, or what should happen next.

Several common tour events illustrate the Episode families.

## Welcoming the Guests: Inform

The first Episode might be:

> Welcome to the West Wing tour. We will visit five galleries and finish in
> the sculpture court.

This is an `Inform`. It communicates something the guests should presently
understand. It does not ask them to make a museum-domain decision or imply that
operational work is underway.

The guide may report the **Presentation Observation**:

> Readable opportunity provided.

That report means only that the welcome was presented for a suitable
opportunity. It does not prove that every guest read, heard, understood, or
accepted it. The Coordinator decides whether the applicable policy and current
Journey truth permit progression.

## Verifying Tickets: Await

Before entering the first gallery, the Active Episode becomes:

> Everyone must have a valid ticket before the tour can continue.

This is an `Await`. The required condition exists outside the presentation:
admission must be verified.

A guest saying, “I bought a ticket,” does not make the condition true. The
**Completion Authority** is the source capable of establishing the condition
truthfully, such as the admissions scanner or ticket desk.

The guide may offer directions to the ticket desk. That supporting action can
help the guest satisfy the condition, but opening directions does not complete
the Episode. The Coordinator advances only after valid admission evidence
arrives.

## Choosing a Language: Ask

The tour may ask:

> Would you like the tour in English, French, or Mandarin?

This is an `Ask<Language>`. The guests are genuinely responsible for choosing
among the permitted answers.

The Renderer presents the choices and returns the selected candidate. The
Coordinator confirms that the response belongs to the current Episode, accepts
it through the Journey contract, and records the decision on the clipboard.

Only then does the chosen language become durable Journey truth.

## Moving to the Next Gallery: Work

The Active Episode may then be:

> Proceeding from the atrium to the Renaissance Gallery.

This is `Work`. The museum's operational side supplies truthful facts about the
movement, route, and arrival. The guide may communicate those facts but must
not manufacture progress because enough time has elapsed or the walking
animation looks complete.

When the authorized operational evidence establishes that the group reached
the gallery, the Coordinator records the transition and derives the next
Episode.

## Taking a Bathroom Break: Await and Resume

Halfway through the tour, the group requests a bathroom break. The Coordinator
records that the tour is paused and derives:

> We will reconvene beside the blue statue when everyone has returned.

The guide explains where to meet and waits. Five minutes passing does not prove
that the group has returned. Neither does one guest saying, “I think everyone
is here.”

The authorized observer performs the required headcount. Once the return
condition is established, the guide reports it with the identity of the
current interaction. The Coordinator validates the report, updates the
clipboard, and resumes the route.

The pause did not destroy the Journey. The clipboard preserved the undertaking
while no movement was taking place.

## Answering Questions and Making Announcements

An ordinary factual question can be answered without changing the Journey:

> Who painted this?

The guide answers, and the tour continues.

If the question creates a real coordination decision, the Coordinator may
derive a new `Ask`:

> Would the group prefer the textile room or the sculpture court?

Likewise, a museum announcement may become an `Inform`:

> The east gallery has closed for the afternoon.

The gallery closure itself is a museum fact. The announcement communicates
that fact. Any resulting route change is committed by the Coordinator rather
than improvised by presentation code.

## A Moment Beside the Dinosaur

While the group stands beside a dinosaur skeleton, the guide quietly remarks:

> If you look carefully, one rib is actually a replica.

This is a **Moment**.

It enriches the experience without changing the clipboard. It does not
complete the current Episode, alter the route, record a decision, or establish
an operational fact required by the Journey.

If the guide omits it, the tour still coordinates and completes correctly.
That is the defining test: a Moment may add warmth or interest, but the Journey
must never depend on it.

## Several Tours at Once

The tour office may be coordinating several Journeys simultaneously:

- Group 17 is visiting the Renaissance Gallery;
- a school group is waiting for a wheelchair-accessible lift;
- an evening tour is assembling in the lobby.

All three Journeys exist. Their clipboards remain durable. Presence nevertheless
designates exactly one as the **Foreground Journey**, and that Journey has one
Active Episode. The guide or Presence surface gives its full attention to that
interaction.

Suppose the school group's lift becomes available while the guide is speaking
to Group 17. Museum staff can report that the background Journey now needs
attention. They cannot seize the guide, overwrite the current clipboard, or
force a new interaction onto the current group.

The Coordinator performs foreground arbitration. It considers the current
commitment, urgency, applicable policy, and safe interruption points. It may:

- keep Group 17 foregrounded;
- postpone the new request;
- deliberately transfer foreground attention;
- arrange operational assistance without changing foreground Presence.

A background Journey requesting attention is therefore not the same as
interrupting the Foreground Journey. The request becomes coordination input;
the Coordinator decides its effect.

## Every Report Carries a Stamped Tour Slip

Every Coordinator-bound interaction from the guide carries **Provenance**. A
declared Presentation Observation carries the same Provenance when it crosses
that boundary. Imagine each report arriving with a stamped tour slip:

```text
Journey identity       Saturday 10:00 tour, Group 17
Journey revision       Clipboard revision 12
Episode identity       Bathroom reconvening obligation
Activation occurrence  Current guide activation 3
Interaction occurrence Return report 41
```

Each part answers a different question.

**Journey identity** says which undertaking the report concerns.

**Journey revision** says which authoritative clipboard state produced the
interaction. A response prepared under an earlier route decision cannot modify
the current revision.

**Episode identity** says which logical interaction obligation the report
addresses. The bathroom reconvening obligation remains the same obligation
while its evidence is refreshed.

**Activation occurrence** says which grant of foreground rendering authority
produced the interaction. If the guide is replaced, the old guide's later
reports cannot affect the current tour even when the logical Episode remains
the same.

**Interaction occurrence** distinguishes one semantic interaction from every
other interaction. If the same return report is delivered twice, the
Coordinator accepts it at most once.

Together these stamps make stale rejection mechanical. The Coordinator does
not guess whether a report “looks recent enough.” It checks whether the
Provenance is current and whether that interaction occurrence has already been
consumed.

### Restart and Activation Authority

Suppose the tour office computer restarts during the bathroom break.

The durable clipboard still says that Group 17 is waiting to reconvene. The
logical Episode identity may therefore survive: it is still the same bathroom
reconvening obligation.

The previous activation authority does not survive. Restart reconciliation
issues a new activation occurrence before the Episode is presented again.
Reports stamped by the pre-restart activation can no longer affect current
Journey truth.

The obligation survived. The former authority to speak for its active
presentation did not.

## Completion and Farewell

When museum facts establish that the group completed the route, the
Coordinator records the completed Journey and derives a final `Inform`:

> The tour is complete. Thank you for visiting.

The farewell does not make the route complete. It communicates a completion
that has already been established by the appropriate authority.

## Presence Is an Architecture of Responsibilities

The analogy works because each participant has a narrow responsibility:

- **Journey owns continuity.** The clipboard preserves the undertaking,
  decisions, current obligation, and outcome.
- **Coordinator owns transitions.** The tour manager determines what happens
  next from current Journey truth and authorized evidence.
- **Episode owns interaction semantics.** It states what kind of interaction is
  currently required and what authority can complete it.
- **Renderer owns presentation.** The guide, display, or headset communicates
  the Active Episode according to Presentation Policy.
- **Museum systems own factual truth.** Admissions, route operations,
  authorized observers, and other museum authorities establish domain facts.
- **Moments enrich but never coordinate.** They may make the tour memorable,
  but the tour never depends on them.

Nobody maintains correctness by casually performing another participant's
responsibility. The guide does not rewrite the clipboard. The clipboard does
not scan tickets. The ticket scanner does not choose the next gallery. The
Coordinator does not invent museum facts.

Presence applies the same discipline to software: continuity, transition,
interaction meaning, presentation, factual authority, and ambient enrichment
remain separate so that the whole undertaking can survive interruption without
losing truth.

## Where the Analogy Bends

In a real museum, one employee may simultaneously act as guide, headcount
observer, and tour manager. Presence separates these as architectural
responsibilities even when one implementation component happens to perform
more than one role.

The clipboard is also an intentionally simplified picture of durable Journey
state. It helps explain continuity and authority, but it should not be read as
a prescription for storage format or implementation.

Finally, a museum tour is mostly linear. Presence Journeys may involve richer
operational evidence, interruption, reconciliation, and recovery. The analogy
explains responsibility and authority; the canonical documents define the
complete architecture.
