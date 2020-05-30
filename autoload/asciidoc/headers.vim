
let s:headerSingleLineRegex = '\s\{0,}\(=\{1,5}\)\s\+.\+\s\+\1'

let s:headerSingleLineLevelsRegex = {
    \ 0: '^\s\{0,}\(=\{1}\)\s\+.\+\s\+\1$',
    \ 1: '^\s\{0,}\(=\{2}\)\s\+.\+\s\+\1$',
    \ 2: '^\s\{0,}\(=\{3}\)\s\+.\+\s\+\1$',
    \ 3: '^\s\{0,}\(=\{4}\)\s\+.\+\s\+\1$',
    \ 4: '^\s\{0,}\(=\{5}\)\s\+.\+\s\+\1$'
\ }

let s:headerSingleLineLeftOnlyRegex = '^\s\{0,}\(=\{1,5}\)\s\+.\+\s\{0,}$'

let s:headerSingleLineLeftOnlyLevelsRegex = {
    \ 0: '^\s\{0,}\(=\{1}\)\s\+.\+\s\{0,}$',
    \ 1: '^\s\{0,}\(=\{2}\)\s\+.\+\s\{0,}$',
    \ 2: '^\s\{0,}\(=\{3}\)\s\+.\+\s\{0,}$',
    \ 3: '^\s\{0,}\(=\{4}\)\s\+.\+\s\{0,}$',
    \ 4: '^\s\{0,}\(=\{5}\)\s\+.\+\s\{0,}$',
\ }

let s:headerUnderlineRegex = '.\+\n[=\-+~\^]\{1,}'

let s:headerUnderlineLevelsRegex = {
    \ 0: '^.\+\n[=]\{1,}$',
    \ 1: '^.\+\n[\-]\{1,}$',
    \ 2: '^.\+\n[~]\{1,}$', 
    \ 3: '^.\+\n[\^]\{1,}$',
    \ 4: '^.\+\n[+]\{1,}$'
\ }

" Args: [line]
fun! asciidoc#headers#header_level(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:text = getline(l:line)
	if getline(l:line) =~ s:headerSingleLineRegex
		for l:key in keys(s:headerSingleLineLevelsRegex)
			if l:text =~ get(s:headerSingleLineLevelsRegex, l:key)
				return l:key
			endif
		endfor
	elseif getline(l:line) =~ s:headerSingleLineLeftOnlyRegex
		for l:key in keys(s:headerSingleLineLeftOnlyLevelsRegex)
			if l:text =~ get(s:headerSingleLineLeftOnlyLevelsRegex, l:key)
				return l:key
			endif
		endfor
	else
		let l:text = join([getline(l:line), getline(l:line + 1)], "\n") =~ s:headerUnderlineRegex
		if l:text =~ s:headerUnderlineRegex
			for l:key in keys(s:headerUnderlineLevelsRegex)
				if l:text =~ get(s:headerUnderlineLevelsRegex, l:key)
					return l:key
				endif
			endfor
		endif
	endif
	return -1
endfun

" Args: [line]
fun! asciidoc#headers#increment_level(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:text = getline(l:line)
	if asciidoc#headers#header_level(l:line) == 4
		echom "Can't increment more"
	elseif asciidoc#headers#header_level(l:line) == -1
		let l:text = "= " . l:text . " ="
	else
		let l:text = "=" . l:text . "="
	endif
	call setline(l:line, l:text)
endfun

" Args: [line]
fun! asciidoc#headers#decrement_level(...)
	if a:0 == 0
		let l:line = line('.')
	else
		let l:line = a:1
	endif
	let l:text = getline(l:line)
	if asciidoc#headers#header_level(l:line) == -1
		echom "Can't decrement more"
	elseif asciidoc#headers#header_level(l:line) == 0
		let l:text = strcharpart(l:text, 2, strlen(l:text) - 4)
	else
		let l:text = strcharpart(l:text, 1, strlen(l:text) - 2)
	endif
	call setline(l:line, l:text)
endfun

