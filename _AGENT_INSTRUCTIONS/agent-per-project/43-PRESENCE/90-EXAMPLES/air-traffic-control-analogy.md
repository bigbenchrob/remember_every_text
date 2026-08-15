# The Air Traffic Control Analogy

The museum tour analogy explains Presence through a calm, mostly linear
undertaking. Air Traffic Control offers a harder test. Many undertakings remain
active at once. Communication can arrive late or be repeated. Operational work
continues during controller changes, display changes, and system recovery.
Mistaking a report for current truth can have serious consequences.

This document uses a deliberately simplified ATC setting to explain Presence.
It is not aviation instruction, and it does not claim that real ATC systems use
the Presence model. The canonical Presence documents remain authoritative.

## One Aircraft, One Durable Flight Strip

Imagine one aircraft moving from airport ground control, through taxi and
takeoff, and into departure control.

The durable coordination record is its **flight progress strip**, whether that
strip is paper or electronic. It records facts such as:

- aircraft identity;
- flight plan;
- current phase;
- accepted clearances and readbacks;
- runway assignment;
- holds and other current obligations;
- coordination and handoff state;
- completion of the local undertaking.

That strip is the analogy for the **Journey**.

The pilot is not the Journey. The speaking controller is not the Journey. The
aircraft is not the Journey. The Journey is the durable record that allows the
undertaking to remain coherent as people, displays, and communication channels
change.

A controller may finish a shift while the aircraft remains at a hold point.
The replacement controller receives the same strip and the same unresolved
obligation. The person has changed; the Journey has not.

For this analogy, the Journey is:

> Coordinate aircraft N123AB from initial airport contact through departure
> handoff.

## Separating the Speaking Controller From Coordination Authority

The most visible ATC participant is the controller speaking over the radio.
That makes it tempting to map the controller to every Presence responsibility.
That would hide the important architecture.

Conceptually, separate two roles:

- the **Renderer** presents the current instruction or request to the pilot and
  returns declared pilot interactions;
- the **Coordinator** owns the flight strip, evaluates current operational
  facts, and commits the next coordination state.

In a real facility, one controller may perform both roles. Presence cares about
the responsibility boundary rather than the number of people involved.

The speaking controller cannot make a runway clear by saying that it is clear.
The radio cannot make an aircraft airborne by transmitting a clearance. The
flight strip cannot observe surface movement. Each responsibility depends on
the authority capable of establishing its own facts.

## The Current Communication Is the Active Episode

The **Episode** is the one current interaction obligation derived from the
flight strip and operational facts. The **Active Episode** is the Episode
currently presented for the **Foreground Journey**.

The radio voice, data-link message, or controller display is the Renderer. It
may adapt wording, pacing, visual arrangement, alerts, or accessibility
treatment according to **Presentation Policy**. Those choices cannot change:

- the meaning of the clearance;
- the required response;
- the Completion Authority;
- the aircraft's actual operational state;
- the Journey transition.

The following sequence illustrates how the responsibilities interact. The
Episode-family mappings explain Presence protocols, not aviation categories.

## 1. Greeting an Aircraft Entering the Sector

The aircraft makes initial contact and the current Episode communicates:

> N123AB, radar contact.

As a Presence protocol, this can be an `Inform` whose policy requires an
appropriate acknowledgement before the interaction is considered complete.

The Renderer transmits the greeting. The pilot's correctly identified response
is returned to the Coordinator with Provenance. The Coordinator determines
whether that response satisfies the current interaction contract and updates
the strip.

The mere fact that the words were transmitted is not Journey completion
evidence. At most, the Renderer may report a declared **Presentation
Observation** about its own presentation. It cannot report that the pilot
understood the operational situation.

## 2. Obtaining a Runway Assignment

The flight requires a runway assignment before taxi instructions can be
derived. That assignment comes from current airport configuration and
authorized operational coordination, not from the radio presentation.

The Active Episode is therefore an `Await` for an externally established
assignment.

- **Completion Authority:** the authorized airport or tower coordination
  source;
