---
name: vercel-react-best-practices
description: Provides React and Next.js performance optimization guidelines from Vercel Engineering. Activates when writing, reviewing, or refactoring React/Next.js code.
---

# Vercel React Best Practices

57 rules across 8 categories, prioritized by impact.

## Applicability

This skill applies **only** to React and Next.js projects. Do not apply these rules to non-React codebases. Detect applicability by checking for `react` or `next` in `package.json` dependencies, or the presence of `.tsx`/`.jsx` files and `next.config.*`.

## When to Apply

- Writing new React components or Next.js pages
- Implementing data fetching (client or server-side)
- Reviewing code for performance issues
- Refactoring existing React/Next.js code
- Optimizing bundle size or load times

---

## 1. Eliminating Waterfalls (CRITICAL)

Sequential async operations are the single biggest performance killer. Always parallelize independent work.

- [ ] **async-defer-await**: Move `await` into the branch where the result is actually used; do not await at the top of a function if only one code path needs the value
- [ ] **async-parallel**: Use `Promise.all()` for independent async operations instead of sequential `await` calls
- [ ] **async-dependencies**: Use `better-all` or manual promise chaining for partially dependent async operations where some promises depend on others but not all are sequential
- [ ] **async-api-routes**: In API routes, start promises as early as possible and `await` them as late as possible to maximize concurrency
- [ ] **async-suspense-boundaries**: Wrap async server components in `<Suspense>` boundaries to stream content incrementally instead of blocking the entire page

## 2. Bundle Size Optimization (CRITICAL)

Every kilobyte shipped to the client costs load time. Minimize what gets bundled.

- [ ] **bundle-barrel-imports**: Import directly from the module file (`import { X } from 'lib/X'`), never from barrel `index.ts` files that pull in the entire package
- [ ] **bundle-dynamic-imports**: Use `next/dynamic` or `React.lazy()` for heavy components (charts, editors, maps) that are not needed at initial render
- [ ] **bundle-defer-third-party**: Load analytics, logging, and non-critical third-party scripts after hydration using `next/script` with `strategy="afterInteractive"` or `"lazyOnload"`
- [ ] **bundle-conditional**: Load modules only when their feature is activated (e.g., behind a feature flag or user action) using dynamic `import()`
- [ ] **bundle-preload**: Preload route chunks on hover/focus of navigation links to improve perceived speed without increasing initial bundle

## 3. Server-Side Performance (HIGH)

Maximize server efficiency and minimize data sent to the client.

- [ ] **server-auth-actions**: Authenticate server actions with the same rigor as API routes; never trust the client to only call authorized actions
- [ ] **server-cache-react**: Use `React.cache()` to deduplicate identical data fetches within a single server render pass (per-request memoization)
- [ ] **server-cache-lru**: Use an LRU cache (e.g., `lru-cache`) for cross-request caching of expensive computations or external API calls on the server
- [ ] **server-dedup-props**: Avoid passing the same large object as props to multiple server components; fetch once in a parent and pass down, or use `React.cache()`
- [ ] **server-serialization**: Minimize data passed from server components to client components; serialize only the fields the client actually needs, not entire database objects
- [ ] **server-parallel-fetching**: Restructure component trees so sibling server components fetch data in parallel rather than creating parent-child fetch waterfalls
- [ ] **server-after-nonblocking**: Use the `after()` API (Next.js 15+) for non-blocking post-response work like logging, analytics, and cache revalidation

## 4. Client-Side Data Fetching (MEDIUM-HIGH)

Efficient client-side data management reduces network overhead and improves responsiveness.

- [ ] **client-swr-dedup**: Use SWR or React Query for automatic request deduplication, caching, and revalidation instead of raw `fetch` in `useEffect`
- [ ] **client-event-listeners**: Deduplicate global event listeners; use a single shared listener with a subscriber pattern instead of one listener per component instance
- [ ] **client-passive-event-listeners**: Use `{ passive: true }` for scroll and touch event listeners to avoid blocking the main thread during scrolling
- [ ] **client-localstorage-schema**: Version localStorage data with a schema key; minimize stored data size and clean up stale keys on schema version change

## 5. Re-render Optimization (MEDIUM)

Prevent unnecessary re-renders to keep the UI responsive under load.

