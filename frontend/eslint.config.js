// TEMPLATE — a React 18 + JSX flat config, taken from a real project as the
// starting point. The bootstrap prompt adapts it to this repo's actual stack:
// TypeScript adds typescript-eslint, Next.js adds eslint-config-next, and the
// `settings.react.version` below must match the installed React.
//
// Rules here are the ones the toolchain enforces so no one has to remember
// them. Anything a linter cannot check belongs in docs/engineering/conventions.md.

import js from '@eslint/js'
import globals from 'globals'
import react from 'eslint-plugin-react'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'

export default [
  // .claude/skills/impeccable is a vendored upstream payload kept verbatim and
  // updated only with `npx impeccable update` (ADR 0002). Linting it would
  // report on code we must not edit.
  { ignores: ['dist', 'build', '.claude/skills/impeccable/**'] },

  {
    files: ['**/*.{js,jsx}'],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    settings: { react: { version: '18.3' } }, // TODO(confirm): installed React version
    plugins: {
      react,
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...js.configs.recommended.rules,
      ...react.configs.recommended.rules,
      ...react.configs['jsx-runtime'].rules,
      ...reactHooks.configs.recommended.rules,

      // Security rules — these are the ones worth an `error`, because the
      // failure mode is a vulnerability, not a style complaint.
      // Every target="_blank" link must carry rel="noopener": reverse
      // tabnabbing. `enforceDynamicLinks` extends it to hrefs built at runtime,
      // which is where user- or third-party-supplied URLs arrive.
      'react/jsx-no-target-blank': ['error', { enforceDynamicLinks: 'always' }],
      // href="javascript:..." — a runtime URL sanitiser (if the repo has one)
      // catches these in data; this rule stops them being written by hand.
      'no-script-url': 'error',

      'react-refresh/only-export-components': 'off',
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      // TODO(confirm): with TypeScript, drop this and let types do the work.
      'react/prop-types': 'off',
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
    },
  },

  {
    // Service worker scripts use console.* for runtime diagnostics; allow it.
    files: ['**/serviceWorker.{js,jsx}', '**/sw.{js,jsx}'],
    rules: {
      'no-console': 'off',
    },
  },

  {
    // Build configuration runs in Node, not the browser: `process`, `__dirname`
    // and friends are legitimate here.
    files: ['*.config.js', 'vite.config.js', 'eslint.config.js'],
    languageOptions: { globals: globals.node },
  },

  {
    // Dangerous URLs like `javascript:` are DATA in tests — we cannot prove
    // they get filtered out without being able to write them down.
    files: ['**/*.{test,spec}.{js,jsx}'],
    rules: {
      'no-script-url': 'off',
    },
  },

  {
    // Vitest globals come from `globals: true` in the vite config; ESLint has
    // to be told about them separately. Node globals too, because the setup
    // file and the tests run outside the browser.
    files: ['**/*.{test,spec}.{js,jsx}', 'src/setupTests.{js,jsx}'],
    languageOptions: {
      globals: {
        ...globals.node,
        describe: 'readonly',
        it: 'readonly',
        test: 'readonly',
        expect: 'readonly',
        vi: 'readonly',
        beforeAll: 'readonly',
        beforeEach: 'readonly',
        afterAll: 'readonly',
        afterEach: 'readonly',
      },
    },
  },
]
