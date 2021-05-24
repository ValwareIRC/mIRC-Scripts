#############################################
#         UnrealIRCd Flood Settings         #
#            v.0.0.0.0.1-beta.0.1           #
#                 Valware ©                 #
#         https://valware.uk/github         #
#############################################


menu channel {
  UnrealIRCd Flood Settings:floodsettings
}

alias IsExChar {
  if ($1 === f) || ($1 === H) || ($1 == l) || ($1 === k) { return $true }
  else return $false
}
RAW *:*:{
  if ($numeric == 324) {
    if ($2 == $active) {
      set %chmod $remove($3,+)
      if (f isincs %chmod) { var %modef $poscs(%chmod,f) }
      if (H isincs %chmod) { var %modeH $poscs(%chmod,H) }
      if (l isincs %chmod) { var %modeLL $poscs(%chmod,l) }
      if (L isincs %chmod) { var %modeUL $poscs(%chmod,L) }
      if (k isincs %chmod) { var %modek $poscs(%chmod,k) }

      var %chch 1
      unset %unrealcc.*
      while (%chch <= $len(%chmod)) {
        if ($IsExChar($mid(%chmod,%chch,1)) == $true) {
          if (%unrealcc.extchars) { set %unrealcc.extchars %unrealcc.extchars $+ $mid(%chmod,%chch,1) }
          elseif (!%unrealcc.extchars) { set %unrealcc.extchars $mid(%chmod,%chch,1) }
        }
        inc %chch
      }
      if (%unrealcc.extchars) {

        var %chch 1
        while (%chch <= $len(%unrealcc.extchars)) {
          if (%unrealcc.extparvs) { set %unrealcc.extparvs %unrealcc.extparvs $gettok($4-,%chch,32) }
          elseif (!%unrealcc.extparvs) { set %unrealcc.extparvs $gettok($4-,%chch,32) }
          inc %chch
        }
      }
    }
    if (%floodreq == on) { dialog -m floodsettings floodsettings | unset %floodreq }
    HALT
  }
}


dialog floodsettings {
  title UnrealIRCd Flood settings for %floodchan
  option dbu
  size -1 -1 300 200
  text "", 1, 5 5 300 20

  text "In", 2, 5 30 10 10
  edit "", 3, 15 28 20 10
  text "seconds:", 4, 37 30 22 10

  edit "", 10, 5 48 20 10
  text "CTCP's will set:", 11, 30 50 40 10
  combo 12, 85 48 40 10, drop
  text "for", 13, 130 50 10 10
  edit "", 14, 140 48 20 10
  text "minutes.", 15, 165 50 30 10
  button "Clear", 16, 200 48 30 10

  edit "", 20, 5 63 20 10
  text "Joins will set", 21, 30 65 40 10
  combo 22, 85 63 40 10, drop
  text "for", 23, 130 65 10 10
  edit "", 24, 140 63 20 10
  text "minutes.", 25, 165 65 30 10
  button "Clear", 26, 200 63 30 10

  edit "", 30, 5 78 20 10
  text "/KNOCKs will set", 31, 30 80 40 10
  combo 32, 85 78 40 10, drop
  text "for", 33, 130 80 10 10
  edit "", 34, 140 78 20 10
  text "minutes.", 35, 165 80 30 10
  button "Clear", 36, 200 78 30 10

  edit "", 40, 5 93 20 10
  text "Channel msgs will set", 41, 30 95 52 10
  combo 42, 85 93 40 10, drop
  text "for", 43, 130 95 10 10
  edit "", 44, 140 93 20 10
  text "minutes.", 45, 165 95 30 10
  button "Clear", 46, 200 93 30 10

  edit "", 50, 5 108 20 10
  text "User msgs will set", 51, 30 110 50 10
  combo 52, 85 108 40 10, drop
  text "for", 53, 130 110 10 10
  edit "", 54, 140 108 20 10
  text "minutes.", 55, 165 110 30 10
  button "Clear", 56, 200 108 30 10

  edit "", 60, 5 123 20 10
  text "Nick changes will set", 61, 30 125 50 10
  combo 62, 85 123 40 10, drop
  text "for", 63, 130 125 10 10
  edit "", 64, 140 123 20 10
  text "minutes.", 65, 165 125 30 10
  button "Clear", 66, 200 123 30 10

  edit "", 70, 5 138 20 10
  text "Repetitions will set", 71, 30 140 50 10
  combo 72, 85 138 40 10, drop
  text "for", 73, 130 140 10 10
  edit "", 74, 140 138 20 10
  text "minutes.", 75, 165 140 30 10
  button "Clear", 76, 200 138 30 10

  button "Clear all", 100, 170 160 40 10
  button "Set and close", 101, 230 180 50 10, default

  text "See this link for more information on UnrealIRCd's anti-flood feature:", 103, 5 160 150 14
  link "https://www.unrealircd.org/docs/Anti-flood_features", 104, 5 175 130 10
}
alias floodsettings mode $active | set %floodreq on
on *:DIALOG:floodsettings:*:*:{
  if ($devent == init) && ($did == 0) {
    did -f $dname 100
    didtok -a $dname 12 44 +C (default),+m,+M
    didtok -a $dname 22 44 +i (default),+R
    did -a $dname 32 +K (default)
    didtok -a $dname 42 44 +m (default),M,drop
    did -a $dname 52 +N (default)
    didtok -a $dname 62 44 Kick (default),Ban,Drop
    didtok -a $dname 72 44 Kick (default),Ban,Drop

    did -a floodsettings 1 Here, you can easily make use of UnrealIRCd's anti-flood features in channels. $crlf $+ Obvious logic applies, i.e. you cannot "kick" someone for 3 minutes.
    var %position_of_floodchar $poscs(%unrealcc.extchars,f)
    var %flood_params $gettok(%unrealcc.extparvs,%position_of_floodchar,32)
    var %interval_seconds $gettok(%flood_params,2,58)
    did -ra $dname 3 %interval_seconds
    var %actions $remove($gettok(%flood_params,1,58),[,])
    var %num_of_actions $numtok(%actions,44)
    var %s 1
    while (%s <= %num_of_actions) {
      var %action $gettok(%actions,%s,44)
      var %num_trig $left($gettok(%action,1,35),-1)
      var %act_trig $right($gettok(%action,1,35),1)
      var %act_action $left($gettok(%action,2,35),1)
      var %act_mins $right($gettok(%action,2,35),-1)

      if (%act_trig === c) { 
        did -ra $dname 10 %num_trig
        if (%act_action) {
          if (%act_action === m) { did -c $dname 12 2 }
          if (%act_action === M) { did -c $dname 12 3 }
          else { did -c $dname 12 1 }
        }
        else { did -c $dname 12 1 }
        did -ra $dname 14 %act_mins
      }
      if (%act_trig === j) {
        did -ra $dname 20 %num_trig
        if (%act_action === R) { did -c $dname 22 2 }
        else { did -c $dname 22 1 }
        did -ra $dname 24 %act_mins
      }
      if (%act_trig === k) { 
        did -ra $dname 30 %num_trig
        did -c $dname 32 1
        did -ra $dname 34 %act_mins
      }
      if (%act_trig === m) {
        did -ra $dname 40 %num_trig
        if (%act_action) {
          if (%act_action === M) { did -c $dname 42 2 }
          if (%act_action === d) { did -c $dname 42 3 }
          else { did -c $dname 42 1 }
        }
        else { did -c $dname 42 1 }
        did -ra $dname 44 %act_mins
      }
      if (%act_trig === n) {
        did -ra $dname 50 %num_trig
        did -c $dname 52 1
        did -ra $dname 54 %act_mins
      }
      if (%act_trig == t) {
        did -ra $dname 60 %num_trig
        if (%act_action == m) { did -c $dname 62 1 }
        if (%act_action == b) { did -c $dname 62 2 }
        if (%act_action == d) { did -c $dname 62 3 }
        else { did -c $dname 62 1 }
        did -ra $dname 64 %act_mins
      }
      if (%act_trig == r) {
        did -ra $dname 70 %num_trig
        if (%act_action) { did -c $dname 72 $iif(%act_action === d,2,3) }
        did -ra $dname 74 %act_mins
      }
      inc %s
    }
  }
  if ($devent == sclick) {

    if ($did == 101) {

      mode %floodchan $putmodef
    }
  }
}

