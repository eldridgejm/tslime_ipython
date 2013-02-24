if !has('python')
	finish
endif

python << EOF

import vim
import re
from string import ascii_letters

def slime_cell(move_to_next=True):
	# get the current cursor position
	(cur_row, cur_col) = vim.current.window.cursor

	# get a list of all of the mark locations
	locations = []
	for letter in ascii_letters:
		location_of_mark = vim.current.buffer.mark(letter)
		if location_of_mark is not None:
			locations.append(location_of_mark[0])

	# make dummy "marks" at the beginning and end of the file
	locations = sorted(set([1] + locations))

	# find which cell we are in. The line that the cursor is on should always be included in the cell.
	cell_start = [mark for mark in locations if mark <= cur_row][-1]	
	
	candidate_ending_marks = [mark for mark in locations if mark > cur_row]

	# if there are no marks after the current row, then select to the end of the buffer
	if candidate_ending_marks:
		cell_end = candidate_ending_marks[0]-1
	else:
		cell_end = len(vim.current.buffer)

	# get the contents of the cell
	cell = vim.current.buffer[cell_start-1:cell_end]

	# join with a newline and escape
	cell_as_string = re.escape('\n'.join(cell))

	# format the string for ipython's cpaste functionality
	cell_as_string = "%cpaste\n" + cell_as_string + "\n--\n"
	
	# send to tmux window
	vim.command('call Send_to_Tmux("%s")' % cell_as_string)

	# move the cursor to the next cell
	if candidate_ending_marks:
		vim.current.window.cursor = (candidate_ending_marks[0], 0)


EOF

noremap <C-b> :python slime_cell() <CR>
