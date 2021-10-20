if empty(glob('~/.vim/tmp'))
    silent !mkdir -p ~/.vim/tmp
endif
set directory=$HOME/.vim/tmp

set termguicolors
" let g:gruvbox_italic=1
colorscheme dracula
" let g:gruvbox_contrast_dark='hard'

set relativenumber
set colorcolumn=120
set splitbelow splitright       " More natural split
set updatetime=300

set showtabline=0

let g:closetag_filenames = '*.html,*.xml,*.js,*.jsx,*.ts,*.tsx,*.go,*.dart'

let mapleader=' '

" Make it so that a curly brace automatically inserts an indented line
inoremap {<CR> {<CR>}<Esc>O<BS><Tab>

" insert comment at beginning
nmap <Leader>c gcc
vmap <Leader>c gc

" Clear search highlight
nnoremap <Leader>noh :noh<CR>

nnoremap <C-p> :Files<Cr>
" Open fuzzy finder in current dir of current buffer (find sibling files)
nnoremap <silent> <Leader>. :Files <C-r>=expand("%:h")<CR>/<CR>
nnoremap <silent> <leader><leader> :Buffers<CR>

" NERDTree
silent! nmap <F2> :NERDTreeToggle<CR>
silent! map <F3> :NERDTreeFind<CR>

let g:NERDTreeMapActivateNode="<F3>"
let g:NERDTreeMapPreview="<F4>"
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1

" Airline
let g:airline_theme='base16_dracula'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 0

" Emmet
let g:user_emmet_settings = {
\  'javascript' : {
\      'extends' : 'jsx',
\  },
\}
let g:user_emmet_leader_key='<C-Z>'

" Search word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" open es module import
nnoremap <Leader>gf 0f'gf

" insert comma / semicolon at end of line
nnoremap <Leader>, m`A,<Esc>``
nnoremap <Leader>; m`A;<Esc>``

nnoremap <Leader>o o<Esc>k
nnoremap <Leader>O O<Esc>j

nnoremap <leader>bd :bd<CR>

"" Buffer nav
noremap <leader>h :bp<CR>
noremap <leader><Left> :bp<CR>
noremap <leader>l :bn<CR>
noremap <leader><Right> :bn<CR>

" vim-javascript
autocmd FileType *.js,*,jsx setl tabstop=2|setl shiftwidth=2|setl expandtab softtabstop=2

" Ale
let g:ale_sign_error = '●' " Less aggressive than the default '>>'
let g:ale_sign_warning = '.'
let g:ale_lint_on_enter = 0 " Less distracting when opening a new file
