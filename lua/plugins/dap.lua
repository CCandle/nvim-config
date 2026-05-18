local function get_codelldb()
	local mason = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
	if vim.fn.executable(mason) == 1 then
		return mason
	end
	return vim.fn.exepath("codelldb")
end

local role = require("core.role")

local dap_deps = {
	"rcarriga/nvim-dap-ui",
	"nvim-neotest/nvim-nio",
}

if role.is_mac then
	table.insert(dap_deps, "mfussenegger/nvim-dap-python")
end

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = dap_deps,
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Debug continue",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Debug REPL",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Debug UI",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Debug terminate",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			if role.is_mac then
				require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = get_codelldb(),
						args = { "--port", "${port}" },
					},
				}

				dap.configurations.cpp = {
					{
						name = "Launch executable",
						type = "codelldb",
						request = "launch",
						program = function()
							return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/build/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				}
				dap.configurations.c = dap.configurations.cpp
			end

			if role.is_mpsoc then
				dap.adapters.gdb = {
					type = "server",
					port = "${port}",
					executable = {
						command = "gdb",
						args = { "-q", "--interpreter=dap" },
					},
				}

				dap.configurations.cpp = {
					{
						name = "Launch (GDB)",
						type = "gdb",
						request = "launch",
						program = function()
							return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/build/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopAtBeginningOfMainSubprogram = false,
					},
				}
				dap.configurations.c = dap.configurations.cpp
			end
		end,
	},
}
