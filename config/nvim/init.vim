" Need to set the leader before defining any leader mappings
let mapleader = "\<Space>"

filetype plugin indent on
syntax on

" set hidden                      " Allow buffer change w/o saving
" set lazyredraw                  " Don't update while executing macros
" set backspace=indent,eol,start  " Sane backspace behavior

" Fix background color
set termguicolors

" Softtabs, 2 spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Don't let Vim hide characters or make loud dings
set conceallevel=1
set noerrorbells
" Space above/beside cursor from screen edges
set scrolloff=1
set sidescrolloff=5
" Disable mouse support
set mouse=r
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

set autoindent

set splitbelow
set splitright

set cursorcolumn              " highlight current column
set cursorline                " highlight current line

set number relativenumber
set inccommand=split
set noshowmode                " hide default mode indicator
set ignorecase

" Automatic toggling between line number modes
" via https://jeffkreeftmeijer.com/vim-number
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" Set colorscheme
colorscheme dracula

" ---- Minpac plugin manager ---------------------------------------------------
" For a paranoia.
" Normally `:set nocp` is not needed, because it is done automatically
" when .vimrc is found.
if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

if exists('*minpac#init')
  " minpac is loaded.
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})

  " Additional plugins here.
  " call minpac#add('vim-jp/syntax-vim-ex')
  call minpac#add('tpope/vim-surround')
  " call minpac#add('kassio/neoterm')
  " call minpac#add('janko-m/vim-test')
  call minpac#add('itchyny/lightline.vim')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('airblade/vim-gitgutter')
  call minpac#add('editorconfig/editorconfig-vim')
  call minpac#add('scrooloose/nerdtree')
  call minpac#add('dracula/vim')
  call minpac#add('machakann/vim-highlightedyank')
  call minpac#add('christoomey/vim-tmux-navigator')
  call minpac#add('Yggdroot/indentLine')
  " call minpac#add('w0rp/ale')
  " call minpac#add('danro/rename.vim')
  call minpac#add('tpope/vim-repeat')
  " call minpac#add('SirVer/ultisnips')
  " call minpac#add('honza/vim-snippets')
  call minpac#add('vim-scripts/tComment')
  call minpac#add('wikitopian/hardmode')
  call minpac#add('ncm2/ncm2')
  call minpac#add('roxma/nvim-yarp')
  call minpac#add('roxma/vim-hug-neovim-rpc')
  call minpac#add('roxma/ncm-flow')
  call minpac#add('luochen1990/rainbow')
  call minpac#add('junegunn/vim-easy-align')
  call minpac#add('sbdchd/neoformat')
  call minpac#add('ervandew/supertab')
  call minpac#add('AndrewRadev/splitjoin.vim')
  call minpac#add('dkarter/bullets.vim')
  call minpac#add('jiangmiao/auto-pairs')
  call minpac#add('tpope/vim-endwise')
  call minpac#add('rstacruz/vim-closer')
  call minpac#add('metakirby5/codi.vim')
  call minpac#add('pangloss/vim-javascript')
  call minpac#add('mxw/vim-jsx')
  call minpac#add('skywind3000/asyncrun.vim')
  call minpac#add('ncm2/ncm2-bufword')
  call minpac#add('ncm2/ncm2-path')
  call minpac#add('ncm2/ncm2-tmux')
  call minpac#add('ncm2/ncm2-tern', {'do': 'silent! !npm install'})
  " call minpac#add('rstacruz/vim-hyperstyle')
  " call minpac#add('chrisbra/Colorizer')
  " call minpac#add('Shougo/denite.nvim')
  " call minpac#add('edkolev/tmuxline.vim')
  call minpac#add('justinmk/vim-sneak')
  call minpac#add('autozimu/LanguageClient-neovim', {
        \ 'branch': 'next',
        \ 'do': 'silent! !bash install.sh'
        \})
endif

" Plugin settings here.
"
" HardMode plugin settings
"" Enable HardMode plugin by default and map it
"" autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
"" :call EasyMode() <== to disable it
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
let g:HardMode_level='wannabe'

" Lightline config
let g:lightline = {
      \ 'colorscheme': 'Dracula',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \   'LinterStatus': 'LinterStatus',
      \ },
      \ }

