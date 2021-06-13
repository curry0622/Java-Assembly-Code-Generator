.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
	ldc 99
	istore 0
	ldc 1
	istore 1
	iload 1
	ldc 0
	isub
	ifgt label_0
	iconst_0
	goto label_1
	label_0:
	iconst_1
	label_1:
	iload 1
	ldc 1
	isub
	istore 1
	ldc 3.140000
	fstore 2
	fload 2
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(F)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	iload 0
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 0.000000
	fstore 3
	ldc 1
	istore 4
	iload 1
	ldc 1
	istore 1
	iload 1
	ldc 0
	isub
	ifgt label_2
	iconst_0
	goto label_3
	label_2:
	iconst_1
	label_3:
	ldc "hello world"
	astore 5
	iload 1
	ldc 1
	isub
	istore 1
	iload 4
	ldc 0
	isub
	ifgt label_4
	iconst_0
	goto label_5
	label_4:
	iconst_1
	label_5:
	iload 4
	ldc 1
	isub
	istore 4
	iconst_1
	istore 6
	iload 6
	ifne label_6
	ldc "false"
	goto label_7
	label_6:
	ldc "true"
	label_7:
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	aload 5
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	fload 3
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(F)V
	return
.end method
