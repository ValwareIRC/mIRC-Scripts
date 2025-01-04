;; Valware © 2024
;; Talon © 2025
;;
;; Better Channel Typing Notifications
;; v2.0
;; Screenshot: https://i.ibb.co/9q05t9w/Screenshot-from-2024-08-17-04-42-21.png

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Changes:
; - Uses a temporary hash table now instead of individual ini files. This does
;   NOT require any cleanup as it's just a temp table in memory.
; - Logs typers by connection id instead of by server name
; - Removed echo-message CAP necessity, now just spoofs TAGMSG's for yourself if
;   sending typing notifications is checked in: alt+o->IRC->Options
;
; Fixes:
; - Ensures TAGMSG belongs to a channel and not a query
; - Did not clear typer instantly on an action message (missing event for it)
; - No longer expunges typers info on nickchange. (Like force-nickchange for not
;   identifying to services for example) IRCv3 vaguely specifies do this
;   on a recieved msg/part/quit, got a done TAGMSG, +30s from paused TAGMSG, or
;   +6s from the last active TAGMSG.
; - Runaway global variable "%i" since it was never declared in the NICK event.
;
; New:
; - Made identifier $GetTypers(#,N).<active|paused> to support the ability to
;   return various info: full lists of active/paused typers, counts of 
;   active/paused typers, and the ability to grab individual typers from the
;   active/paused list by index. See Documentation comments below.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;################################################################################
; Aliases
;################################################################################

;== Identifier to return typers of a given channel (left as global-alias just incase you may want to use it elsewhere)
; $GetTypers(#,N)
;
; Properties: active, paused
;
; The N parameter is optional, if $null returns tokenized list of nicknames.
; Properties are also optional, if none specified, defaults to active.
;
; Examples:
; $GetTypers(#) Returns tokenized list of nicknames of active typers by a comma (IE: foo, bar, baz)
; $GetTypers(#).paused Returns tokenized list of nicknames of paused typers by a comma (IE: foo, bar, baz)
;
; $GetTypers(#,0) Returns total number of active typers
; $GetTypers(#,1) Returns the first nickname that is actively typing.
;
; $GetTypers(#,0).paused Returns total number of paused typers
; $GetTypers(#,1).paused Returns the first nickname that is paused.
;
alias GetTypers {
  ;== Find total entries and iterate over them
  var %x = $hfind(IRCv3Typers,$+($cid,.,$$1,.*),0,w) , %count = 0 , %query = $iif(!$prop,active,$prop) , %ret
  while (%x) {
    var %item = $hfind(IRCv3Typers,$+($cid,.,$1,.*),%x,w) , %nick = $gettok(%item,-1,46) , %value = $hget(IRCv3Typers,%item)

    ;== Test if the value is what we're looking for (active/paused)
    if (%value == %query) { 
      ;== If we're only passed one parameter, we must want a tokenized list. Append to it.
      if ($0 == 1) { var %ret = $addtok(%ret,$chr(32) $+ %nick,44) }

      ;== Else increase our count variable. If we passed a 2nd argument > 0, return the nick in this spot if current count matches.
      else {
        inc %count
        if (%count == $2) { return %nick }
      }      
    }
    dec %x  
  }

  ;== If we passed a 2nd argument == 0, return the total count of nicks.
  if ($2 == 0) { return %count }

  ;== Lastly if all other returns don't trigger, we must want the tokenized list or we exceeded the total count of nicks in the 2nd parameter, in which case %ret will also be $null so returning this is fine
  return %ret
}

;== Local helper-alias to update the 2nd editbox...
alias -l ShowTypers { 
  var %typers = $GetTypers($1), %paused = $GetTypers($1).paused

  ;=-=-=-= Uncomment line below to retain replacing $me with (You) =-=-=-=
  ;var %typers = $replace(%typers,$me,(You)) , %paused = $replace(%paused,$me,(You))
  ;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

  ;== Modify the contents of the 2nd Editbox (set blank if no typers)
  editbox -o $$1 $iif(%typers,Typing:) %typers

  ;== Comment above one and uncomment this one AND the if below to show both active and paused!
  ;editbox -o $$1 $iif(%typers,Typing:) %typers $+ $iif(%typers && %paused,$chr(44)) $iif(%paused,Paused:) %paused 

  ;== Set a timer to update typers after 6 seconds IF we have paused typers (since it takes 5x as long to remove... 6 * 5 = 30s)
  ; Note: We can't just set it to 30, it might get reset to 6 from another typer, etc... we just have to keep re-starting it if we have typers..
  ;if (%paused) { $+(.timer,typers,.,$cid,.,$1) 1 6 ShowTypers $1 }
}

;################################################################################
; Remotes
;################################################################################

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;== Make sure the second editbox is open (Uncomment to re-enable auto 2nd editbox activation)
;on *:ACTIVE:#:{ if ($len($editbox($active,1)) == 0) { editbox -ovq1 $active } }
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;== Spoof our own TAGMSG lines back to ourselves (queue a new parseline in)
;- NOTE: Must have alt+o->IRC->Options Send typing notifications checked to see ourself...
on *:PARSELINE:out:*: {
  var %pl = $parseline
  if ($parseutf) { %pl = $utfdecode(%pl) }

  ;== If any number of characters not a space, then " TAGMSG " and the next character IS of a chantype from $chantypes
  ; spoof our own inbound TAGMSG to mIRC by replacing the 1st "space" with " :<fulladdress> " (@+typing=... :Me!user@host TAGMSG <target>)
  ; also remove $cr and/or $lf from end of parsed line since this is off of an outbound (mirc would treat it as <chan>$chr(10) otherwise...)
  if ($regex(%pl,/^[^ ]+ TAGMSG $+([,$chantypes,]/))) { .parseline -qtiu0 $remove($regsubex(%pl,/( )/,$+(\1,:,$address($me,5),\1)),$cr,$lf) | return }
}

;== Process +typing TAGMSGs
RAW TAGMSG:*:{
  ;== Determine if the target is a channel
  if ($target ischan) {

    ;== Determine timeout based on active/paused/done
    var %key = $msgtags(+typing).key

    if (%key == active) { var %timeout = 6 }
    elseif (%key == paused) { var %timeout = 30 }
    elseif (%key == done) { var %timeout = 0 }

    ;== If %timeout is != 0, Update the nickname that is typing's key and timeout (recieved active/paused)
    if (%timeout) {
      ;==Add new entry by dynamic item name: ConnectionID.Target.Nick
      hadd $+(-mu,%timeout) IRCv3Typers $+($cid,.,$target,.,$nick) %key 

      ;== Set a timer to update typers after 6 seconds
      $+(.timer,typers,.,$cid,.,$target) 1 6 ShowTypers $target
    }

    ;== Else remove nickname that was typing (recieved a done) (If the table does exist... To avoid hdel no such table)
    elseif ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.,$target,.,$nick) }

    ;== Immediately show the new active typers
    ShowTypers $target
  }
}

;== Expunge all entries for connection ID if we got disconnected (Extra precaution, do it as well if we connected too)
on *:DISCONNECT: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.*) } }
on *:CONNECT: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.*) } }