" Asynchronous Lint Engine (ALE)
"" Configure linter status for  lightline
" function! LinterStatus() abort
"     let l:counts = ale#statusline#Count(bufnr(''))
"
"     let l:all_errors = l:counts.error + l:counts.style_error
"     let l:all_non_errors = l:counts.total - l:all_errors
"
"     return l:counts.total == 0 ? '' : printf(
"     \   'ALE: %dW %dE',
"     \   all_non_errors,
"     \   all_errors
"     \)
" endfunction
" let g:ale_echo_msg_error_str = 'E'
" let g:ale_echo_msg_warning_str = 'W'
" let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
"
" "" Set this if you want to.
" let g:ale_open_list = 1
" "" This can be useful if you are combining ALE with
" "" some other plugin which sets quickfix errors, etc.
" let g:ale_keep_list_window_open = 1

"" Limit linters used for JavaScript.
" let g:ale_linters = {
"     \  'javascript': ['flow']
"     \}

"" Setup fixers
" let g:ale_fixers = {}
" let g:ale_fixers['javascript'] = ['prettier']
" let g:ale_fix_on_save = 1

"" Extran settings for ALE
" highlight clear ALEErrorSign   " otherwise uses error bg color (typically red)
" highlight clear ALEWarningSign " otherwise uses error bg color (typically red)
" let g:ale_sign_column_always = 2
" let g:ale_sign_error = '✖︎'     " could use emoji
" let g:ale_sign_warning = '!'    " could use emoji
" " let g:ale_lint_on_enter = 0 " Less distracting when opening a new file
" let g:ale_statusline_format = ['✖︎ %d', '! %d', '']
" "" %linter% is the name of the linter that provided the message
" "" %s is the error or warning message
" let g:ale_echo_msg_format = '%linter% says %s'
" "" Map keys to navigate between lines with errors and warnings.
" nnoremap <leader>an :ALENextWrap<cr>
" nnoremap <leader>ap :ALEPreviousWrap<cr>
"" Enable completion where available.
" let g:ale_completion_enabled = 1

" nvim-completion-manager optional configuration
"" Supress the annoying completion messages
"" don't give |ins-completion-menu| messages.  For example,
"" '-- XXX completion (YYY)', 'match 1 of 2', 'The only match',
set shortmess+=c
"" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to hide the menu and also start a new line.

" AsyncRun settings
  autocmd BufWritePost *.js AsyncRun -post=checktime eslint --fix %

" IndentLine settings
let g:indentLine_enabled = 1
let g:indentLine_char = "▏"
" let g:indentLine_leadingSpaceEnabled = 1

" Gitgutter settings
"" Set ripgrep as default grep for gitgutter
"" Default:
let g:gitgutter_grep = 'rg'
"" To turn off signs by default
let g:gitgutter_signs = 0
"" To turn on line highlighting by default
" let g:gitgutter_highlight_lines = 1

" Editorconfig
let g:EditorConfig_exec_path = '/usr/local/bin/editorconfig'
let g:EditorConfig_core_mode = 'external_command'
"" To ensure that this plugin works well with Tim Pope's fugitive,
"" use the following patterns array:
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
"" You might want to override some project-specific EditorConfig rules in global
"" or local vimrc in some cases to resolve coflicts of trailing whitespace
"" trimming and buffer autosaving.
"let g:EditorConfig_disable_rules = ['trim_trailing_whitespace']

" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()

" Sneak config
"" 2-character Sneak (default)
nmap s <Plug>Sneak_s
nmap S <Plug>Sneak_S
"" visual-mode
xmap s <Plug>Sneak_s
xmap S <Plug>Sneak_S
"" operator-pending-mode
omap s <Plug>Sneak_s
omap S <Plug>Sneak_S

"" repeat motion
map ; <Plug>Sneak_;
map , <Plug>Sneak_,

"" 1-character enhanced 'f'
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
"" visual-mode
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
"" operator-pending-mode
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F

"" 1-character enhanced 't'
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
"" visual-mode
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
"" operator-pending-mode
omap t <Plug>Sneak_t
omap T <Plug>Sneak_T
" force label-mode
nmap <leader>s <Plug>SneakLabel_s
nmap <leader>S <Plug>SneakLabel_S

