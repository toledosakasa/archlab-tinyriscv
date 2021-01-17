// Based on code by Schuyler Eldridge. Copyright (c) Boston University
// https://github.com/seldridge/rocket-rocc-examples/blob/master/src/main/c/rocc.h

#ifndef SRC_MAIN_C_ROCC_H
#define SRC_MAIN_C_ROCC_H

#ifndef __aligned
#define __aligned(x) __attribute__ ((aligned (x)))
#endif

// Standard macro that passes rd, rs1, and rs2 via registers
#define ROCC_INSTRUCTION_DSS(X, rd, rs1, rs2, funct) \
    ROCC_INSTRUCTION_R_R_R(X, rd, rs1, rs2, funct)

#define ROCC_INSTRUCTION_DS(X, rd, rs1, funct) \
    ROCC_INSTRUCTION_R_R_I(X, rd, rs1, 0, funct)

#define ROCC_INSTRUCTION_D(X, rd, funct) \
    ROCC_INSTRUCTION_R_I_I(X, rd, 0, 0, funct)

#define ROCC_INSTRUCTION_SS(X, rs1, rs2, funct) \
    ROCC_INSTRUCTION_I_R_R(X, 0, rs1, rs2, funct)

#define ROCC_INSTRUCTION_S(X, rs1, funct) \
    ROCC_INSTRUCTION_I_R_I(X, 0, rs1, 0, funct)

#define ROCC_INSTRUCTION(X, funct) \
    ROCC_INSTRUCTION_I_I_I(X, 0, 0, 0, funct)

// funct3 flags
#define ROCC_XD     0x4
#define ROCC_XS1    0x2
#define ROCC_XS2    0x1

// rd must be an lvalue if used as a register.
// These macros do not insert a compiler memory barrier.

#define ROCC_INSTRUCTION_R_R_R(X, rd, rs1, rs2, funct)                  \
    do {                                                                \
        __asm__ __volatile__ (                                          \
            ".insn r CUSTOM_" #X ", %3, %4, %0, %1, %2\n\t"             \
            : "=r" (rd)                                                 \
            : "r" (rs1), "r" (rs2),                                     \
              "i" (ROCC_XD | ROCC_XS1 | ROCC_XS2), "i" (funct));        \
    } while (0)

#define ROCC_INSTRUCTION_R_R_I(X, rd, rs1, rs2, funct)                  \
    do {                                                                \
        __asm__ __volatile__ (                                          \
            ".insn r CUSTOM_" #X ", %3, %4, %0, %1, x%2\n\t"            \
            : "=r" (rd)                                                 \
            : "r" (rs1), "K" (rs2),                                     \
              "i" (ROCC_XD | ROCC_XS1), "i" (funct));                   \
    } while (0)

#define ROCC_INSTRUCTION_R_I_I(X, rd, rs1, rs2, funct)                  \
    do {                                                                \
        __asm__ __volatile__ (                                          \
            ".insn r CUSTOM_" #X ", %3, %4, %0, x%1, x%2\n\t"           \
            : "=r" (rd)                                                 \
            : "K" (rs1), "K" (rs2),                                     \
              "i" (ROCC_XD), "i" (funct));                              \
    } while (0)

#define ROCC_INSTRUCTION_I_R_R(X, rd, rs1, rs2, funct)                  \
    do {                                                                \
        __asm__ __volatile__ (                                          \
            ".insn r CUSTOM_" #X ", %3, %4, x%0, %1, %2\n\t"            \
            :                                                           \
            : "K" (rd), "r" (rs1), "r" (rs2),                           \
              "i" (ROCC_XS1 | ROCC_XS2), "i" (funct));                  \
    } while (0)

#define ROCC_INSTRUCTION_I_R_I(X, rd, rs1, rs2, funct)                  \
    do {                                                                \
        __asm__ __volatile__ (                                          \
            ".insn r CUSTOM_" #X ", %3, %4, x%0, %1, x%2\n\t"           \
            :                                                           \
            : "K" (rd), "r" (rs1), "K" (rs2),                           \
              "i" (ROCC_XS1), "i" (funct));                             \
    } while (0)

