 /*                                                                      
 Copyright 2019 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

`include "defines.v"

// tinyriscv处理器核顶层模块
module tinyriscv(

    input wire clk,
    input wire rst,

    output wire[`MemAddrBus] rib_ex_addr_o,    // 读、写外设的地址
    input wire[`MemBus] rib_ex_data_i,         // 从外设读取的数据
    output wire[`MemBus] rib_ex_data_o,        // 写入外设的数据
    output wire rib_ex_req_o,                  // 访问外设请求
    output wire rib_ex_we_o,                   // 写外设标志

    output wire[`MemAddrBus] rib_pc_addr_o,    // 取指地址
    input wire[`MemBus] rib_pc_data_i,         // 取到的指令内容

    input wire[`RegAddrBus] jtag_reg_addr_i,   // jtag模块读、写寄存器的地址
    input wire[`RegBus] jtag_reg_data_i,       // jtag模块写寄存器数据
    input wire jtag_reg_we_i,                  // jtag模块写寄存器标志
    output wire[`RegBus] jtag_reg_data_o,      // jtag模块读取到的寄存器数据

    input wire rib_hold_flag_i,                // 总线暂停标志
    input wire jtag_halt_flag_i,               // jtag暂停标志
    input wire jtag_reset_flag_i,              // jtag复位PC标志

    input wire[`INT_BUS] int_i                 // 中断信号

    );

    // pc_reg模块输出信号
	(* mark_debug ="true" *) wire[`InstAddrBus] pc_pc_o;

    //sha1模块输出信号
    wire[`MemBus] sha1_result_o;
    wire sha1_busy_o;
    wire sha1_ready_o;
    wire[`MemAddrBus] sha1_addr_o;
    wire sha1_write_busy_o;
   

    //bp_unit模块输出信号
    wire bp_isbranch_o;
    wire[`InstAddrBus] bp_branch_addr_o;

    // if_id模块输出信号
	wire[`InstBus] if_inst_o;
    wire[`InstAddrBus] if_inst_addr_o;
    wire[`INT_BUS] if_int_flag_o;
    wire if_isbranch_o;

    // id模块输出信号
    wire[`RegAddrBus] id_reg1_raddr_o;
    wire[`RegAddrBus] id_reg2_raddr_o;
    wire[`InstBus] id_inst_o;
    wire[`InstAddrBus] id_inst_addr_o;
    wire[`RegBus] id_reg1_rdata_o;
    wire[`RegBus] id_reg2_rdata_o;
    wire id_reg_we_o;
    wire[`RegAddrBus] id_reg_waddr_o;
    wire[`MemAddrBus] id_csr_raddr_o;
    wire id_csr_we_o;
    wire[`RegBus] id_csr_rdata_o;
    wire[`MemAddrBus] id_csr_waddr_o;
    wire[`MemAddrBus] id_op1_o;
    wire[`MemAddrBus] id_op2_o;
    wire[`MemAddrBus] id_op1_jump_o;
    wire[`MemAddrBus] id_op2_jump_o;

    // id_ex模块输出信号
    wire[`InstBus] ie_inst_o;
    wire[`InstAddrBus] ie_inst_addr_o;
    wire ie_reg_we_o;
    wire[`RegAddrBus] ie_reg_waddr_o;
    wire[`RegBus] ie_reg1_rdata_o;
    wire[`RegBus] ie_reg2_rdata_o;
    wire ie_csr_we_o;
    wire[`MemAddrBus] ie_csr_waddr_o;
    wire[`RegBus] ie_csr_rdata_o;
    wire[`MemAddrBus] ie_op1_o;
    wire[`MemAddrBus] ie_op2_o;
    wire[`MemAddrBus] ie_op1_jump_o;
    wire[`MemAddrBus] ie_op2_jump_o;
    wire ie_isbranch_o;

    // ex模块输出信号
    wire[`MemBus] ex_mem_wdata_o;
    wire[`MemAddrBus] ex_mem_raddr_o;
    wire[`MemAddrBus] ex_mem_waddr_o;
    wire ex_mem_we_o;
    wire ex_mem_req_o;
    wire[`RegBus] ex_reg_wdata_o;
    wire ex_reg_we_o;
    wire[`RegAddrBus] ex_reg_waddr_o;
    wire ex_hold_flag_o;
    wire ex_jump_flag_o;
    wire[`InstAddrBus] ex_jump_addr_o;
    wire ex_div_start_o;
    wire[`RegBus] ex_div_dividend_o;
    wire[`RegBus] ex_div_divisor_o;
    wire[2:0] ex_div_op_o;
    wire[`RegAddrBus] ex_div_reg_waddr_o;
    wire[`RegBus] ex_csr_wdata_o;
    wire ex_csr_we_o;
    wire[`MemAddrBus] ex_csr_waddr_o;
    wire[1:0] ex_branch_taken_o;
    wire[`Sha1In] ex_sha1_para_o;         // 发给sha1的输入
    wire ex_sha1_start_o;
    wire[`MemAddrBus] ex_sha1_addr_o;

    // regs模块输出信号
    wire[`RegBus] regs_rdata1_o;
    wire[`RegBus] regs_rdata2_o;

    // csr_reg模块输出信号
    wire[`RegBus] csr_data_o;
    wire[`RegBus] csr_clint_data_o;
    wire csr_global_int_en_o;
    wire[`RegBus] csr_clint_csr_mtvec;
    wire[`RegBus] csr_clint_csr_mepc;
    wire[`RegBus] csr_clint_csr_mstatus;

    // ctrl模块输出信号
    wire[`Hold_Flag_Bus] ctrl_hold_flag_o;
    wire ctrl_jump_flag_o;
    wire[`InstAddrBus] ctrl_jump_addr_o;

    // div模块输出信号
    wire[`RegBus] div_result_o;
	wire div_ready_o;
    wire div_busy_o;
    wire[`RegAddrBus] div_reg_waddr_o;

    // clint模块输出信号
    wire clint_we_o;
    wire[`MemAddrBus] clint_waddr_o;
    wire[`MemAddrBus] clint_raddr_o;
    wire[`RegBus] clint_data_o;
    wire[`InstAddrBus] clint_int_addr_o;
    wire clint_int_assert_o;
    wire clint_hold_flag_o;

    //WriteEnable时会使用写地址而非读地址，但奇怪的是在写操作里还是把读地址也赋值了
    assign rib_ex_addr_o = (ex_mem_we_o == `WriteEnable)? ex_mem_waddr_o: ex_mem_raddr_o;
    assign rib_ex_data_o = ex_mem_wdata_o;
    assign rib_ex_req_o = ex_mem_req_o;
    assign rib_ex_we_o = ex_mem_we_o;

    assign rib_pc_addr_o = pc_pc_o;


    // pc_reg模块例化, 几个输入是受控制模块ctrl支配的
    pc_reg u_pc_reg(
        .clk(clk),
        .rst(rst),
        .jtag_reset_flag_i(jtag_reset_flag_i), // jtag复位PC标志
        .pc_o(pc_pc_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .jump_flag_i(ctrl_jump_flag_o),
        .jump_addr_i(ctrl_jump_addr_o),
        .isbranch_i(bp_isbranch_o),
        .branch_addr_i(bp_branch_addr_o)
    );

    bp_unit u_bp_unit(
        .clk(clk),
        .rst(rst),
        .inst_i(rib_pc_data_i), // jtag复位PC标志
        .inst_addr_i(pc_pc_o),
        .isbranch_o(bp_isbranch_o),
        .branch_addr_o(bp_branch_addr_o),
        .branch_taken_i(ex_branch_taken_o),
        .hold_flag_i(ctrl_hold_flag_o)
    );

    sha1_dfa u_sha1_dfa(
        .clk(clk),
        .rst(rst),
        .para_i(ex_sha1_para_o),
	    .start_i(ex_sha1_start_o),
        .sha1_addr_i(ex_sha1_addr_o),
        .result_o(sha1_result_o),
        .ready_o(sha1_ready_o),
        .busy_o(sha1_busy_o),
        .sha1_addr_o(sha1_addr_o),
        .write_busy_o(sha1_write_busy_o)
    );

    // sha1 u_sha1(
    //     .sha1_i(ex_sha1_o),
    //     .sha1_o(sha1_sha1_o)
    // );

    // sha1_assist u_sha1_assist(
    //     .clk(clk),
    //     .rst(rst),
    //     .start_i(ex_sha1_assist_o),
    //     .sha1_state_o(sha1_assist_state_o),
    //     .sha1_para_i(ex_sha1_para_o),
    //     .sha1_addr_i(ex_sha1_addr_o),
    //     .sha1_para_o(sha1_assist_para_o),
    //     .sha1_addr_o(sha1_assist_addr_o)
    // );

    // ctrl模块例化, 产生控制信号的模块，执行部分，clint，和rib会产生一些信号作为控制模块的输入
    ctrl u_ctrl(
        .rst(rst),
        .jump_flag_i(ex_jump_flag_o),
        .jump_addr_i(ex_jump_addr_o),
        .hold_flag_ex_i(ex_hold_flag_o),
        .hold_flag_rib_i(rib_hold_flag_i),
        .hold_flag_o(ctrl_hold_flag_o),
        .hold_flag_clint_i(clint_hold_flag_o),
        .jump_flag_o(ctrl_jump_flag_o),
        .jump_addr_o(ctrl_jump_addr_o),
        .jtag_halt_flag_i(jtag_halt_flag_i)
    );

    // regs模块例化, 两读一写寄存器堆
    regs u_regs(
        .clk(clk),
        .rst(rst),
        .we_i(ex_reg_we_o),
        .waddr_i(ex_reg_waddr_o),
        .wdata_i(ex_reg_wdata_o),
        .raddr1_i(id_reg1_raddr_o),
        .rdata1_o(regs_rdata1_o), //读寄存器1的数据
        .raddr2_i(id_reg2_raddr_o),
        .rdata2_o(regs_rdata2_o),
        .jtag_we_i(jtag_reg_we_i),
        .jtag_addr_i(jtag_reg_addr_i),
        .jtag_data_i(jtag_reg_data_i),
        .jtag_data_o(jtag_reg_data_o)
    );

    // csr_reg模块例化  csr 控制寄存器， 和regs在一起
    csr_reg u_csr_reg(
        .clk(clk),
        .rst(rst),
        .we_i(ex_csr_we_o),
        .raddr_i(id_csr_raddr_o),
        .waddr_i(ex_csr_waddr_o),
        .data_i(ex_csr_wdata_o),
        .data_o(csr_data_o),
        .global_int_en_o(csr_global_int_en_o),
        .clint_we_i(clint_we_o),
        .clint_raddr_i(clint_raddr_o),
        .clint_waddr_i(clint_waddr_o),
        .clint_data_i(clint_data_o),
        .clint_data_o(csr_clint_data_o),
        .clint_csr_mtvec(csr_clint_csr_mtvec),
        .clint_csr_mepc(csr_clint_csr_mepc),
        .clint_csr_mstatus(csr_clint_csr_mstatus)
    );

    // if_id模块例化
    if_id u_if_id(
        .clk(clk),
        .rst(rst),
        .inst_i(rib_pc_data_i), //取到的指令内容
        .inst_addr_i(pc_pc_o), // pc指针
        .int_flag_i(int_i),    //中断信号，int_i是来源于顶层中赋值的{7'h0, timer0_int}
        .int_flag_o(if_int_flag_o), // 输出的中断信号,产生的方式不太理解，涉及gen_pipe_dff
        .hold_flag_i(ctrl_hold_flag_o), // 流水线暂停标志
        .inst_o(if_inst_o),
        .inst_addr_o(if_inst_addr_o),
        .isbranch_i(bp_isbranch_o),
        .isbranch_o(if_isbranch_o)
    );

    // id模块例化
    id u_id(
        .rst(rst),
        .inst_i(if_inst_o), // if_id输出的指令内容
        .inst_addr_i(if_inst_addr_o), // if_id输出的指令地址
        .reg1_rdata_i(regs_rdata1_o), //寄存器堆的读数据1
        .reg2_rdata_i(regs_rdata2_o), //寄存器堆的读数据2
        .ex_jump_flag_i(ex_jump_flag_o), //执行模块产生的是否跳转标志
        .reg1_raddr_o(id_reg1_raddr_o), //由译码部件产生的, 读通用寄存器1地址
        .reg2_raddr_o(id_reg2_raddr_o), //由译码部件产生的, 读通用寄存器2地址
        .inst_o(id_inst_o), //id输出的指令内容, 和输入的inst_i一样
        .inst_addr_o(id_inst_addr_o), //id输出的指令地址, 和输入的inst_addr_i一样
        .reg1_rdata_o(id_reg1_rdata_o), //id输出的寄存器堆的读数据，和reg1_rdata_i一样
        .reg2_rdata_o(id_reg2_rdata_o), 
        .reg_we_o(id_reg_we_o),// id输出的写通用寄存器标志
        .reg_waddr_o(id_reg_waddr_o), //id输出的写通用寄存器堆的地址
        .op1_o(id_op1_o),//译码得到的操作数1?
        .op2_o(id_op2_o),
        .op1_jump_o(id_op1_jump_o), //??
        .op2_jump_o(id_op2_jump_o),
        .csr_rdata_i(csr_data_o), // CSR寄存器输入数据
        .csr_raddr_o(id_csr_raddr_o), // 读CSR寄存器地址
        .csr_we_o(id_csr_we_o), // 写CSR寄存器标志
        .csr_rdata_o(id_csr_rdata_o), // CSR寄存器数据
        .csr_waddr_o(id_csr_waddr_o) // 写CSR寄存器地址
    );

    // id_ex模块例化
    id_ex u_id_ex(
        .clk(clk),
        .rst(rst),
        .inst_i(id_inst_o),
        .inst_addr_i(id_inst_addr_o),
        .reg_we_i(id_reg_we_o),
        .reg_waddr_i(id_reg_waddr_o),
        .reg1_rdata_i(id_reg1_rdata_o),
        .reg2_rdata_i(id_reg2_rdata_o),
        .hold_flag_i(ctrl_hold_flag_o),
        .inst_o(ie_inst_o),
        .inst_addr_o(ie_inst_addr_o),
        .reg_we_o(ie_reg_we_o),
        .reg_waddr_o(ie_reg_waddr_o),
        .reg1_rdata_o(ie_reg1_rdata_o),
        .reg2_rdata_o(ie_reg2_rdata_o),
        .op1_i(id_op1_o),
        .op2_i(id_op2_o),
        .op1_jump_i(id_op1_jump_o),
        .op2_jump_i(id_op2_jump_o),
        .op1_o(ie_op1_o),
        .op2_o(ie_op2_o),
        .op1_jump_o(ie_op1_jump_o),
        .op2_jump_o(ie_op2_jump_o),
        .csr_we_i(id_csr_we_o),
        .csr_waddr_i(id_csr_waddr_o),
        .csr_rdata_i(id_csr_rdata_o),
        .csr_we_o(ie_csr_we_o),
        .csr_waddr_o(ie_csr_waddr_o),
        .csr_rdata_o(ie_csr_rdata_o),
        .isbranch_i(if_isbranch_o),
        .isbranch_o(ie_isbranch_o)
    );

    // ex模块例化
    ex u_ex(
        .rst(rst),
        .inst_i(ie_inst_o), //输入的指令内容
        .inst_addr_i(ie_inst_addr_o), //输入的指令地址
        .reg_we_i(ie_reg_we_o), // 是否写通用寄存器
        .reg_waddr_i(ie_reg_waddr_o), // 写通用寄存器地址
        .reg1_rdata_i(ie_reg1_rdata_o), // 通用寄存器1输入数据
        .reg2_rdata_i(ie_reg2_rdata_o), // 通用寄存器2输入数据
        .op1_i(ie_op1_o), //操作数1？
        .op2_i(ie_op2_o),
        .op1_jump_i(ie_op1_jump_o),
        .op2_jump_i(ie_op2_jump_o),
        .mem_rdata_i(rib_ex_data_i), // 从外设读取的数据, 是m0_data_o，即总线中主模块0的输出数据
        .mem_wdata_o(ex_mem_wdata_o), // 写内存数据
        .mem_raddr_o(ex_mem_raddr_o), // 读内存地址
        .mem_waddr_o(ex_mem_waddr_o), // 写内存地址
        .mem_we_o(ex_mem_we_o), // 是否写内存
        .mem_req_o(ex_mem_req_o), // 请求访问内存标志
        .reg_wdata_o(ex_reg_wdata_o), // 写寄存器数据
        .reg_we_o(ex_reg_we_o), // 是否要写通用寄存器
        .reg_waddr_o(ex_reg_waddr_o), // 写通用寄存器地址
        .hold_flag_o(ex_hold_flag_o), // 是否暂停标志, 传给ctrl模块
        .jump_flag_o(ex_jump_flag_o), // 是否跳转标志
        .jump_addr_o(ex_jump_addr_o), // 跳转目的地址
        .int_assert_i(clint_int_assert_o), // 中断发生标志, 从clint模块那里过来
        .int_addr_i(clint_int_addr_o), // 中断跳转地址
        .div_ready_i(div_ready_o), // 除法运算完成标志，从div模块那里过来
        .div_result_i(div_result_o), // 除法运算结果
        .div_busy_i(div_busy_o), // 除法运算忙标志
        .div_reg_waddr_i(div_reg_waddr_o), // 除法运算结束后要写的寄存器地址
        .div_start_o(ex_div_start_o), // 开始除法运算标志, 传给div模块
        .div_dividend_o(ex_div_dividend_o), // 被除数
        .div_divisor_o(ex_div_divisor_o), // 除数
        .div_op_o(ex_div_op_o), // 具体是哪一条除法指令
        .div_reg_waddr_o(ex_div_reg_waddr_o), // 除法运算结束后要写的寄存器地址
        .csr_we_i(ie_csr_we_o), // 是否写CSR寄存器
        .csr_waddr_i(ie_csr_waddr_o),
        .csr_rdata_i(ie_csr_rdata_o),
        .csr_wdata_o(ex_csr_wdata_o),
        .csr_we_o(ex_csr_we_o),
        .csr_waddr_o(ex_csr_waddr_o),
        .isbranch_i(ie_isbranch_o),
        .branch_taken_o(ex_branch_taken_o),
        .sha1_para_o(ex_sha1_para_o),
        .sha1_start_o(ex_sha1_start_o),
        .sha1_addr_o(ex_sha1_addr_o),
        .sha1_result_i(sha1_result_o),
        .sha1_ready_i(sha1_ready_o),
        .sha1_busy_i(sha1_busy_o),
        .sha1_addr_i(sha1_addr_o),
        .sha1_write_busy_i(sha1_write_busy_o)
    );

    // div模块例化
    div u_div(
        .clk(clk),
        .rst(rst),
        .dividend_i(ex_div_dividend_o), // 被除数, 从ex模块来
        .divisor_i(ex_div_divisor_o), // 除数
        .start_i(ex_div_start_o), // 开始信号，运算期间这个信号需要一直保持有效
        .op_i(ex_div_op_o), // 具体是哪一条指令
        .reg_waddr_i(ex_div_reg_waddr_o), // 运算结束后需要写的寄存器
        .result_o(div_result_o), // 除法结果，高32位是余数，低32位是商 ??
        .ready_o(div_ready_o), // 运算结束信号
        .busy_o(div_busy_o), // 正在运算信号 
        .reg_waddr_o(div_reg_waddr_o) // 运算结束后需要写的寄存器
    );

    // clint模块例化
    clint u_clint(
        .clk(clk),
        .rst(rst),
        .int_flag_i(if_int_flag_o), // 中断输入信号
        .inst_i(id_inst_o),  // 指令内容
        .inst_addr_i(id_inst_addr_o), // 指令地址 
        .jump_flag_i(ex_jump_flag_o), // 是否跳转标志
        .jump_addr_i(ex_jump_addr_o), // 跳转目的地址
        .hold_flag_i(ctrl_hold_flag_o),  // 流水线暂停标志
        .div_started_i(ex_div_start_o), // 开始除法运算标志,从ex模块来
        .data_i(csr_clint_data_o), // CSR寄存器输入数据
        .csr_mtvec(csr_clint_csr_mtvec), // mtvec寄存器??
        .csr_mepc(csr_clint_csr_mepc), // mepc寄存器
        .csr_mstatus(csr_clint_csr_mstatus), // mstatus寄存器
        .we_o(clint_we_o), // 写CSR寄存器标志
        .waddr_o(clint_waddr_o), // 写CSR寄存器地址
        .raddr_o(clint_raddr_o), // 读CSR寄存器地址
        .data_o(clint_data_o), // 写CSR寄存器数据
        .hold_flag_o(clint_hold_flag_o), // 流水线暂停标志
        .global_int_en_i(csr_global_int_en_o), // 全局中断使能标志
        .int_addr_o(clint_int_addr_o), // 中断入口地址
        .int_assert_o(clint_int_assert_o) // 中断标志
    );

endmodule
