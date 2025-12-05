import { default as importPlugin } from "eslint-plugin-import"
import stylistic from "@stylistic/eslint-plugin"

export default [
  {
    ignores: [
      "node_modules/**",
      "app/assets/**",
      "public/**",
      "vendor/**",
      "coverage/**",
      "tmp/**",
      "log/**",
      "db/**",
      "bin/**",
      "app/javascript/vendor/**"
    ]
  },
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        Blacklight: "readonly",
        Turbo: "readonly",
        document: "readonly",
        window: "readonly",
        $: "readonly",
        jQuery: "readonly",
        global: "readonly",
        undefined: "readonly"
      }
    },
    plugins: {
      import: importPlugin,
      "@stylistic": stylistic
    },
    rules: {
      "no-console": ["error", { allow: ["error"] }],
      "import/no-extraneous-dependencies": "error",
      "no-param-reassign": "off",
      "max-len": ["warn", { code: 150 }],
      "no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^(_|e|f|\\$.*|window|document|global)"
        }
      ],
      // Stylistic rules (warnings for gradual adoption)
      "@stylistic/indent": ["warn", 2],
      "@stylistic/quotes": ["warn", "double", { avoidEscape: true }],
      "@stylistic/semi": ["warn", "never"],
      "@stylistic/comma-dangle": ["warn", "never"],
      "@stylistic/object-curly-spacing": ["warn", "always"],
      "@stylistic/array-bracket-spacing": ["warn", "never"],
      "@stylistic/space-before-function-paren": ["warn", "never"],
      "@stylistic/space-in-parens": ["warn", "never"],
      "@stylistic/keyword-spacing": ["warn", { before: true, after: true }],
      "@stylistic/space-infix-ops": "warn",
      "@stylistic/comma-spacing": ["warn", { before: false, after: true }],
      "@stylistic/key-spacing": [
        "warn",
        { beforeColon: false, afterColon: true }
      ],
      "@stylistic/no-trailing-spaces": "warn",
      "@stylistic/eol-last": ["warn", "always"]
    }
  }
]
