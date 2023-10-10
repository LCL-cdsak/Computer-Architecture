#include <stdint.h>
#include <stdio.h>
uint16_t count_leading_zeros(uint64_t x){

    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);
    x |= (x >> 32);
    x -= ((x >> 1) & 0x5555555555555555 );
    x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333);
    x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    x += (x >> 32);

    return (64 - (x & 0x7f));
}
int main()
{
    uint64_t test_data[3] = {0b0000000000000000000000000000000000000000001000000000000000000000
                            ,0b0000000000000000000001000000000000000000000000000000000001010000
                            ,0b0000000000000000000000000000000000000000000000000000000001010000};
    for(int m=0;m<3;m++)
    {
        uint16_t leadingZeros = count_leading_zeros(test_data[m]);
        uint64_t k;
        int position = -1;
        for(uint16_t i =leadingZeros;i<64;i++)
            {
                k = 1 << (63-i);
                k &= test_data[m];
                if(k == 0)
                {
                    position = 63-i;
                    break;
                }
            }
        printf("test_data_%d = %d\n",m,position);
    }
}