# React Hints

What to search for when documenting a **React** SPA.

---

## File Patterns

| What | Where to look |
|------|--------------|
| Entry point | `src/main.tsx`, `src/index.tsx`, `src/App.tsx` |
| Routes | `src/router/`, `src/routes/`, `src/app/routes.tsx`, files with `createBrowserRouter` or `<Route>` |
| Pages | `src/pages/`, `src/views/`, `src/app/` |
| Components | `src/components/`, `src/ui/`, `src/shared/` |
| Hooks | `src/hooks/`, `src/lib/hooks/`, `use*.ts` files |
| State management | `src/store/`, `src/context/`, `src/state/` |
| API/data layer | `src/api/`, `src/services/`, `src/lib/api/`, `src/hooks/use*Query.ts` |
| Config | `vite.config.ts`, `webpack.config.*`, `.env*`, `src/config/` |
| Styles | `src/styles/`, `src/theme/`, `*.module.css`, `*.styled.ts`, `tailwind.config.*` |

## Keywords to Search

- **State:** `createContext`, `useContext`, `useReducer`, `create(` (Zustand), `createSlice` (Redux), `atom` (Jotai/Recoil)
- **Data fetching:** `useQuery`, `useMutation`, `useSWR`, `queryClient`, `QueryClientProvider`
- **Routing:** `createBrowserRouter`, `Routes`, `Route`, `useNavigate`, `useParams`, `Outlet`
- **Auth:** `AuthProvider`, `useAuth`, `ProtectedRoute`, `token`, `interceptor`
- **Forms:** `useForm`, `Controller`, `register`, `handleSubmit` (React Hook Form), `Formik`
- **Styling:** `styled`, `css`, `className`, `theme`, `tokens`, design system imports
- **Testing:** `render(`, `screen.`, `userEvent`, `vi.mock`, `jest.mock`

## Language-Specific Patterns for `how-to/patterns.md`

- Props: always typed interface, `Readonly<Props>`
- Components: function declarations (not arrow in exports), named exports
- Hooks: `use` prefix, proper dependency arrays, custom hooks for shared logic
- State: lift state to nearest common ancestor, colocate state with usage
- Effects: cleanup functions, avoid unnecessary effects
- Memoization: `useMemo`/`useCallback` only when measured perf issue
- Error boundaries for graceful failure

## Framework Specifics

| Bundler | Config file | Dev command | Build output |
|---------|------------|-------------|-------------|
| Vite | `vite.config.ts` | `vite` / `vite dev` | `dist/` |
| Webpack | `webpack.config.*` | `webpack serve` | `build/` / `dist/` |
| Next.js | `next.config.*` | `next dev` | `.next/` |

| Router | Registration pattern |
|--------|---------------------|
| React Router v6+ | `createBrowserRouter([{ path, element, children }])` |
| TanStack Router | `createRootRoute`, `createRoute` |
| Next.js App Router | File-based (`app/` directory) |
