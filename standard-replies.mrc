on *:PARSELINE:in:*:{
  tokenize 32 $parseline
  if ($left($parseline,1) == @) {
    tokenize 32 $2-
  }
  else tokenize 32 $1-
  if (. isin $1)  tokenize 32 $2-
  %s = $1
  %cmd = $2
  %code = $iif($left($3,1) !== $chr(58),(Error code: $3 $+ ),$null)
  %context = $iif($left($4,1) !== $chr(58),( $+ $4 $+ ),$null)
  if ($1 !== FAIL) && ($1 !== WARN) && ($1 !== NOTE) {
    return
  }
  if (%s == FAIL) %c = 4
  elseif (%s == WARN) %c = 7
  elseif (%s == NOTE) %c = 8
  tokenize 58 $1-
  echo %c -at * %s $+ : $2 ( $+ %cmd $+ ) %code %context
}
