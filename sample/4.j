.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
	ldc 3
	newarray int
	astore 0
	aload 0
	ldc 0
	ldc 1
	ldc 2
	iadd
	iastore
	aload 0
	ldc 1
	aload 0
	ldc 0
	iaload
	ldc 1
	isub
	iastore
	aload 0
	ldc 2
	aload 0
	ldc 2
	ldc 1
	isub
	iaload
	ldc 3
	imul
	iastore
	aload 0
	ldc 0
	iaload
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	aload 0
	ldc 1
	iaload
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	aload 0
	ldc 2
	iaload
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(I)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	ldc 3
	newarray float
	astore 1
	aload 1
	ldc 0
	ldc 1.000000
	ldc 2.000000
	fadd
	fastore
	aload 1
	ldc 1
	aload 1
	ldc 0
	faload
	ldc 1.000000
	fsub
	fastore
	aload 1
	ldc 2
	aload 1
	ldc 2
	ldc 1
	isub
	faload
	ldc 3.000000
	fdiv
	fastore
	aload 1
	ldc 0
	faload
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(F)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	aload 1
	ldc 1
	faload
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(F)V
	ldc "\n"
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
	aload 1
	ldc 2
	faload
	getstatic java/lang/System/out Ljava/io/PrintStream;
	swap
	invokevirtual java/io/PrintStream/print(F)V
	return
.end method
