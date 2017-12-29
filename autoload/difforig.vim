function! difforig#main()

    if &buftype != '' || !filereadable(bufname('%'))
        echohl WarningMsg
        echomsg 'difforig.vim: File not accessible.'
        echohl None
        return
    endif

    if !&modified
        echohl WarningMsg
        echomsg 'difforig.vim: No modifications.'
        echohl None
        return
    endif

    silent call difforig#openDiffTab()
    redraw | echomsg 'difforig.vim: Press "q" to exit the diff tab.'

    call g:DiffOrigSetTabName()
endfunction

function! difforig#openDiffTab()
    let l:fileName = bufname('%')
    call difforig#cacheBufferContents()

    execute 'tabedit ' . difforig#getNewDiffBufferName()
    call difforig#putCacheContents()
    call difforig#setDiffBufferOptions('AFTER')

    execute 'leftabove vertical split ' . difforig#getNewDiffBufferName()
    call difforig#putFileContents(l:fileName)
    call difforig#setDiffBufferOptions('BEFORE')

    nohlsearch
    diffupdate
endfunction

function! difforig#getNewDiffBufferName()

    if !exists('s:diffBufferCount')
        let s:diffBufferCount = 0
    endif
    let s:diffBufferCount += 1

    while bufexists('DiffOrig_' . string(s:diffBufferCount))
        let s:diffBufferCount += 1
    endwhile

    return 'DiffOrig_' . string(s:diffBufferCount)
endfunction

function! difforig#cacheBufferContents()
    let l:temp = @"
    %yank
    let s:bufferCache = @"
    let @" = l:temp
endfunction

function! difforig#putCacheContents()
    put =s:bufferCache
    1delete _
endfunction

function! difforig#putFileContents(fileName)
    execute 'read ' . a:fileName
    1delete _
endfunction

function! difforig#setDiffBufferOptions(status)
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal filetype=
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal norelativenumber
    setlocal noswapfile
    setlocal readonly
    setlocal winfixwidth

    if has('syntax')
        setlocal colorcolumn=0
        setlocal nocursorcolumn
        setlocal nocursorline
        setlocal nospell
    endif

    if has('gui_running') || (exists('g:colors_name') && g:colors_name != 'default')
        let &l:statusline = ' DiffOrig %#CursorLine# ' . a:status . '%='
                    \ . ' %## |%c| %l/%L '
    else
        let &l:statusline = ' DiffOrig -- ' . a:status . '%='
                    \ . ' |%c| %l/%L '
    endif

    nnoremap <buffer> <silent> q :call difforig#closeDiffTab()<CR>

    diffthis
endfunction

function! difforig#closeDiffTab()

    if tabpagenr() > 1
        tabprevious | +tabclose!
        return
    endif

    try
        tabclose!
    catch /E784/
        tabnew | -tabclose!
    endtry
endfunction
