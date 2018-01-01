" ============================================================================
" "difforig.vim" - A polished implementation of the ":DiffOrig" command.
"
" Maintainer:   Jason Franklin <j_fra@fastmail.us>
" Last Change:  2018-01-01
" Version:      1.1.2
" License:      This project is released under the terms of the MIT License.
" ============================================================================


if &compatible || v:version < 700
    finish
endif

if !has('diff') || !has('quickfix') || !has('vertsplit')
    finish
endif

if exists('g:loaded_difforig')
    finish
endif
let g:loaded_difforig = 1

if !exists('*g:DiffOrigSetTabName')
    function g:DiffOrigSetTabName()
        " pass
    endfunction
endif

if !(exists(':DiffOrig') == 2)
    command -bar -nargs=0 DiffOrig call difforig#main()
endif

if !hasmapto('<Plug>(DiffOrig)')
    nmap <silent> <unique> <Leader>o <Plug>(DiffOrig)
endif
nnoremap <unique> <Plug>(DiffOrig) :<C-U>call difforig#main()<CR>
