if !has('python')
	finish
endif

python << EOF

import vim
from re import escape

# CONFIGURATION
# -------------

# The set of marks that will be used as cell delimiters.
DEFAULT_VALID_MARKS = 'abcdefghijklmnopqrstuvqxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

# The default way of delimiting cells, either 'marks' or 'tags'
DEFAULT_DELIMIT_CELL_BY = 'marks'

# Default tag to use if delimiting by tags is set.
DEFAULT_TAG = '##'

# Whether or not to move to the next cell after sending the current one.
DEFAULT_MOVE_TO_NEXT = True

# -------------

def get_cell_by_tags(cur_row, tag):
	# find the start of the cell
	cell_start = cur_row
	while cell_start > 1:
		if vim.current.buffer[cell_start-1].strip() == tag:
			break
		else:
			cell_start -= 1

	# find the end of the cell
	if cur_row == len(vim.current.buffer):
		cell_end = len(vim.current.buffer)
	else:
		cell_end = cur_row+1
		while cell_end < len(vim.current.buffer):
			if vim.current.buffer[cell_end-1].strip() == tag:
				cell_end -= 1
				break
			else:
				cell_end += 1

	next_cell_start = cur_row if cell_end == len(vim.current.buffer) else cell_end+1

	return cell_start, cell_end, next_cell_start

def get_cell_by_marks(cur_row, valid_marks):
	# get a list of all of the mark locations
	locations = []
	for letter in valid_marks:
		location_of_mark = vim.current.buffer.mark(letter)
		if location_of_mark is not None:
			locations.append(location_of_mark[0])
	# make dummy "marks" at the beginning and end of the file
	locations = sorted(set([1] + locations))

	# find which cell we are in. The line that the cursor is on should always be included in the cell.
	cell_start = [mark for mark in locations if mark <= cur_row][-1]	
	
	next_cell_start = [mark for mark in locations if mark > cur_row]

	# if there are no marks after the current row, then select to the end of the buffer
	cell_end = next_cell_start[0]-1 if next_cell_start else len(vim.current.buffer)

	# if there are marks after this one, make them the start of the next cell, otherwise, stay where you are
	next_cell_start = next_cell_start[0] if next_cell_start else cur_row

	return cell_start, cell_end, next_cell_start

def slime_cell(move_to_next=DEFAULT_MOVE_TO_NEXT, delimit_cell_by=DEFAULT_DELIMIT_CELL_BY, tag=DEFAULT_TAG, valid_marks=DEFAULT_VALID_MARKS):
	# get the current cursor position
	(cur_row, cur_col) = vim.current.window.cursor

	if delimit_cell_by == 'marks':
		cell_start, cell_end, next_cell_start = get_cell_by_marks(cur_row, valid_marks)
	elif delimit_cell_by == 'tags':
		cell_start, cell_end, next_cell_start = get_cell_by_tags(cur_row, tag)
	else:
		raise AssertionError("Invalid method of delimiting a cell was specified.")

	# get the contents of the cell
	cell = vim.current.buffer[cell_start-1:cell_end]

	"""
	There is a bug (feature?) is ipython or tslime which only copies 50 lines at a time.
	We therefore break the cell up into chunks of 25 lines and send these chunks one at a time
	"""
	while cell:
		chunk = cell[:25]
		cell[:25] = []

		# join with a newline and escape
		chunk_as_string = escape('\n'.join(chunk))

		# format the string for ipython's cpaste functionality
		chunk_as_string = "%cpaste\n" + chunk_as_string + "\n--\n"
		
		# send to tmux window
		vim.command('call Send_to_Tmux("%s")' % chunk_as_string)

	# move the cursor to the next cell
	if move_to_next:
		vim.current.window.cursor = (next_cell_start, 0)

EOF

noremap <C-b> :python slime_cell() <CR>
