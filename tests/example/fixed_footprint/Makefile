RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = fixed_footprint


CFLAGS += -DSIMULATION
#CFLAGS += -O2
#ASM_SRCS +=
#LDFLAGS +=
#INCLUDES += -I.

C_SRCS := \
	fixed_footprint.c \


COMMON_DIR = ..
TOOLCHAIN_DIR = ../../..
include ../common.mk
