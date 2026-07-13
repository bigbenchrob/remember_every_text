# Open Question Evaluation: Contact Tags

## Question

Should Conversations support Contact Tags, and if so, should they behave like ordinary user-created Tags?

## Recommendation

Conversation Contact Tags should be a special category of Conversation Tag.

They are not ordinary text Tags.

They are **identity-backed retrieval coordinates** that refer to canonical Contact identity rather than storing a copied display name.

Their purpose is not to classify a Conversation.

Their purpose is to make retrieval of relationship chapters natural and explicit.

---

## The Problem

Many Conversations are primarily distinguished by **who** they involve.

However, long-lived relationships often span multiple Conversations because the
other participant changes:

- phone number
- email address
- iPad
- laptop
- work account
- university account

The Conversation browser already treats these as distinct Conversations.

Suppose the user has four Conversations with Claire.

One contains:

- UBCO

Another:

- Condo

Another:

- Subaru

Another:

- 4B

Those chapter Tags alone are not always sufficient.

The user naturally wants to retrieve:

```
Claire
UBCO
```

rather than relying on the assumption that only Claire attended UBCO.

The retrieval becomes explicit rather than inferred.

---

## Why Not Just Use Contacts?

The Contacts feature already understands identity.

However, this is a Conversations workflow.

The user is already working inside the Conversations feature.

They should not need to leave Conversations simply because the retrieval happens
to involve a Contact.

MessageLens deliberately treats:

- Contacts
- Conversations
- Messages

as peer entry points.

Conversation retrieval should therefore be complete within the Conversations
feature.

---

## Why Not Just Type "Claire"?

Because that creates another problem.

Suppose the user later changes Claire's display name to:

```
Ru
```

or

```
Dr. Campbell
```

or any other preferred display identity.

A text Tag would immediately become stale.

The system would no longer know whether:

```
Claire
```

and

```
Ru
```

represent the same person.

---

## Identity-Backed Contact Tags

Instead, Contact Tags should store:

```
contactId
```

not

```
display text
```

The visible label should always be resolved through the same Contact identity
resolution used everywhere else in MessageLens.

Therefore:

```
Conversation Tag

↓

Contact 417

↓

display identity resolver

↓

"Ru"
```

Changing the Contact display name automatically updates every Conversation Tag.

No Tag rename operation is required.

This is exactly the behavior users should expect from MessageLens.

---

## Contact Tags Are Not Contact Tags

Although derived from Contact identity, these are still **Conversation Tags**.

They belong entirely to the Conversations namespace.

They simply happen to use Contact identity as their backing data.

They should not appear in Contact Tag management.

Likewise Contact Tags should not appear in Conversation Tag management unless
they have been explicitly applied to Conversations.

---

## Application-Supplied

Unlike ordinary semantic Tags:

- UBCO
- Hawaii
- Taxes

Contact Tags should be supplied by the application.

The user should not need to remember:

- whether they used Claire or Clare;
- Rusung or Ru;
- Robert or Rob.

Instead the workflow should simply offer:

> Add Contact Tag

For one-to-one Conversations this should normally become a one-click operation.

The application already knows who the other participant is.

---

## Group Conversations

Group Conversations require different behavior.

Automatically creating Contact Tags for every participant is likely to create
noise.

Instead the application should present a participant picker.

The user explicitly selects which participant(s) should become retrieval
coordinates.

The MessageLens user should normally be omitted from this picker.

---

## Retrieval

Contact Tags become another structured retrieval token.

Examples:

```
👤 Claire
🏷 UBCO
```

means:

> Claire's UBCO chapter.

Likewise:

```
👤 Claire
🏷 Condo
```

means:

> Claire's condominium purchase chapter.

The retrieval vocabulary becomes explicit.

Nothing is inferred.

---

## Relationship To Ordinary Tags

Conversation Tags now have two distinct forms.

### Semantic Tags

Created by the user.

Examples:

- UBCO
- Hawaii
- Taxes
- Canucks

These capture meaning.

### Contact Tags

Supplied by the application.

Backed by Contact identity.

These provide retrieval coordinates.

Both are Conversation Tags.

They simply represent different kinds of meaning.

---

## Why This Is Better

This approach provides:

- stable identity;
- automatic display-name updates;
- explicit retrieval;
- no duplicated identity strings;
- no requirement for users to remember exactly which name they typed;
- complete retrieval within the Conversations feature.

It also reinforces the MessageLens philosophy that display identity is resolved
centrally rather than copied into local features.

---

## Architectural Principle

Conversation Contact Tags are **identity-backed Conversation retrieval
coordinates**.

They are Conversation Tags whose durable identity is a canonical Contact rather
than user-authored text.

Display labels are resolved dynamically through the shared Contact identity
resolver.

---

## Decision

**Approve.**

Conversation Contact Tags should become a specialized form of Conversation Tag.

They should:

- belong to the Conversations feature;
- store Contact identity rather than copied text;
- resolve display labels dynamically;
- be application-supplied rather than manually invented;
- support explicit retrieval of relationship chapters;
- remain separate from future Contact Tags, which represent an entirely
  different namespace.

---

## Future work

Future work may allow one or more messages to serve as evidence anchors for a tagged Conversation chapter, making notable segments directly reachable within long threads. This should be designed only after Message Tags have their own clear semantics, to avoid conflating independently tagged evidence with chapter navigation.
