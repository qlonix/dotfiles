# 参考: http://www.crimson-snow.net/tips/unix/zsh.html

##
# キーバインド
# bindkey -v
bindkey -e
bindkey '^@' backward-delete-char

# 補完
autoload -U compinit
compinit
setopt auto_menu
setopt correct
setopt list_packed
setopt list_types

alias vi="/usr/local/bin/vim"
alias ls="ls -FG"
alias la="ls -aF"
alias ll="ls -lF"
alias lla="ls -alF"
alias sls="screen -ls"
alias sr="screen -r"
alias t="todo"
alias jnethack="cocot -t UTF-8 -p EUC-JP /usr/local/bin/jnethack"

##
# ヒストリー機能
HISTFILE=~/.zsh_history      # ヒストリファイルを指定
HISTSIZE=10000               # ヒストリに保存するコマンド数
SAVEHIST=10000               # ヒストリファイルに保存するコマンド数
setopt hist_ignore_all_dups  # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups      # 直前と同じコマンドラインはヒストリに追加しない
setopt share_history         # コマンド履歴ファイルを共有する
setopt append_history        # 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt inc_append_history    # 履歴をインクリメンタルに追加
setopt hist_no_store         # historyコマンドは履歴に登録しない
setopt hist_reduce_blanks    # 余分な空白は詰めて記録
#setopt hist_ignore_space    # 先頭がスペースの場合、ヒストリに追加しない
setopt extended_history	     # 履歴ファイルに時刻を記録
function history-all { history -E 1 } # 全履歴の一覧を出力する

# cd - と入力してTabキーで今までに移動したディレクトリを一覧表示
setopt auto_pushd

# ディレクトリスタックに重複する物は古い方を削除
setopt pushd_ignore_dups

##
# プロンプト関係
# プロンプトに escape sequence (環境変数) を通す
setopt prompt_subst

# ^[  は「エスケープ」
PROMPT="%B%{[36m%}%n@%m %c %#%{[m%}%b " # 通常のプロンプト
PROMPT2="%B%_>%b "                          # forやwhile/複数行入力時などに表示されるプロンプト
SPROMPT="%r is correct? [n,y,a,e]: "        # 入力ミスを確認する場合に表示されるプロンプト
RPROMPT="%T"                                # 右に表示したいプロンプト(24時間制での現在時刻)

setopt transient_rprompt                    # 右プロンプトに入力がきたら消す

# ターミナルのタイトル
case "${TERM}" in
kterm*|xterm)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    ;;
esac

##
# 補完
zstyle ':completion:*:default' menu select=1

# 色設定
autoload -U colors; colors

# もしかして機能
setopt correct

# PCRE 互換の正規表現を使う
setopt re_match_pcre

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# プロンプト指定
PROMPT="[%n@%m] %{${fg[yellow]}%}%~%{${reset_color}%}%(?.%{$fg[green]%}.%{$fg[blue]%})%(?!(*'-') <!(*;-;%)? <)%{${reset_color}%} "

# プロンプト指定(コマンドの続き)
PROMPT2='[%n]> '

# もしかして時のプロンプト指定
SPROMPT="%{$fg[red]%}%{$suggest%}(*'~'%)? < もしかして %B%r%b %{$fg[red]%}かな? [そう!(y), 違う!(n),a,e]:${reset_color} "
