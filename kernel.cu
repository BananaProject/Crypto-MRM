#include "crypt_mrm.cuh"


#define DEBUG 1
int main()
{
	int value = 0;
	crypt_mrm_init();

	crypt_mrm_set_ram_swap_int(&value, 123456);

	printf("%d\n", value);

	printf("%d\n", crypt_mrm_get_ram_swap_int(value));
	system("pause");
	return 0;
}