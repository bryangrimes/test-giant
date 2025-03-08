" Automatically load the Lua module for test-giant
if exists("g:loaded_test_giant")
  finish
endif
let g:loaded_test_giant = 1

lua require("my_test_giant")