" Rainbow config
let g:rainbow_conf = {
\    'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
\    'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\    'operators': '_,_',
\    'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\    'separately': {
\        '*': {},
\        'tex': {
\                'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\        },
\        'lisp': {
\                'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\        },
\        'vim': {
\                'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\        },
\        'html': {
\                'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\        },
\        'css': 0,
\    }
\}

" Easy align config
"" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
"" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" ---- EOF plugin settings -----------------------------------------------------

" Force the cursor onto a new line after 80 characters
" via https://csswizardry.com/2017/03/configuring-git-and-vim
set textwidth=80
"" However, in Git commit messages, let’s make it 72 characters
autocmd FileType gitcommit set textwidth=72
"" Colour the 81st (or 73rd) column so that we don’t type over our limit
set colorcolumn=+1
"" In Git commit messages, also colour the 51st column (for titles)
autocmd FileType gitcommit set colorcolumn+=51

" Style the terminal cursor when the terminal is inactive
" via thoughtbot.com/upcase/videos/neovim-pasting-into-a-terminal-buffer
" hi! TermCursorNC ctermfg=15 guifg=#fdf6e3 ctermbg=14 guibg=#93a1a1 cterm=NONE gui=NONE

" Split edit your vimrc. Type space, v, r in sequence to trigger
nmap <leader>vr :sp $MYVIMRC<cr>
" Source (reload) your vimrc. Type space, s, o in sequence to trigger
nmap <leader>so :source $MYVIMRC<cr>
" Extra escap mappins
imap jk <esc>:w<cr>
imap kj <esc>:w<cr>
" Bind `q` to close the buffer for help files
autocmd Filetype help nnoremap <buffer> q :q<CR>

" Add Nvim terminal emulator key mappings for vim-tmux-navigator
" via https://github.com/christoomey/vim-tmux-navigator/pull/172/files
tnoremap <silent> <c-h> <c-\><c-n>:TmuxNavigateLeft<cr>
tnoremap <silent> <c-j> <c-\><c-n>:TmuxNavigateDown<cr>
tnoremap <silent> <c-k> <c-\><c-n>:TmuxNavigateUp<cr>
tnoremap <silent> <c-l> <c-\><c-n>:TmuxNavigateRight<cr>
tnoremap <silent> <c-\> <c-\><c-n>:TmuxNavigatePrevious<cr>

" Getting out of Terminal mode
tnoremap <A-[> <C-\><C-n>

" Pasting a register in Terminal mode
" via thoughtbot.com/upcase/videos/neovim-pasting-into-a-terminal-buffer
tnoremap <expr> <A-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'

" via christoomey/dotfiles/vim/rcfiles/
"" Move between wrapped lines, rather than jumping over wrapped segments
nmap j gj
nmap k gk
"" Quick sourcing of the current file, allowing for quick vimrc testing
" nnoremap <leader>sop :source %<cr>
"" Swap 0 and ^. Jump to the first non-whitespace character
nnoremap 0 ^
nnoremap ^ 0
"" Switch between the last two files
nnoremap <leader><leader> <c-^>
"" Use C-Space to Esc out of any mode
nnoremap <C-Space> <Esc>:noh<CR>
vnoremap <C-Space> <Esc>gV
onoremap <C-Space> <Esc>
cnoremap <C-Space> <C-c>
inoremap <C-Space> <Esc>
"" Terminal sees <C-@> as <C-space>
nnoremap <C-@> <Esc>:noh<CR>
vnoremap <C-@> <Esc>gV
onoremap <C-@> <Esc>
cnoremap <C-@> <C-c>
inoremap <C-@> <Esc>
"" More leader mappings
nnoremap <leader>df :file ~/.dotfiles<cr>
nnoremap <leader>; :
nmap <leader>bi :PackUpdate<cr>
nmap <leader>bd :PackClean<cr>
"" General settings
set backspace=2      " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile
set history=50
set showcmd          " display incomplete commands
set autowrite        " Automatically :write before running commands
set formatoptions-=t " Don't auto-break long lines (re-enable this for prose)
"" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" via https://github.com/colbycheeze/dotfiles/blob/master/vimrc
""" Use enter to create new lines w/o entering insert mode
"nnoremap <CR> o<Esc>
""" Below is to fix issues with the ABOVE mappings in quickfix window
"autocmd CmdwinEnter * nnoremap <CR> <CR>
"autocmd BufReadPost quickfix nnoremap <CR> <CR>
"" Reload files changed outside vim
set autoread
"" Trigger autoread when changing buffers or coming back to vim in terminal.
au FocusGained,BufEnter * :silent! !
"" Scrolling
set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1
