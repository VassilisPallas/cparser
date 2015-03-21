# cparser
a simple parser for C programs

write in terminal: flex parse.l
this is auto generate a file named lex.yy.c

then write: 
	for Linux: gcc lex.yy.c -o parse
	for Windows: gcc lex.yy.c -o parse.exe
	
this command will create the executable file named parse

and then run the program writing in the terminal:
	for Linux: ./parse
	for Windows: parse.exe