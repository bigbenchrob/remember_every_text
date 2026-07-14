I think we’ve now crossed an important threshold.

The first two decisions (Conversation Intent and persistence lifetimes) were architectural. This one is product semantics. It answers the question, “What is a Working Set for?” rather than “How do we implement it?”

I particularly like Codex’s implementation guardrail:

”…add this message’s Conversation to the Working Set…”

That’s exactly the kind of wording that prevents architectural drift. If you let the UI say “Add message to Working Set,” you’ve accidentally changed the model without realizing it.

⸻

I think the next question should be:

Hidden / Ignored Conversations

At first glance this looks straightforward, but I think it has the potential to become one of the most subtle Conversation Intent types.

The key question isn’t

“Can the user hide a Conversation?”

It’s

“What does ‘hidden’ actually mean?”

There are at least four plausible interpretations:

1. Hide everywhere
   I never want to see this Conversation again unless I explicitly ask.
2. Hide from normal browsing
   Remove it from ordinary Conversation browsing, but let Search still find it.
3. Hide from Discovery
   Don’t let this Conversation appear in “Dormant,” “Oldest,” “Most Active,” etc., but allow normal retrieval.
4. Hide only in this lens
   This is really UI state rather than Conversation Intent.

Those are very different behaviors.

⸻

My instinct

I would make Hidden a durable Conversation Intent, but define its meaning very narrowly:

Hidden means “exclude from ordinary browsing and discovery.”

It does not mean:

- delete;
- archive;
- remove from Search;
- remove from evidence;
- pretend it doesn’t exist.

Instead:

- All Messages search still finds it.
- A direct Conversation retrieval still finds it.
- If a message search lands in it, the excerpt still opens.
- It simply doesn’t clutter the day-to-day experience.

That seems to fit your earlier observation about “crap” conversations—MFA codes, spam, one-off business messages, delivery notifications, and similar noise. They’re still part of the archive, but they shouldn’t dominate browsing or discovery.

In fact, I wonder whether the user-facing word should even be Hidden. Something like Suppress from browsing or Exclude from discovery might communicate the behavior more accurately. The underlying intent is not “this conversation no longer exists”; it’s “this conversation is not part of my everyday memory landscape.”

I suspect resolving that question will also influence the eventual retrieval UI, because it introduces another intent token:

[ Visibility: Normal ]

[ Visibility: Hidden ]

which feels much cleaner than another sidebar mode. I also suspect you’ll find that “Hidden” is really about visibility policy, whereas Tags and Favourites are about meaning. They all belong under Conversation Intent, but they represent different kinds of intent, which is a useful distinction to preserve.
