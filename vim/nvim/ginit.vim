if exists("g:neovide")
    let g:neovide_cursor_vfx_mode = "railgun"
    let g:neovide_hide_mouse_when_typing = v:true
    let g:neovide_remember_window_size = v:true
    let g:neovide_remember_window_position = v:true
    let g:neovide_scroll_animation_length = 0.1
    if has('macunix')
        set guifont=SF_Mono,Menlo:h15
        cd
        autocmd VimEnter * call timer_start(20, {tid -> execute('NeovideFocus')})
    else
        set guifont=SFMono_Nerd_Font_Mono,Noto_Sans_Mono:h11
    endif
endif
