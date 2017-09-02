" ============================================================================
" "difforig.vim" - A polished implementation of the ":DiffOrig" command.
"
" Maintainer:   Jason Franklin <j_fra@fastmail.us>
" Last Change:  2017-09-02
" Version:      0.1.0
" License:      This project is released under the terms of the MIT License.
" ============================================================================


if v:version < 700 || &compatible
    finish
endif

if !has('diff') || !has('quickfix')
    finish
endif

if exists('g:loaded_difforig')
    finish
endif
let g:loaded_difforig = 1

" FUNCTION: s:CacheBufferContents() {{{1
" Store the contents of the active buffer in a script-local cache.  The cache
" contents can then be read into a new buffer with the "s:PutCacheContents()"
" function.
" Globals:
"     s:bufferCache
" Returns:
"     Always 0
function! s:CacheBufferContents()
    let l:temp = @"
    %yank
    let s:bufferCache = @"
    let @" = l:temp
endfunction

" FUNCTION: s:GetNewDiffBufferName() {{{1
" Generate a string giving a unique name for a new diff buffer.
" Globals:
"     s:diffBufferCount
" Returns:
"     A string of the form "DiffOrig_{number}", certain to be unique
function! s:GetNewDiffBufferName()

    if !exists('s:diffBufferCount')
        let s:diffBufferCount = 0
    endif
    let s:diffBufferCount += 1

    while bufexists('DiffOrig_' . string(s:diffBufferCount))
        let s:diffBufferCount += 1
    endwhile

    return 'DiffOrig_' . string(s:diffBufferCount)
endfunction

" FUNCTION: s:PutCacheContents() {{{1
" Paste the text from the script-local cache.  This is intended to be used to
" initialize the contents of a new, empty diff buffer.
" Globals:
"     s:bufferCache
" Returns:
"     Always 0
function! s:PutCacheContents()
    put =s:bufferCache
    1delete _
endfunction

" FUNCTION: s:PutFileContents(fileName) {{{1
" Read the contents of the file referenced by "fileName" from disk into the
" active buffer.  This is meant to be used in a new, empty diff buffer.
" Arguments:
"     a:fileName
" Returns:
"     Always 0
function! s:PutFileContents(fileName)
    execute 'read ' . a:fileName
    1delete _
endfunction

" FUNCTION: s:OpenDiffTab() {{{1
" Open a new tab with vertically split windows showing a diff of the active
" buffer with its representation on disk.
" Returns:
"     Always 0
function! s:OpenDiffTab()
    let l:fileName = bufname('%')
    call s:CacheBufferContents()

    execute 'tabedit ' . s:GetNewDiffBufferName()
    call s:PutCacheContents()
    call s:SetDiffBufferOptions('AFTER')

    execute 'leftabove vertical split ' . s:GetNewDiffBufferName()
    call s:PutFileContents(l:fileName)
    call s:SetDiffBufferOptions('BEFORE')

    diffupdate
endfunction

" FUNCTION: s:SetDiffBufferOptions() {{{1
" Initialize the buffer-local and window-local options for a new diff buffer.
" Arguments:
"     a:status - A string giving information for the buffer's status line
" Returns:
"     Always 0
function! s:SetDiffBufferOptions(status)
    setlocal buftype=nofile
    setlocal filetype=
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal norelativenumber

    if has('syntax')
        setlocal colorcolumn=0
        setlocal nocursorcolumn
        setlocal nocursorline
        setlocal nospell
    endif

    if has('gui_running') || (exists('g:colors_name') && g:colors_name != 'default')
        let &l:statusline = ' DiffOrig %#CursorLine# ' . a:status
    else
        let &l:statusline = ' DiffOrig -- ' . a:status
    endif

    nnoremap <buffer> <silent> q :tabclose!<CR>

    diffthis
endfunction

" FUNCTION: s:DiffOrig() {{{1
" The main function that drives the command and the mapping defined by this
" plugin.  This function will abort with a warning message when conditions for
" its operation are unsuitable.
" Returns:
"     Always 0
function! s:DiffOrig()

    if &buftype != '' || !filereadable(bufname('%'))
        echohl WarningMsg
        echo 'difforig.vim: File not accessible.'
        echohl None
        return
    endif

    if !&modified
        echohl WarningMsg
        echo 'difforig.vim: No modifications.'
        echohl None
        return
    endif

    silent call s:OpenDiffTab()
    redraw | echomsg 'difforig.vim: Press "q" to exit the diff tab.'

    call g:DiffOrigSetTabName()
endfunction

" }}}

if !exists('*g:DiffOrigSetTabName')
    function g:DiffOrigSetTabName()
        " pass
    endfunction
endif

if !(exists(':DiffOrig') == 2)
    command -bar -nargs=0 DiffOrig call <SID>DiffOrig()
endif

if !hasmapto('<Plug>(DiffOrig)')
    nmap <silent> <unique> <Leader>o <Plug>(DiffOrig)
endif
nnoremap <unique> <Plug>(DiffOrig) :call <SID>DiffOrig()<CR>

" vim: foldmethod=marker
