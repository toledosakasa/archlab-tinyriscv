`timescale 1ns/1ns
module sha1_tb;
reg clk = 0;
reg [31:0] in;
wire [159:0] out;
sha1 DUT(
	.clk(clk),
	.sha1_i(in),
	.sha1_o(out)
);
initial begin
    in = 32'h31323334; #30; //"1234"
	in = 32'h41424344; #30; //"ABCD"
	in = 32'h61626364; #30; //"abcd"
	in = 32'h212f395e; #30; // "!/9^"
    in = 32'h78797a61;      // "xyza"
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
	$dumpfile("sha1_test.vcd");
	$dumpvars;
end
endmodule
