;; Valware © 2024
;; https://github.com/ValwareIRC
;;
;; Better Typing Notifications
;; v1.0
;; Please allow this script to run on load,
;; this is so that it can create its own
;; directory to manage typing notifications
;; using files to remember what's going on

on *:LOAD:{
  set %unableToCreateDir $false
  if ($isdir($mircdirTypingNotifs)) return
  echo -at ~~ ^__^ Thank you so much for checking out the Typing Notifications script.
  echo -at ~~ Just gotta make a directory! La la la...
  .mkdir " $+ $mircdirTypingNotifs $+ "
  if (!$isdir($mircdirTypingNotifs)) {
    set %unableToCreateDir $true
    echo -at ~~ Oh no! It seems that I,the Typing Notifications script, cannot create the directory.
    echo -at ~~ I only need it for tidiness. Please could you create it? It needs to be called:
    echo -at ~~  $+ $mircdirTypingNotifs
    echo -at ~~ ~~**~~
  }
  else {
    set %unableToCreateDir $false
    echo -at ~~ Created! Yay, can't wait for you to see how it works! =]
  }
}

;; Make sure the second editbox is open
on *:ACTIVE:#:{
  if ($len($editbox($active,1)) == 0) {
    editbox -ovq1 $active
  }
  set %unableToCreateDir $iif($isdir,$false,$true)
  if (!$isdir($mircdirTypingNotifs)) || (%unableToCreateDir == $false) || (%unableToCreateDir == $null) {
    echo -at ~~ Did you create that directory yet? => /mkdir $mircdirTypingNotifs
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

RAW TAGMSG:*:{
  if ($msgtags(+typing).key == active) AddTyping $server $target $nick
  else RemoveTyping $server $target $nick
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

on *:DISCONNECT:{
  ;; check if there are any other connections from our client before we start deleting stuff
  if (!$checkForMultipleConnections) && ($status == connected) remove TypingNotifs/ $+ $server $+ -typing.ini
}
on *:PART:#:RemoveTyping $server $chan $nick
on *:NICK:{
  while (%i <= $comchan($nick,0)) {
    RemoveTyping $server $comchan($nick,%i) $nick
    inc %i
  }
}

alias checkForMultipleConnections {
  var %i 0
  var %currentServer = $scid($cid).server
  echo -at %currentServer
  while (%i <= $scon(0)) {
    inc %i
    if (!$scon(%i)) continue
    if ($scon(%i).status != connected) continue
    if ($scon(%i).server != %currentServer) continue

    ; satisfied we're connected to the server from another window
    return 1    
  }
  return 0
}
