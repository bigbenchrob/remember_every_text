The museum analogy proved extremely valuable because it demonstrated that the Presence architecture is really an architecture of responsibilities rather than software components.

I would now like to pressure-test the architecture against a much more demanding real-world domain.

Create a new explanatory document:

43-PRESENCE/90-EXAMPLES/air-traffic-control-analogy.md

Also add it to the examples index.

This is an explanatory document only.

Do not modify canonical Presence documents.

Do not modify application code.

Do not invent new Presence concepts.

The purpose is to determine whether the existing Presence architecture still feels natural in a domain where:

- several Journeys exist simultaneously;
- independent authorities establish truth;
- communication may be delayed;
- stale information can have severe consequences;
- operations continue while presentation changes;
- multiple human operators may be replaced during an undertaking.

---

## Purpose

Write for human readers.

Assume they already understand software but still want to internalize Presence.

The document should explain Presence through Air Traffic Control.

The goal is not to teach aviation.

The goal is to teach Presence.

---

## The Cast

Map Presence concepts onto the ATC world.

For example, consider mappings such as:

Journey

Coordinator

Episode

Renderer

Presentation Policy

Completion Authority

Moment

Foreground Journey

Active Episode

Provenance

Do not force a mapping if a concept genuinely differs.

Explain why.

---

## The Flight Strip

As the museum used the durable clipboard, identify the equivalent durable coordination record.

This will likely be the flight progress strip (paper or electronic).

Show how it records:

- aircraft identity;
- flight plan;
- current phase;
- accepted clearances;
- runway assignment;
- current coordination state;
- completion.

Explain why replacing a controller does not replace the Journey.

---

## Controller

Separate:

the controller speaking to the pilot

from

the coordination authority.

Avoid collapsing responsibilities.

Clarify who presents instructions and who commits coordination truth.

---

## Concrete Scenarios

Walk through at least the following Episodes.

1.  Greeting an aircraft entering the sector.

2.  Obtaining a runway assignment.

3.  Awaiting confirmation that a runway is clear.

4.  Issuing a taxi clearance.

5.  Aircraft taxiing.

6.  Temporary hold position.

7.  Runway inspection requiring a delay.

8.  Takeoff clearance.

9.  Departure.

10. Handoff to another controller.

For each scenario explain:

- Journey
- Active Episode
- Completion Authority
- Renderer
- Coordinator
- Journey transition

---

## Independent Truth

Demonstrate clearly that:

The pilot saying

"We're airborne."

does not necessarily establish truth.

Likewise,

a controller issuing

"Cleared for takeoff."

does not establish that takeoff occurred.

Identify the operational authorities that actually establish each transition.

---

## Foreground Arbitration

Assume one controller is responsible for many aircraft.

Explain:

- multiple concurrent Journeys;
- only one Foreground Journey at a time;
- background Journeys requesting attention;
- why no aircraft can seize foreground attention merely because something changed.

Show how the Coordinator decides.

---

## Moments

Determine whether an ATC analogy even has Moments.

If not,

say so.

If it does,

identify an equivalent that enriches communication without affecting coordination.

Do not force the analogy.

It is acceptable to conclude that this aspect of Presence has little real-world equivalent.

---

## Provenance

Demonstrate Provenance using radio communication.

Illustrate:

Journey identity

Journey revision

Episode identity

Activation occurrence

Interaction occurrence

Show how stale radio messages are rejected mechanically.

Demonstrate:

- controller replacement;
- shift change;
- delayed transmission;
- repeated transmission;
- restart of the coordination system.

Explain why Episode identity may survive while activation authority changes.

---

## Responsibilities

Conclude with a responsibility map.

Journey

Coordinator

Episode

Renderer

Feature truth

Presentation Policy

Provenance

Explain why ATC safety depends upon keeping these responsibilities separate.

---

## Stress Test

After completing the analogy,

evaluate the Presence architecture itself.

Identify:

- concepts that mapped naturally;
- concepts that required stretching;
- concepts that became clearer than in the museum analogy;
- concepts that still feel awkward.

If the analogy reveals a genuine architectural weakness,

identify it.

If the architecture survives unchanged,

say so explicitly.

The goal is not to defend Presence.

The goal is to pressure-test it honestly.

---

## Review

When complete:

1. Summarize the strongest insights gained.
2. Compare the museum and ATC analogies.
3. Recommend which should be read first by future contributors.
4. Confirm that no new Presence concepts were introduced.
