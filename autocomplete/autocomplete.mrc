; 2023 © Valware https://github.com/ValwareIRC
; LICENSE: GPLv3-or-later
; AUTHOR: Valware
;
; This script works with the third/cmdslist UnrealIRCd module
;
; Suggests and auto-completes 

on *:PARSELINE:in:*:{
  var %cap valware.uk/cmdslist
  tokenize 32 $parseline
  ; lose any msgtags as we don't need to touch them
  if ($left($1,1) == @) {
    tokenize 32 $2-
  }
  if ($2 == CAP) && ($4 == LS) {
    if (%cap isin $5-) {
      cap req %cap | remini cmds.ini $right($1,-1) list | cmdslist
    }
  }
  else if ($2 == CMDSLIST) {
    var %add $iif($left($3,1) == +, $true, $false)
    var %check = $right($3,-1)
    if (%add) writeini cmds.ini $right($1,-1) list $readini(cmds.ini, $right($1,-1), list) %check $+ ,
    else if (!%add) writeini cmds.ini $right($1,-1) list $replace($readini(cmds.ini, $right($1,-1), list), $+($chr(32),%check,$chr(44)), $null)
    .parseline -it
  }
  else return
}

; Special thanks to Koragg for pointing out I
; can use TABCOMP instead of some F-key alias
; <3
on *:TABCOMP:*:{
  tokenize 32 $editbox($active)
  if ($left($1,1) != /) return
  if ($len($1) == 1) {
    commands
    return
  }
  set %commandLookup $right($1,-1)
  valware.lookup.command $server
  if (%[ $+ [ $server $+ ] .i < 1) {
    echo -at -AutoComplete- No suggestion for ' $commandLookup $+ '
  }
  unset %commandLookup
}

alias valware.lookup.command {
  var %server $1
  var %commands $readini(cmds.ini, %server, list)
  if (!%commands) return
  var %i 1
  var %found 0
  while (%i <= $numtok(%commands,44)) {
    var %cmd $replace($gettok(%commands,%i,44),$chr(32),)
    inc %i
    var %t %commandLookup
    if ($upper(%t) == $left(%cmd, $len(%t))) {
      if (!%found) var %foundCommands $+(,$rand(93,95),%cmd,)
      else var %foundCommands %foundCommands $+ $chr(44) $+(,$rand(93,95),%cmd,)
      inc %found
    }
  }
  if (%found == 1) {
    editbox -ap / $+ $lower($strip(%foundCommands))
  }
  else echo -at -AutoComplete- Found $numtok(%foundCommands,44) commands matching $+(,",%t,",) $+ $iif(%found,: %foundCommands,) | echo -a -
}

alias commands {
  var %data $readini(cmds.ini, $server, list)
  if (%data) { 
    var %it 1
    while (%it < $numtok(%data,44)) {
      var %new %new $+(,$rand(93,95),$replace($gettok(%data,%it,44),$chr(32),),) $+ $chr(44)
      inc %it
    }
    echo -at -- Commands Available To You --
    echo -at %new
    echo -at -- For more information on a command, try /helpop <command>
    echo -a -
  }
  ;; fallback lmao
  else helpop usercmds
}

