`timescale 1ns/1ns
module sha1_dfa_tb;
reg clk = 0;
reg rst = 0;
reg [31:0] in;
reg start;
reg [31:0]addr_i;
wire [159:0] out;
wire [31:0]addr_o;
wire ready;
wire busy;

sha1_dfa DUT(
	.clk(clk),
    .rst(rst),
	.para_i(in),
	.start_i(start),
    .sha1_addr_i(addr_i),
    .result_o(out),
    .ready_o(ready),
    .busy_o(busy),
    .sha1_addr_o(addr_o)
);
initial begin
    rst = 0; #30;
    rst = 1; in = 32'h31323334; start = 1; addr_i = 32'h10001000;#30; //"1234"
    in = 32'h0; addr_i = 32'h0;#3000;
	// in = 32'h41424344; #30; //"ABCD"
	// in = 32'h61626364; #30; //"abcd"
	// in = 32'h212f395e; #30; // "!/9^"
    // in = 32'h78797a61;      // "xyza"
	// in = 32'h3c3c3c3c; #30;
	// in = 32'h3d3d3d3d; #30;
	// in = 32'h3e3e3e3e; #30;
	// in = 32'h3f3f3f3f; #30;
	// in = 32'h40404040; #30;
	// in = 32'h41414141; #30;
    // in = 32'h42424242;
$stop;
#100;
$finish;
end
always begin #15 clk = ~clk; end
initial
	$monitor("At time %t, in = %x, out = %x", $time, in, out);
initial begin
	$dumpfile("sha1_dfa_test.vcd");
	$dumpvars;
end
endmodule
