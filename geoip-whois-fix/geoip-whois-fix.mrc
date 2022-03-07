# Simple script to fix the displaying of GEOIP whois numeric data
# Valware © 2022

on *:PARSELINE:in:*:{

  tokenize 32 $parseline

  ; lose any msgtags as we don't need to touch them
  if ($left($1,1) == @) {
    tokenize 32 $2-
  }

  ; we only are after 344
  if ($2 !== 344) { return }

  %IsNew = $iif(connecting isin $5-,$true,$false)

  ; if string contains "connecting", it's new. if it contains "connected" it's old.

  if (!%IsNew) { return }
  if ($server == $scid($activecid).server) {
    if ($GetWhoisBufferOption) { echo -at $4 is connecting from $9 ( $+ $5 $+ ) }
    else { echo -st $4 is connecting from $9 ( $+ $5 $+ ) }
  }
  else { echo -st $4 is connecting from $9 ( $+ $5 $+ ) }
}


; hide the old broken one
RAW 344:*:{
  if (connecting isin $4-) { HALT }
}

; function to honor the option which chooses whether to display whois strings in active window or not
alias GetWhoisBufferOption {
  tokenize 44 $readini(mirc.ini,options,n2)
  if ($26 == 1) { return $true }
  return $false
}
