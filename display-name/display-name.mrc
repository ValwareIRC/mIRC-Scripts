# This is a script which allows you to see and send the IRCv3 proposed `display-name` message-tag
# You can set your display name by typing /displayname WeeWoo
# Must be connected to a server which supports message-tags, or if unrealircd, you'll need to load my module:
# https://github.com/ValwareIRC/valware-unrealircd-mods/tree/main/display-name

on ^*:TEXT:*:*:{
  %display = $msgtags(+draft/display-name).key
  if (!%display) return
  echo -tc normal $chan < $+ %display ( $+ $nick $+ ) $+ > $1-
  window -g1 $target
  halt
}


on ^*:ACTION:*:*:{
  %display = $msgtags(+draft/display-name).key
  %rep = \s
  %repl = $chr(32)
  %display = $replace(%display,%rep,%repl)
  if (!%display) return
  echo -tc action $target * %display ( $+ $nick $+ ) $1-
  window -g1 $target
  halt
}

on *:PARSELINE:out:*:{
  tokenize 32 $parseline
  if (%displayname == $null) return
  if ($left($1,1) == @) && (display-name !isin $1) {
    .parseline -ot $1 $+ ;+draft/display-name= $+ %displayname $2-
  }
}

on *:LOAD:set %displayname $$?="What display name would you like?"
alias displayname set %displayname $1-
