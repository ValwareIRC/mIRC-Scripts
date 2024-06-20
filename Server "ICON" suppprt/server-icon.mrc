;; Gets a server's ICON and applies it to the corner of your Status window.
;; ICON is an ISUPPORT token which has not yet been made popular, but if
;; your server supports ICON and you're running this script, this will get
;; the image and apply it automatically.
;;
;; (c) Valware 2024

alias geticon {
  ; socket is already open
  if ($sock(geticon)) return
  sockopen -e geticon $1 443
  sockmark geticon $2-
}
on *:sockopen:geticon: {
  if ($sockerr) { echo -a Aaaaa $sockerr | return }
  var %s = sockwrite -n $sockname, %f = $sock($sockname).mark
  sockmark $sockname
  .fopen -o geticon $qt($gettok(%f,-1,47))
  %s GET %f HTTP/1.1
  %s Host: $sock($sockname).addr
  %s User-Agent: mIRC $version
  %s Connection: close
  %s $crlf
}
on *:sockread:geticon: {
  if ($sockerr > 0) { return }
  if ($sock($sockname).mark == 1) { goto download }

  var %s
  sockread %s
  while ($sockbr > 0) {
    if (%s == $null) {
      sockmark $sockname 1
      return
    }
    sockread %s
  }
  return

  :download
  var &s
  sockread &s
  while ($sockbr > 0) {
    .fwrite -b geticon &s
    sockread &s
  }
}
on *:sockclose:geticon: {
  .fclose geticon
  var %icon $eval($+(%,$server,.icon),2)
  .background -sp %icon
  .remove %icon
  echo -ts Set icon according to the ISUPPORT token for ICON
}

RAW 005:*ICON=*:{
  var %i = 1
  while ($gettok($1-,%i,32) != $null) {
    if ($left($gettok($1-,%i,32),5) == ICON=) {

      ;; mIRC sucks, I had to do this just to split up the
      ;; ICON token and correctly parse the given URL

      %url = $right($gettok($1-,%i,32),-5)
      if ($left(%url,7) == http://) %url = $right(%url,-7)
      if ($left(%url,8) == https://) %url = $right(%url,-8)
      %part_one = $left(%url,$calc($pos(%url,/) - 1))
      %part_two = $right(%url,$calc($+(-,$pos(%url,/)) + 1))
      set % $+ $server $+ .icon $gettok(%part_two,-1,47)
      geticon %part_one %part_two
    }
    inc %i
  }
