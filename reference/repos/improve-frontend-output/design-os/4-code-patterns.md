# Design OS - Code Patterns

## Coding Style and Conventions

Naming:
- PascalCase for component names: `ProductPage`, `SectionPage`, `ColorSwatch`
- camelCase for functions and variables: `loadProductData`, `sectionData`, `stepStatuses`
- kebab-case for file names: `dropdown-menu.tsx`, `product-loader.ts`
- PascalCase for UI component files exporting sub-components: `button.tsx` exports `Button`

Imports:
- Path alias `@/` used consistently: `@/lib/utils`, `@/components/ui/card`
- External imports first, then internal imports separated by blank line
- Radix primitives as namespace: `import * as DialogPrimitive from "@radix-ui/react-dialog"`
- React as namespace: `import * as React from "react"`
- Icons individually: `import { ChevronRight, Layout } from 'lucide-react'`

Other conventions:
- Mixed quotes (UI components double, page components single)
- No semicolons anywhere
- Helper/pure functions above main export, private sub-components below
- UI components use grouped `export {}` at bottom, pages use inline `export function`

## Component Patterns

### shadcn/ui Primitives

- Plain functions (not `React.forwardRef`, not arrow functions)
- Props typed via `React.ComponentProps<"element">` or `React.ComponentProps<typeof RadixPrimitive>`
- Destructured props with `className` first, rest spread: `{ className, ...props }`
- Every component gets `data-slot="component-name"` attribute
- `cn()` utility always wraps className merging

### Variant Pattern (class-variance-authority)

Used by `Button` and `Badge`:

```tsx
const buttonVariants = cva("base-classes", {
  variants: {
    variant: { default: "...", destructive: "..." },
    size: { default: "...", sm: "...", lg: "..." },
  },
  defaultVariants: { variant: "default", size: "default" },
})
```

Both the component and variants constant are exported.

### Polymorphic/asChild Pattern

`Button` and `Badge` support `asChild` prop using Radix `Slot`. When `asChild=true`, renders as child element instead of default HTML element.

### Composition Pattern

Complex components split into independently exported sub-components:

```
Card -> CardHeader, CardContent, CardFooter, CardTitle, CardDescription, CardAction
```

Sub-components communicate through CSS selectors (`has-data-[slot=...]`).

### Page Components

- Use `useMemo` for data loading (synchronous)
- Use react-router-dom for navigation (`useNavigate`, `useParams`, `Link`)
- Step-indicator wizard pattern with statuses (completed, current, upcoming)
- Conditional rendering: populated data vs EmptyState
- Layout handled by shared `AppLayout` wrapper

### Props Patterns

- Extension via intersection: `React.ComponentProps<"button"> & VariantProps<typeof buttonVariants> & { asChild?: boolean }`
- Inline types preferred over separate interfaces
- Default values in destructuring: `side = "right"`, `asChild = false`

## Styling Approach

Tailwind CSS v4:
- `@import "tailwindcss"` (v4 syntax)
- `@theme` and `@theme inline` blocks for design tokens
- `@custom-variant dark (&:is(.dark *))` for class-based dark mode
- `@layer base` and `@layer utilities` for custom styles

Design tokens as CSS custom properties:
- OKLCH color space
- Full semantic token set: background, foreground, card, popover, primary, secondary, muted, accent, destructive, border, input, ring, chart colors, sidebar colors
- Radius tokens from single `--radius` base variable
- Light and dark theme with complete token sets

All styling via Tailwind utility classes inline in JSX. No CSS modules, no styled-components, no inline styles (except dynamic colors). Stone palette throughout for warm neutral aesthetic.

Animations:
- `tw-animate-css` for Radix animation integration
- Custom collapse and fade animations
- Radix state animations via `data-[state=open]:animate-in`

Typography:
- DM Sans for display/body/sans
- IBM Plex Mono for monospace
- Font families via `--font-*` CSS custom properties

## shadcn/ui Components

| Component    | Radix Primitive                  | Has Variants |
|--------------|----------------------------------|--------------|
| Button       | @radix-ui/react-slot             | Yes (cva)    |
| Badge        | @radix-ui/react-slot             | Yes (cva)    |
| Card         | None (pure HTML)                 | No           |
| Dialog       | @radix-ui/react-dialog           | No           |
| Tabs         | @radix-ui/react-tabs             | No           |
| Input        | None (pure HTML)                 | No           |
| Table        | None (pure HTML)                 | No           |
| Sheet        | @radix-ui/react-dialog           | No           |
| DropdownMenu | @radix-ui/react-dropdown-menu    | No           |
| Label        | @radix-ui/react-label            | No           |
| Separator    | @radix-ui/react-separator        | No           |
| Skeleton     | None (pure HTML)                 | No           |
| Avatar       | @radix-ui/react-avatar           | No           |
| Collapsible  | @radix-ui/react-collapsible      | No           |

Key utility stack: `clsx` + `tailwind-merge` (via `cn()`) + `class-variance-authority`.

## TypeScript Patterns

- Strict typing via `React.ComponentProps<>` for all component props
- `VariantProps<typeof buttonVariants>` for cva type extraction
- Intersection types (`&`) for extending native props
- `import { type StepStatus }` for type-only imports
- `ReturnType<typeof loadSectionData>` instead of separate type exports
- Generics: `useParams<{ sectionId: string }>`
- No `any` types visible
- No enums; string literal unions for variants
- Interfaces used sparingly; inline types preferred

## Error Handling

Minimal approach:
- Graceful fallbacks: `productData.roadmap?.sections || []`
- Optional chaining: `sectionData?.screenDesigns`
- Missing route params: early return with "not found" UI
- No try/catch, no error boundaries, no error state management
- Empty states via dedicated `<EmptyState type="..." />` component

## Testing

No test files, configurations, or testing dependencies found. No `*.test.*`, `*.spec.*`, or test runner configs. No vitest, jest, or @testing-library.

However, the export package generates `tests.md` files with framework-agnostic TDD specs for the implementation agent to use.

## CI/CD

Two GitHub workflows, both focused on community management (not code quality):

1. pr-decline.yml - Automated PR decline system with 4 canned reason labels. Uses `actions/github-script@v7`.
2. stale.yml      - Daily stale issue cleanup (30 days + 7 days). Bug-labeled issues exempt. Uses `actions/stale@v9`.

No build, test, or deploy workflows.

## Contribution Process

- Discussions-first workflow: bugs go to Discussions first, features need `approved` label
- PRs require linked Issue or Discussion
- PR template: summary, linked item, test steps checklist, reviewer notes
- Automated PR decline via label-triggered workflow
- Docs-only PRs always welcome
- Paid support via Builder Methods Pro
