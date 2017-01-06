; commentaire

@str = constant [4 x i8] c"%d\0A\00", align 1

declare i32 @printf(i8*, ...)

define void @pile() {
label0:
  %a = alloca i32
  %b = alloca i32
  %c = alloca i32
  %x0 = add i32 0, 5
  %x1 = add i32 0, 6
  store i32 %x0, i32* %a
  store i32 %x1, i32* %b
  %x2 = load i32, i32* %a
  %x3 = load i32, i32* %b
  %x4 = add i32 %x2, %x3
  store i32 %x4, i32* %c
  ret void
}

define i32 @ifthenelse(i32 %x) {
label0: ;entry
  %ret = alloca i32
  %x0 = add i32 0, 0
  store i32 %x0, i32* %ret
  %x1 = icmp sgt i32 %x, 0
  br i1 %x1, label %label1, label %label2

label1: ; if.then
  store i32 1, i32* %ret
  br label %label3

label2: ; if.else
  store i32 2, i32* %ret
  br label %label3

label3: ; if.end
  %x2 = load i32, i32* %ret
  ret i32 %x2
}

define i32 @loop(i32 %x) {
label0: ; entry
  %x.addr = alloca i32
  store i32 %x, i32* %x.addr
  %sum = alloca i32
  %i = alloca i32
  store i32 0, i32* %sum
  store i32 0, i32* %i
  br label %label1

label1: ; for.cond
  %x0 = load i32, i32* %i
  %x1 = load i32, i32* %x.addr
  %x2 = icmp slt i32 %x0, %x1
  br i1 %x2, label %label2, label %label4

label2: ; for.body
  %x3 = load i32, i32* %sum
  %x4 = add i32 %x3, 1
  store i32 %x4, i32* %sum
  br label %label3

label3: ; for.inc
  %x5 = load i32, i32* %i
  %x6 = add i32 %x5, 1
  store i32 %x6, i32* %i
  br label %label1

label4: ; for.end
  %x7 = load i32, i32* %sum
  ret i32 %x7
}

define void @add_int_double() {
label0:
  %a = alloca i32
  %b = alloca double
  %c = alloca double
  %x0 = add i32 0, 1
  store i32 %x0, i32* %a, align 4
  %x1 = fadd double 0x0000000000000000, 0x4000000000000000
  store double %x1, double* %b, align 8
  %x2 = load i32, i32* %a, align 4
  %x3 = sitofp i32 %x2 to double
  %x4 = load double, double* %b, align 8
  %x5 = fadd double %x3, %x4
  store double %x5, double* %c, align 8
  ret void
}

define void @add_double_int() {
label0:
  %a = alloca double
  %b = alloca i32
  %c = alloca i32
  %x0 = fadd double 0x0000000000000000, 0x3ff0000000000000
  store double %x0, double* %a
  %x1 = add i32 0, 3
  store i32 %x1, i32* %b
  %x2 = load double, double* %a, align 8
  %x3 = load i32, i32* %b, align 4
  %x4 = sitofp i32 %x3 to double
  %x5 = fadd double %x2, %x4
  %x6 = fptosi double %x5 to i32
  store i32 %x6, i32* %c, align 4
  ret void
}


define i32 @main() {
label0:
  %n = alloca i32
  call void @pile()
  %x0 = call i32 @ifthenelse(i32 42)
  store i32 %x0, i32* %n
  %x1 = load i32, i32* %n
  %x2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str, i32 0, i32 0), i32 %x1)
  %x3 = call i32 @loop(i32 10)
  store i32 %x3, i32* %n
  %x4 = load i32, i32* %n
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str, i32 0, i32 0), i32 %x4)
  ret i32 0
}
