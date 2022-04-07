module.exports = {
  env: {
    browser: false,
    es2021: true,
    mocha: true,
    node: true,
  },
  plugins: ["@typescript-eslint"],
  extends: [
    "standard",
    "plugin:prettier/recommended",
    "plugin:node/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 12,
  },
  settings: {
    node: {
      allowModules: [],
      resolvePaths: [__dirname],
      tryExtensions: [".js", ".ts", ".json", ".node"],
    },
  },
  rules: {
    "node/no-unsupported-features/es-syntax": [
      "error",
      { ignores: ["modules"] },
    ],
  },
  overrides: [
    {
      files: ["truffle-config.js"],
      rules: {
        "node/no-unpublished-require": "off",
      },
    },
  ],
};
