--[[-------------------------------------
Lip
-----------------------------------------
Lip is a Lisp like mini language in Lua.
under GPL lisence.
copyright (c) 2006 hanzhao (abrash_han@hotmail.com)
http://luaforge.net/projects/lip/
--]]-------------------------------------

----------------------
-- key words of Lip --
Lisp = {
 lambda = 0,
 ret = 1,
 cond = 2,
}

-- verbose switch --
Lisp.verbose = false

-- a reg knows which function is lisp defined function --
Lisp.lisp_func_reg = {}

-- debug output --
function lip_debug_print(val)
 if(Lisp.verbose) then
  print(val)
 end
end

--------------------------------------------
-- core lib of Lip -------------------------

-- arithmetic ops --
function add(x, y)
 lip_debug_print("> add " .. x .. ", " .. y)
 return x + y
end

function sub(x, y)
 lip_debug_print("> sub " .. x .. ", " .. y)
 return x - y
end

function mut(x, y)
 lip_debug_print("> mut " .. x .. ", " .. y)
 return x * y
end

function div(x, y)
 lip_debug_print("> div " .. x .. ", " .. y)
 return x / y;
end

function mod(x, y)
 lip_debug_print("> mod " .. x .. ", " .. y)
 return math.mod(x, y)
end

-- compare ops --
function eq(x, y)
 lip_debug_print("> eq " .. tostring(x) .. ", " .. tostring(y))
 return x == y
end

function gt(x, y)
 lip_debug_print("> gt " .. x .. ", " .. y)
 return x > y
end

function ge(x, y)
 lip_debug_print("> ge " .. x .. ", " .. y)
 return x >= y
end

function lt(x, y)
 lip_debug_print("> lt " .. x .. ", " .. y)
 return x < y
end

function le(x, y)
 lip_debug_print("> le " .. x .. ", " .. y)
 return x <= y
end

-- logic ops --
function _or(x, y)
 lip_debug_print("> or " .. tostring(x) .. ", " .. tostring(y))
 return x or y
end

function _and(x, y)
 lip_debug_print("> and " .. tostring(x) .. ", " .. tostring(y))
 return x and y
end

function _not(x)
 lip_debug_print("> not " .. tostring(x))
 return not x
end

-- util func --
-- print
function lip_print(v)
 print("[lip print] : " .. tostring(v))
end

-- asserts
function lip_assert_eq(lhs, rhs)
 if(lhs ~= rhs) then error('[lip assert] failed : ' .. tostring(lhs) .. ', ' .. tostring(rhs)) end
end

function lip_assert_true(v)
 lip_assert_eq(v, true)
end

function lip_assert_false(v)
 lip_assert_true(not v)
end

-- drop a message here
function lip_for_whom()
 print("------------------------------")
 print("-- Lip\'s written for Xu Hui --")
 print("------------------------------")
end

-- version
function lip_version()
 print('Lip 0.1 Alpha copyright(c) hanzhao(abrash_han@hotmail.com)')
end

-- end core lib ----------------------------

--------------------------------------------
-- utility functions for Lip interperator --

-- make args named for arguments bind --
function pass_args(parm, arg)
 for i = 1, table.getn(parm) do
  -- should here be an exec on each arg?
  arg[parm[i]] = arg[i]
 end
end

-- evaluate all args in stat to args before perform a call --
-- both to native lua function and lip defined function
function bind_args(stat, upper)
  local rslt = {}
  local n = table.getn(stat)
  
  if(type(stat[1]) == "function" and type(stat[2]) == "table") then
    -- native function call, if stat[2] is not table, it's just another
    -- function arg
    lip_debug_print('stat[1] is function')
    rslt[1] = lisp_exec(stat, upper)
    return rslt
  end
  
  -- it's a lisp defined function call
  if(type(stat[1]) == "string" and type(stat[2]) == "table") then
    lip_debug_print('stat[1] is string')
    local val = upper[stat[1]]
    if(type(val) == "function") then
     -- func call
     rslt[1] = lisp_exec(stat, upper)
     return rslt
    end
  end
  
  --[[ it's an anonymous lambda
  if(type(stat[1]) == "number" and stat[1] == Lisp.lambda) then
   if(type(stat[2]) ~= "table") then
    error("expect table as params for anonymous lambda but get " .. type(stat[2]))
   end
   rslt[1] = lisp_exec(stat, upper)
   return rslt
  end]]--
  
  for i=1, n do
   if(type(stat[i]) == "table") then
    rslt[i] = lisp_exec(stat[i], upper)
   elseif(type(stat[i]) == "string") then
    if(upper[stat[i]]) then
     -- defined names, param or named lambda
     local val = upper[stat[i]]
     --[[if(type(val) == "function") then
      -- func call
      --rslt[1] = lisp_exec(stat, upper)
      --return rslt
      error("argument error, unexpected function.")
     else--]]
      -- normal arg
      rslt[i] = val
     --end
    else
     -- normal string
     rslt[i] = stat[i]
    end
   else
    rslt[i] = stat[i]
   end
  end
  return rslt
end