- **Renderer:** the controller display may show that assignment is pending;
- **Coordinator:** accepts the assignment only if it applies to the current
  Journey revision;
- **Journey transition:** records the assigned runway and derives the next
  interaction.

The pilot cannot complete this Episode by choosing a convenient runway unless
the actual domain contract explicitly makes that a permitted decision.

## 3. Awaiting Confirmation That a Runway Is Clear

Before movement onto a runway can be authorized, the relevant operational
condition must be established.

The Active Episode is:

> Await runway-clear confirmation.

This is another `Await`.

The Completion Authority is not the pilot and not the speaking Renderer. It is
the authorized combination of runway-status, inspection, surveillance, and
controller evidence defined by the operational domain.

A stale “runway clear” report from an earlier inspection cannot satisfy the
current obligation merely because its words sound correct. Its Journey
revision, Episode identity, activation occurrence, or operational occurrence
will not match current truth.

## 4. Issuing a Taxi Clearance

Once the required facts are current, the Coordinator derives an interaction
that presents a taxi clearance and requires a correct readback.

For Presence purposes, this resembles an `Ask<ClearanceReadback>`:

- the Renderer presents the approved clearance;
- the pilot returns a constrained semantic response;
- the relevant authority validates that response;
- the Coordinator records the accepted clearance and readback.

This mapping does not claim that a clearance is an ordinary user question. It
shows that Presence classifies the interaction by what truthfully completes
it: a specific response must be accepted before the coordination state may
advance.

Issuing the clearance does not establish that the aircraft has moved.

## 5. Aircraft Taxiing

After the clearance and readback are accepted, the aircraft begins taxiing.
The Active Episode is now `Work`.

Operational movement continues whether or not a particular display is visible.
Surface surveillance, authorized position reports, and other domain evidence
describe what is actually happening.

- **Renderer:** communicates approved movement status and any current
  instructions;
- **Coordinator:** reconciles the strip with current movement evidence;
- **Completion Authority:** the domain evidence capable of establishing that
  the aircraft reached the required point;
- **Journey transition:** records arrival at that point and derives the next
  Episode.

An animated aircraft icon is not evidence of motion. Rendering does not become
operational truth.

## 6. Temporary Hold Position

The aircraft is instructed to hold at a designated point.

The clearance presentation and required readback form one interaction. Once
accepted, the Journey enters an `Await`:

> Remain at the hold point until the release condition is established.

Waiting time does not authorize release. The pilot saying “ready” may be useful
input, but it does not make the runway available. The Coordinator advances
only when the declared Completion Authority establishes the required
condition.

The aircraft may remain operationally active while the Presence interaction is
quiet. The absence of new presentation does not mean that the Journey
disappeared.

## 7. Runway Inspection Requiring a Delay

Airport operations reports that the runway requires inspection.

That domain fact may first produce an `Inform`:

> Expect a delay for runway inspection.

The subsequent Active Episode is an `Await` for the inspection outcome. The
inspection team and authorized runway-status process own the relevant facts.
The Renderer communicates them but does not manufacture them.

If the inspection result changes the runway assignment, the Coordinator
commits a new Journey revision. A delayed interaction prepared under the old
assignment is then stale by construction.

## 8. Takeoff Clearance

When all required conditions are current, the Coordinator derives the takeoff
clearance interaction.

The Renderer transmits the clearance and receives the required readback. The
accepted readback can complete that communication Episode.

It does not establish that takeoff occurred.

This distinction is central:

> “Cleared for takeoff” authorizes an operation. It is not evidence that the
> operation completed.

The Journey advances into the operational takeoff phase only according to its
declared transition contract.

## 9. Departure

Takeoff and departure are represented as `Work`.

The pilot saying “we're airborne” may be relevant evidence, but it is not
automatically authoritative merely because it was spoken. The owning
operational domain determines what combination of surveillance, reports, and
procedural evidence establishes airborne and departure state.

The Coordinator consumes those facts and updates the strip. The Renderer may
then communicate the already-established status.

## 10. Handoff to Another Controller

