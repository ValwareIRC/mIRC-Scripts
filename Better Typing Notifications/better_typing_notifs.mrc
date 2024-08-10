;; Valware © 2024
;; https://github.com/ValwareIRC
;;
;; Better Typing Notifications
;; v1.2
;; Please allow this script to run on load,
;; this is so that it can create its own
;; directory to manage typing notifications
;; using files to remember what's going on

on *:LOAD:{
  ensureDir
}
on *:START:{
  ensureDir
}

alias -l ensureDir {
  set %unableToCreateDir $false
  if ($isdir($mircdirTypingNotifs)) return $true
  echo -at ~~ ^__^ Thank you so much for checking out the Typing Notifications script.
  echo -at ~~ Just gotta make a directory! La la la...
  .mkdir " $+ $mircdirTypingNotifs $+ "
  if (!$isdir($mircdirTypingNotifs)) {
    set %unableToCreateDir $true
    echo -at ~~ Oh no! It seems that I,the Typing Notifications script, cannot create the directory.
    echo -at ~~ I only need it for tidiness. Please could you create it? It needs to be called:
    echo -at ~~  $+ $mircdirTypingNotifs
    echo -at ~~ ~~**~~
    return $false
  }
  else {
    set %unableToCreateDir $false
    echo -at ~~ Created! Yay, can't wait for you to see how it works! =]
    return $true
  }
}

;; Make sure the second editbox is open
on *:ACTIVE:#:{
  if ($len($editbox($active,1)) == 0) {
    editbox -ovq1 $active
  }
}

alias AddTyping {
  if ($readini($server $+ -typing.ini,$2,$3) != $null) return
  writeini TypingNotifs/ $+ $1 $+ -typing.ini $2 $3 active
}

alias RemoveTyping {
  remini TypingNotifs/ $+ $1 $+ -typing.ini $2 $3
}

alias GetTyping {
  set %string [none]
  var %i 1
  while (%i <= $ini(TypingNotifs/ $+ $server $+ -typing.ini, $1, 0)) {
    set %string %string $+ , $ini(TypingNotifs/ $+ $server $+ -typing.ini, $1, %i)
    inc %i
  }
  set %string $replace(%string,$me,(You))
  editbox -o $1 Typing: $iif($len($right(%string,-8)) <= 0,(none),$right(%string,-8))
}

alias RemoveAndClear {
  RemoveTyping $1-
  GetTyping $2
}

RAW TAGMSG:*:{
  ; User is typing. Show us and set a 6 second timer to remove it. If they typed between now and then, the timer restarts.
  if ($msgtags(+typing).key == active) AddTyping $server $target $nick | .timer $+ $+($server,$target,$nick) 1 6 RemoveAndClear $server $target $nick
  else if ($msgtags(+typing).key == paused) || ($msgtags(+typing).key == done) RemoveTyping $server $target $nick
  GetTyping $target
}

on *:QUIT:{
  var %i 0
  while (%i <= $comchan($nick,0)) {
    inc %i
    if ($nick == $me) continue
    RemoveTyping $server $comchan($nick,%i) $nick
  }
}

on *:TEXT:*:#:RemoveTyping $server $chan $nick
on *:DISCONNECT:{
  ;; check if there are any other connections from our client before we start deleting stuff
  remove TypingNotifs/ $+ $server $+ -typing.ini
}
on *:KICK:#:RemoveTyping $server $chan $knick
on *:PART:#:RemoveTyping $server $chan $nick
on *:NICK:{
  while (%i <= $comchan($nick,0)) {
    RemoveTyping $server $comchan($nick,%i) $nick
    inc %i
  }
}
on *:CONNECT:{
  .remove TypingNotifs/ $+ $server $+ -typing.ini
}

on *:PARSELINE:out:*:{
  tokenize 32 $parseline
  if ($1 == CAP) && ($2 == REQ) && (echo-message !isin $3-) { parseline -ton cap req :echo-message $right($3-,-1) | haltdef }
}
