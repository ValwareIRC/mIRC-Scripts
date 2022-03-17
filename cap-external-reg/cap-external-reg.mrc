RAW *:*:{
  %str = $chr(42) LS
  if ($1-2 == %str) {
    %string = $1-
    %i = 0
    while (0 == 0) {
      tokenize 32 %string
      if (external-reg isin $1) {
        %extreglink = $gettok($1,2,61)
        open_reg_link_dialog $server %extreglink
        break
      }
      else {
        if (!$2) { break }
        %string = $2-
        tokenize 32 %string
      }
    }
  }
}
dialog reg_link_dialog {
  title This IRC server is asking to use a webpage to register an account
  option dbu
  size -1 -1 300 100

  text "", 1, 5 5 240 20
  text "Only click 'Open' if you trust this server and would like to open the website it's asking you to register on.", 2, 5 20 260 10
  text "Would you like to continue and open the webpage?", 6, 5 65 150 14
  text "The webpage this server is asking you to visit is:", 4, 5 35 150 10
  edit "", 5, 5 45 270 13

  button "Open", 10, 100 85 40 10, close
  button "Cancel", 11, 160 85 40 10, default close
}
on *:DIALOG:reglink_*:*:*:{
  if ($devent == init) { did -a $dname 1 %reglinknet is asking you to register using a webpage. | did -a $dname 5 %extreglink | did -m $dname 5 }
  if ($devent == sclick) && ($did == 10) { run %extreglink | dialog -x $dname }
  if ($devent == sclick) && ($did == 11) { dialog -x $dname }
  if ($devent == close) { unset %extreglink }
}

alias open_reg_link_dialog {
  if ($server($1).methodpass) { return }
  set %reglinknet $1
  if ($dialog(reglink_ $+ $1)) { return }
  dialog -m reglink_ $+ $1 reg_link_dialog 
}
