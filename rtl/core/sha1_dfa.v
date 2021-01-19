`include "defines.v"


module sha1_dfa(

    input wire clk,
    input wire rst,

    // from ex
    input wire[`Sha1In] para_i,             // sha1输入
    input wire start_i,                     // 开始信号，运算期间这个信号需要一直保持有效
    input wire[`MemAddrBus] sha1_addr_i,    // 结果要写入的地址   

    // to ex
    output reg[`MemBus] result_o,          // sha1结果
    output reg ready_o,                     // 运算结束信号
    output reg busy_o,                      // 正在运算信号
    output reg[`MemAddrBus] sha1_addr_o,
    output reg write_busy_o                 //正在需要写入的阶段  

    );

    // 状态定义
    localparam STATE_IDLE  = 4'b0001;
    localparam STATE_START = 4'b0010;
    localparam STATE_CALC  = 4'b0100;
    localparam STATE_END   = 4'b1000;

    reg[3:0] state;
    reg[`Sha1In] para;

    reg [`Sha1Pad] sha_pad;

    reg[511:0] W;
    wire[31:0] W_tmp;
    reg[31:0] A;
    reg[31:0] B;
    reg[31:0] C;
    reg[31:0] D;
    reg[31:0] E;
    reg[31:0] count;
    reg[31:0] write_count; //
    wire[31:0] fun_res;
    wire[31:0] k_res;
    
    assign W_tmp = (count <16)? sha_pad[511:480]:
        ((W[95:64]^W[255:224]^W[447:416]^W[511:480])<<1)|((W[95:64]^W[255:224]^W[447:416]^W[511:480])>>31);


    fun Fun
	(
        .B(B),
        .C(C),
        .D(D),
        .count(count),
        .res(fun_res)
	);

    k K
    (
        .count(count),
        .res(k_res)
    );

    // 状态机实现
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            state <= STATE_IDLE;
            ready_o <= 0;
            result_o <= 32'b0;
            sha1_addr_o <= `ZeroWord;
            busy_o <= 0;
            write_busy_o <=0;
            write_count <= 0;

        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start_i == 1) begin
                        para <= para_i;
                        sha1_addr_o <= sha1_addr_i;
                        state <= STATE_START;
                        busy_o <= `True;
                    end else begin
                        para <= `ZeroWord;
                        ready_o <= 0;
                        result_o <= 32'b0;
                        busy_o <= `False;
                        sha1_addr_o <= `ZeroWord;
                    end
                end

                STATE_START: begin
                    if (start_i == 1) begin
                        sha_pad[63:0] <= 64'd32;
                        sha_pad[511:480] <= para;
                        sha_pad[478:64] <= 415'd0;
                        sha_pad[479] <= 1;
                        A <= 32'h67452301;
                        B <= 32'hEFCDAB89;
                        C <= 32'h98BADCFE;
                        D <= 32'h10325476;
                        E <= 32'hC3D2E1F0;
                        count <=0;
                        busy_o <= 1;
                        state <= STATE_CALC;
                    end else begin
                        state <= STATE_IDLE;
                        ready_o <= 0;
                        result_o <= 32'b0;
                        busy_o <= `False;
                    end
                end

                STATE_CALC: begin
                    write_count <= 0;
                    if (start_i == `DivStart) begin
                        count <= count+1;
                        W <= {W[479:0], W_tmp};//左移W
                        sha_pad <= {sha_pad[479:0], 32'b0}; //左移sha_pad以满足count<16时W的补充
                        if(count == 32'd79) begin
                            state <= STATE_END; 
                        end else begin
                            state <= STATE_CALC; 
                        end
                        E <= D;
                        D <= C;
                        C <= ((B<<30)|(B>>2));
                        B <= A;
                        A <= ((A<<5)|(A>>(32-5))) + E + fun_res + W_tmp + k_res;
                    end else begin
                        state <= STATE_IDLE;
                        ready_o <= 0;
                        result_o <= 32'b0;
                        busy_o <= `False;
                    end
                end

                STATE_END: begin
                    if (start_i == `DivStart) begin
                        ready_o <= 1;
                        busy_o <= 0;
                        if(write_count == 5) begin //要到5时才结束写
                            state <= STATE_IDLE;
                            write_busy_o <= 0;
                        end else begin
                            state <= STATE_END;
                            write_busy_o <= 1;
                        end
                        write_count <= write_count + 1;
                        case (write_count)
                            0:begin
                                result_o <= A+32'h67452301;
                                sha1_addr_o <= sha1_addr_o;
                            end 
                            1:begin
                                result_o <= B+32'hEFCDAB89;
                                sha1_addr_o <= sha1_addr_o + 4;
                            end
                            2:begin
                                result_o <= C+32'h98BADCFE;
                                sha1_addr_o <= sha1_addr_o + 4;
                            end
                            3:begin
                                result_o <= D+32'h10325476;
                                sha1_addr_o <= sha1_addr_o + 4;
                            end
                            default: begin
                                result_o <= E+32'hC3D2E1F0;
                                sha1_addr_o <= sha1_addr_o + 4;
                            end
                        endcase
                    end else begin
                        state <= STATE_IDLE;
                        ready_o <= 0;
                        result_o <= 32'b0;
                        busy_o <= `False;
                    end
                end
            endcase
        end
    end
endmodule


module fun(
    input wire[31:0] B,
    input wire[31:0] C,
    input wire[31:0] D,
    input wire[31:0] count,
    output reg[31:0] res
    );

    always @ (*) begin
        if (count < 32'd20) begin
            res <= ((B&C)|((~B) & D));
        end else begin
            if (count < 32'd60 && count >= 32'd40) begin
                res <= ((B&C)|(B&D)|(C&D));
            end else begin
                res <= (B^C^D);
            end
        end
    end
endmodule

module k(
    input wire[31:0] count,
    output reg[31:0] res
    );

    always @ (*) begin
        if (count < 32'd20) begin
            res <= 32'h5A827999;
        end else begin
            if (count < 32'd40) begin
                res <= 32'h6ED9EBA1;
            end else begin
                if(count <32'd60) begin
                    res <= 32'h8F1BBCDC;
                end else begin
                    res <= 32'hCA62C1D6;
                end
            end
        end
    end
endmodule

