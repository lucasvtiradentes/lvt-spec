# Design OS - Technical Details

## Tech Stack

| Layer          | Technology                | Version  |
|----------------|---------------------------|----------|
| Framework      | React                     | ^19.2.0  |
| Language       | TypeScript                | ~5.9.3   |
| Build Tool     | Vite                      | ^7.2.4   |
| CSS Framework  | Tailwind CSS v4           | ^4.1.17  |
| Routing        | react-router-dom          | ^7.9.6   |
| UI Kit         | shadcn/ui (new-york)      | -        |
| Icons          | lucide-react              | ^0.554.0 |
| Linting        | ESLint (flat config)      | ^9.39.1  |
| Module System  | ESM ("type": "module")    | -        |

## Runtime Dependencies

| Package                         | Version    | Purpose                          |
|---------------------------------|------------|----------------------------------|
| react                           | ^19.2.0    | UI framework                     |
| react-dom                       | ^19.2.0    | React DOM renderer               |
| react-router-dom                | ^7.9.6     | Client-side routing              |
| tailwindcss                     | ^4.1.17    | Utility-first CSS framework      |
| @tailwindcss/vite               | ^4.1.17    | Tailwind v4 Vite plugin          |
| @radix-ui/react-avatar          | ^1.1.11    | Avatar primitive                 |
| @radix-ui/react-collapsible     | ^1.1.12    | Collapsible primitive            |
| @radix-ui/react-dialog          | ^1.1.15    | Dialog/modal primitive           |
| @radix-ui/react-dropdown-menu   | ^2.1.16    | Dropdown menu primitive          |
| @radix-ui/react-label           | ^2.1.8     | Label primitive                  |
| @radix-ui/react-separator       | ^1.1.8     | Separator primitive              |
| @radix-ui/react-slot            | ^1.2.4     | Slot composition primitive       |
| @radix-ui/react-tabs            | ^1.1.13    | Tabs primitive                   |
| class-variance-authority        | ^0.7.1     | Variant-based class composition  |
| clsx                            | ^2.1.1     | Conditional classnames           |
| tailwind-merge                  | ^3.4.0     | Merge Tailwind classes safely    |
| lucide-react                    | ^0.554.0   | Icon library                     |
| jszip                           | ^3.10.1    | ZIP file creation for exports    |

## Dev Dependencies

| Package                         | Version    | Purpose                          |
|---------------------------------|------------|----------------------------------|
| typescript                      | ~5.9.3     | Type checking                    |
| vite                            | ^7.2.4     | Build tool / dev server          |
| @vitejs/plugin-react            | ^5.1.1     | React Fast Refresh for Vite      |
| eslint                          | ^9.39.1    | Linter                           |
| @eslint/js                      | ^9.39.1    | ESLint JS recommended rules      |
| typescript-eslint               | ^8.46.4    | TypeScript ESLint integration    |
| eslint-plugin-react-hooks       | ^7.0.1     | React hooks lint rules           |
| eslint-plugin-react-refresh     | ^0.4.24    | React Refresh lint rules         |
| globals                         | ^16.5.0    | Global variable definitions      |
| @types/node                     | ^24.10.1   | Node.js type definitions         |
| @types/react                    | ^19.2.5    | React type definitions           |
| @types/react-dom                | ^19.2.3    | React DOM type definitions       |
| tw-animate-css                  | ^1.4.0     | Tailwind animation utilities     |

## Installation

```bash
git clone https://github.com/buildermethods/design-os.git my-project-design
cd my-project-design
git remote remove origin
npm install
npm run dev
```

Requirements: Node.js v18+, npm.

## Build Commands

| Command           | Script                    | Purpose                            |
|-------------------|---------------------------|------------------------------------|
| npm run dev       | vite                      | Start dev server on port 3000      |
| npm run build     | tsc -b && vite build      | Type-check then production build   |
| npm run lint      | eslint .                  | Lint all files                     |
| npm run preview   | vite preview              | Preview production build locally   |

## Configuration

### Vite (vite.config.ts)

- Plugins: `@vitejs/plugin-react` + `@tailwindcss/vite` (native Tailwind v4 integration)
- Path alias: `@` mapped to `./src`
- Dev server port: 3000

### TypeScript

Three config files using project references pattern:

- tsconfig.json (root)           - References app and node configs, defines `@/*` path alias
- tsconfig.app.json (app code)   - Target ES2022, strict mode, `erasableSyntaxOnly`, `verbatimModuleSyntax`, `noUncheckedSideEffectImports`
- tsconfig.node.json (Vite side) - Target ES2023, covers only `vite.config.ts`

### ESLint (eslint.config.js)

- Flat config format (ESLint v9)
- Extends: `@eslint/js` recommended, `typescript-eslint` recommended, `react-hooks`, `react-refresh`
- ECMA version: 2020
- Globals: browser

### shadcn/ui (components.json)

- Style: new-york
- RSC: false
- Tailwind CSS file: src/index.css
- Base color: neutral
- CSS variables: true
- Icon library: lucide
- Aliases: `@/components`, `@/components/ui`, `@/lib/utils`, `@/lib`, `@/hooks`

## Notable Technical Decisions

1. Tailwind CSS v4 with native Vite plugin (no PostCSS, no tailwind.config.js)
2. React 19 with latest features (Actions, use())
3. TypeScript 5.9 with `erasableSyntaxOnly` for Node-native TS stripping compatibility
4. `noUncheckedSideEffectImports` to catch dead bare imports
5. Build-time static loading via `import.meta.glob({ eager: true })` -- no runtime data fetching
6. jszip for client-side ZIP generation of the export package
7. Google Fonts loaded externally (DM Sans, IBM Plex Mono) in index.html
8. Private package (`"private": true`, version `0.0.0`) -- not published to npm
