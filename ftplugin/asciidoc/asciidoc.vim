
command! AsciidocIncrementHeaderLevel call asciidoc#headers#increment_level()
command! AsciidocDecrementHeaderLevel call asciidoc#headers#decrement_level()
command! -range AsciidocFormatBold call asciidoc#formatting#surrond_with_formatting('*')
command! -range AsciidocFormatEmphasized call asciidoc#formatting#surrond_with_formatting('_')
command! -range AsciidocFormatLiteral call asciidoc#formatting#surrond_with_formatting('`')
command! -range AsciidocFormatMonospaced call asciidoc#formatting#surrond_with_formatting('+')

command! AsciidocInsertListingBlock call asciidoc#block#insert_block('-')
command! AsciidocInsertLiteralBlock call asciidoc#block#insert_block('.')
command! AsciidocInsertSidebarBlock call asciidoc#block#insert_block('*')
command! AsciidocInsertQuoteBlock call asciidoc#block#insert_block('_')
command! AsciidocInsertExampleBlock call asciidoc#block#insert_block('=')
command! AsciidocInsertCommentBlock call asciidoc#block#insert_block('/')
command! AsciidocInsertPassthroughBlock call asciidoc#block#insert_block('+')
command! AsciidocInsertOpenBlock call asciidoc#block#insert_block('-', 2)

command! AsciidocCycleBlockStyle call asciidoc#block#cycle_style()

command! -range AsciidocMakeListingBlock call asciidoc#block#make_block(<line1>, <line2>, '-')
command! -range AsciidocMakeLiteralBlock call asciidoc#block#make_block(<line1>, <line2>, '.')
command! -range AsciidocMakeSidebarBlock call asciidoc#block#make_block(<line1>, <line2>, '*')
command! -range AsciidocMakeQuoteBlock call asciidoc#block#make_block(<line1>, <line2>, '_')
command! -range AsciidocMakeExampleBlock call asciidoc#block#make_block(<line1>, <line2>, '=')
command! -range AsciidocMakeCommentBlock call asciidoc#block#make_block(<line1>, <line2>, '/')
command! -range AsciidocMakePassthroughBlock call asciidoc#block#make_block(<line1>, <line2>, '+')
command! -range AsciidocMakeOpenBlock call asciidoc#block#make_block(<line1>, <line2>, '-', 2)

noremap <buffer> <silent> = :AsciidocIncrementHeaderLevel<CR>
noremap <buffer> <silent> - :AsciidocDecrementHeaderLevel<CR>
noremap <buffer> <silent> + :AsciidocCycleBlockStyle<CR>

noremap <buffer> <silent> <leader>fb :AsciidocFormatBold<CR>
noremap <buffer> <silent> <leader>fe :AsciidocFormatEmphasized<CR>
noremap <buffer> <silent> <leader>fl :AsciidocFormatLiteral<CR>
noremap <buffer> <silent> <leader>fm :AsciidocFormatMonospaced<CR>

