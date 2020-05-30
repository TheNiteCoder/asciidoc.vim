
fun! asciidoc#formatting#surrond_with_formatting(char)
	let [l:line_start, l:column_start] = getpos("'<")[1:2]
	let [l:line_end, l:column_end] = getpos("'>")[1:2]
	let l:text = getline(l:line_start)
	let l:text = strcharpart(l:text, 0, l:column_start - 1) . a:char . 
				\ strcharpart(l:text, l:column_start - 1)
	call setline(l:line_start, l:text)
	let l:text = getline(l:line_end)
	let l:text = strcharpart(l:text, 0, l:column_end + 1) . a:char . 
				\ strcharpart(l:text, l:column_end + 1)
	call setline(l:line_end, l:text)
endfun

