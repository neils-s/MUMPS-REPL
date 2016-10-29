REPLTST
	;
try(code,%returnVal) q:$g(code)="" ""
	n $etrap
	s $etrap="g catch^"_$t(+0) ; goto the 'catch' code in the current routine
	x code
	q:$quit $g(%returnVal) q
catch s $ec="" ; clear the error condition
	q:$quit "" q
	;
replCommand() 
	q "n $et s $et=""u 0 w """"<ERROR>""""_$ec,! s $ec="""""""""" f  x ""u 0:delim=$c(13,10) n %in w $c(13,10)_"""">"""" r %in:60 halt:'$t  x:$l(%in) %in"""
	;
doubleQuote(str) n pos
	s pos=0,str=$g(str)
	f  s pos=$f(str,"""",pos) q:pos=0  d
	. s str=$e(str,1,pos-1)_""""_$e(str,pos,$l(str))
	. s pos=pos+1
	q """"_str_""""
	;
REPL(%port,%host,%timeout) q:$g(%port)=""
	s:$g(%timeout)="" %timeout=60
	n %dv,%in,%conn,%handle,%jobCmd
	s %dv="|TCP|"_$j
	w !,"Opening connection"
	i $g(%host)]"" d  i 1  ; open a TCP client connection to a remote host
	. s %handle="client"
	. OPEN %dv:(connect=%host_":"_%port_":TCP":delim=$c(13):attach=%handle):%timeout:"socket"
	. s %conn=$t
	e  d  i 1  ; open a TCP server to listen for incoming connections
	. i 1 OPEN %dv:(listen=%port_":TCP":delim=$c(13)):1:"socket"
	. i '$t s %conn=0 q  ; listening port failed to open
	. u %dv w /wait(%timeout) s %conn=$T,%handle=$p($k,"|",2)
	;
	i %conn d  i 1
	. USE 0 w !,"Connection established.  Passing socket to new job running REPL..."
	. USE %dv:detach=%handle ; detach handle for passing
	. s %jobCmd="try("_$$doubleQuote($$replCommand())_"):(input=""SOCKET:"_%handle_""":output=""SOCKET:"_%handle_""")"
	. JOB @%jobCmd
	. USE 0 w $s($t:"successfully",1:"unsuccessfully")
	e  USE 0 w !,"Connection refused."
	USE 0 w !,"Closing connector in this job." CLOSE %dv ; :socket=%handle
	q
	;

