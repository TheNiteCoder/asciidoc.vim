
let s:blockRegex = '^[-|\.|\*|+|_|`|=|/]\+$'

let s:blockTypesRegex = {
			\ 'open' : '^--$',
			\ 'listing' : '^-\{3,}$',
			\ 'literal' : '^\.\{3,}$',
			\ 'sidebar' : '^\*\{3,}$',
			\ 'quote' : '^_\{3,}$',
			\ 'example' : '^=\{3,}$',
			\ 'comment' : '^/\{3,}$',
			\ 'passthough' : '^+\{3,}$',
			\ }

let s:blockStyles = {
			\ "open" : ["abstract", "partintro"],
			\ "listing" : ["source", "music", "graphviz"],
			\ "literal" : ["listing", "verse"],
			\ "sidebar" : [],
			\ "quote" : ["quote", "verse"],
			\ "example" : ["NOTE", "TIP", "WARNING", "IMPORTANT", "CAUTION"],
			\ "comment" : [],
			\ "passthough" : ["pass", "asciimath", "latexmath"],
			\ }

let s:extraInfoRegex = '^\[.\+\]$'

" Args: border, [times = 0, [line = line('.')]]
fun! asciidoc#block#insert_block(border, ...)
	if a:0 == 0
		let l:times = 20
	else
		let l:times = a:1
	endif
	if a:0 <= 1
		let l:line = line('.')
	else
		let l:line = a:2
	endif
	let l:text = ""
	let l:counter = l:times
	while l:counter > 0
		let l:text .= a:border
		let l:counter -= 1
	endwhile
	call append(l:line, l:text)
	call append(l:line, "")
	call append(l:line, l:text)
	call setpos('.', [0, l:line + 2, 0, 0]) " move cursor to center
endfun

fun! asciidoc#block#block_type(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	if getline(l:line) =~ s:blockRegex 
		for l:key in keys(s:blockTypesRegex)
			if getline(l:line) =~ get(s:blockTypesRegex, l:key)
				return l:key
			endif
		endfor
	endif
	return ""
endfun

" Args: [line]
fun! asciidoc#block#find_border(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:num = l:line
	while l:num <= line('$')
		if getline(l:num) =~ s:blockRegex
			return l:num
		endif
		let l:num += 1
	endwhile
	return 0
endfun

" Args: [line]
fun! asciidoc#block#find_border_backward(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:num = l:line
	while l:num > 0
		if getline(l:num) =~ s:blockRegex
			return l:num
		endif
		let l:num -= 1
	endwhile
	return 0
endfun

" Args: line
" Returns: [begin_line, end_line] -1 on error or not found
fun! asciidoc#block#block_borders(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:top = asciidoc#block#find_border_backward(l:line)
	if l:top == l:line
		let l:bot = asciidoc#block#find_border(l:line + 1)
	else
		let l:bot = asciidoc#block#find_border(l:line)
	endif
	if l:top == 0
		return [-1, -1]
	elseif l:bot == 0
		return [-1, -1]
	elseif asciidoc#block#block_type(l:top) != asciidoc#block#block_type(l:bot)
		return [-1, -1]
	else
		return [l:top, l:bot]
	endif
endfun


" Args: line
" Returns: []
fun! asciidoc#block#extra_info(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	if ! getline(l:line) =~ s:extraInfoRegex
		return []
	endif
	let l:text = trim(getline(l:line))
	let l:text = l:text[1:strlen(l:text)-2] " remove []
	let l:parts = split(l:text, ',')
	let l:result = []
	for l:part in l:parts
		call add(l:result, trim(l:part))
	endfor
	return l:result
endfun

" Args: info: [], [line: int]
fun! asciidoc#block#set_extra_info(info, ...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:text = "[" . join(a:info, ", ") . "]"
	call setline(l:line, l:text)
endfun

" Args: [line]
fun! asciidoc#block#cycle_style(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	if getline(l:line) =~ s:extraInfoRegex " if on block header look at borders one below
		let l:line += 1
	endif
	let [l:block_top, l:block_bot] = asciidoc#block#block_borders(l:line)
	if l:block_top == -1 || l:block_bot == -1
		echohl ErrorMsg
		echo "Not in a block"
		echohl None
		return
	endif
	let l:type = asciidoc#block#block_type(l:block_top)
	if l:type == ""
		echohl ErrorMsg
		echo "Block is not an asciidoc block"
		echohl None
		return
	endif
	if l:block_top != 1
		let l:extra_info = asciidoc#block#extra_info(l:block_top - 1)
	else
		let l:extra_info = []
	endif
	if len(l:extra_info) == 0 && len(get(s:blockStyles, l:type)) > 0
		call add(l:extra_info, get(s:blockStyles, l:type)[0])
		if l:block_top - 1 == 0
			call append(0, "")
			let l:info_line = 1
		else
			if getline(l:block_top - 1) =~ s:extraInfoRegex
				let l:info_line = l:block_top - 1
			else
				call append(l:block_top - 1, "")
				let l:info_line = l:block_top
			endif
		endif
	elseif len(l:extra_info) > 0
		let l:styles = get(s:blockStyles, l:type)
		let l:index = index(l:styles, l:extra_info[0])
		if l:index == -1
			let l:extra_info[0] = l:styles[0]
		else
			if l:index + 1 == len(l:styles)
				let l:index = 0
			else
				let l:index += 1
			endif
			let l:extra_info[0] = l:styles[l:index]
		endif
		if l:block_top - 1 == 0
			call append(0, "")
			let l:info_line = 1
		else
			if getline(l:block_top - 1) =~ s:extraInfoRegex
				let l:info_line = l:block_top - 1
			else
				call append(l:block_top - 1, "")
				let l:info_line = l:block_top
			endif
		endif
	endif
	call asciidoc#block#set_extra_info(l:extra_info, l:info_line)
endfun

" Args: times
fun! asciidoc#block#make_block(start, end, char, ...)
	if a:0 == 0
		let l:times = 20
	else
		let l:times = a:1
	endif
	let l:c = l:times
	let l:text = ""
	while l:c > 0
		let l:text .= a:char
		let l:c -= 1
	endwhile
	call append(a:start - 1, l:text)
	call append(a:end + 1, l:text) " +1 because previous line just added a line
endfun

