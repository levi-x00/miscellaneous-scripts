module.exports = {
  env: {
    browser: false,
    es2021: true,
  },
  extends: 'airbnb-base',
  overrides: [
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  rules: {
    quotes: ['error', 'single'],
    // we want to force semicolons
    semi: ['error', 'always'],
    // we use 2 spaces to indent our code
    indent: ['off', 2],
    'no-tabs': ['error', { allowIndentationTabs: true }],
    // we want to avoid extraneous spaces
    'no-multi-spaces': ['error'],
    'no-console': 'off',
  },
};
