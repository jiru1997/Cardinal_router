//EE577b Project Phase 1 router - CW input and output module design
//Author: Sihao Chen
//Date: Oct.6.2021

module cw_input_output(cwsi, cwri, cwdi, cwso, cwro, cwdo, rst, clk);
	parameter DATA_WIDTH = 64;
	input cwsi, cwro, rst, clk;
	output reg cwri, cwso;
	input [DATA_WIDTH-1:0] cwdi;
	output reg [DATA_WIDTH-1:0] cwd0;

	parameter IN_IDLE = 4'b0001;
	parameter IN_1 = 4'b0010;
	parameter OUT_IDLE = 4'b0100;
	parameter OUT_1 = 4'b1000;

	reg [3:0] state_in, next_state_in, state_out, next_state_out;
	reg flag_in, flag_out;//Indicate whether in and out buffer are full or empty.
	reg [DATA_WIDTH-1:0] data_1, data_2;
	reg en1, en2, en3;

	//Input buffer
	always@(posedge clk) begin
		if (rst) data_1 <= 0; 
		else if (en1) data_1 <= cwdi;
		else  data_1 <= data_1;
	end
	//Output buffer
	always@(posedge clk) begin
		if (rst) data_2 <= 0; 
		else if (en2) data_2 <= data_1;
		else  data_2 <= data_2;
	end
	//To next router
	always@(posedge clk) begin
		if (rst) cwdo <= 0; 
		else if (en3) cwdo <= data_2;
		else  cwdo <= cwdo;
	end

	//FSM for input logic
	always@(posedge clk) begin
		if (rst) state_in <= IN_IDLE;
		else state_in <= next_state_in;
	end

	always@(*) begin
		case(state_in)
			IN_IDLE : 
				begin
					if (cwsi) next_state_in = IN_1;
					else next_state_in = IN_IDLE;
				end
			IN_1 : 
				begin
					if (flag_out) next_state_in = IN_IDLE;
					else next_state_in = IN_1;
				end
		endcase 
	end

	always@(*) begin
		case(state_in)
			IN_IDLE : 
				begin
					if (cwsi) begin
						flag_in = 1;
						en1 = 1;
					end
					else begin
						flag_in = 0;
						en1 = 0;
					end
					cwri = 0;
				end
			IN_1 : 
				begin
					if (flag_out) begin
						cwri = 1;
						flag_in = 0;
					end else begin
						flag_in = 1;
						cwri  = 0;
					end
					en1 = 0;
				end
		endcase 
	end

	//FSM for output logic
	always@(posedge clk) begin
		if (rst) state_out <= OUT_IDLE;
		else state_out <= next_state_out;
	end

	always@(*) begin
		case(state_out)
			OUT_IDLE : 
				begin
				 	if (flag_in) next_state_out = OUT_1;
				 	else next_state_out = OUT_IDLE;
				end 
			OUT_1 : 
				begin
					if (cwro) next_state_out = OUT_IDLE;
					else next_state_in = OUT_1;
				end
		endcase
	end

	always@(*) begin
		case(state_out)
			OUT_IDLE : 
				begin
					if (flag_in) begin
						flag_out = 1;
						en2 = 1;
					end else begin
						flag_out = 0;
						en2 = 0;
					end
					en3 = 0;
					cwso = 0;
				end 
			OUT_1 : 
				begin
					if (cwro) begin
						flag_out = 0;
						cwso = 1;
						en3 = 1;
					end else if begin
						flag_out = 1;
						cwso = 0;
						en3 = 0;
					end
					en2 = 0;
				end
		endcase
	end


endmodule // cw_input_output






