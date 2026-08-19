# Swift Coding Standards — Kid Storytime

> Loaded by every agent before writing Swift. Each rule exists because its
> violation already cost us a bug, a review finding, or reviewer time.
> When you need an exception, record why in the story plan.

## Concurrency

1. **`async/await` over completion handlers** for any new API surface.
   Completion-handler plumbing in `BackendClient` forced every caller to
   rebuild `withCheckedThrowingContinuation` wrappers — don't add more.
2. **Never `DispatchQueue.main.async` inside a `@MainActor` type.** The hop is
   redundant and hides ordering assumptions. Same for
   `.receive(on: RunLoop.main)` in a `@MainActor` view model.
3. **Every `Task` or `Timer` closure that outlives a call frame captures
   `[weak self]` — including *nested* tasks.** The sleep-timer leak survived
   review because the outer closure was weak and the inner `Task` re-captured
   strongly.
4. **Completion callbacks that mutate `@Published` state must be delivered on
   the main actor by the *callee*,** not by whoever remembers at the call site.
5. **One owner per system resource.** `AVAudioSession` is configured by
   `AudioManager` only. If two objects call `setCategory`, the last one wins
   silently and background audio breaks at lock screen — we shipped that bug.

## State & architecture

6. **Views render; view models decide.** No `NotificationCenter.post`, no
   engine mutation, no `objectWillChange.send()` from a `View` body.
7. **Never call `objectWillChange.send()` manually in a type whose state is
   all `@Published`.** If the UI doesn't update without it, find the real bug.
8. **Feature gating goes through `PremiumManager.canUse(_:)`** — nowhere else.
9. **Stores own their persistence keys.** A store exposes
   `static var allUserDefaultsKeys: [String]`; test-reset code aggregates
   these instead of hard-coding key strings that drift.
10. **Inject dependencies through `init`.** Reaching for `.shared` inside a
    view model makes the type untestable. The singleton may exist, but only
    the composition root touches it.

## SwiftUI traps (each one shipped as a bug — see PRODUCT.md §16.5)

11. One `.navigationDestination` per stack, routed by an enum. Multiple
    `isPresented:` destinations silently drop all but the last.
12. `.accessibilityIdentifier` on a container requires
    `.accessibilityElement(children: .contain)` or every child's identifier
    is destroyed — and UI tests go blind.
13. `.swipeActions` works only inside `List`/`Form`. In a `LazyVStack` it
    compiles and does nothing.
14. No `withAnimation` around state that drives programmatic navigation.

## Logging & comments

15. **`Logger(subsystem:category:)`, not `print`.** No emoji-narration
    (`print("✅ Saved!")`) — it reads as machine-generated and ships to
    stderr in release.
16. **Comments explain *why*, never *what*.** If the comment restates the
    line below it, delete it. Good example to copy: `BackendClient.swift`'s
    auth-scheme rationale. Bad pattern to avoid: `// Premium only` above
    `return false` four times in one switch.
17. **At most 3 `MARK:` sections per file.** More is a hint the file needs
    splitting, not labelling.
18. Doc-comments (`///`) on public API only. Private helpers get one only
    when the *why* is genuinely non-obvious.

## Size & structure

19. Files stay under **500 lines**. `AudioManager` at 1,061 lines is the
    cautionary tale — split by responsibility, not by adding MARKs.
20. A view body longer than ~80 lines gets decomposed into named subviews.
21. Debug-only surfaces (`AudioDebugView`, fixtures, force-premium switches)
    compile only under `#if DEBUG`.

## Tests

22. Test names: `test_<subject>_<condition>_<expectation>()`.
23. **Any constant mirrored across codebases gets a contract test on both
    sides** (see the 3000-char prompt cap in `StoryPromptBuilderTests` +
    `quota.test.js`). A number that can drift silently, will.
24. New UI surfaces ship with accessibility identifiers in the same commit —
    UI tests are not a later problem.
