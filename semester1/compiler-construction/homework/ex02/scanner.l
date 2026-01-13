NameStartChar    [a-zA-Z]
NameChar         {NameStartChar}|[\-\.0-9]
Name             {NameStartChar}({NameChar})*
Comment          "<!--"([^\-]|"-"[^\-])*"-->"
String           \'[^\']*\'|\"[^\"]*\"
Token            "<?"|"</"|"<"|"/>"|">"|"?>"|"="

%%

{String}         printf("String: %s\n", yytext);
{Name}           printf("Name: %s\n", yytext);
{Comment}        /* skip */
{Token}          printf("Token: %s\n", yytext);
.|\n             /* skip */

%%

int main(void) {
	yylex();
	return 0;
}
