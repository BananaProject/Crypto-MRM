#include "crypt_mrm.cuh"

/*
* Seed that generate the current crypto scheme.
*/
__device__ long crypt_mrm_rnd_seed;

/*
* Function that generate a random 0<int<256 value.
*/
__device__ int crypt_mrm_generate_random_byte() {
	crypt_mrm_rnd_seed = (crypt_mrm_rnd_seed * 0x5DEECE66DL + 0xBL) & ((1L << 48) - 1);
	return (unsigned char)(crypt_mrm_rnd_seed >> 16)  % 256;
}

/*
* Current session key.
*/
__device__ unsigned char * crypt_mrm_session_key;
__device__ unsigned char * crypt_mrm_session_table;

/*
* Starts a new crypt mrm session.
*/
void crypt_mrm_init() {
	cudaError_t cudaStatus;

	cudaStatus = cudaSetDevice(0);

	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
	}
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
	}

	crypt_mrm_generate_session << <1, 1 >> >(time(NULL));

	cudaDeviceSynchronize();
}

/*
* Generate a new key based in a given seed.
*/
__global__ void crypt_mrm_generate_session(long seed) {
	int i, temp, j;

	crypt_mrm_rnd_seed = seed;
	crypt_mrm_session_key = (unsigned char*)malloc(sizeof(char) * 256);
	crypt_mrm_session_table = (unsigned char*)malloc(sizeof(char) * 256);

	for (i = 0; i < 256; i++)
		crypt_mrm_session_key[i] = crypt_mrm_generate_random_byte();
	
	for (i = 0; i < 256; i++)
		crypt_mrm_session_table[i] = i;

	for (i = j= 0; i < 256; i++) {
		j = (j + crypt_mrm_session_key[i] + crypt_mrm_session_table[i]) & 255;

		temp = crypt_mrm_session_table[i];
		crypt_mrm_session_table[i] = crypt_mrm_session_table[j];
		crypt_mrm_session_table[j] = temp;
	}
}

/*
* The magic starts here.
*/
__global__ void crypt_mrm_magic_bytes(char * dst, const char * src, int size) {
	int i, j, k, temp;
	char *table;

	table = (char*)malloc(sizeof(char) * 256);

	for (i = 0; i < 256; i++)
		table[i] = crypt_mrm_session_table[i];

	for (i = j = k = 0; k < size; k++) {
		i = ++i & 255;
		j = (j + table[i]) & 255;

		temp = table[i];
		table[i] = table[j];
		table[j] = temp;

		dst[k] = src[k] ^ (table[(table[i] + table[j]) & 255]);
	}
	
	free(table);

}

void crypt_mrm_ram_swap(const char * value, char * dst_cpu, size_t size) {
	char * src, *dst;

	cudaMalloc((void**)&src, size);
	cudaMalloc((void**)&dst, size);

	cudaMemcpy(src, value, size, cudaMemcpyHostToDevice);

	crypt_mrm_magic_bytes << <1, 1 >> >(dst, src, size);
	cudaDeviceSynchronize();

	cudaMemcpy(dst_cpu, dst, size, cudaMemcpyDeviceToHost);

	cudaFree(src);
	cudaFree(dst);

}
void crypt_mrm_set_ram_swap_int(int * ptr, int value) {
	*ptr = crypt_mrm_get_ram_swap_int(value);
}

int crypt_mrm_get_ram_swap_int(int value) {
	char * dst_cpu;
	dst_cpu = (char*)malloc(sizeof(int));

	crypt_mrm_ram_swap((char*)(&value), dst_cpu, sizeof(int));
	return *(int *)dst_cpu;
}

void crypt_mrm_set_ram_swap_long(long * ptr, long value) {
	*ptr = crypt_mrm_get_ram_swap_long(value);
}

long crypt_mrm_get_ram_swap_long(long value) {
	char * dst_cpu;
	dst_cpu = (char*)malloc(sizeof(long));

	crypt_mrm_ram_swap((char*)(&value), dst_cpu, sizeof(long));
	return *(long *)dst_cpu;
}
