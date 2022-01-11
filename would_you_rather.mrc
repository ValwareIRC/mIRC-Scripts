on *:LOAD:{

  ;Edit this to change the trigger. Default: !wyr

  set %trigger !wyr

  ;Edit these to change if you want it in a channel (room) and / or private message (true/false)

  set %wyr_in_chan true
  set %wyr_in_priv false

  ;Give question colour? (Press Ctrl+K to bring up the colour board
  ;just remember to delete the control it inputs when you press it)

  set %question_colour_active true
  set %question_background_colour_1 11
  set %question_background_colour_2 4
  set %question_text_colour 1

  wyr

}

on *:TEXT:*:*:{

  if ($1 == %trigger) {
    if ($chan) && (%wyr_in_chan == true) { var %dest $chan }
    elseif (!$chan) && (%wyr_in_priv == true) { var %dest $nick }
    if (%dest) {

      ;Picking a random number between 1 and however many questions you have.

      var %q $read(wyr.txt)   

      msg %dest $iif(%question_colour_active == true,$+(,%question_background_colour_1,$chr(44),%question_text_colour),) $+ Would Yo $+ $iif(%question_colour_active == true,$+(,,%question_background_colour_2,$chr(44),%question_text_colour,),) $+ u Rather: %q
    }
  }
}
dialog wyr {
  title Would You Rather
  size -1 -1 300 200
  option dbu

  tab "Questions", 1, 1 1 300 180
  tab "Settings", 2
  tab "About", 3

  text "Add question", 10, 5 20 40 10, tab 1
  edit "", 11, 5 30 100 10, tab 1
  text "OR", 12, 110 32 10 10, tab 1
  edit "", 13, 120 30 100 10, tab 1
  button "Add", 14, 225 30 40 10, tab 1

  list 15, 5 50 290 130, tab 1

  box "Colours", 20, 5 25 100 100, tab 2
  check "Coloured question", 21, 10 35 60 10, tab 2
  text "Background 1 colour", 22, 10 55 60 10, tab 2
  text "Background 2 colour", 23, 10 75 60 10, tab 2
  edit "", 24, 63 53 20 10, tab 2
  edit "", 25, 63 73 20 10, tab 2

  box "Triggers", 30, 110 25 100 100, tab 2

  text "Phrase", 31, 120 35 40 10, tab 2
  edit "", 32, 140 33 40 10, tab 2
  check "Channels", 33, 120 50 40 10, tab 2
  check "Private", 34, 120 60 40 10, tab 2

  text "Help", 35, 250 20 20 10, tab 2
  text "", 36, 220 30 70 100, center, tab 2

  button "Save", 37, 180 130 30 10, tab 2

  text "About", 40, 5 20 290 10, tab 3, center
  text "Author: V Pond", 41, 5 40 290 10, tab 3, center
  text "Date: 22/08/2020", 42, 5 50 290 10, tab 3, center
  text "Title: Would You Rather", 43, 5 60 290 10, tab 3, center
  text "Version: 0.1", 44, 5 70 290 10, tab 3, center
  link "https://valware.uk", 45, 130 90 100 10, tab 3
  link "irc.valware.uk", 46, 133 100 100 10, tab 3
  link "v.a.pond@outlook.com", 47, 130 110 100 10, tab 3

  button "Close", 50, 260 185 30 10, ok

}
alias wyr dialog -m wyr wyr
menu menubar {
  Would You Rather settings:/wyr
}
on *:DIALOG:wyr:*:*:{
  if ($did == 0) && ($devent == init) {
    did -a wyr 36 You can press Ctrl+K to bring up the colour board whilst in an editbox. Just make sure you delete the square before choosing the number!
    did -a wyr 36 $did(wyr,36) $+ $+($crlf,$crlf)
    did -a wyr 36 $did(wyr,36) $+ I recommend keeping the trigger phrase starting with an exclamation mark.
    var %s 1
    while (%s <= $lines(wyr.txt)) { did -a wyr 15 $strip($read(wyr.txt)) | inc %s }
    if (%question_colour_active == true) { did -c wyr 21 }
    did -a wyr 24 %question_background_colour_1
    did -a wyr 25 %question_background_colour_2
    did -a wyr 32 %trigger
    if (%wyr_in_chan == true) { did -c wyr 33 }
    if (%wyr_in_priv == true) { did -c wyr 34 }

  }
  if ($devent == sclick) && ($did == 14) {
    if ($did(wyr,11).text != $null) && ($did(wyr,13).text != $null) {
      write wyr.txt $did(wyr,11) OR $did(wyr,13)
      did -a wyr 15 $did(wyr,11).text OR $did(wyr,13).text
    } 
    else { echo 12 -a $timestamp *** An error occurred trying to add your questions. Please check both boxes have input. }
  }

  if ($devent == sclick) && ($did == 37) {

    set %question_background_colour_1 $did(wyr,24).text
    set %question_background_colour_2 $did(wyr,25).text
    set %trigger $did(wyr,32).text
    if ($did(wyr,21).state == 1) { set %question_colour_active true }
    if ($did(wyr,21).state == 0) { set %question_colour_active false }
    if ($did(wyr,33).state == 1) { set %wyr_in_chan true }
    if ($did(wyr,33).state == 0) { set %wyr_in_chan false }
    if ($did(wyr,34).state == 1) { set %wyr_in_priv true }
    if ($did(wyr,34).state == 0) { set %wyr_in_priv false }
    echo 12 -a $timestamp *** Your settings have been updated.
  }
}
