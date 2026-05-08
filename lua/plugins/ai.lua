local ollama_model = vim.env.NVIM_MINUET_OLLAMA_MODEL or vim.env.OLLAMA_MODEL or "deepseek-r1:14b"
local ollama_host = vim.env.OLLAMA_HOST or "http://localhost:11434"
local deepseek_model = vim.env.NVIM_DEEPSEEK_MODEL or "deepseek-v4-flash"

local function ensure_no_proxy(hosts)
	local current = vim.env.NO_PROXY or vim.env.no_proxy or ""
	local seen = {}

	for item in current:gmatch("[^,]+") do
		seen[item] = true
	end

	local values = current ~= "" and { current } or {}
	for _, host in ipairs(hosts) do
		if not seen[host] then
			table.insert(values, host)
		end
	end

	vim.env.NO_PROXY = table.concat(values, ",")
	vim.env.no_proxy = vim.env.NO_PROXY
end

ensure_no_proxy({ "localhost", "127.0.0.1", "::1" })

return {
	{
		"milanglacier/minuet-ai.nvim",
		event = "InsertEnter",
		opts = {
			provider = "openai_compatible",
			n_completions = 1,
			context_window = 2048,
			request_timeout = 8,
			throttle = 1500,
			debounce = 700,
			virtualtext = {
				auto_trigger_ft = {},
				keymap = {
					accept = "<M-l>",
					accept_line = "<M-;>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<M-e>",
				},
			},
			provider_options = {
				openai_compatible = {
					api_key = "TERM",
					name = "Ollama",
					end_point = ollama_host .. "/v1/chat/completions",
					model = ollama_model,
					optional = {
						max_tokens = 128,
						top_p = 0.9,
					},
				},
			},
		},
	},
	{
		"olimorris/codecompanion.nvim",
		cmd = {
			"CodeCompanion",
			"CodeCompanionActions",
			"CodeCompanionChat",
			"CodeCompanionCmd",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			{ "<leader>aa", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "AI actions" },
			{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, desc = "AI chat" },
			{ "<leader>aA", "<cmd>CodeCompanionChat Add<CR>", mode = "v", desc = "Add selection to AI chat" },
			{ "<leader>ae", "<cmd>CodeCompanion /explain<CR>", mode = "v", desc = "Explain selection" },
			{ "<leader>af", "<cmd>CodeCompanion /fix<CR>", mode = "v", desc = "Fix selection" },
		},
		opts = {
			adapters = {
				http = {
					deepseek = function()
						return require("codecompanion.adapters").extend("deepseek", {
							env = {
								api_key = "DEEPSEEK_API_KEY",
							},
							schema = {
								model = {
									default = deepseek_model,
								},
							},
						})
					end,
					ollama = function()
						return require("codecompanion.adapters").extend("ollama", {
							schema = {
								model = {
									default = ollama_model,
								},
							},
						})
					end,
				},
			},
			interactions = {
				chat = {
					adapter = {
						name = "deepseek",
						model = deepseek_model,
					},
				},
				inline = {
					adapter = {
						name = "deepseek",
						model = deepseek_model,
					},
				},
				cmd = {
					adapter = {
						name = "deepseek",
						model = deepseek_model,
					},
				},
				background = {
					adapter = {
						name = "ollama",
						model = ollama_model,
					},
				},
			},
			display = {
				action_palette = {
					provider = "telescope",
				},
			},
			opts = {
				log_level = "ERROR",
			},
		},
	},
}