As the aircraft leaves the local area, coordination transfers to another
controller.

The logical obligation is:

> Transfer N123AB safely to departure control.

That obligation may remain the same while communication is repeated or
presentation moves to another controller position. Completion depends on the
authorized handoff evidence: the transfer is coordinated and the receiving
position accepts responsibility according to the domain contract.

The local Journey reaches its terminal state only after that transition is
authoritatively established. Saying “contact departure” does not by itself
prove that the handoff succeeded.

The receiving controller may begin a related undertaking in another
coordination context. Presence does not require two operational domains to
pretend they own one undifferentiated Journey.

## Independent Truth

ATC makes Completion Authority especially easy to see.

The following statements are not interchangeable:

```text
Controller: "Cleared for takeoff."
Pilot:      "We're airborne."
System:     "Current operational evidence establishes departure."
```

The first is an authorization. The second is a report. The third represents
the domain's authoritative conclusion under its actual evidence rules.

Presence does not decide which sensors or procedures establish aviation truth.
It requires the owning feature to declare the authority and provide the facts.
The Coordinator then uses those facts without impersonating their owner.

## Many Aircraft, One Foreground Journey

One controller may remain responsible for many aircraft. Each aircraft has an
ongoing Journey and durable strip:

- one is taxiing;
- one is holding;
- one is awaiting runway inspection;
- one is departing.

Operational monitoring continues across all of them. Presence nevertheless
permits exactly one Foreground Journey and one Active Episode in its current
interaction surface.

Suppose a background aircraft reports a changed condition. That report makes
the Journey eligible for attention; it does not automatically seize foreground
ownership. The Coordinator arbitrates using current Journey state, urgency,
policy, and the existing foreground obligation.

An emergency policy may make the result immediate and obvious. It is still an
arbitrated transition rather than an arbitrary widget or feature taking over
the presentation.

This is one place where the analogy strains. Real controllers continuously scan
several aircraft and rapidly interleave communications. Presence's single
Foreground Journey models the singular interaction currently owning the
communication surface, not the totality of simultaneous operational
awareness.

## Does ATC Have Moments?

ATC has little room for **Moments**.

Weather information, traffic advisories, runway conditions, and safety notices
are not Moments. They can affect operational decisions and therefore belong to
authoritative communication.

A brief courtesy such as “good morning” may be nonessential, but it does not
serve the same ambient, enriching purpose as a museum anecdote. Forcing it into
the Moment model would teach little.

The honest conclusion is that this analogy has almost no strong Moment
equivalent. That does not weaken the architecture. Moments are optional
content admitted only where they suit the domain. An ATC Presence client could
reasonably admit none.

## Provenance as a Stamped Radio Exchange

Imagine every Coordinator-bound radio interaction carrying a stamped
coordination slip:

```text
Journey identity       N123AB local departure undertaking
Journey revision       Flight-strip revision 27
Episode identity       Hold-short release obligation
Activation occurrence  Tower-position activation 6
Interaction occurrence Readback exchange 104
```

**Journey identity** distinguishes this aircraft's undertaking from every
other flight.

**Journey revision** identifies the current authoritative strip state. A
transmission prepared before a runway reassignment cannot alter the revised
state.

**Episode identity** identifies the logical interaction obligation. The same
hold-short obligation may survive repeated transmissions, display
reconstruction, or restart.

**Activation occurrence** identifies one grant of foreground rendering
authority. A shift change, controller replacement, foreground reactivation, or
restart issues a new occurrence. The former controller's delayed transmission
cannot affect current Journey truth.

**Interaction occurrence** identifies one semantic exchange. A repeated radio
packet or duplicated readback cannot be accepted twice.

Real radio protocols do not literally transmit this five-field Presence
structure. Call signs, readbacks, controller positions, sequence, and
procedural context perform related safety work. The stamped slip is a teaching
device for the architectural contract.

### Delayed and Repeated Communication

Consider three failures:

1. A delayed runway-clear message arrives after the runway assignment changed.
   Its Journey revision is obsolete.
