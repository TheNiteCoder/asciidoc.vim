" URL: sd@localhost:/home/sd/git/asciidoc.vim/plugin/asciidoc.vim
" Author: Samuel Daley

" IDEAS
" Add  a tree function where you can open the document in a tree format

" Protect against double loading
if exists('g:loaded_asciidoc')
	finish
endif
let g:loaded_asciidoc = 1

let s:idRegex = '^\s\{0,}\[\[.\+\]\]\s\{0,}$'

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

fun! s:GetHeaderLineNumber(...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif

    while l:line > 0
        if getline(l:line) =~ s:headerSingleLineRegex
            return l:line
        elseif getline(l:line) =~ s:headerSingleLineLeftOnlyRegex
            return l:line
        elseif join([getline(l:line), getline(l:line + 1)], "\n") =~ s:headerUnderlineRegex
            return l:line
        endif
        let l:line = l:line - 1
    endwhile
    return 0
endfun

" rtn(Number): -1 no header found above position, -2 no valid header found at
" location from s:GetHeaderLineNumber(), -3 no level was found
fun! s:GetHeaderLevel(...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let l:location = s:GetHeaderLineNumber(l:line)
    if l:location == 0
        return -1
    endif
    let l:text = getline(l:location)
    if l:text =~ s:headerSingleLineRegex
        for l:key in keys(s:headerSingleLineLevelsRegex)
            if l:text =~ get(s:headerSingleLineLevelsRegex, l:key)
                return l:key
            endif
        endfor
        return -3
    elseif l:text =~ s:headerSingleLineLeftOnlyRegex
        for l:key in keys(s:headerSingleLineLeftOnlyLevelsRegex)
            if l:text =~ get(s:headerSingleLineLeftOnlyLevelsRegex, l:key)
                return l:key
            endif
        endfor
        return -3
    else
        let l:text = join([l:text, getline(l:location+1)], "\n")
    endif
    if ! l:text =~ s:headerUnderlineRegex
        return -1
    else
        for l:key in keys(s:headerUnderlineLevelsRegex)
            if l:text =~ get(s:headerUnderlineLevelsRegex, l:key)
                return l:key
            endif
        endfor
        return -3
    endif
    return -3
endfun

fun! s:GotoCurrentHeader(...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let l:location = s:GetHeaderLineNumber(l:line)
    if l:location == 0
        echom "No headers above cursor"
        return
    else
        call cursor(l:location, 1)
    endif
endfun

fun! s:GetNextHeaderLineNumber(...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let [l:y, l:x] = getpos('.')[1:2]
    let l:loc1 = search(s:headerSingleLineRegex, 'W')
    call cursor(l:y, l:x)
    let l:loc2 = search(s:headerUnderlineRegex, 'W')
    call cursor(l:y, l:x)
    let l:loc3 = search(s:headerSingleLineLeftOnlyRegex, 'W')
    call cursor(l:y, l:x)
    if l:loc1 == 0 && l:loc2 == 0 && l:loc3 == 0
        return -1
    endif
    if l:loc1 > l:loc2
		return l:loc1
    elseif l:loc2 > l:loc3
        return l:loc2
    else
       	return l:loc3
    endif
endfun

fun! s:GotoNextHeader(...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let [l:y, l:x] = getpos('.')[1:2]
    let l:loc1 = search(s:headerSingleLineRegex, 'W')
    call cursor(l:y, l:x)
    let l:loc2 = search(s:headerUnderlineRegex, 'W')
    call cursor(l:y, l:x)
    let l:loc3 = search(s:headerSingleLineLeftOnlyRegex, 'W')
    call cursor(l:y, l:x)
    if l:loc1 == 0 && l:loc2 == 0 && l:loc3 == 0
        echom "No headers next"
        return
    endif
    if l:loc1 > l:loc2
        call cursor(l:loc1, 1)
    elseif l:loc2 > l:loc3
        call cursor(l:loc2, 1)
    else
        call cursor(l:loc3, 1)
    endif
endfun

fun! s:GotoPreviousHeader(...)
    let l:currentHeaderLocation = s:GetHeaderLineNumber()
    let l:noPreviousHeader = 0
    if l:currentHeaderLocation <= 1
        let l:noPreviousHeader = 1
    else
        let l:previousHeaderLineNumber = s:GetHeaderLineNumber(l:currentHeaderLocation - 1)
        if l:previousHeaderLineNumber == 0
            let l:noPreviousHeader = 1
        else
            call cursor(l:previousHeaderLineNumber, 1)
        endif
    endif
    if l:noPreviousHeader
        echom "No previous header"
    endif
endfun

fun! s:GetNextHeaderLineNumberAtLevel(level, ...)
    if a:0 < 1
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let l:l = l:line
    while(l:l <= line('$'))
        if getline(l:l) =~ get(s:headerSingleLineLevelsRegex, a:level)
            return l:l
        elseif getline(l:l) =~ get(s:headerSingleLineLeftOnlyLevelsRegex, a:level)
        elseif join([getline(l:l), getline(l:l+1)], "\n") =~ get(s:headerUnderlineLevelsRegex, a:level)
            return l:l
        endif
        let l:l += 1
    endwhile
    return 0
endfun

fun! s:GetPrevHeaderLineNumberAtLevel(level, ...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let l:l = l:line 
    while(l:l > 0)
        if getline(l:l) =~ get(s:headerSingleLineLevelsRegex, a:level)
            return l:l
        elseif getline(l:l) =~ get(s:headerSingleLineLeftOnlyLevelsRegex, a:level)
            return l:l
        elseif join([getline(l:l), getline(l:l+1)], "\n") =~ get(s:headerUnderlineLevelsRegex, a:level)
            return l:l
        endif
        let l:l -= 1
    endwhile
    return 0
endfun

fun! s:GetParentHeaderLineNumber(...)
    if a:0 == 0
        let l:line = line('.')
    else
        let l:line = a:1
    endif
    let l:level = s:GetHeaderLevel(l:line)
    if l:level > 0
        let l:lineNumber = s:GetPrevHeaderLineNumberAtLevel(l:level - 1, l:line)
        return l:lineNumber
    else
        " echom "[DEBUG] " l:level
    return 0
    endif
endfun

fun! s:GotoParentHeader()
    let l:line = s:GetParentHeaderLineNumber()
    if l:line == 0
        echo "No parent"
    else
        call cursor(l:line, 1)
    endif
endfun

" 1 is char for top and bottom of block
" 2 is times it should be repeated, 0 for default times
" 3 is line
" 4 is a dict that contains arguments and possible values
fun! s:InsertBlock(...)
    if a:0 == 2
        let l:char = a:1
        let l:times = a:2
    elseif a:0 == 1
        let l:char = a:1
        let l:times = 10
    else
        return
    endif
    let l:line = line('.')
    if l:times == 0
        let l:times = 10
    endif
    let l:c = 0
    let l:top = ""
    let l:bot = ""
    while l:c < l:times
        let l:top .= l:char 
        let l:bot .= l:char 
        let l:c += 1
    endwhile
    call append(l:line, [l:top, "", l:bot])
    normal! jji
    " TODO add a attributes list 
endfun

fun! s:InsertTable(columns, rows, ...)
    if a:0 == 0
        let l:width = 10
    else
        let l:width = a:1
    endif
    let l:lines = []
    let l:c = 0
    let l:line = "|"
    while l:c < l:width * a:columns
        let l:line .= "="
        let l:c += 1
    endwhile
    let l:lines += [l:line]
    let l:c = 0
    while l:c < a:rows
        let l:line = ""
        let l:c2 = 0
        while l:c2 < a:columns + 1
            let l:line .= '|'
            let l:c3 = 0
            while l:c3 < l:width
                let l:line .= ' ' 
                let l:c3 += 1
            endwhile
            let l:c2 += 1
        endwhile
        let l:c += 1
        let l:lines += [l:line]
    endwhile
    let l:line = "|"
    let l:c = 0
    while l:c < l:width * a:columns
        let l:line .= "="
        let l:c += 1
    endwhile
    let l:lines += [l:line]
    call append(line('.'), l:lines)
endfun

fun! s:Insert(line, idx, str)
    let l:line = getline(a:line)
    let l:line = strpart(l:line, 0, a:idx) . a:str . strpart(l:line, a:idx)
    call setline(a:line, l:line)
endfun

fun! s:CompleteIds()
    let l:tags = []
    let [l:y, l:x] = getpos('.')[1:2]
    call cursor(line('^'), 1)
    while 1 == 1
        let l:line = search(s:idRegex, 'W')
        if l:line == 0
            break
        endif
        let l:text = getline(l:line)
        let l:text = substitute(l:text, "[[", "", "g")
        let l:text = substitute(l:text, "]]", "", "g")
        let extend(l:tags, [ l:text ])
    endwhile
    call complete(col('.'), l:tags)
endfun

fun! s:MakeFormatted(char)
    let [l:begin, l:colb] = getpos('v')[1:2]
    let [l:end, l:cole] = getpos('.')[1:2]
    call s:Insert(l:begin, l:colb-1, a:char)
    call s:Insert(l:end, l:cole-1+strlen(a:char), a:char)
endfun

fun! s:AsciidocShowSyntaxHelp()
    execute 'new | 0read !asciidoc --help syntax'
    setlocal filetype=asciidoc buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    normal gg
endfun

fun! s:VAsciidocShowSyntaxHelp()
    execute 'vnew | 0read !asciidoc --help syntax'
    setlocal filetype=asciidoc buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    normal gg
endfun


" TODO figure out folding 
fun! s:AsciidocFold()
    let l:line = getline(v:lnum)
    let l:depth = match(l:line, '=\+\s+.\+\s+')
    if l:depth > 0
        if l:depth > 1
            let l:depth -= 1
        endif
        return ">" . l:depth
    endif
endfun
" setlocal foldexpr=<SID>AsciidocFold()

fun! s:BrowseTree(orientation)
	" Goto to top of file
	normal gg
    let [l:y, l:x] = getpos('.')[1:2]
	let l:list = []
	while s:GetNextHeaderLineNumber() != -1
		call s:GotoNextHeader()
		let l:ln = getpos('.')[1]
		let l:text = getline('.')
		let l:list = l:list + [[l:text,l:ln]]
	endwhile
	let l:id = win_getid()
	execute a:orientation
	let w:asciidoc_id = l:id
	setlocal buftype=nofile
	setlocal cursorline
	nnoremap <buffer> <CR> :call <SID>GotoBrowseTag()<CR>
	for l:item in l:list
		call append(line('$')-1, l:item[1] . " | " . l:item[0])
	endfor
endfun

fun s:GotoBrowseTag()
	let l:ln = getpos('.')[1]
	let l:line = getline(l:ln)
	let l:num = split(l:line, " ")[0]
	let l:num = str2nr(l:num)	
	call win_gotoid(w:asciidoc_id)
	call cursor(l:num, 1)
endfun

command! AsciidocGotoCurrentHeader      call <SID>GotoCurrentHeader()
command! AsciidocGotoNextHeader         call <SID>GotoNextHeader()
command! AsciidocGotoPrevHeader         call <SID>GotoPreviousHeader()
command! AsciidocGotoParentHeader       call <SID>GotoParentHeader()

command! AsciidocInsertListingBlock     call <SID>InsertBlock('-')
command! AsciidocInsertLiteralBlock     call <SID>InsertBlock('.')
command! AsciidocInsertSidebarBlock     call <SID>InsertBlock('*')
command! AsciidocInsertQuoteBlock       call <SID>InsertBlock('_')
command! AsciidocInsertExampleBlock     call <SID>InsertBlock('=')
command! AsciidocInsertCommentBlock     call <SID>InsertBlock('/')
command! AsciidocInsertPassthroughBlock call <SID>InsertBlock('+')
command! AsciidocInsertOpenBlock        call <SID>InsertBlock('-', 2)

" command! AsciidocMakeBoldText           call <SID>MakeFormatted('*')
" command! AsciidocMakeItalicsText        call <SID>MakeFormatted('_')
" command! AsciidocMakeEmphasizedText     call <SID>MakeFormatted("'")
" command! AsciidocMakeMonospacedText     call <SID>MakeFormatted('+')
" command! AsciidocMakePassthroughText    call <SID>MakeFormatted('`')

command! -nargs=+ AsciidocInsertTable   call <SID>InsertTable(<f-args>)
command! AsciidocShowSyntaxHelp         call <SID>AsciidocShowSyntaxHelp()
command! AsciidocShowVSyntaxHelp        call <SID>VAsciidocShowSyntaxHelp()
command! AsciidocBrowseTreeV            call <SID>BrowseTree('vnew')
command! AsciidocBrowseTree             call <SID>BrowseTree('new')

nnoremap <C-A>n :AsciidocGotoNextHeader<CR>
nnoremap <C-A>b :AsciidocGotoPrevHeader<CR>
nnoremap <C-A>c :AsciidocGotoCurrentHeader<CR>
nnoremap <C-A>p :AsciidocGotoParentHeader<CR>
nnoremap <C-A><C-P> :AsciidocBrowseTreeV<CR>
nnoremap <C-A>g<C-P> :AsciidocBrowseTree<CR>

