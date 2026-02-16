# Design OS - Usage and Examples

## Getting Started

```bash
git clone https://github.com/buildermethods/design-os.git my-project-design
cd my-project-design
git remote remove origin
npm install
npm run dev
```

Then open Claude Code in the same directory and begin with `/product-vision`.

## Complete Workflow

### Phase 1: Product Planning (Foundation)

Run commands in order. Each builds on the previous:

1. `/product-vision`   - Define product name, description, problems/solutions, features
2. `/product-roadmap`  - Break product into 3-5 self-contained sections
3. `/data-model`       - Define core entities and relationships
4. `/design-tokens`    - Choose Tailwind colors and Google Fonts
5. `/design-shell`     - Design app navigation and layout

### Phase 2: Section Design (Repeat per Section)

For each section in the roadmap:

1. `/shape-section`      - Define scope, user flows, UI requirements
2. `/sample-data`        - Generate realistic data + TypeScript types
3. `/design-screen`      - Create production-grade React components
4. `/screenshot-design`  - Capture screenshots (optional)

Restart dev server after creating new components.

### Phase 3: Export

1. `/export-product` - Generate complete handoff package + ZIP

## Command Details

### /product-vision

5-step conversational process:
1. Gather initial input (raw notes/ideas)
2. Ask 3-5 clarifying questions
3. Present draft, iterate until satisfied
4. Create `product/product-overview.md`
5. Point to `/product-roadmap` next

Output: `product/product-overview.md`

### /product-roadmap

Dual purpose: create new or sync existing roadmap.

Creating new:
1. Reads product overview
2. Proposes 3-5 sections (nav items, roadmap phases, self-contained areas)
3. Discusses ordering (dev priority)
4. Creates file with `### N. Title` format

Output: `product/product-roadmap.md`

### /data-model

6-step process:
1. Reads overview and roadmap
2. Proposes entities based on product analysis
3. Refines: additional entities, key info, relationships
4. Present draft
5. Create file (plain language, no schemas)
6. Point to `/design-tokens`

Rules: singular entity names, minimal descriptions, no field types or validation.

Output: `product/data-model/data-model.md`

### /design-tokens

7-step process:
1. Check for product overview
2. Explain colors + typography process
3. Choose colors: primary, secondary, neutral from Tailwind palette
4. Choose typography: heading, body, mono from Google Fonts
5. Present final choices
6. Create two JSON files
7. Point to `/design-shell`

Includes reference data: full Tailwind palette and 6 popular font pairings.

Output: `product/design-system/colors.json`, `product/design-system/typography.json`

### /design-shell

9-step process:
1. Check prerequisites (overview, roadmap; warn if no tokens)
2. Present layout options: sidebar nav, top nav, minimal header
3. Gather: user menu, responsive behavior, extra nav items
4. Present shell spec
5. Create spec file
6. Create React components: AppShell.tsx, MainNav.tsx, UserMenu.tsx, index.ts
7. Create ShellPreview.tsx with hardcoded nav + sample user
8. Apply design tokens
9. List created files, remind to restart dev server

AppShell props interface:

```tsx
interface AppShellProps {
  children: React.ReactNode
  navigationItems: Array<{ label: string; href: string; isActive?: boolean }>
  user?: { name: string; avatarUrl?: string }
  onNavigate?: (href: string) => void
  onLogout?: () => void
}
```

Output: `product/shell/spec.md`, `src/shell/components/`, `src/shell/ShellPreview.tsx`

### /shape-section

8-step process:
1. Check for roadmap
2. Identify target section
3. Gather initial input
4. Ask 4-6 clarifying questions (user actions, info display, key flows, UI patterns, scope)
5. Ask about shell config (inside shell or standalone)
6. Present draft (overview, user flows, UI requirements, display mode)
7. Create `product/sections/[section-id]/spec.md`
8. Point to `/sample-data`

Output: `product/sections/[section-id]/spec.md`

### /sample-data

7-step process:
1. Check for section spec
2. Cross-reference global data model if exists
3. Analyze spec for needed entities, fields, actions
4. Present data structure
5. Generate JSON with `_meta` section + 5-10 realistic records with edge cases
6. Generate TypeScript types with Props interface (optional callbacks)
7. Point to `/design-screen`

Output: `product/sections/[section-id]/data.json`, `product/sections/[section-id]/types.ts`

### /design-screen

10-step process:
1. Check prerequisites (spec.md, data.json, types.ts)
2. Check for design system and shell
3. Analyze requirements
4. Clarify screen scope (which view first if multiple)
5. Invoke frontend-design skill for quality
6. Create props-based component (all data/callbacks via props)
7. Create sub-components if needed
8. Create preview wrapper (default export, imports sample data)
9. Create component index
10. Suggest next steps

Design requirements:
- Mobile responsive (sm:, md:, lg:)
- Light and dark mode (dark: variants)
- Design tokens applied
- All spec requirements implemented
- Callbacks via optional chaining: `onDelete?.(id)`

