`include "defines.v"


module sha1(

    // input wire clk,
    // input wire rst,
    input wire[`Sha1In] sha1_i,         // 从外设读取的数据
    output wire[`Sha1Out] sha1_o        // 读、写外设的地址
    );

    reg [`Sha1Pad] sha_pad;

    reg[31:0] W[80:0];
    reg[31:0] A[80:0];
    reg[31:0] B[80:0];
    reg[31:0] C[80:0];
    reg[31:0] D[80:0];
    reg[31:0] E[80:0];
    reg[31:0] TEMP[80:0];

    integer i;
    always @(*) begin
        sha_pad[63:0] <= 64'd32;
        sha_pad[511:480] <= sha1_i;
        sha_pad[478:64] <= 415'd0;
        sha_pad[479] <= 1;
        A[0] <= 32'h67452301;
        B[0] <= 32'hEFCDAB89;
        C[0] <= 32'h98BADCFE;
        D[0] <= 32'h10325476;
        E[0] <= 32'hC3D2E1F0;
        W[1] <= sha_pad[511:480];
        W[2] <= sha_pad[479:448];
        W[3] <= sha_pad[447:416];
        W[4] <= sha_pad[415:384];
        W[5] <= sha_pad[383:352];
        W[6] <= sha_pad[351:320];
        W[7] <= sha_pad[319:288];
        W[8] <= sha_pad[287:256];
        W[9] <= sha_pad[255:224];
        W[10] <= sha_pad[223:192];
        W[11] <= sha_pad[191:160];
        W[12] <= sha_pad[159:128];
        W[13] <= sha_pad[127:96];
        W[14] <= sha_pad[95:64];
        W[15] <= sha_pad[63:32];
        W[16] <= sha_pad[31:0];
        for (i = 1; i<=16; i=i+1) begin
            A[i] <= ((A[i-1]<<5)|(A[i-1]>>(32-5))) + ((B[i-1]&C[i-1])|((~B[i-1]) & D[i-1])) + (E[i-1]) +W[i] + 32'h5A827999;
            E[i] <= D[i-1];
            D[i] <= C[i-1];
            C[i] <= ((B[i-1]<<30)|(B[i-1]>>2));
            B[i] <= A[i-1];
        end

        for (i = 17; i<=20; i=i+1) begin
            W[i] <= ((W[i-3]^W[i-8]^W[i-14]^W[i-16])<<1)|((W[i-3]^W[i-8]^W[i-14]^W[i-16])>>31);
            A[i] <= ((A[i-1]<<5)|(A[i-1]>>(32-5))) + ((B[i-1]&C[i-1])|((~B[i-1]) & D[i-1])) + (E[i-1]) +W[i] + 32'h5A827999;
            E[i] <= D[i-1];
            D[i] <= C[i-1];
            C[i] <= ((B[i-1]<<30)|(B[i-1]>>2));
            B[i] <= A[i-1];
        end
        for (i = 21; i<=40; i=i+1) begin
            W[i] <= ((W[i-3]^W[i-8]^W[i-14]^W[i-16])<<1)|((W[i-3]^W[i-8]^W[i-14]^W[i-16])>>31);
            A[i] <= ((A[i-1]<<5)|(A[i-1]>>(32-5))) + (B[i-1]^C[i-1]^D[i-1]) + (E[i-1]) +W[i] + 32'h6ED9EBA1;
            E[i] <= D[i-1];
            D[i] <= C[i-1];
            C[i] <= ((B[i-1]<<30)|(B[i-1]>>2));
            B[i] <= A[i-1];
        end

        for (i = 41; i<=60; i=i+1) begin
            W[i] <= ((W[i-3]^W[i-8]^W[i-14]^W[i-16])<<1)|((W[i-3]^W[i-8]^W[i-14]^W[i-16])>>31);
            A[i] <= ((A[i-1]<<5)|(A[i-1]>>(32-5))) + ((B[i-1]&C[i-1])|(B[i-1]&D[i-1])|(C[i-1]&D[i-1]))+ (E[i-1]) +W[i] + 32'h8F1BBCDC;
            E[i] <= D[i-1];
            D[i] <= C[i-1];
            C[i] <= ((B[i-1]<<30)|(B[i-1]>>2));
            B[i] <= A[i-1];
        end

        for (i = 61; i<=80; i=i+1) begin
            W[i] <= ((W[i-3]^W[i-8]^W[i-14]^W[i-16])<<1)|((W[i-3]^W[i-8]^W[i-14]^W[i-16])>>31);
            A[i] <= ((A[i-1]<<5)|(A[i-1]>>(32-5))) + (B[i-1]^C[i-1]^D[i-1]) + (E[i-1]) +W[i] + 32'hCA62C1D6;
            E[i] <= D[i-1];
            D[i] <= C[i-1];
            C[i] <= ((B[i-1]<<30)|(B[i-1]>>2));
            B[i] <= A[i-1];
        end
    end


    assign sha1_o[159:128] = A[0] + A[80];
    assign sha1_o[127:96] = B[0] + B[80];
    assign sha1_o[95:64] = C[0] + C[80];
    assign sha1_o[63:32] = D[0] + D[80];
    assign sha1_o[31:0] = E[0] + E[80];

endmodule

