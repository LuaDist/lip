--[[-------------------------------------
Lip/test_lip.lua
-----------------------------------------
Lip is a Lisp like mini language in Lua.
under GPL lisence.
copyright (c) 2006 hanzhao (abrash_han@hotmail.com)
http://luaforge.net/projects/lip/
--]]-------------------------------------

-- Lip test cases --
require 'lip.lua'

-- turn on verbose to see the details of Lip exec
Lisp.verbose = false

-- for compose
function foo(str)
 print('my foo ' .. str)
 return 'my foo ' .. str
end

function bar(str)
 print('bar ' .. str)
 return 'bar ' .. str
end

function fact2(n)
 if(n == 1) then return 1 end
 return n * fact2(n-1)
end

-- our lip program starts here, 
-- statement by statement
-- or table by table
prog = {
{lip_version, {}}, -- version info

-- factorial --
{Lisp.lambda, 'fact', {'n'},
	{Lisp.cond, {eq, {'n', 1}},
	  {Lisp.ret, {1}}, -- true
	  {Lisp.ret, {mut, {{'fact', {sub, {'n', 1}}}, 'n'}}}  -- false
	} -- cond
}, -- lambda
{lip_print, {'fact', {5}}}, -- print factorial result

-- Fibonacci --
{Lisp.lambda, 'fib', {'n'},
	{Lisp.cond, {_or, {{eq, {'n', 2}}, {eq, {'n', 1}}}},
		{Lisp.ret, {1}}, -- true
		{Lisp.ret, {add, {{'fib', {sub, {'n', 1}}}, {'fib', {sub, {'n', 2}}}}}}, -- false
	},
},
{lip_print, {'fib', {7}}}, -- print fibonacci result

-- compose --
{Lisp.lambda, 'compose', {'f', 'g'},
	{Lisp.lambda, {'x'}, {'f', {'g', {'x'}}}},
},
{{'compose', {foo, bar}}, {'dude'}}, -- compose 2 native lua functions
{lip_print, { {{'compose', {'fact', 'fib'}}, {7}}} }, -- compose 2 lip defined functions
{lip_print, { {{'compose', {'fib', 'fact'}}, {3}}} }, -- and the reverse
{lip_print, { {{'compose', {'fib',  fact2}}, {3}}} }, -- compose a lua native function and a lip defined function
{lip_print, { {{'compose', {fact2, 'fib'}}, {7}}} },  -- and the reverse

-- gcd --
{Lisp.lambda, 'gcd', {'m', 'n'},
	{Lisp.cond, {eq, {{mod, {'m', 'n'}}, 0}}, 
		{Lisp.ret, {'n'}}, -- true
		{Lisp.ret, {'gcd', {'n', {mod, {'m', 'n'}}}}}, -- false
	},
},
{lip_print, {'gcd', {33, 57}}}, -- print gcd result

-- logic test --
{lip_assert_eq, {{_and, {eq, {1, 2}}, {eq, {1, 1}}}, false} }, 
{lip_assert_eq, {{_and, {true, true}}, true }},
{lip_assert_eq, {{_and, {false, true}}, false} },
{lip_assert_eq, {{_not, {true}}, false} },
{lip_assert_eq, {{_not, {false}}, true} },
{lip_assert_eq, {{_or, {false, true}}, true} },
{lip_assert_eq, {{_or, {false, false}}, false} },
{lip_assert_eq, {{eq, {false, true}}, false} },

--[[-- uncommnet this seg to raise a lua error
{Lisp.cond, {true}, 
	{error, {'test lua error'}}, -- true 
	{}, -- false
},
--]]--
--{lip_for_whom, {}},
}

-- lets run it
lip_runner(prog)