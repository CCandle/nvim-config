local function project_root(markers)
	return function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		on_dir(vim.fs.root(fname, markers) or vim.uv.cwd())
	end
end

local function clangd_cmd(dispatchers, config)
	local cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
		"--pch-storage=memory",
	}

	local root_dir = config.root_dir
	local build_db = root_dir and (root_dir .. "/build/compile_commands.json")
	if build_db and vim.uv.fs_stat(build_db) then
		table.insert(cmd, "--compile-commands-dir=" .. root_dir .. "/build")
	end

	return vim.lsp.rpc.start(cmd, dispatchers, {
		cwd = root_dir,
		env = config.cmd_env,
		detached = config.detached,
	})
end

return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			PATH = "prepend",
			ui = { border = "rounded" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local function map(bufnr, mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
			end

			local function on_attach(client, bufnr)
				if client.name == "ruff" then
					client.server_capabilities.hoverProvider = false
				end

				map(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to definition")
				map(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map(bufnr, "n", "gr", vim.lsp.buf.references, "References")
				map(bufnr, "n", "gi", vim.lsp.buf.implementation, "Implementation")
				map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover")
				map(bufnr, "n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
				map(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
				map(bufnr, "n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
				map(bufnr, "n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
				map(bufnr, "n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

				if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end

			vim.diagnostic.config({
				virtual_text = { prefix = "●", spacing = 2 },
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
			})

			vim.lsp.config("clangd", {
				capabilities = capabilities,
				on_attach = on_attach,
				cmd = clangd_cmd,
				root_dir = project_root({ "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", ".git" }),
			})

			vim.lsp.config("basedpyright", {
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = project_root({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }),
				settings = {
					basedpyright = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "workspace",
							typeCheckingMode = "basic",
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			vim.lsp.config("ruff", {
				capabilities = capabilities,
				on_attach = on_attach,
				root_dir = project_root({ "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" }),
			})

			vim.lsp.enable({ "clangd", "basedpyright", "ruff" })
		end,
	},
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp", "objc", "objcpp", "cuda" },
		opts = {
			inlay_hints = { inline = false },
			ast = { role_icons = "none", kind_icons = "none" },
		},
	},
}
