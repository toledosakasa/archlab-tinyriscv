#include <stdint.h>
#include "asm_macro.h"
#include "../include/utils.h"

int main()
{
    int a = 0x31323334;
    int rs1 = 0x10000100;
    int rs2 = a;
    int sha_res[5] = {1,2,3,4,5};
    asm volatile("fence" ::: "memory");
    ROCC_INSTRUCTION_I_R_R(0,0,rs1,rs2,0);
    // LOADW(sha_res[0],rs1);
    // LOADW(sha_res[1],rs1+0x4);
    // LOADW(sha_res[2],rs1+0x8);
    // LOADW(sha_res[3],rs1+0x12);
    // LOADW(sha_res[4],rs1+0x16);
    LOADW1(sha_res[0],0,rs1);
    LOADW1(sha_res[1],4,rs1);
    LOADW1(sha_res[2],8,rs1);
    LOADW1(sha_res[3],12,rs1);
    LOADW1(sha_res[4],16,rs1);
    asm volatile("fence" ::: "memory");

    if (sha_res[0] == 0x7110eda4 && sha_res[1] == 0xd09e062a && sha_res[2] == 0xa5e4a390 && sha_res[3] == 0xb0a572ac && sha_res[4] == 0x0d2c0220)
    // if (sha_res[0] == 0x7110eda4)
        set_test_pass();
    else
        set_test_fail();
        
    return 0;
}
