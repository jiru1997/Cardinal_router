//Test bench for router module
//Author: Sihao Chen
//Date: Oct.13.2021

`timescale 1 ns/1 ns
module tb_gold_router;
	parameter DATA_WIDTH = 64;
	reg clk, rst;
	reg cwsi, ccwsi, pesi, cwro, ccwro, pero;
	reg [DATA_WIDTH-1:0] cwdi, ccwdi, pedi;
	wire cwri, ccwri, peri, cwso, ccwso, peso, polarity;
	wire [DATA_WIDTH-1:0] cwdo, ccwdo, pedo;

	gold_router r1(cwsi, cwri, cwdi, cwso, cwro, cwdo, ccwsi, ccwri, ccwdi, ccwso, ccwro, ccwdo, pesi, peri, pedi, peso, pero, pedo, clk, polarity, rst);

	initial clk = 0;
	always #2 clk = ~clk;


	initial begin
		rst = 1;
		cwsi = 0;
		ccwsi = 0;
		pesi = 0;
		cwro = 0;
		ccwro = 0;
		pero = 0;
		cwdi = 0;
		ccwdi = 0;
		pedi = 0;
		#20;
		pero = 1;
		cwro = 1;
		ccwro = 1;
		rst = 0;
		cwsi = 1;
		cwdi = 64'h1102111100000000;
		pesi = 1;
		pedi = 64'h2203222200000000;
		#4;
		cwsi = 0;
		pesi = 0;
		#4;
		cwdi = 0;
		pedi = 0;
		#20;
		cwsi = 1;
		cwdi = 64'h1102333300000000;
		pesi = 1;
		pedi = 64'h2203444400000000;
		#4;
		cwsi = 0;
		pesi = 0;
		#4;
		cwdi = 0;
		pedi = 0;
		#20;
		/*
		cwsi = 1;
		cwdi = 64'h2200111100000000;
		#4;
		cwsi = 0;
		#4;
		cwdi = 0;
		#20;
		ccwsi = 1;
		ccwdi = 64'hAA03FFFF00000000;
		#4;
		ccwsi = 0;
		#4;
		ccwdi = 0;
		#20;
		ccwsi = 1;
		ccwdi = 64'hBB00FFFF00000000;
		#4;
		ccwsi = 0;
		#4;
		ccwdi = 0;
		#20;
		pesi = 1;
		pedi = 64'h0504FFFF00000000;
		#4;
		pesi = 0;
		#4;
		pedi = 0;
		#20;
		pesi = 1;
		pedi = 64'h4604FFFF00000000;
		#4;
		pesi = 0;
		#4;
		pedi = 0;
		#20;*/
		$finish;
	end

endmodule