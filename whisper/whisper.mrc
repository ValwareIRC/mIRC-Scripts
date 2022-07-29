; Licence: GPLv3 or later
; Copyright Ⓒ 2022 Valerie Pond
; This is just a small script which lets you use /WHISPER <nick> <message>
; It sends a message to the specified nick using the channel as a context
; allowing you to essentially whisper to someone in the channel.
;
; The server MUST support `draft/channel-context` in order for this to work.
; The channel MUST be the active window when using /WHISPER

alias whisper {
  %nick = $1
  %msg = $2-
  %chan = $active
  if (%chan !ischan) {
    echo -at You are not on a channel
    return
  }
  if ($left(%nick,1) isin $chantypes) {
    echo -at * You cannot whisper to a channel
    return
  }
  if (%nick !ison %chan) || ($me !ison %chan) {
    echo -at * You do not share that channel
    return
  }
  .raw @+draft/channel-context= $+ %chan NOTICE %nick : $+ %msg
  echo -t %chan [Whisper to %nick $+ ] %msg
}

on *:NOTICE:*:?:{
  if ($msgtags(+draft/channel-context).key !== $null) echo -t $msgtags(+draft/channel-context).key [Whisper from $nick $+ ] $1-
}
