PATH=$HOME/.rbenv/bin:$HOME/bin:$HOME/usr/local/bin:$PATH:/sbin
EDITOR=/usr/local/bin/vim
export EDITOR PATH

LANG=ja_JP.UTF-8
export LANG

LISTMAX=0
export LISTMAX

# cpanm
export PERL_CPANM_OPT="--local-lib=~/extlib"
export PERL5LIB="$HOME/extlib/lib/perl5:$HOME/extlib/lib/perl5/i386-freebsd-64int:$PERL5LIB"
