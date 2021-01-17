`include "defines.v"


module sha1_assist(

    input wire clk,
    input wire rst,
    input wire start_i,   
    input wire[`RegBus] sha1_para_i,
    input wire[`MemAddrBus] sha1_addr_i,

    output reg[3:0] sha1_state_o,
    output reg[`RegBus] sha1_para_o,
    output reg[`MemAddrBus] sha1_addr_o      
    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            sha1_state_o <= 0;
        end else begin
            if(start_i == 1) begin
                sha1_state_o <= 4'b1000;
                sha1_para_o <= sha1_para_i;
                sha1_addr_o <= sha1_addr_i;
            end else begin
                if(sha1_state_o[3] == 1)begin
                    case (sha1_state_o[2:0])
                        4: begin
                            sha1_state_o <= 0;
                        end
                        default: begin
                            sha1_state_o <= sha1_state_o + 1;
                        end
                    endcase
                end else begin
                    sha1_state_o <= 0;
                end
            end
        end
    end

endmodule

