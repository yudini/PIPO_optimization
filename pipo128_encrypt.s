	.global pipo128_encrypt
	.type pipo128_encrypt, @function

	#define RK R0

	//평문이 64비트이므로 총 8개의 레지스터가 평문 연산에 필요
	#define PT0 R18 
	#define PT1 R19
	#define PT2 R20 
	#define PT3 R21
	#define PT4 R22 
	#define PT5 R23
	#define PT6 R24 
	#define PT7 R25

	#define TM0 R15
	#define TM1 R16
	#define TM2 R26
	#define TM3 R27

	#define CNT R17

	.macro KEYADD
		LD RK, Z+
		EOR PT0, RK
		LD RK, Z+
		EOR PT1, RK
		LD RK, Z+
		EOR PT2, RK
		LD RK, Z+
		EOR PT3, RK
		LD RK, Z+
		EOR PT4, RK
		LD RK, Z+
		EOR PT5, RK
		LD RK, Z+
		EOR PT6, RK
		LD RK, Z+
		EOR PT7, RK

	.endm

	.macro Pbox
		//X[1] <<7 | X[1] >>1
		BST PT1, 0
		ROR PT1
		BLD PT1, 7
		
		//X[2] <<4 |X[2] >>4
		CLC 
		ROL PT2
		ADC PT2, R1
		ROL PT2
		ADC PT2, R1
		ROL PT2
		ADC PT2, R1
		ROL PT2
		ADC PT2, R1

		//x[3] <<3
		CLC 
		ROL PT3
		ADC PT3, R1
		ROL PT3
		ADC PT3, R1
		ROL PT3
		ADC PT3, R1

		//x[4] <<6 | x[4] >>2
		BST PT4, 0
		ROR PT4 
		BLD PT4, 7
		BST PT4, 0
		ROR PT4
		BLD PT4, 7

		//x[5] <<5 |x[5] >>3
		BST PT5, 0
		ROR PT5
		BLD PT5, 7
		BST PT5, 0
		ROR PT5
		BLD PT5, 7
		BST PT5, 0
		ROR PT5
		BLD PT5, 7

		//x[6] <<1
		CLC
		ROL PT6
		ADC PT6, R1

		//x[7] <<2
		CLC
		ROL PT7
		ADC PT7,R1
		ROL PT7
		ADC PT7, R1

	.endm

	.macro Sbox
		//X[5] ^=(x[7]&x[6])
		MOV TM0, PT7
		AND PT7, PT6
		EOR PT5, PT7
		MOV PT7, TM0

		//X[4] ^=(x[3]&x[5])
		MOV TM0, PT3
		AND PT3, PT5
		EOR PT4, PT3
		MOV PT3, TM0

		//x[7]^= x[4]
		EOR PT7, PT4
		//X[6]^= x[3]
		EOR PT6, PT3

		//X[3] ^=(x[4] |x[5])
		MOV TM0, PT4
		OR PT4, PT5
		EOR PT3, PT4
		MOV PT4, TM0

		//x[5]^=x[7]
		EOR PT5, PT7

		//x[4]^=(x[5] &x[6])
		MOV TM0, PT5
		AND PT5, PT6
		EOR PT4, PT5
		MOV PT5, TM0

		//x[2] ^=x[1]&x[0]
		MOV TM0, PT1
		AND PT1, PT0
		EOR PT2, PT1
		MOV PT1, TM0

		//X[0] ^=(x[2] |x[1])
		MOV TM0, PT2
		OR PT2, PT1
		EOR PT0, PT2
		MOV PT2, TM0

		//X[1] ^=(x[2] |x[0])
		MOV TM0, PT2
		OR PT2, PT0
		EOR PT1, PT2
		MOV PT2, TM0

		//x[2]=~X[2]
		COM PT2

		//x[7]^=x[1]
		EOR PT7, PT1

		//x[3]^=x[2]
		EOR PT3,PT2

		//x[4]^=x[0]
		EOR PT4, PT0

		//T[0]= x[7] , T[1]=X[3], T[2] = X[4]
		MOV TM0, PT7
		MOV TM1, PT3
		MOV TM2, PT4

		//X[6] ^= (T[0]&X[5])
		MOV TM3, TM0
		AND TM0, PT5
		EOR PT6, TM0
		MOV TM0, TM3

		//T[0] ^=X[6]
		EOR TM0, PT6

		//X[6]^=(T[2] |T[1])
		MOV TM3, TM2
		OR TM2, TM1
		EOR PT6, TM2
		MOV TM2, TM3

		//T[1]^=X[5]
		EOR TM1, PT5

		//X[5]^=(X[6] |T[2])
		MOV TM3, PT6
		OR PT6, TM2
		EOR PT5, PT6
		MOV PT6, TM3
		
		//T[2] ^=(T[1]&T[0])
		MOV TM3, TM1
		AND TM1, TM0
		EOR TM2, TM1
		MOV TM1, TM3

		//X[2]^=T[0]
		EOR PT2, TM0

		//T[0]=X[1]^T[2]
		EOR PT1, TM2
		MOV TM0, PT1

		//X[1]=X[0]^T[1]
		EOR PT0, TM1
		MOV PT1, PT0

		MOV PT0, PT7 //X[0] =X[7]
		MOV PT7, TM0 //X[7] =T[0]
		MOV TM1, PT3 //T[1] =X[3]
		MOV PT3, PT6 //X[3] =X[6]
		MOV PT6, TM1 //X[6] =T[1]
		MOV TM2, PT4 //T[2] =X[4]
		MOV PT4, PT5 //X[4] =X[5]
		MOV PT5, TM2 //X[5] =T[2]
	.endm

	pipo128_encrypt:

	//callee saved 레지스터 스택에 push
	PUSH R15
	PUSH R16
	PUSH R17
	PUSH R28
	PUSH R29

	MOVW R28, R24  //ct Ypointer
	MOVW R26, R22 //pt Xpointer
	MOVW R30, R20 //rk Zpointer

	LD PT0, X+  //xpointer를 이용하여 암호화할 평문 로드
	LD PT1, X+
	LD PT2, X+
	LD PT3, X+
	LD PT4, X+
	LD PT5, X+
	LD PT6, X+
	LD PT7, X+

	PUSH R26
	PUSH R27

	LDI CNT, 0
	KEYADD

	LOOP:
		Sbox
		Pbox
		KEYADD
		INC CNT
		CPI CNT, 13
		BRGE LOOP_OUT  // 비교 값이 크거나 같으면 LOOP_OUT
		RJMP  LOOP  //같지 않으면 LOOP로 점프
	LOOP_OUT:

	POP R27
	POP R26

	ST Y+, PT0  //Ypointer로 암호문 저장
	ST Y+, PT1
	ST Y+, PT2
	ST Y+, PT3
	ST Y+, PT4
	ST Y+, PT5
	ST Y+, PT6
	ST Y+, PT7

	//스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R29
	POP R28
	POP R17
	POP R16
	POP R15

	RET