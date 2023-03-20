	.global pipo256_keygen
	.type pipo256_keygen, @function

	#define CNT R18
	#define MK0 R22
	#define MK1 R23
	#define MK2 R24
	#define MK3 R25

	.macro MKRK
		LD MK0, X+ 
		LD MK1, X+
		LD MK2, X+
		LD MK3, X+

		EOR MK0, CNT

		ST Z+, MK0
		ST Z+, MK1
		ST Z+, MK2
		ST Z+, MK3

		LD MK0, X+ 
		LD MK1, X+
		LD MK2, X+
		LD MK3, X+

		ST Z+, MK0
		ST Z+, MK1
		ST Z+, MK2
		ST Z+, MK3

		INC CNT
	.endm


	pipo256_keygen:

	MOVW R30, R24  //rk, Zpointer
	MOVW R26, R22  //mk, Xpointer
	LDI CNT, 0

	LOOP:
	MKRK
	MKRK
	MKRK
	MKRK
	SUBI R26, 32
	CPI CNT, 34
	BRGE LOOP_OUT
	RJMP LOOP

	LOOP_OUT:
	RET