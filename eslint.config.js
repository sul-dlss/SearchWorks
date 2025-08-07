import { default as importPlugin } from 'eslint-plugin-import';

export default [
  {
    ignores: [
      'node_modules/**',
      'app/assets/**',
      'public/**',
      'vendor/**',
      'coverage/**',
      'tmp/**',
      'log/**',
      'db/**',
      'bin/**',
      'app/javascript/vendor/**'
    ]
  },
  {
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        Blacklight: 'readonly',
        Turbo: 'readonly',
        document: 'readonly',
        window: 'readonly',
        $: 'readonly',
        jQuery: 'readonly',
        global: 'readonly',
        undefined: 'readonly'
      }
    },
    plugins: {
      import: importPlugin
    },
    rules: {
      'no-console': ['error', { allow: ['error'] }],
      'import/no-extraneous-dependencies': 'error',
      'no-param-reassign': 'off',
      'max-len': ['warn', { code: 150 }],
      'no-unused-vars': ['error', {
        argsIgnorePattern: '^(_|e|f|\\$.*|window|document|global)'
      }]
    }
  }
];
