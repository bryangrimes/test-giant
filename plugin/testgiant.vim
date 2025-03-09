" Automatically load the Lua module for test-giant
if exists("g:loaded_testgiant")
  finish
endif
let g:loaded_testgiant = 1

lua require("testgiant")

