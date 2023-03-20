
#include <stdint.h>

extern void pipo128_keygen(uint8_t* rks, const uint8_t* mk);
extern void pipo128_encrypt(uint8_t* dst, const uint8_t* src, const uint8_t* rks);
extern void pipo128_decrypt(uint8_t* dst, const uint8_t* src, const uint8_t* rks);
extern void pipo128_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks);

extern void pipo256_keygen(uint8_t* rks, const uint8_t* mk);
extern void pipo256_encrypt(uint8_t* dst, const uint8_t* src, const uint8_t* rks);
extern void pipo256_decrypt(uint8_t* dst, const uint8_t* src, const uint8_t* rks);
extern void pipo256_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks);

#include <avr/io.h>

uint8_t rks[] __attribute__ ((section(".RKSection")))  ={0};
	
void test_pipo128()
{
	//mk: 0x2E152297, 0x7E1D20AD, 0x779429d2, 0x6dc416dd
	//pt 0x1E270026, 0x098552f6
	//ct: 0xAD5D0327, 0x6B6B2981
	uint8_t mk[] ={ 0x97, 0x22, 0x15, 0x2E, 0xAD, 0x20, 0x1D, 0x7E, 0xD2, 0x28, 0x94, 0x77, 0xDD, 0x16, 0xC4, 0x6D, };
	
	uint8_t pt[9] ={ 0x26, 0x00, 0x27, 0x1E, 0xf6, 0x52, 0x85, 0x09,};
	
	uint8_t ct[8] ={0};//;{ 0x27, 0x03, 0x5D, 0xAD, 0x81, 0x29, 0x6B, 0x6B,};
		
	uint8_t IV[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	
	uint8_t encrypted[8] ={0,};   // 카운터모드 할 때 주의.
	
	uint16_t pt_len =sizeof(pt);  //8, 배열 수
	
	pipo128_keygen(rks,mk);// key schedule
	pipo128_encrypt(ct,pt,rks);// 1-block encrypt/decrypt
	pipo128_decrypt(pt,ct,rks);
	pipo128_ctr_encrypt(encrypted,pt,pt_len,IV,rks);// CTR encrypt/decrypt
	pipo128_ctr_encrypt(encrypted,encrypted,pt_len,IV,rks);
}

void test_pipo256()
{
	//mk: 0x2E152297, 0x7E1D20AD, 0x779429d2, 0x6dc416dd,
	//    0x26D15633, 0x54A71206, 0x76A96DB5, 0x009A3AA4
	//pt: 0x1E270026, 0x098552f6
	//ct: 0xB6523889, 0x816DAE6F
	uint8_t mk[] ={ 0x97, 0x22, 0x15, 0x2E, 0xAD, 0x20, 0x1D, 0x7E, 0xD2, 0x28, 0x94, 0x77, 0xDD, 0x16, 0xC4, 0x6D, 
		            0x33, 0x56, 0xD1, 0x26, 0x06, 0x12, 0xA7, 0x54, 0xB5, 0x6D, 0xA9, 0x76, 0xA4, 0x3A, 0x9A, 0x00, };
	uint8_t pt[] ={ 0x26, 0x00, 0x27, 0x1E, 0xf6, 0x52, 0x85, 0x09,};
	uint8_t ct[] ={ 0x89, 0x38, 0x52, 0xB6, 0x6F, 0xAE, 0X6D, 0x81,};
		
	uint8_t IV[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	
	uint8_t encrypted[8] ={0,};   // 카운터모드 할 때 주의.
	
	uint16_t pt_len =sizeof(pt);  //8, 배열 수
	
	pipo256_keygen(rks,mk);// key schedule
	pipo256_encrypt(ct,pt,rks);// 1-block encrypt/decrypt
	pipo256_decrypt(pt,ct,rks);
	pipo256_ctr_encrypt(encrypted,pt,pt_len,IV,rks);// CTR encrypt/decrypt
	pipo256_ctr_encrypt(encrypted,encrypted,pt_len,IV,rks);
}

int main(void)
{
	// variables...
	test_pipo128();
	test_pipo256();
	
}
