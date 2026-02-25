---
name: web-design-guidelines
description: Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".
allowed-tools: Read, Grep, Glob, Bash, WebFetch
---

# Web Interface Guidelines

Review files for compliance with Vercel's Web Interface Guidelines.

This skill is for **UI implementation and review only** -- not for backend or infrastructure work.

## How It Works

1. Fetch the latest guidelines from the source URL below using WebFetch
2. Read the specified files (or prompt user for files/pattern)
3. Check against all rules in the fetched guidelines
4. Output findings in the terse `file:line` format

## Guidelines Source

Fetch fresh guidelines before each review:

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

Use the WebFetch tool to retrieve this URL at the start of every review session to ensure you are working with the latest rules.

## Rule Categories (summary)

- **Accessibility**: aria-label, semantic HTML, keyboard handlers, headings hierarchy
- **Focus States**: focus-visible, no outline-none without replacement, focus-within
- **Forms**: autocomplete, correct input types, no paste blocking, inline errors
- **Animation**: prefers-reduced-motion, compositor-friendly transforms, no transition:all
- **Typography**: ellipsis chars, curly quotes, non-breaking spaces, tabular-nums
- **Content Handling**: truncation, min-w-0 for flex, empty states, user-generated content
- **Images**: explicit width/height, lazy loading, priority/fetchpriority
- **Performance**: virtualization for large lists, no layout reads in render, preconnect
- **Navigation & State**: URL reflects state, deep-linking, destructive action confirmation
- **Touch & Interaction**: touch-action:manipulation, overscroll-behavior, drag handling
- **Safe Areas & Layout**: safe-area-inset, overflow control, flex/grid over JS
- **Dark Mode & Theming**: color-scheme, theme-color meta, explicit select colors
- **Locale & i18n**: Intl.DateTimeFormat, Intl.NumberFormat, Accept-Language
- **Hydration Safety**: onChange with value, date/time guards, suppressHydrationWarning
- **Hover & Interactive States**: hover feedback, increased contrast for interactive states
- **Content & Copy**: active voice, title case, numerals, specific button labels

## Anti-patterns to Flag

- `user-scalable=no` or `maximum-scale=1`
- `onPaste` with `preventDefault`
- `transition: all`
- `outline-none` without `focus-visible` replacement
- Inline `onClick` navigation without `<a>`
- `div`/`span` with click handlers instead of `button`
- Images without dimensions
- Large arrays `.map()` without virtualization
- Form inputs without labels
- Icon buttons without `aria-label`
- Hardcoded date/number formats
- `autoFocus` without clear justification

## Output Format

Report all findings in `file:line` format:

```
src/components/Button.tsx:42 — outline-none without focus-visible replacement
src/components/Card.tsx:15 — img missing explicit width/height
src/pages/Dashboard.tsx:88 — large array .map() without virtualization
```
