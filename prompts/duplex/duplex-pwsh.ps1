#!/usr/bin/env pwsh

function prompt {
    # print a newline
    write-host "" -nonewline
    
    # escape character
    $E = [char]0x1B
    
    # set color
    write-host "$E[0;31m" -nonewline
    
    # Add character
    $bracket1 = [text.encoding]::getstring((226,148,140,226,148,128))
    write-host "$bracket1" -nonewline
    
\[\033[0;31m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; fi)\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\] "
}
