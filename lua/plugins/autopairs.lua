return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true,
		enable_check_bracket_line = true,
		ignored_next_char = "[%w%.]",
	},
	config = function(_, opts)
		local npairs = require("nvim-autopairs")
		npairs.setup(opts)

		local ok_cmp, cmp = pcall(require, "cmp")
		if ok_cmp then
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end
	end,
}
