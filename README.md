tslime_ipython
==============

A vim plugin to send cells of code from vim to ipython using tslime.
Cells are defined by delimiting them with vim marks. This attempts to bring some of the benefits of
the IPython notebook's cells to vim.

Requirements 
------------
vim compiled with python support, tslime, and ipython.

Usage
-----
Use vim marks (lower case letters) to delimit blocks of code. Hitting Ctrl-b will select
all of the code in the current "cell" and send it tslime, which will then enable you to send it
to ipython. The code is pasted using ipython's "%cpaste" magic function, which nicely formats the incoming text.

A "cell" is the block of code from the previous line with a lowercase mark (including the line that the cursor is on), 
to the line before the next mark. If there is no previous mark, then the start of the cell is the first line
of the buffer. If there is no next mark, then the end of the cell is the last line of the buffer.

Here's an example. Say you have the following code with marks a on line 3 and b on line 6.

<pre>
  1: import my_module
  2:
a 3: # do an operation that takes a long time
  4: result = my_function(foo, bar, baz)
  5:
b 6: # examine the result
  7: print(result)
  8: x = 5
  9: print(result + x)
</pre>

If my cursor is on lines 1 or 2, and I invoke tslime_ipython, lines 1 and 2 will be sent.
If my cursor is on line 3,4, or 5, then lines 3, 4, and 5 will be sent. Note that line 6 will be excluded, as 
it is part of the next cell.
If my cursor is on line 6 or after, then all lines from the sixth onward will be sent.
Note that if I have a file with no marks, invoking the command will send the entire file.

Workflow
--------
Why is this useful? Suppose you have some code that takes a long time to run, and now you want to write some code to 
visualize the results:

<pre>
# do a long calculation
result = my_function(foo, bar, baz)

# examine the result
plot(result)
</pre>

If I just `run` this from the ipython interpreter, every time I rerun my script the calculation will
be repeated. This will obviously be wasteful, and prevents me from quickly analyzing my results.

There are two obvious ways to get around this. First, I could use ipython's `run -i` command to share the namespace
of the interpreter with the script, so that I can check to see if the result is defined. If it isn't, I can
simply run the calculation:

<pre>
# do a long calculation, but only if the result variable isn't in my scope
try:
  result
except NameError:
  result = my_function(foo, bar, baz)

# examine the result
plot(result)
</pre>

This works, but is kludgy. An alternative is to use the ipython notebook, which is excellently suited for this type
of task, as you may run individual cells. The downside of the notebook, of course, is that it takes you out of
your favorite editor.

By marking off cells in our code, we get the notebook's cell functionality, but get to stay in vim. Therefore,
I can simply run the cell containing my calculation once, and then run my visualization code several times without
recomputing my result by sending only that cell to ipython.