Output: `src/sections/[section-id]/components/`, preview wrapper

### /screenshot-design

5-step process:
1. Check for Playwright MCP (provides install command if missing)
2. Identify screen design
3. Start dev server in background
4. Capture: navigate to URL, hide nav bar, full-page at 1280px width, PNG
5. Copy to `product/sections/[section-id]/[name].png`

Install command: `claude mcp add playwright npx @playwright/mcp@latest`

Output: `product/sections/[section-id]/[name].png`

### /export-product

15-step process generating the complete handoff package:
1. Check prerequisites (overview, roadmap, at least 1 section with screen designs)
2. Gather all product files
3. Create directory structure
4. Generate product-overview.md
5. Generate milestone instructions (foundation + per-section)
6. Generate one-shot-instructions.md
7. Copy and transform components (fix import paths)
8. Generate section READMEs (overview, flows, callback props table)
9. Generate section test instructions (TDD specs)
10. Generate design system files (tokens.css, tailwind-colors.md, fonts.md)
11. Generate prompt files (one-shot and section prompts)
12. Generate README.md (quick start)
13. Copy screenshots
14. Create product-plan.zip
15. Confirm completion

Output: `product-plan/` directory + `product-plan.zip`

## Export Package Structure

```
product-plan/
├── README.md                            - quick start guide
├── product-overview.md                  - product summary
├── prompts/
│   ├── one-shot-prompt.md               - full implementation prompt
│   └── section-prompt.md                - per-section prompt template
├── instructions/
│   ├── one-shot-instructions.md         - all milestones combined
│   └── incremental/
│       ├── 01-foundation.md             - tokens, data model, routing, shell
│       ├── 02-[first-section].md        - section implementation + TDD
│       └── ...
├── design-system/
│   ├── tokens.css                       - CSS custom properties
│   ├── tailwind-colors.md               - Tailwind color guide
│   └── fonts.md                         - Google Fonts setup
├── data-model/
│   ├── README.md                        - entity descriptions
│   ├── types.ts                         - TypeScript interfaces
│   └── sample-data.json                 - combined sample data
├── shell/
│   ├── README.md                        - design intent
│   ├── components/
│   │   ├── AppShell.tsx                 - layout wrapper
│   │   ├── MainNav.tsx                  - navigation
│   │   ├── UserMenu.tsx                 - user menu
│   │   └── index.ts                     - exports
│   └── screenshot.png                   - visual reference
└── sections/
    └── [section-id]/
        ├── README.md                    - feature overview, callback props table
        ├── tests.md                     - TDD test instructions
        ├── components/
        │   ├── [Component].tsx          - props-based components
        │   └── index.ts                 - exports
        ├── types.ts                     - TypeScript interfaces
        ├── sample-data.json             - test data
        └── screenshot.png               - visual reference
```

## Implementation Approaches

### Incremental (Recommended)

Build milestone by milestone using `prompts/section-prompt.md`:
1. Copy `product-plan/` to your codebase
2. Start with `01-foundation.md` (tokens, data model, routing, shell)
3. Implement one section at a time using the section prompt template
4. Fill in variables: SECTION_NAME, SECTION_ID, NN

### One-Shot

Build everything at once using `prompts/one-shot-prompt.md`:
1. Copy `product-plan/` to your codebase
2. Paste the one-shot prompt into your coding agent
3. The prompt guides the agent to ask clarifying questions about auth, user modeling, tech stack

## Component Design Pattern

All exported components are props-based and portable:

```tsx
<InvoiceList
  invoices={data}
  onView={(id) => navigate(`/invoices/${id}`)}
  onEdit={(id) => navigate(`/invoices/${id}/edit`)}
  onDelete={(id) => confirmDelete(id)}
  onCreate={() => navigate('/invoices/new')}
/>
```

What the export includes:
- Props-based React components with full Tailwind styling
- Responsive design (sm:, md:, lg:)
- Dark mode support
- TypeScript interfaces
- Realistic sample data
- TDD test specs

What the implementation agent builds:
- Backend APIs and database schema
- Authentication and authorization
- Data fetching and state management
- Business logic and validation
- Error/loading/empty states
- Routing and callback wiring
- Tests based on provided specs

## AI Agent Configuration

The `agents.md` file provides directives covering two contexts:

1. Design OS Application - The React app itself (src/), uses stone/lime palette
2. Product Design        - The product being planned (product/, src/sections/)

Four pillars that must exist before screen design:
1. Product Overview - the "what" and "why"
2. Data Model       - the "nouns" of the system
3. Design System    - the "look and feel"
4. Application Shell - the persistent chrome

Design requirements for generated components:
- Mobile responsive with Tailwind prefixes
- Light and dark mode with dark: variants
- Use design tokens when defined
- Props-based (never import data directly)
- Tailwind CSS v4 only (no v3 patterns)
