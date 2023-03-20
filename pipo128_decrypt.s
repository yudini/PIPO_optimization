	.global pipo128_decrypt
	.type pipo128_decrypt, @function

	#define RK R0

	//암호문이 64비트이므로 총 8개의 레지스터가 평문 연산에 필요
	#define CT0 R18 
	#define CT1 R19
	#define CT2 R20 
	#define CT3 R21
	#define CT4 R22 
	#define CT5 R23
	#define CT6 R24 
	#define CT7 R25

	#define TM0 R15
	#define TM1 R16
	#define TM2 R26
	#define TM3 R27

	#define CNT R17

	.macro KEYADD
		LD RK, Z+
		EOR CT0, RK
		LD RK, Z+
		EOR CT1, RK
		LD RK, Z+
		EOR CT2, RK
		LD RK, Z+
		EOR CT3, RK
		LD RK, Z+
		EOR CT4, RK
		LD RK, Z+
		EOR CT5, RK
		LD RK, Z+
		EOR CT6, RK
		LD RK, Z+
		EOR CT7, RK

	.endm

	.macro INV_Pbox
		//X[1] = ((X[1] << 1)) | ((X[1] >> 7));
		CLC
		ROL CT1
		ADC CT1, R1

		//X[2] = ((X[2] << 4)) | ((X[2] >> 4));
		CLC 
		ROL CT2
		ADC CT2, R1
		ROL CT2
		ADC CT2, R1
		ROL CT2
		ADC CT2, R1
		ROL CT2
		ADC CT2, R1

		//X[3] = ((X[3] << 5)) | ((X[3] >> 3));
		CLC
		BST CT3, 0
		ROR CT3
		BLD CT3, 7
		BST CT3, 0
		ROR CT3
		BLD CT3, 7
		BST CT3, 0
		ROR CT3
		BLD CT3, 7

		//X[4] = ((X[4] << 2)) | ((X[4] >> 6));
		CLC
		ROL CT4
		ADC CT4, R1
		ROL CT4
		ADC CT4, R1

		//X[5] = ((X[5] << 3)) | ((X[5] >> 5));
		CLC
		ROL CT5
		ADC CT5, R1
		ROL CT5
		ADC CT5, R1
		ROL CT5
		ADC CT5, R1

		//X[6] = ((X[6] << 7)) | ((X[6] >> 1));
		CLC
		BST CT6, 0
		ROR CT6
		BLD CT6, 7

		//X[7] = ((X[7] << 6)) | ((X[7] >> 2));
		CLC
		BST CT7, 0
		ROR CT7
		BLD CT7, 7
		BST CT7, 0
		ROR CT7
		BLD CT7, 7

	.endm

	.macro INV_SBox

		//T[0] = X[7]; X[7] = X[0]; X[0] = X[1]; X[1] = T[0];
		MOV TM0, CT7
		MOV CT7, CT0
		MOV CT0, CT1
		MOV CT1, TM0

		//T[0] = X[7];	T[1] = X[6]; T[2] = X[5];
		MOV TM0, CT7
		MOV TM1, CT6
		MOV TM2, CT5

		//X[4] ^= (X[3] | T[2]);
		MOV TM3, CT3
		OR CT3, TM2
		EOR CT4, CT3
		MOV CT3, TM3

		//X[3] ^= (T[2] | T[1]);
		MOV TM3, TM2
		OR TM2, TM1
		EOR CT3, TM2
		MOV TM2, TM3

		//T[1] ^= X[4];
		EOR TM1, CT4

		//T[0] ^= X[3];
		EOR TM0, CT3

		//T[2] ^= (T[1] & T[0]);
		MOV TM3, TM1
		AND TM1, TM0
		EOR TM2, TM1
		MOV TM1, TM3

		//X[3] ^= (X[4] & X[7]);
		MOV TM3, CT4
		AND CT4, CT7
		EOR CT3, CT4
		MOV CT4, TM3

		//X[0] ^= T[1] 
		EOR CT0, TM1

		//X[1] ^= T[2] 
		EOR CT1, TM2

		//X[2] ^= T[0];
		EOR CT2, TM0

		//T[0] = X[3]; X[3] = X[6]; X[6] = T[0];
		MOV TM0, CT3
		MOV CT3, CT6
		MOV CT6, TM0

		//T[0] = X[5]; X[5] = X[4]; X[4] = T[0];
		MOV TM0, CT5
		MOV CT5, CT4
		MOV CT4, TM0

		//X[7] ^= X[1];	X[3] ^= X[2];	X[4] ^= X[0];
		EOR CT7, CT1
		EOR CT3, CT2
		EOR CT4, CT0

		//X[4] ^= (X[5] & X[6]);
		MOV TM3, CT5
		AND CT5, CT6
		EOR CT4, CT5
		MOV CT5, TM3

		//X[5] ^= X[7];
		EOR CT5, CT7

		//X[3] ^= (X[4] | X[5]);
		MOV TM3, CT4
		OR CT4, CT5
		EOR CT3, CT4
		MOV CT4, TM3

		//X[6] ^= X[3];
		EOR CT6, CT3

		//X[7] ^= X[4];
		EOR CT7, CT4

		//X[4] ^= (X[3] & X[5]);
		MOV TM3, CT3
		AND CT3, CT5
		EOR CT4, CT3
		MOV CT3, TM3

		//X[5] ^= (X[7] & X[6]);
		MOV TM3, CT7
		AND CT7, CT6
		EOR CT5, CT7
		MOV CT7, TM3
		
		//X[2] = ~X[2];
		COM CT2
		
		//X[1] ^= X[2] | X[0];
		MOV TM3, CT2
		OR CT2, CT0
		EOR CT1, CT2
		MOV CT2, TM3
		
		//X[0] ^= X[2] | X[1];
		MOV TM3, CT2
		OR CT2, CT1
		EOR CT0, CT2
		MOV CT2, TM3
		
		//X[2] ^= X[1] & X[0];
		MOV TM3, CT1
		AND CT1, CT0
		EOR CT2, CT1
		MOV CT1, TM3
	.endm

	pipo128_decrypt:

	PUSH R15
	PUSH R16
	PUSH R17
	PUSH R28
	PUSH R29

	MOVW R28, R24  //pt Ypointer
	MOVW R26, R22 //ct Xpointer
	MOVW R30, R20 //rk Zpointer

	LD CT0, X+ //xpointer를 이용하여 복호화할 암호문 로드
	LD CT1, X+
	LD CT2, X+
	LD CT3, X+
	LD CT4, X+
	LD CT5, X+
	LD CT6, X+
	LD CT7, X+

	PUSH R26
	PUSH R27
	SUBI R30, -104 
	LDI CNT, 13
	LOOP:
		KEYADD
		INV_PBox
		INV_SBox
		DEC CNT
		CPI CNT, 0
		SUBI R30, 16
		BREQ LOOP_OUT //같으면 LOOP_OUT
		RJMP LOOP //같지 않으면 LOOP로 점프

	LOOP_OUT:
	KEYADD

	POP R27
	POP R26

	ST Y+, CT0 //Ypointer로 복호문 저장
	ST Y+, CT1
	ST Y+, CT2
	ST Y+, CT3
	ST Y+, CT4
	ST Y+, CT5
	ST Y+, CT6
	ST Y+, CT7

	//스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R29
	POP R28
	POP R17
	POP R16
	POP R15

	RET
