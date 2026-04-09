import js from "@eslint/js";
import prettier from "eslint-config-prettier";
import unusedImports from "eslint-plugin-unused-imports";
import tseslint from "typescript-eslint";

export default tseslint.config(
	// Global ignores
	{
		ignores: [
			"**/node_modules/**",
			"**/dist/**",
			"**/.next/**",
			"**/.turbo/**",
			"**/.open-next/**",
			"**/.wrangler/**",
			"**/out/**",
		],
	},

	// Base configs
	js.configs.recommended,
	...tseslint.configs.recommended,

	// Unused imports plugin
	{
		plugins: {
			"unused-imports": unusedImports,
		},
		rules: {
			"no-unused-vars": "off",
			"@typescript-eslint/no-unused-vars": "off",
			"unused-imports/no-unused-imports": "error",
			"unused-imports/no-unused-vars": [
				"error",
				{
					vars: "all",
					varsIgnorePattern: "^_",
					args: "after-used",
					argsIgnorePattern: "^_",
				},
			],
		},
	},

	// General rules
	{
		rules: {
			"no-param-reassign": "error",
			"@typescript-eslint/no-non-null-assertion": "warn",
			"@typescript-eslint/no-explicit-any": "warn",
			"@typescript-eslint/no-empty-object-type": "off",
			"@typescript-eslint/no-require-imports": "off",
		},
	},

	// Node.js globals for config files
	{
		files: ["**/*.config.{ts,mjs,js}", "**/*.mjs"],
		languageOptions: {
			globals: {
				process: "readonly",
				console: "readonly",
				Buffer: "readonly",
				__dirname: "readonly",
				__filename: "readonly",
				module: "readonly",
				require: "readonly",
			},
		},
	},

	// Allow default exports in framework files
	{
		files: [
			"**/app/**/{page,layout,loading,error,not-found,sitemap,robots,manifest,route}.{ts,tsx}",
			"**/*.config.{ts,mjs,js}",
			"**/next.config.{ts,mjs,js}",
			"**/postcss.config.mjs",
			"**/vitest.config.ts",
			"**/vitest.workspace.ts",
			"apps/worker/src/index.ts",
		],
		rules: {},
	},

	// Prettier must be last
	prettier,
);
