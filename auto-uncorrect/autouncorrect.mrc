;==============================
;=====Auto-uncorrect=========
;========by Valware===========

on *:INPUT:*:{

  var %data $1-

  if ($left($1,1) !== /) {

    var %data $replace(%data,%data,$lower(%data))
    var %data $replace(%data,??,?¿)
    var %data $replace(%data,¿?¿,¿/?)
    var %data $replace(%data,??,/?//)
    var %data $replace(%data,!!,$+(!,¡))
    var %data $replace(%data,¡!¡,¡1!)
    var %data $replace(%data,!!,one!¡!!)
    var %data $replacecs(%data,LOL,KEK)
    var %data $replacecs(%data,lol,kek)
    var %data $replace(%data,red,3red)
    var %data $replace(%data,blue,4blue)
    var %data $replace(%data,green,14green)
    var %data $replace(%data,yellow,9yellow)
    var %data $replace(%data,pink,12pink)
    var %data $replace(%data,purple,12purple)
    var %data $replace(%data,understand,comprende)
    var %data $replace(%data,:D,;d)
    var %data $replace(%data,:P,;p)
    var %data $replace(%data,:O,;o)
    var %data $replace(%data,:@,;#)
    var %data $replacecs(%data,lmao,lma0)
    var %data $replacecs(%data,LMAO,ELLEMAYO)
    var %data $replace(%data,rofl,omg u keel me ded)
    var %data $replace(%data,pmsl,fk i pissd myself)
    var %data $replace(%data,replace,s/./e/g)
    var %data $replace(%data,fuck,duck)
    var %data $replace(%data,shit,schizm)
    var %data $replace(%data,can't,carnt)
    var %data $replace(%data,you,u)
    var %data $replace(%data,me,mii)
    var %data $replace(%data,ha,ja)
    var %data $replace(%data,hehe,uwu)
    
    say %data
    halt
  }
}
