@w = common global double 0.000000e+00
@h = common global double 0.000000e+00
@angle = common global double 0.000000e+00
@angle_dir = common global i32 0
@N = common global i32 0

declare void @background(double)
declare void @fill(double)
declare void @stroke(double)
declare void @ellipse(double, double, double, double)
declare void @rect(double, double, double, double)
declare double @sin(double)
declare double @cos(double)
declare void @createCanvas(double, double)

define void @my_setup() {
  store double 6.400000e+02, double* @w
  store double 4.800000e+02, double* @h
  store double 0.000000e+00, double* @angle
  store i32 0, i32* @angle_dir
  store i32 200, i32* @N
  %1 = load double, double* @w
  %2 = load double, double* @h
  call void @createCanvas(double %1, double %2)
  ret void
}

define void @my_draw() {
  %1 = alloca i32
  %2 = alloca double
  call void @background(double 0.000000e+00)
  store i32 0, i32* %1
  br label %3

; <label>:3:                                      ; preds = %50, %0
  %4 = load i32, i32* %1
  %5 = load i32, i32* @N
  %6 = icmp slt i32 %4, %5
  br i1 %6, label %7, label %53

; <label>:7:                                      ; preds = %3
  %8 = load i32, i32* %1
  %9 = sitofp i32 %8 to double
  %10 = fmul double 2.550000e+02, %9
  %11 = load i32, i32* @N
  %12 = sitofp i32 %11 to double
  %13 = fdiv double %10, %12
  call void @fill(double %13)
  %14 = load i32, i32* @N
  %15 = load i32, i32* %1
  %16 = sub nsw i32 %14, %15
  %17 = sitofp i32 %16 to double
  %18 = fmul double 2.550000e+02, %17
  %19 = load i32, i32* @N
  %20 = sitofp i32 %19 to double
  %21 = fdiv double %18, %20
  call void @stroke(double %21)
  %22 = load i32, i32* %1
  %23 = sitofp i32 %22 to double
  %24 = load double, double* @angle
  %25 = fadd double %23, %24
  store double %25, double* %2
  %26 = load double, double* @w
  %27 = fdiv double %26, 2.000000e+00
  %28 = load i32, i32* %1
  %29 = sitofp i32 %28 to double
  %30 = load double, double* %2
  %31 = call double @sin(double %30)
  %32 = fmul double %29, %31
  %33 = fadd double %27, %32
  %34 = load double, double* @h
  %35 = fdiv double %34, 2.000000e+00
  %36 = load i32, i32* %1
  %37 = sitofp i32 %36 to double
  %38 = load double, double* %2
  %39 = call double @cos(double %38)
  %40 = fmul double %37, %39
  %41 = fadd double %35, %40
  %42 = load i32, i32* %1
  %43 = sitofp i32 %42 to double
  %44 = load double, double* @angle
  %45 = fmul double %43, %44
  %46 = load i32, i32* %1
  %47 = sitofp i32 %46 to double
  %48 = load double, double* @angle
  %49 = fmul double %47, %48
  call void @rect(double %33, double %41, double %45, double %49)
  br label %50

; <label>:50:                                     ; preds = %7
  %51 = load i32, i32* %1
  %52 = add nsw i32 %51, 1
  store i32 %52, i32* %1
  br label %3

; <label>:53:                                     ; preds = %3
  %54 = load i32, i32* @angle_dir
  %55 = icmp eq i32 %54, 0
  br i1 %55, label %56, label %63

; <label>:56:                                     ; preds = %53
  %57 = load double, double* @angle
  %58 = fadd double %57, 1.000000e-02
  store double %58, double* @angle
  %59 = load double, double* @angle
  %60 = fcmp ogt double %59, 2.000000e+00
  br i1 %60, label %61, label %62

; <label>:61:                                     ; preds = %56
  store i32 1, i32* @angle_dir
  br label %62

; <label>:62:                                     ; preds = %61, %56
  br label %74

; <label>:63:                                     ; preds = %53
  %64 = load i32, i32* @angle_dir
  %65 = icmp eq i32 %64, 1
  br i1 %65, label %66, label %73

; <label>:66:                                     ; preds = %63
  %67 = load double, double* @angle
  %68 = fsub double %67, 1.000000e-02
  store double %68, double* @angle
  %69 = load double, double* @angle
  %70 = fcmp olt double %69, -2.000000e+00
  br i1 %70, label %71, label %72

; <label>:71:                                     ; preds = %66
  store i32 0, i32* @angle_dir
  br label %72

; <label>:72:                                     ; preds = %71, %66
  br label %73

; <label>:73:                                     ; preds = %72, %63
  br label %74

; <label>:74:                                     ; preds = %73, %62
  ret void
}
