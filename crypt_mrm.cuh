#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <cuda_profiler_api.h>


/*-------------------------------------------- crypt_mrm_init -----
|  Function crypt_mrm_init
|
|  Purpose: Initialize a random session key that will be used
|			in mrm functions.
|
|  Parameters:
|
|  Returns:  
|
*-------------------------------------------------------------------*/
void crypt_mrm_init();

/*-------------------------------------------- crypt_mrm_generate_session -----
|  Function crypt_mrm_generate_session
|
|  Purpose: Initialize a random session key that will be used in mrm +
|			functions. This is the GPU function.
|
|  Parameters:
|			  seed(long) -- Seed using for generating random session key.
|
|  Returns:
|
*-------------------------------------------------------------------*/
__global__ void crypt_mrm_generate_session(long);

/*-------------------------------------------- crypt_mrm_magic_bytes -----
|  Function crypt_mrm_magic_bytes
|
|  Purpose: Parse an array of bytes and generate a cipher byte array (GPU)
|
|  Parameters:
|			  dst -- Variable where the output will be stored.
|			  src -- Byte array that have to be cipher.
|			  size -- size of dst and src.
|
|  Returns:
|
*-------------------------------------------------------------------*/
__global__ void crypt_mrm_magic_bytes(char * dst, const char * src, int size);

/*--------------------------------------------  crypt_mrm_ram_swap -----
|  Function  crypt_mrm_ram_swap
|
|  Purpose: Parse an array of bytes and generate a cipher byte array
|  Parameters:
|			  dst -- Variable where the output will be stored.
|			  src -- Byte array that have to be cipher.
|			  size -- size of dst and src.
|
|  Returns:
|
*-------------------------------------------------------------------*/
void crypt_mrm_ram_swap(const char * , char * , size_t );
void crypt_mrm_set_ram_swap_int(int *, int);
int crypt_mrm_get_ram_swap_int(int);
void crypt_mrm_set_ram_swap_long(long *, long );
long crypt_mrm_get_ram_swap_long(long);
