# Assistant Behavior

## Code Modification Policy
**Do NOT modify code unless the CURRENT message contains an explicit,
imperative instruction to change it.**
A previous request to edit code does not grant permission to edit in follow-up messages.

- EDIT ONLY IF the current message gives a direct command to change code:
  "fix", "change", "refactor", "implement", "update", "add", "rewrite",
  "modify", "edit", "delete", "make it...", "replace...".
- A statement of preference, desire, opinion, or observation is NOT permission to edit.
Treat these as discussion and respond with text only:
  - "I want X", "I'd like X", "it would be better if X"
  - "this should be Y", "X is wrong", "X looks off"
  - any question ("why...", "how...", "what if...", "can it...").
- For ALL other messages -> respond with text ONLY, no code edits.
- When in doubt, do NOT edit. Ask: "Do you want me to explain this or
  make a change?"

## Code Comments Policy
**Use only ASCII characters in generated code comments.** No Unicode, emoji, arrows (→), dashes (—), or other non-ASCII symbols.

