Lip
---
Lip is a Lisp like mini language written in Lua.
It's designed to support functional programming directly in Lua.
In Lip you can write lua code like:
 {Lisp.lambda, 'compose', {'f', 'g'},
  {Lisp.lambda, {'x'}, {'f', {'g', {'x'}}}}
 }
And it's designed just for fun.

Lip is under GPL lisence.

You can visit http://luaforge.net/projects/lip/ to get the latest 
version of Lip.

Content
-------
2 files are there for Lip:
 1) lip.lua
    core lib and some utility function are also defined here. the 
    interpreter entry is lip_runner(prog).
    
 2) test_lip.lua
    this file includes some real Lip code:
     a) fact, function for compute factorial
     b) fib, function for compute Fibonacci numbers
     c) compose, function for compose two function together to from 
                 a new function
     d) gcd, return the GCD of two numbers
     e) logic expression test
     f) code that may raise a Lua error
    you can check this file to get an impact of the Lip language.
    
How to use
----------
Let's illustrate Lip with the 'fact' function from test_lip.lua:
 -- compute factorial of n --
 {Lisp.lambda, 'fact', {'n'}, -- 1
  {Lisp.cond, {eq, {'n', 1}}, -- 2
   {Lisp.ret, {1}}, -- true   -- 3
   {Lisp.ret, {mut, {{'fact', {sub, {'n', 1}}}, 'n'}}}  -- false -- 4
  } -- cond                   -- 5
 }, -- lambda                 -- 6
 {lip_print, {'fact', {5}}}, -- print factorial result -- 7

You can see that all Lip code is written in Lua tables.

There are 3 key words for Lip now: 
 1) lambda, to define a function
 2) cond, to define a condition
 3) ret, to return from a function
they are all defined in a table named Lisp.

The 'fact' function starts with the function prototype:
 Lisp.lambda, 'fact', {'n'}, -- 1
it's a function(Lisp.lambda), and named 'fact', with a param list
{'n'}, and one param in the param list - 'n'.

Line 2 to 5 is the body of the function(a table too) which is a 
conditional statement:
 Lisp.cond, {eq, {'n', 1}}, -- 2
when the condition({eq, {'n', 1}}) is true Lip will execute the first
one of the two tables followed:
 {Lisp.ret, {1}}, -- 3
 it just returns 1, for 1! is 1.
If the condition is false, the second one will execute:
 {Lisp.ret, {mut, {{'fact', {sub, {'n', 1}}}, 'n'}}}, -- 4
 and will return (n-1)!*n.

You may notice there are some operations like: eq, mut, sub, etc. They
are basic operations defined in the core lib of Lip for logical and 
arithmetic operations(in lip.lua).

To call the 'fact' function:
 {'fact', {5}},
 will return 5!.
 
To print the result, you need to use a utility function lip_print
which is also defined in the core lib:
 {lip_print, {'fact', {5}}}, -- 7
and the output is:
[lip print] : 120

The code above consists of 2 statements(2 top level tables), one for
function definition, and another for function call. To execute a 
Lip program, you need to include all statements into a higher level
table:
 prog = {
  {stat1},
  {stat2},
  -- more stats ...
 }
and run:
 lip_runner(prog)

We've seen how to define function and how to call it. Now here comes 
the anonymous lambda(a lambda without name):
-- compose --
{Lisp.lambda, 'compose', {'f', 'g'},
	{Lisp.lambda, {'x'}, {'f', {'g', {'x'}}}} -- anonymous lambda
},
anonymous lambda works like closure in Lua. When the above 'compose'
called with args {foo, bar}, it'll return a new function whose param 
list is {'x'} and 'f' and 'g' are combined with foo and bar:
 {'compose', {foo, bar}}

Later when the new function gets called:
 {{'compose', {foo, bar}}, {'dude'}} -- call the composed function

it will perform a call like:
 foo(bar('dude'))

We can 'compose' both Lip defined functions and native lua functions.
See test_lip.lua for more examples.

Please check lip.lua for all core lib functions and other utility
functions.

You can turn on Lisp.verbose to inspect the execution of the Lip 
interpreter(quite noisy).

Status
------
Lip is in 0.1 Alpha

History
-------
Lip was inspired by a Lisp code snippet from Michael L. Scott's book
'Programming Language Pragmatics'(Chap 11.2):
 (define compose
  (lambda (f g)
   (lambda (x) (f (g x)))))
 )
I'd never use Lisp before, and when I saw the code I know that it's 
closure in Lua. And I know I can use table to write almost the same
code in Lua. So Lip was born after two nights:-)

The first version was buggy and with 5 more key words to simplify 
the interpreter. This version is the fifth rewrite. And it's much
simpler than its predecessors. Now we can write code like:

 {Lisp.lambda, 'compose', {'f', 'g'},
  {Lisp.lambda, {'x'}, {'f', {'g', {'x'}}}}
 }
sure, almost the same with Lisp:-)

To-Do List
----------
1) Lip's interpreter is fragile and not yet fully tested with complex
   Lip code.
2) core lib of Lip need more functions.

Known issues
------------
Lip is still in its alpha now and doesn't have a strict grammar. And
I'm not a Lisper or a language lawyer. So Lip might not be as pure
as it declares or as you'd thought. Be tolerant:-)

Feedback
--------
Please send your comments, bugs, patches or change request to 
hanzhao(abrash_han@hotmail.com).