- [ ] **rerender-defer-reads**: Do not subscribe a component to state that is only used inside event callbacks; read it inside the callback instead using a ref or store selector
- [ ] **rerender-memo**: Extract expensive subtrees into `React.memo()` wrapped components so they skip re-render when their props have not changed
- [ ] **rerender-memo-with-default-value**: Hoist default values for non-primitive props (objects, arrays) to module scope so `React.memo()` shallow comparison works correctly
- [ ] **rerender-dependencies**: Use primitive values (strings, numbers, booleans) as `useEffect`/`useMemo`/`useCallback` dependencies instead of objects to avoid false invalidation
- [ ] **rerender-derived-state**: Subscribe components to derived booleans (e.g., `isLoaded`) rather than raw data objects to minimize re-render surface
- [ ] **rerender-derived-state-no-effect**: Derive state during render (inline computation or `useMemo`) instead of using `useEffect` + `setState`, which causes an extra render cycle
- [ ] **rerender-functional-setstate**: Use functional `setState(prev => ...)` form so callbacks do not depend on the current state value, making them stable for `useCallback`
- [ ] **rerender-lazy-state-init**: Pass a function to `useState(() => expensiveInit())` instead of calling `expensiveInit()` directly, so it only runs on mount
- [ ] **rerender-simple-expression-in-memo**: Do not wrap simple primitive expressions in `useMemo`; the overhead of memoization exceeds the cost of recomputing `a + b`
- [ ] **rerender-move-effect-to-event**: Put interaction-driven logic in event handlers, not `useEffect`; effects are for synchronization with external systems, not for responding to user actions
- [ ] **rerender-transitions**: Use `startTransition` for non-urgent state updates (filtering, tab switching) so they do not block urgent updates like typing
- [ ] **rerender-use-ref-transient-values**: Use `useRef` for values that change frequently but do not need to trigger a re-render (scroll position, timers, animation frames)

## 6. Rendering Performance (MEDIUM)

Optimize how the DOM is updated and painted.

- [ ] **rendering-animate-svg-wrapper**: Animate a `<div>` wrapper around SVG elements rather than the SVG element itself; DOM updates on SVGs are slower
- [ ] **rendering-content-visibility**: Use CSS `content-visibility: auto` for long scrollable lists to skip rendering of off-screen items
- [ ] **rendering-hoist-jsx**: Extract static JSX (elements that never change) outside the component function so React reuses the same object reference
- [ ] **rendering-svg-precision**: Reduce SVG coordinate precision to 1-2 decimal places to cut SVG file size without visible quality loss
- [ ] **rendering-hydration-no-flicker**: Use an inline `<script>` in `<head>` (via Next.js `beforeInteractive`) to set client-only data (theme, locale) before first paint to prevent hydration flicker
- [ ] **rendering-hydration-suppress-warning**: Use `suppressHydrationWarning` on elements with expected server/client mismatches (timestamps, random IDs) instead of restructuring code
- [ ] **rendering-activity**: Use the `<Activity>` component (React 19+) for show/hide toggling that preserves component state without unmounting
- [ ] **rendering-conditional-render**: Use ternary operators (`cond ? <A/> : null`) instead of `&&` for conditional rendering to avoid accidentally rendering `0` or `""` to the DOM
- [ ] **rendering-usetransition-loading**: Prefer `useTransition` with `isPending` for loading states over manual `useState` booleans; it integrates with Suspense and concurrent features

## 7. JavaScript Performance (LOW-MEDIUM)

Micro-optimizations that compound in hot paths and large datasets.

- [ ] **js-batch-dom-css**: Group CSS changes by setting `className` or `el.style.cssText` in a single operation instead of setting individual style properties
- [ ] **js-index-maps**: Build a `Map` or plain object index for repeated lookups on arrays instead of using `.find()` or `.filter()` in loops
- [ ] **js-cache-property-access**: Cache deeply nested object property access (`const val = obj.a.b.c`) in a local variable when accessed multiple times in a loop
- [ ] **js-cache-function-results**: Cache expensive function results in a module-level `Map` when the function is called repeatedly with the same arguments
- [ ] **js-cache-storage**: Cache `localStorage.getItem()` / `sessionStorage.getItem()` reads in a variable; do not read from storage on every render or function call
- [ ] **js-combine-iterations**: Combine multiple `.filter().map().reduce()` chains into a single loop to avoid creating intermediate arrays
- [ ] **js-length-check-first**: Check `array.length` before performing expensive comparisons or operations on array elements (fail fast)
- [ ] **js-early-exit**: Return early from functions when preconditions are not met instead of nesting logic in deeply nested `if` blocks
- [ ] **js-hoist-regexp**: Hoist `RegExp` creation outside loops and hot paths; compile the regex once at module level and reuse it
- [ ] **js-min-max-loop**: Use a single `for` loop with comparisons for finding min/max values instead of `Math.max(...arr)` which has call stack limits on large arrays
- [ ] **js-set-map-lookups**: Use `Set` for membership checks and `Map` for key-value lookups instead of arrays; both provide O(1) access vs O(n) for array `.includes()`
- [ ] **js-tosorted-immutable**: Use `.toSorted()`, `.toReversed()`, `.toSpliced()` for immutable array operations instead of cloning then mutating

## 8. Advanced Patterns (LOW)

Specialized patterns for complex applications.

- [ ] **advanced-event-handler-refs**: Store event handler functions in refs (`useRef`) when they need to be stable across renders but always call the latest version
- [ ] **advanced-init-once**: Initialize global singletons (SDK clients, telemetry) exactly once per app load using a module-level flag or `React.cache()`, not inside components
- [ ] **advanced-use-latest**: Implement a `useLatest(value)` hook that returns a ref always pointing to the latest value, providing a stable reference for callbacks without re-render
