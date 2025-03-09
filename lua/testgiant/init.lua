local M = {}

local config = {
	keymap = "<leader>r", -- Key mapping to trigger the test runner.
	languages = {
		python = {
			include_pattern = "^test_", -- Only include files starting with "test_"
			exclude_pattern = "test_fixtures", -- Exclude files matching "test_fixtures"
			runner = "pytest", -- Hardcoded test runner for now.
			pytest_options = "-srA --disable-warnings --showlocals",
		},
		-- Future language configurations can be added here.
	},
	fallback_to_vim_test = true, -- If no configuration for the filetype, use vim-test's TestNearest.
}

function M.setup(user_config)
	user_config = user_config or {}
	config = vim.tbl_deep_extend("force", config, user_config)

	if config.keymap then
		vim.api.nvim_set_keymap(
			"n",
			config.keymap,
			":lua require('testgiant').run_current_scope()<CR>",
			{ noremap = true, silent = true }
		)
	end
end

local function get_test_identifier()
	local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
	if not ok then
		print("nvim-treesitter is required for test-giant")
		return ""
	end

	local node = ts_utils.get_node_at_cursor()
	while node do
		local node_type = node:type()
		if node_type == "function_definition" then
			local field = node:field("name")
			if field and field[1] then
				local name = vim.treesitter.get_node_text(field[1], 0)
				print("Found test method: " .. name)
				return "::" .. name
			end
		elseif node_type == "class_definition" then
			local field = node:field("name")
			if field and field[1] then
				local name = vim.treesitter.get_node_text(field[1], 0)
				print("Found test class: " .. name)
				return "::" .. name
			end
		end
		node = node:parent()
	end
	return ""
end

function M.run_current_scope()
	local ft = vim.bo.filetype
	local lang_config = config.languages[ft]
	local file = vim.fn.expand("%:p")
	local filename = vim.fn.expand("%:t")

	if lang_config then
		if not filename:match(lang_config.include_pattern) then
			print("Current file does not match include pattern: " .. lang_config.include_pattern)
			return
		end

		if lang_config.exclude_pattern and filename:match(lang_config.exclude_pattern) then
			print("Current file is excluded by pattern: " .. lang_config.exclude_pattern)
			return
		end

		local identifier = get_test_identifier() or ""
		local cmd = lang_config.runner .. " " .. file .. identifier .. " " .. lang_config.pytest_options
		print("Running: " .. cmd) -- For debugging and confirmation only...
		vim.cmd("silent ! " .. cmd)
	else
		print("No language configuration for filetype: " .. ft)
		if config.fallback_to_vim_test then
			print("Falling back to vim-test's TestNearest")
			vim.cmd("TestNearest")
		else
			print("No test runner available for filetype: " .. ft)
		end
	end
end

if vim.g._TEST then
	M.__TEST_get_test_identifier = get_test_identifier
end

return M