-- bind closure --
-- bind all params in stat from ctxt, but not from except
function bind_closure(stat, ctxt, except)
 lip_debug_print("bind closure")
 local n = table.getn(stat)
 for i = 1, n do
  if(type(stat[i]) == 'string') then
   lip_debug_print(stat[i])
   if(ctxt[stat[i]] and not except[stat[i]]) then
    stat[i] = ctxt[stat[i]]
   end
  elseif(type(stat[i]) == 'table') then
   bind_closure(stat[i], ctxt, except)
  else
   -- no other type need to be handled here
  end
 end
end

-- chain up the meta tables for name lookup --
function chain_up(tbl, meta)
 setmetatable(tbl, meta)
 meta.__index = meta
end

-- return a copy of src tbl --
-- to copy an anonymous lambda's body
function cpytbl(src)
 local n = table.getn(src)
 local dst = {}
 for i = 1, n do
  if(type(src[i]) == 'table') then
   dst[i] = cpytbl(src[i])
  else
   dst[i] = src[i]
  end
 end
 return dst
end
-- end utility functions for interperator -----

-----------------------------------------------
-- Lip interperator ---------------------------

function lisp_exec(stat, upper)
 if(stat[1] == nil) then error("error: unknown stat[1].") end
 if(upper == nil) then error("error: no context passed in.") end
 
 -- where to find names
 setfenv(1, upper)
 
 if(type(stat[1]) == "number") then
  -- lisp key words
  if(stat[1] == Lisp.lambda) then
   lip_debug_print("define lambda")
   if(type(stat[2]) == "string") then -- named lambda
    -- name, param, body
    local func = function (arg)
	              -- bind 
	              pass_args(stat[3], arg)
                      -- name lookup
	              chain_up(arg, upper) 
	              return lisp_exec(stat[4], arg)
                 end

    -- a new func name defined(in upper context), so latter can be called
    upper[stat[2]] = func
    --table.foreach(upper, print)
    Lisp.lisp_func_reg[func] = true
    return func
    
   elseif(type(stat[2]) == "table") then -- anonymous lambda
    -- param, body
    lip_debug_print("anonymous lambda")
    --table.foreach(upper, print)
    
    -- closure need a copy
    local stat3cpy = cpytbl(stat[3])
    bind_closure(stat3cpy, upper, stat[2])
    local func = function (arg)
                  -- bind
                  local tabled_arg = arg
                  pass_args(stat[2], tabled_arg)

                  -- name lookup
                  chain_up(tabled_arg, upper)
                  return lisp_exec(stat3cpy, tabled_arg)
                 end
                 
     Lisp.lisp_func_reg[func] = true
     return func
   else
    error('unsupported lambda type' .. type(stat[2]))
   end
   
  elseif(stat[1] == Lisp.ret) then
   -- {ret, {vals}}
   lip_debug_print("return")
   --return lisp_exec(stat[2], upper)
   local rslt = bind_args(stat[2], upper)
   return rslt[1] -- only one return val
   
  elseif(stat[1] == Lisp.cond) then
   -- {Lisp.cond, bool-expression, true-first, false-second}
   lip_debug_print("- cond")
   --table.foreach(stat[2], print)
   local rslt = lisp_exec(stat[2], upper)
   if(rslt) then
    lip_debug_print("-- cond true")
    return lisp_exec(stat[3], upper) -- true
   else
    lip_debug_print("-- cond false")
    return lisp_exec(stat[4], upper) -- false
   end
  elseif(stat[1] == Lisp.arg) then
   -- {Lisp.arg, {args}}
   return lisp_exec(stat[2], upper)
  else
   error('unrecognized key word : ' .. stat[1])
  end
  
 elseif(type(stat[1]) == "function") then
  -- native lua function call
  -- {func, {args}}
  lip_debug_print("native function call")
  -- bind args
  
  local rslt = bind_args(stat[2], upper)
  if(Lisp.lisp_func_reg[stat[1]]) then
   -- lisp defined function need args be in table
   return stat[1](rslt)
  else
   -- unpack the result to call native lua func
   return stat[1](unpack(rslt))
  end
  
 elseif(type(stat[1]) == "table") then
  -- {{closure}, {args}}
  -- calc stat[1] first
  lip_debug_print("- eval table")
  -- it's a function call? defining a closure
  --bind_closure(stat[1][2], upper, {})
  --table.foreach(stat[1][2], print)
  local func = lisp_exec(stat[1], upper)
  
  --stat[1] = func
  --lisp_exec(stat, upper)
  
  return func(stat[2])

 elseif(type(stat[1]) == "string") then
  -- lisp defined function
  lip_debug_print("call lisp defined function : " .. stat[1])
  -- it must be in upper context
  -- local arg = lisp_exec(stat[2], upper)
  local rslt = bind_args(stat[2], upper)
  --table.foreach(rslt, print)
  return upper[stat[1]](rslt)
 elseif(type(stat[1]) == "boolean") then
  -- bool expression
  lip_debug_print("boolean expression")
  return stat[1]
 else
  error('unsupported stat[1] type : ' .. type(stat[1]))
 end
end

-----------------------------
-- lip program runner -------
-- run, prog, run     -------
function lip_runner(prog)
 chain_up(prog, _G)
 local n = table.getn(prog)
 for i=1, n do
  lip_debug_print("exec " .. i)
  lisp_exec(prog[i], prog)
 end
end