2. The same clearance readback is delivered twice. Its interaction occurrence
   has already been consumed.
3. A report arrives from the controller activation that ended at shift change.
   Its activation occurrence is no longer current.

The Coordinator rejects each report mechanically. It does not infer freshness
from wording, arrival time, or apparent plausibility.

### Controller Replacement and Restart

Suppose the coordination system restarts while N123AB remains at the same hold
point.

The durable strip still describes the same Journey and the same logical
hold-short Episode. Those identities may survive reconciliation.

The previous activation authority cannot. Restart reconciliation issues a new
activation occurrence before rendering resumes. A transmission from the
pre-restart activation is stale even if the Episode wording is unchanged.

The obligation survived. The former authority to speak for its active
presentation did not.

## Responsibility Map

ATC safety depends on separating responsibilities:

- **Journey owns continuity.** The flight strip preserves the undertaking,
  accepted decisions, current obligation, and coordination state.
- **Coordinator owns transitions.** It applies the Journey contract to current
  facts and accepted interactions.
- **Episode owns interaction semantics.** It defines what interaction is
  presently required and what can truthfully complete it.
- **Renderer owns presentation.** Radio, data link, displays, and the speaking
  role communicate the Active Episode.
- **Feature truth remains with operational authorities.** Surveillance,
  runway status, inspection, pilot reports, and coordination systems retain
  their actual domain authority.
- **Presentation Policy governs treatment.** It controls how the current
  Episode is communicated without changing its meaning or authority.
- **Provenance protects the boundary.** It lets the Coordinator reject obsolete
  and duplicate interactions mechanically.
- **Moments remain optional and nonauthoritative.** In this domain, admitting
  none is probably the truthful choice.

No participant becomes safer by quietly absorbing another participant's job.
The Renderer does not declare runway truth. The Coordinator does not invent
sensor facts. The feature does not seize foreground presentation. A report
does not commit its own transition.

## What the Stress Test Reveals

### Concepts That Map Naturally

The strongest mappings are:

- Journey as the durable flight strip;
- Coordinator as transition authority;
- Completion Authority as independent operational truth;
- Provenance as protection against stale and duplicate communication;
- stable Episode identity separated from replaceable activation authority;
- operational continuity despite controller and Renderer replacement.

ATC makes these authority boundaries even clearer than the museum analogy.

### Concepts That Require Stretching

The speaking controller and Coordinator are often embodied by one real person,
so the analogy requires separating responsibilities that operational practice
may combine.

Episode-family labels also describe Presence interaction protocols rather than
aviation concepts. In particular, treating a required clearance readback as an
`Ask<T>` is architecturally useful but linguistically unusual.

The single Foreground Journey is another deliberate simplification. ATC
maintains broad concurrent awareness even though radio exchanges and immediate
interaction attention are serialized.

### Concepts With Weak Equivalents

Moments have no compelling ATC equivalent. Most information worth
communicating can affect safety or coordination and therefore cannot be merely
ambient.

The analogy also cannot identify real aviation Completion Authorities in full.
Those belong to aviation procedures, not Presence.

### Architectural Result

The architecture survives this pressure test unchanged.

The difficult cases do not reveal a missing Presence concept. They reveal where
the analogy combines several architectural responsibilities in one human role,
or where a high-consequence domain chooses not to use an optional capability.

ATC particularly strengthens three ideas:

1. presentation is not operational truth;
2. authorization is not completion evidence;
3. stable obligation and current activation authority are different things.

## Which Analogy Should Be Read First?

Future contributors should read the
[`museum-tour-analogy.md`](museum-tour-analogy.md) first. Its pace and visible
roles make Journey, Episode, Coordinator, Renderer, and Moment easier to
internalize.

The ATC analogy should come second. It is the stronger authority and stale-event
stress test, but its concurrency and combined human roles make it less suitable
as an introduction.

Together they show that Presence is not a collection of screens. It is an
architecture for preserving truthful responsibility while an undertaking
continues through communication, interruption, replacement, and recovery.
