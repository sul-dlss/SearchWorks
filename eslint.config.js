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
        jQuery: 'readonly'
      }
    },
    plugins: {
      import: importPlugin
    },
    rules: {
      'no-console': ['error', { allow: ['warn', 'error'] }],
      'import/no-extraneous-dependencies': 'off',
      'no-param-reassign': 'off',
      'max-len': ['error', { code: 120 }],
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }]
    }
  }
];