alias -l ftext return $did(floodsettings,$1).text
alias -l fsel return $did(floodsettings,$1).sel
alias putmodef {
  if ($ftext(10) > 0) {
    var %sel $fsel(12)
    if (%sel == 1) { var %action C }
    if (%sel == 2) { var %action m }
    if (%sel == 3) { var %action M }
    var %c $ftext(10) $+ c $+ $iif(%action,$chr(35) $+ %action $+ $ftext(14)) $+ $chr(44)
    var %action
  }
  if ($ftext(20) > 0) {
    var %sel $fsel(22)
    if (%sel == 1) { var %action i }
    if (%sel == 2) { var %action R }
    var %j $ftext(20) $+ j $+ $iif(%action,$chr(35) $+ %action $+ $ftext(24)) $+ $chr(44)
    var %action
  }
  if ($ftext(30) > 0) {
    var %sel $fsel(32)
    var %action K
    var %k $ftext(30) $+ k $+ $iif(%action,$chr(35) $+ %action $+ $ftext(34)) $+ $chr(44)
    var %action
  }  
  if ($ftext(40) > 0) {
    var %sel $fsel(42)
    if (%sel == 1) { var %action m }
    if (%sel == 2) { var %action M }
    if (%sel == 3) { var %action d }
    var %m $ftext(40) $+ m $+ $iif(%action,$chr(35) $+ %action $+ $ftext(44)) $+ $chr(44)
    var %action
  }
  if ($ftext(50) > 0) {
    var %sel $fsel(52)
    if (%sel == 1) { var %action M }
    if (%sel == 2) { var %action b }
    if (%sel == 3) { var %action d }
    var %t $ftext(50) $+ t $+ $iif(%action,$chr(35) $+ %action $+ $ftext(54)) $+ $chr(44)
    var %action
  }
  if ($ftext(60) > 0) {
    var %sel $fsel(62)
    var %action N
    var %n $ftext(60) $+ n $+ $iif(%action,$chr(35) $+ %action $+ $ftext(64)) $+ $chr(44)
    var %action
  }
  if ($ftext(70) > 0) {
    var %sel $fsel(72)
    if (%sel == 2) { var %action b }
    if (%sel == 3) { var %action d }
    var %r $ftext(70) $+ r $+ $iif(%action,$chr(35) $+ %action $+ $ftext(74))
  }
  var %int $ftext(3)

  var %chmodef $+(%c,%j,%k,%m,%t,%n,%r)
  if (!%chmodef) { return -f }
  if ($right(%chmodef,1) == $chr(44)) { var %chmodef $left(%chmodef,-1) }
  var %full $+($chr(91),%chmodef,$chr(93),:,%int)
  return +f %full
}
