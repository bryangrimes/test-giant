local assert = require("luassert")

describe("testgiant", function()
	local testgiant

	before_each(function()
		vim.g._TEST = true

		-- Reset mocks and globals.
		package.loaded["nvim-treesitter.ts_utils"] = nil
		_G.last_cmd = nil

		-- Override vim.fn.expand to simulate file path and name.
		vim.fn.expand = function(arg)
			if arg == "%:p" then
				return "/dummy/test_example.py"
			elseif arg == "%:t" then
				return "test_example.py"
			end
			return ""
		end

		vim.cmd = function(cmd)
			_G.last_cmd = cmd
		end

		vim.bo = { filetype = "python" }

		package.loaded["testgiant"] = nil
		testgiant = require("testgiant")
	end)

	after_each(function()
		vim.g._TEST = nil
		package.loaded["nvim-treesitter.ts_utils"] = nil
	end)

	it("should return test function identifier for function_definition", function()
		local fake_name_node = {}
		-- a fake node simulating a function definition
		local fake_node = {
			type = function()
				return "function_definition"
			end,
			field = function(self, key)
				if key == "name" then
					return { fake_name_node }
				end
			end,
			parent = function()
				return nil
			end,
		}
		-- override the treesitter get_node_text function
		vim.treesitter = {
			get_node_text = function(node, _)
				return "test_function"
			end,
		}
		-- a fake ts_utils module
		local fake_ts_utils = {
			get_node_at_cursor = function()
				return fake_node
			end,
		}
		package.loaded["nvim-treesitter.ts_utils"] = fake_ts_utils

		local result = testgiant.__TEST_get_test_identifier()
		assert.are.equal("::test_function", result)
	end)

	it("should return test class identifier for class_definition", function()
		local fake_name_node = {}
		local fake_node = {
			type = function()
				return "class_definition"
			end,
			field = function(self, key)
				if key == "name" then
					return { fake_name_node }
				end
			end,
			parent = function()
				return nil
			end,
		}
		vim.treesitter = {
			get_node_text = function(node, _)
				return "TestClass"
			end,
		}
		local fake_ts_utils = {
			get_node_at_cursor = function()
				return fake_node
			end,
		}
		package.loaded["nvim-treesitter.ts_utils"] = fake_ts_utils

		local result = testgiant.__TEST_get_test_identifier()
		assert.are.equal("::TestClass", result)
	end)

	it("should run pytest command with the detected test function", function()
		local fake_name_node = {}
		local fake_node = {
			type = function()
				return "function_definition"
			end,
			field = function(self, key)
				if key == "name" then
					return { fake_name_node }
				end
			end,
			parent = function()
				return nil
			end,
		}
		vim.treesitter = {
			get_node_text = function(node, _)
				return "test_function"
			end,
		}
		local fake_ts_utils = {
			get_node_at_cursor = function()
				return fake_node
			end,
		}
		package.loaded["nvim-treesitter.ts_utils"] = fake_ts_utils

		testgiant.run_current_scope()
		local expected_cmd = "pytest /dummy/test_example.py::test_function -srA --disable-warnings --showlocals"
		assert.are.equal("silent ! " .. expected_cmd, _G.last_cmd)
	end)

	it("should fall back to vim-test when filetype is not configured", function()
		vim.bo.filetype = "unknown" -- simulate unsupported filetype
		local fallback_called = false
		vim.cmd = function(cmd)
			fallback_called = true
		end
		testgiant.run_current_scope()
		assert.is_true(fallback_called)
	end)
end)
