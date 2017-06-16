; un commentaire
; declare une constante, ici une chaine "=> %d"
@str = constant [7 x i8] c"=> %d\0A\00"
;declare une fonction, sans la définir
declare i32 @printf(i8*,...)
; declare et defini la fonction mafonction
define i32 @mafonction(i32 %arg) {
;mafonction est une fonction (globale)
%x = mul i32 %arg, 2
;multiplication entière, retournant un i32
%y = add i32 %x , 32
; addition entière
%z = sub i32 %y, %x
; soustraction entière
%a = sdiv i32 %z, 4
;division entière

%b = sitofp i32 %a to double
; conversion de %a en double
%c = fmul double %b, 0x4000000000000000
;multuplication flottante, retournant un double
%d = fptosi double %c to i32
; conversion de %c en entier
ret i32 %d
}

define i32 @main() {
; main est une variable globale
%retval = call i32 @mafonction(i32 42)
; appelle printf avec le resultat renvoye par mafonction
call i32 (i8*, ...) @printf(i8* getelementptr ([7 x i8], [7 x i8]* @str, i32 0, i32 0),
i32 %retval)
ret i32 0
}