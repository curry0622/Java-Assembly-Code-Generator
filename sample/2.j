.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
	ldc 3
	ldc 4
	ldc 5
	ldc -8
	iadd
	imul
	isub
	ldc 10
	ldc 7
	idiv
	isub
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 3
	ldc 4
	ldc 5
	ldc -8
	iadd
	imul
	isub
	ldc 10
	ldc 7
	idiv
	isub
	ldc -4
	ldc 3
	irem
	isub
	ifgt label_0
	iconst_0
	goto label_1
	label_0:
	iconst_1
	label_1:
	iconst_1
	iconst_1
	ixor
	iconst_0
	iconst_1
	ixor
	iconst_1
	ixor
	iand
	ior
	ifne label_2
	ldc "false"
	goto label_3
	label_2:
	ldc "true"
	label_3:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 3.000000
	ldc 4.000000
	ldc 5.000000
	ldc -8.000000
	fadd
	fmul
	fsub
	ldc 10.000000
	ldc 7.000000
	fdiv
	fsub
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(F)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 3.000000
	ldc 4.000000
	ldc 5.000000
	ldc -8.000000
	fadd
	fmul
	fsub
	ldc 10.000000
	ldc 7.000000
	fdiv
	fsub
	ldc -4.000000
	fcmpl
	ifgt label_4
	iconst_0
	goto label_5
	label_4:
	iconst_1
	label_5:
	iconst_1
	iconst_1
	ixor
	iconst_0
	iconst_1
	ixor
	iconst_1
	ixor
	iand
	ior
	ifne label_6
	ldc "false"
	goto label_7
	label_6:
	ldc "true"
	label_7:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	return
.end method
