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

// 将指令向译码模块传递
module bp_unit(

    input wire clk,
    input wire rst,
    input wire[`Hold_Flag_Bus] hold_flag_i, // 流水线暂停标志

    input wire[`InstBus] inst_i,            // 指令内容
    input wire[`InstAddrBus] inst_addr_i,   // 指令地址

    output reg isbranch_o,
    output reg [`InstAddrBus] branch_addr_o,

    input wire[1:0] branch_taken_i
    );
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    reg[1:0] bp_counter[3:0];
    reg[1:0] history;
    wire [1:0] history_0;
    wire [1:0] history_1;
    wire [1:0] history_2;
    wire hold_en1 = (hold_flag_i >= `Hold_If);
    wire hold_en2 = (hold_flag_i >= `Hold_Id);
    assign history_0 = history;
    gen_pipe_dff #(2) history_ff1(clk, rst, hold_en1, 2'b00, history_0, history_1);
    gen_pipe_dff #(2) history_ff2(clk, rst, hold_en2, 2'b00, history_1, history_2);
    wire [1:0]assist1;
    wire [1:0]assist2;
    assign assist1 = bp_counter[history];
    assign assist2 = bp_counter[history_2];

    integer i;
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            for (i = 0; i<=3; i=i+1) begin
                bp_counter[i] <= 2'b00;
                history <= 2'b00;
            end
        end else begin
            if(branch_taken_i == 2'b01)begin // not taken
                if(bp_counter[history_2] > 2'b00)begin
                    bp_counter[history_2] = bp_counter[history_2] - 2'b01;
                end
                history = (history <<1) + 2'b00;
            end
            else if (branch_taken_i == 2'b10) begin // taken
                if(bp_counter[history_2] < 2'b11)begin
                    bp_counter[history_2] = bp_counter[history_2] + 2'b01;
                end
                history = (history <<1) + 2'b01;
            end
        end
    end

    always @ (*) begin
        isbranch_o = `JumpDisable;
        branch_addr_o = `ZeroWord;
        //b型分支指令
        if (opcode == `INST_TYPE_B) begin
            case (funct3)
                `INST_BEQ, `INST_BNE, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU: begin
                    branch_addr_o = inst_addr_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                    if(bp_counter[history] > 2'b01)
                        isbranch_o = `JumpEnable;
                end
            endcase
        end
        //jal
        if (opcode == `INST_JAL) begin
            isbranch_o = `JumpEnable;
            branch_addr_o = inst_addr_i + {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        end
    end

endmodule
