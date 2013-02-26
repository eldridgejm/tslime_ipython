tslime_ipython
==============

tslime_ipython is a vim plugin to send cells of code from vim to ipython using tslime. This attempts to bring some of the benefits of
the IPython notebook's cells to vim. For example, if my code looks like the following, with marks on lines 3 and 4:

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

then I can send everything up to line 3 by hitting <C-b> while my cursor is above line 3. Lines 3 through 5 (inclusive)
can be sent by positioning my cursor in that cell and hitting <C-b>, and so on. The code is pasted into ipython
using the `%cpaste` magic function, so everything looks tidy and neat.

You can also use comment tags to delimit cells. For instance:

<pre>
  1: import my_module
  2:
  3: ##
  4: result = my_function(foo, bar, baz)
  5:
  6: ##
  7: print(result)
  8: x = 5
  9: print(result + x)
</pre>

will act the same as the previous example. Here the tags are `##`, though they can be set to whatever you'd like. 
By default, delimiting cells by tags is turned off. See below on how to configure this behavior.

---
Table of Contents
---

- [Requirements ](#requirements-)
- [Configuration](#configuration)
	- [Using a subset of marks to delimit cells](#using-a-subset-of-marks-to-delimit-cells)
	- [Delimiting cells by vim marks or by comment tags](#delimiting-cells-by-vim-marks-or-by-comment-tags)
	- [Changing the definition of a comment tag](#changing-the-definition-of-a-comment-tag)
	- [Move to the next cell after evaluation](#move-to-the-next-cell-after-evaluation)
	- [Changing the keybinding](#changing-the-keybinding)
- [Workflow](#workflow)


Requirements 
------------
vim compiled with python support, tslime, and ipython.


Configuration
-------------
By default, tslime_ipython works by treating any lowercase mark as the boundary of a cell. Once a cell is sent,
the cursor is moved to the start of the next cell if one exists, otherwise the cursor remains in its current
position.

There are two ways to modify these settings. First, the default setting can be changed by editing the appropriate
configuration line in tslime_ipython. Second, these settings may be passed as keyword arguments to `slime_cell()`.
This is powerful, as it enables you to set different keybindings for different tslime_ipython behaviors.

### Using a subset of marks to delimit cells
By default the entire alphabet is considered when looking for delimiting marks, upper
and lower cases. For users who would rather use a subset of the alphabet as cell boundaries, this option may
be set by changing the `DEFAULT_VALID_MARKS` option in tslime_ipython.vim, or by setting `valid_marks` as a keyword
argument in the keybinding.

Example:
<pre>
# change the keybinding so that only marks 'a-f' are used as cell delimiters
noremap <C-b> :python slime_cell(valid_marks='abcdef') <CR>
</pre>

### Delimiting cells by vim marks or by comment tags
Set this option in the plugin file by editing `DEFAULT_DELIMIT_CELL_BY`
or by setting the keyword argument `delimit_cell_by`. Valid options are `marks` and `tags`.

Tags are comments inserted directly into the python source, used
to delimit blocks of code. The default tag is `##`, though other tags may be set (see below). When tslime_ipython
is invoked, lines that entirely match the tag are searched for. This means that if `tag='##'`, then a line containing
`## this is not a cell` will not be considered as cell delimiters.

Example:
<pre>
# use tags instead of marks
noremap <C-b> :python slime_cell(delimit_cell_by='tags') <CR>
</pre>

### Changing the definition of a comment tag
By default, tslime_ipython looks for lines that contain only `##` when searching for tag delimiters. You
may modify this however you like, though only lines containing `#` as their first characters will be valid
python code. This setting is `DEFAULT_TAG` in the plugin file, or the `tag` keyword in the keybinding.

Note that if `DEFAULT_DELIMIT_CELL_BY` is set to `marks`, then it is not sufficient to pass only the `tag` keyword
to delimit by tags. You must also set `delimit_cell_by` to `tags`.

Example:
<pre>
# delimit by tags, where a tag is a line containing only '## cell'
noremap <C-b> :python slime_cell(delimit_cell_by='tags', tag='## cell') <CR>
</pre>

### Move to the next cell after evaluation
By default, tslime_ipython takes you to the start of the next cell after you have send the current one.
If you are in the last cell of a source file, the cursor will stay put, since you are most likely going to
edit the current cell more.

To change this behavior, set `DEFAULT_MOVE_TO_NEXT` or the keyword argument `move_to_next` to `False`.

### Changing the keybinding
The keybinding is set at the bottom of `tslime_ipython.vim`. By default it is <C-b>.

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