;== Expunge typer on input/action/text/kick/part (if the table exists yet...) and update windows typer list
on *:INPUT:#: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.,$target,.,$me) } | ShowTypers # }
on *:ACTION:*:#: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.,$target,.,$nick) } | ShowTypers # }
on *:TEXT:*:#: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.,$target,.,$nick) } | ShowTypers # }
on *:KICK:#: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.,$target,.,$knick) } | ShowTypers # }
on *:PART:#: { if ($hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.,$target,.,$nick) } | ShowTypers # }

;== Expunge entries for when a user or ourself quits
on *:QUIT: { 
  ;== If we're the one quitting, expunge all entries for the connection (if the table exists yet...)
  if ($nick == $me && $hget(IRCv3Typers)) { hdel -w IRCv3Typers $+($cid,.*) }

  ;== Else only expunge those records for the nickname that quit
  else { 
    ;== Find total entries and iterate over them (If we didn't need to update the list we could've just used hdel -w ...)
    var %x = $hfind(IRCv3Typers,$+($cid,.*.,$nick),0,w)
    while (%x) {
      var %item = $hfind(IRCv3Typers,$+($cid,.*.,$nick),%x,w) , %target = $gettok(%item,2,46)

      ;== Expunge entry and update typers (no need to check if table exists, we know it does if hfind returns > 0)
      hdel -w IRCv3Typers %item
      ShowTypers %target
      dec %x
    }
  }
}

;== Update typer on nickchange
on *:NICK: {
  ;== Find total entries and iterate over them
  var %x = $hfind(IRCv3Typers,$+($cid,.*.,$nick),0,w)
  while (%x) {
    var %item = $hfind(IRCv3Typers,$+($cid,.*.,$nick),%x,w) , %target = $gettok(%item,2,46) , %value = $hget(IRCv3Typers,%item) , %timeout = $hget(IRCv3Typers,%item).unset , %ret

    ;== Add new entry for the new nickname with the time remaining until it is to be expunged
    hadd $+(-mu,%timeout) IRCv3Typers $+($cid,.,%target,.,$newnick) %value

    ;== Expunge entry and update typers (no need to check if table exists, we know it does if hfind returns > 0)
    hdel -w IRCv3Typers %item
    ShowTypers %target
    dec %x
  }
}
