"行番号表示
set number

"カレントカーソルの横線を強調
set cursorline

" インサートモード中の BS、CTRL-W、CTRL-U による文字削除を柔軟にする
set backspace=indent,eol,start

"カレントカーソルの縦線を強調
set cursorcolumn

"検索時の単語をハイライト
set hlsearch

" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

"文字コードをUFT-8に設定
set fenc=utf-8

" 入力中のコマンドをステータスに表示する
set showcmd

" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore

" インデントはスマートインデント
set smartindent
set tabstop=2
set expandtab
set shiftwidth=2

" 括弧入力時の対応する括弧を表示
set showmatch

" ステータスラインを常に表示
set laststatus=2


" コマンドラインの補完
set wildmode=list:longest
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
" シンタックスハイライトの有効化
syntax enable
colorscheme elflord

" diff比較の際にスペースを無視する
set diffopt=iwhite

" 不可視文字を可視化
set list listchars=tab:\\^,trail:-

" Tab文字を半角スペースにする
" set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2

" yankとクリップボードを同期
set clipboard=unnamedplus

" コマンドモードの補完
set wildmenu
" 保存するコマンド履歴の数
set history=5000
" 補完ウィンドウの設定
set completeopt=menuone

function! s:remove_dust()
  let cursor = getpos(".")
  " 保存時に行末の空白を除去する
  %s/\s\+$//ge
  call setpos(".", cursor)
  unlet cursor
endfunction
" autocmd BufWritePre * call <SID>remove_dust()
