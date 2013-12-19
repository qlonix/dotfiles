## PATH
PATH=$HOME/bin:$HOME/usr/local/bin:$PATH:/sbin

## rbenv
#if [ -d $HOME/.rbenv ]; then
#	PATH=$HOME/.rbenv/bin:$PATH
#	eval "$(rbenv init -)"
#fi

export PATH

## EDITOR
if [ -x /usr/local/bin/vim ]; then
	EDITOR=/usr/local/bin/vim
else
	EDITOR=vi
fi
export EDITOR

## LANG
export LANG=ja_JP.UTF-8

## LISTMAX
export LISTMAX=0

## cpanm
export PERL_CPANM_OPT="--local-lib=~/extlib"
export PERL5LIB="$HOME/extlib/lib/perl5:$HOME/extlib/lib/perl5/i386-freebsd-64int:$PERL5LIB"
export PERL5LIB="/home/qlo/perl5/lib/perl5:$PERL5LIB";
export PERL_LOCAL_LIB_ROOT="/home/qlo/perl5:$PERL_LOCAL_LIB_ROOT";
export PERL_MB_OPT="--install_base "/home/qlo/perl5"";
export PERL_MM_OPT="INSTALL_BASE=/home/qlo/perl5";
export PATH="/home/qlo/perl5/bin:$PATH";
