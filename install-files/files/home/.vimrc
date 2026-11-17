set relativenumber
set number
syntax on
colorscheme torte
set autoindent

"set softtabstop=3 "for java professor's code
"set softtabstop=2 "for graphics professor's code
set softtabstop=4
set expandtab

set nowrap "do not auto wrap on load
"set formatoption-=t " do not auto wrap when typing

"set clipboard=unnamed

" function! Osc52Yank()
"	let buffer=system('base64 -w0', @0) " -w0 to disable 74 char line wrapping
"	let buffer='\ePtmux;\e\e]52;c;'.buffer.'\x07\e\\'
"	silent exe "!exho -ne ".shellscape(buffer)." > ".shellescape(g:tty)
" endfunction
" nnoremap <leader>y :call Osc52Yank()<CR>
" needs slave tty on creating terminal
set nocompatible
syntax enable
filetype plugin on

"search down into subfolders
"Provides tab-completion for all file-related tasks
set path+=**

"Display all matching files when we tab complete
set wildmenu

"command! MakeTags !ctags -R .
":echo expand("%") shows current file
"https://github.com/changemewtf/no_plugins

" Tweaks for browsing
"let g:netrw_banner=0        " disable annoying banner
"let g:netrw_browse_split=4  " open in prior window
"let g:netrw_altv=1          " open splits to the right
"let g:netrw_liststyle=3     " tree view
"let g:netrw_list_hide=netrw_gitignore#Hide()
"let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

set showcmd

nnoremap /htmlskel :-1read $HOME/.vim/vim/.skeleton.html<CR>
nnoremap /cppskel :-1read $HOME/.vim/vim/.skeleton.cpp<CR>
nnoremap /cskel :-1read $HOME/.vim/vim/.skeleton.c<CR>
nnoremap /luaskel :-1read $HOME/.vim/vim/.skeleton.lua<CR>
nnoremap /pythonskel :-1read $HOME/.vim/vim/.skeleton.py<CR>
nnoremap /rustskel :-1read $HOME/.vim/vim/.skeleton.rs<CR>
nnoremap /haskellskel :-1read $HOME/.vim/vim/.skeleton.hs<CR>
nnoremap /smlskel :-1read $HOME/.vim/vim/.skeleton.sml<CR>
nnoremap /javaskel :-1read $HOME/.vim/vim/.skeleton.java<CR>
nnoremap /lcp :-1read $HOME/.vim/vim/.skeleton.leetcode<CR>

"what? register
set mouse=a

"jumps to searched word as searching
set incsearch

"execute pathogen#infect()
"filetype plugin indent on

"solving python autocomplete file includes
setlocal complete-=i
