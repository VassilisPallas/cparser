%option noyywrap yylineno

%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	int numberOfOpenCurlyBrackets = 0;
	int numberOfCloseCurlyBrackets = 0;
	char *thirdArgument[1];
	
	
	struct stack
	{
		char *info;
		struct stack *link;
		int lineno;
	};
	
	struct stack *start=NULL;

	void push(int, char *, char *);
	void pop(char *);
	void parsing(int, char *);
	int checkIfHasOpenedComment();
	int checkIfHasDoubleQuotes();
%}

LeftParentheses  "(" 
RightParentheses ")"
OpenCurlyBrackets "{"
CloseCurlyBrackets "}"
OpenBrackets "["
CloseBrackets "]"
OpenComment "\/\*"
CloseComment "\*\/"
DoubleQuotes "\""

%%
{LeftParentheses}		{ 
							if(checkIfHasOpenedComment() == -1 && checkIfHasDoubleQuotes() == -1)
								push(yylineno, "(", thirdArgument[0]);
						}
						
						
{OpenCurlyBrackets}		{
							if(checkIfHasOpenedComment() == -1 && checkIfHasDoubleQuotes() == -1)
							{
								push(yylineno, "{", thirdArgument[0]); 
								numberOfOpenCurlyBrackets++;
							}
						}
						
						
{OpenBrackets}			{
							if(checkIfHasOpenedComment() == -1 && checkIfHasDoubleQuotes() == -1) 
								push(yylineno, "[", thirdArgument[0]); 
						}
						
						
{OpenComment}			{ /* Το regex για το άνοιγμα του comment */ 
							if(checkIfHasOpenedComment() == -1 && checkIfHasDoubleQuotes() == -1)
								push(yylineno, "/*", thirdArgument[0]);
						}
						
						
{DoubleQuotes}			{ /* Το regex για τα double quotes */ 
							if(strcmp(start->info, "\"") == 0)
								pop(thirdArgument[0]);
							else if(checkIfHasDoubleQuotes() == -1 && checkIfHasOpenedComment() == -1)
								push(yylineno, "\"", thirdArgument[0]);
						}


{RightParentheses}		{ 
							if(strcmp(start->info, "(") == 0)
								pop(thirdArgument[0]);
						}
						
						
{CloseCurlyBrackets}	{ 
							if(checkIfHasOpenedComment() == -1 && checkIfHasDoubleQuotes() == -1)
								numberOfCloseCurlyBrackets++;
							if(strcmp(start->info, "{") == 0)
							{
								pop(thirdArgument[0]);
							}
						}
						
						
{CloseBrackets}			{ 
							if(strcmp(start->info, "[") == 0)
								pop(thirdArgument[0]);
						}

{CloseComment}			{ /* Το regex για το κλείσιμο του comment */
							if(checkIfHasOpenedComment() == 0)
								pop(thirdArgument[0]);
						}

.|\n 					{ /* για οποιονδήποτε άλλον χαρακτήρα δεν θα κάνει τίποτα */}
%%

int main(int argc, char *argv[])
{
	FILE* fp;
	
	if(argc < 2) {
		printf("Δεν δόθηκε όνομα αρχείου\n");
		exit(1);
	}
	else if(argc < 3) {
		printf("Δεν δόθηκε το τρίτο όρισμα\n");
		exit(1);
	}
		
	char *secondArgumentContainsDot = strrchr(argv[1], '.');
	if (secondArgumentContainsDot){
		if(strcmp(secondArgumentContainsDot, ".c") == 0){
			fp = fopen(argv[1],"r");
			if(!fp) 
			{
				/* Αν δεν μπορεί να ανοίξει επειδή δεν το βρήσκει ή λόγω δικαιωμάτων του 
				*  χρήστη
				*/
				perror(argv[1]);
				return 1;
			}
		}
		else{
			printf("Το αρχείο δεν είναι .c\n");
			exit(1);
		}
	}		
	else
	{
		printf("Το αρχείο δεν έχει καθορισμένη επέκταση\n");
		exit(1);
	}
	
	if(strcmp(argv[2], "on") == 0)
	{
		thirdArgument[0] = "on";
	}
	else if(strcmp(argv[2], "off") == 0)
	{
		thirdArgument[0] = "off";
	}
	else
	{
		printf("Το τρίτο όρισμα θα πρέπει να είναι on ή off\n");
		exit(1);
	}
	
	yyrestart(fp);
	yylineno = 1;
	yylex();
	fclose(fp);
	
	parsing(yylineno, thirdArgument[0]);
	return 0;
}

void push(int lineno, char *regex, char *thirdArgument)
{
	struct stack *new,*temp;
    int i=0;
    
	new = malloc(sizeof(start));

	new->info = regex;
	new->lineno = lineno;
	new->link = start;
	
	
	start=new;
	
	
	for(temp=start;temp!=NULL;temp=temp->link)
    {
		i++;
    }
	
	if(i>0 && strcmp(thirdArgument, "on") == 0)
	{
		for(temp=start;temp!=NULL;temp=temp->link)
		{
			printf("%s ",temp->info);
		}
		printf("\n");
	}
}

void pop(char *thirdArgument)
{
	struct stack *temp,*temp2;
    int i=0, j=0;
    
    for(temp=start;temp!=NULL;temp=temp->link)
    {
        i++;
    }
    
    if(i>0)
    {
		temp2=start->link;
        start=temp2;
    }
    
    for(temp=start;temp!=NULL;temp=temp->link)
    {
        j++;
    }
    
    if(j>0 && strcmp(thirdArgument, "on") == 0)
	{
		for(temp=start;temp!=NULL;temp=temp->link)
		{
			printf("%s ",temp->info);
		}
		printf("\n");
	}
	else if(j==0 && strcmp(thirdArgument, "on") == 0)
		printf("άδεια\n");
    
}

void parsing(int lineno, char *thirdArgument)
{
    struct stack *temp;
    int i = 0;
    int j;
    for(temp=start;temp!=NULL;temp=temp->link)
    {
       i++;
    }
    
    if(i != 0){
		int errors[i];
		for(temp=start, j=0;temp!= NULL;temp=temp->link, j++)
		{
			lineno = temp->lineno;
			errors[j] = lineno;
		}
		
		if((numberOfCloseCurlyBrackets == numberOfOpenCurlyBrackets))
			printf("\nError in line %d\n\n", errors[i-2]);
		else
			printf("\nError in line %d\n\n", errors[i-1]);
		
    }
    else if(i == 0)
		printf("\nParsing Complete.\n\n");
}


int checkIfHasOpenedComment()
{
	struct stack *temp;
    int i = 0;
           
    for(temp=start;temp!=NULL;temp=temp->link)
    {
        i++;
    }
    
    if(i != 0)
    {
		if(strcmp(start->info, "/*") == 0)
			return 0; 
	}
	return -1;
}

int checkIfHasDoubleQuotes()
{
	struct stack *temp;
    int i = 0;
           
    for(temp=start;temp!=NULL;temp=temp->link)
    {
        i++;
    }
    
    if(i != 0)
    {
		if(strcmp(start->info, "\"") == 0)
			return 0; 
	}
	return -1;
}
