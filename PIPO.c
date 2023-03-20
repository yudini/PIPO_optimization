/*
 * PIPO.c
 *
 * Created: 2022-06-10 오후 3:07:06
 *  Author: 
 */ 

#include "PIPO.h"


void pipo128_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks)
{
	uint8_t temp_input[8];
	uint8_t temp_output[8]={0};
	memcpy(temp_input,iv,8);
	
	uint16_t* temp_count=(uint16_t*)temp_input;
	
	for(int i=0;i<src_len/8;i++){
		pipo128_encrypt(temp_output,temp_input,rks);
		
		for(int j=0;j<8;j++){
			dst[i*8+j] = temp_output[j]^src[i*8+j];
		}
		
		temp_count[0]++;
	}
	
}


void pipo256_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks)
{
	uint8_t temp_input[8];
	uint8_t temp_output[8]={0};
	memcpy(temp_input,iv,8);
	
	uint16_t* temp_count=(uint16_t*)temp_input;
	
	for(int i=0;i<src_len/8;i++){
		pipo256_encrypt(temp_output,temp_input,rks);
		
		for(int j=0;j<8;j++){
			dst[i*8+j] = temp_output[j]^src[i*8+j];
		}
		
		temp_count[0]++;
	}
	
}