#define ROCC_INSTRUCTION_I_I_I(X, rd, rs1, rs2, funct)                  \
    do {                                                                \
        __asm__ __volatile__ (                                          \
            ".insn r CUSTOM_" #X ", %3, %4, x%0, x%1, x%2\n\t"          \
            :                                                           \
            : "K" (rd), "K" (rs1), "K" (rs2),                           \
              "i" (0), "i" (funct));                                    \
    } while (0)

#define LOADB(dst_var, addr)                                            \
    do {                                                                \
        __asm__ __volatile__ (                                          \
           ".insn i  LOAD, 0, %0, " #addr "(zero)\n\t"                  \
           : "=r" (dst_var)                                             \
           :                                                            \
        );                                                              \
    } while (0)

#define LOADH(dst_var, addr)                                            \
    do {                                                                \
        __asm__ __volatile__ (                                          \
           ".insn i  LOAD, 1, %0, " #addr "(zero)\n\t"                  \
           : "=r" (dst_var)                                             \
           :                                                            \
        );                                                              \
    } while (0)

#define LOADW(dst_var, addr)                                            \
    do {                                                                \
        __asm__ __volatile__ (                                          \
           ".insn i  LOAD, 2, %0, " #addr "(zero)\n\t"                  \
           : "=r" (dst_var)                                             \
           :                                                            \
        );                                                              \
    } while (0)

#define LOADW1(dst_var, addr, base)                                     \
    do {                                                                \
        __asm__ __volatile__ (                                          \
           ".insn i  LOAD, 2, %0, " #addr "(%1)\n\t"                    \
           : "=r" (dst_var)                                             \
           : "r" (base)                                                 \
        );                                                              \
    } while (0)

#define STOREB(src_var, addr)   										\
    do {    															\
        __asm__ __volatile__ (  										\
			".insn s  STORE, 0, %0, " #addr "(zero)\n\t"			    \
			:: "r" (src_var) 											\
        );  															\
    } while (0) 	

#define STOREH(src_var, addr)   										\
    do {    															\
        __asm__ __volatile__ (  										\
			".insn s  STORE, 1, %0, " #addr "(zero)\n\t"			    \
			:: "r" (src_var) 											\
        );  															\
    } while (0) 	

#define STOREW(src_var, addr)   										\
    do {    															\
        __asm__ __volatile__ (  										\
			".insn s  STORE, 2, %0, " #addr "(zero)\n\t"			    \
			:: "r" (src_var) 											\
        );  															\
    } while (0) 														\

#endif // SRC_MAIN_C_ROCC_H

// name                func3        opcode
//
// @custom0            14..12=0 6..2=0x02 1..0=3
// @custom0.rs1        14..12=2 6..2=0x02 1..0=3
// @custom0.rs1.rs2    14..12=3 6..2=0x02 1..0=3
// @custom0.rd         14..12=4 6..2=0x02 1..0=3
// @custom0.rd.rs1     14..12=6 6..2=0x02 1..0=3
// @custom0.rd.rs1.rs2 14..12=7 6..2=0x02 1..0=3

// @custom1            14..12=0 6..2=0x0A 1..0=3
// @custom1.rs1        14..12=2 6..2=0x0A 1..0=3
// @custom1.rs1.rs2    14..12=3 6..2=0x0A 1..0=3
// @custom1.rd         14..12=4 6..2=0x0A 1..0=3
// @custom1.rd.rs1     14..12=6 6..2=0x0A 1..0=3
// @custom1.rd.rs1.rs2 14..12=7 6..2=0x0A 1..0=3

// @custom2            14..12=0 6..2=0x16 1..0=3
// @custom2.rs1        14..12=2 6..2=0x16 1..0=3
// @custom2.rs1.rs2    14..12=3 6..2=0x16 1..0=3
// @custom2.rd         14..12=4 6..2=0x16 1..0=3
// @custom2.rd.rs1     14..12=6 6..2=0x16 1..0=3
// @custom2.rd.rs1.rs2 14..12=7 6..2=0x16 1..0=3

// @custom3            14..12=0 6..2=0x1E 1..0=3
// @custom3.rs1        14..12=2 6..2=0x1E 1..0=3
// @custom3.rs1.rs2    14..12=3 6..2=0x1E 1..0=3
// @custom3.rd         14..12=4 6..2=0x1E 1..0=3
// @custom3.rd.rs1     14..12=6 6..2=0x1E 1..0=3
// @custom3.rd.rs1.rs2 14..12=7 6..2=0x1E 1..0=3
