//EE577b Project Phase 1 router - CW input module design
//Author: Sihao Chen
//Date: Oct.6.2021
//Add pe channel to original only supporting cw
//Add seperate request signals for even and odd vc 

module cw_input(cwsi, cwri, cwdi, 
	request_cw_odd, request_cw_even, request_pe_odd, request_pe_even, 
	grant_cw_odd, grant_cw_even, grant_pe_odd, grant_pe_even, 
	data_out_even_cw, data_out_odd_cw, data_out_even_pe, data_out_odd_pe, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 2'b01;
	parameter STATE1 = 2'b10;
	input cwsi, grant_cw_odd, grant_cw_even, grant_pe_odd, grant_pe_even, rst, clk, polarity;
	output reg cwri, request_cw_odd, request_cw_even, request_pe_odd, request_pe_even;
	input [DATA_WIDTH-1:0] cwdi;
	output reg [DATA_WIDTH-1:0] data_out_even_cw, data_out_odd_cw, data_out_even_pe, data_out_odd_pe;

	reg [1:0] state_even, state_odd, next_state_even, next_state_odd;
	reg enable_cw_even, enable_cw_odd, enable_pe_even, enable_pe_odd;

	reg cwri_odd, cwri_even;
	always@(*) begin
		//if (polarity) cwri = cwri_odd;
		//else cwri = cwri_even;
		cwri = cwri_even * cwri_odd;
	end

	//buffer data for cw channel
	always@(negedge clk) begin
		if (rst) begin
			data_out_odd_cw <= 0;
		end else if (enable_cw_odd) begin
				data_out_odd_cw <= cwdi;
		end else begin
			data_out_odd_cw <= data_out_odd_cw;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_out_even_cw <= 0;
		end else if (enable_cw_even) begin
				data_out_even_cw <= cwdi;
		end else begin
			data_out_even_cw <= data_out_even_cw;
		end
	end
	//buffer data for pe channel
	always@(negedge clk) begin
		if (rst) begin
			data_out_odd_pe <= 0;
		end else if (enable_pe_odd) begin
				data_out_odd_pe <= cwdi;
		end else begin
			data_out_odd_pe <= data_out_odd_pe;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_out_even_pe <= 0;
		end else if (enable_pe_even) begin
				data_out_even_pe <= cwdi;
		end else begin
			data_out_even_pe <= data_out_even_pe;
		end
	end

	//State transistion
	always@(posedge clk) begin
		if (rst) begin
			state_odd <= STATE0;
			state_even <= STATE0;
		end else begin 
			state_odd <= next_state_odd;
			state_even <= next_state_even;
		end
	end

	// For odd vc, only when cwsi and polarity both asserted, we use two state machines to indicated seperated vc channels
	always@(state_odd, cwsi, grant_cw_odd, grant_pe_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if (cwsi & polarity) next_state_odd = STATE1;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (grant_cw_odd | grant_pe_odd) next_state_odd = STATE0; // either one of grant signal is asserted
					else next_state_odd = STATE1;
				end
			default : next_state_odd = STATE0;
		endcase
	end

	always@(state_even, cwsi, grant_cw_even, grant_pe_even) begin
		case(state_even)
			STATE0 : 
				begin
					if (cwsi & !polarity) next_state_even = STATE1;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (grant_cw_even | grant_pe_even) next_state_even = STATE0; // either one of grant signal is asserted
					else next_state_even = STATE1;
				end
			default : next_state_even = STATE0;
		endcase
	end
	// As long as cwsi is asserted, generate enable signal for input buffer get packect from cwdi and generate request signal to let output buffer know data is ready 
	always@(state_odd, cwsi, grant_cw_odd, grant_pe_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if (cwsi & polarity) begin
						if (cwdi[55:48] == 8'b00000000) begin
							enable_pe_odd = 1;
							request_pe_odd = 1;
							enable_cw_odd = 0;
							request_cw_odd = 0;
						end else begin
							enable_pe_odd = 0;
							request_pe_odd = 0;
							enable_cw_odd = 1;
							request_cw_odd = 1;
						end
						cwri_odd = 0;
					end else begin
						enable_pe_odd = 0;
						request_pe_odd = 0;
						enable_cw_odd = 0;
						request_cw_odd = 0;
						cwri_odd = 1;
					end
				end
			STATE1 : 
				begin
					if (cwsi | (!grant_cw_odd & !grant_pe_odd)) begin
						if (cwdi[55:48] == 8'b00000000) begin
							//enable_pe_odd = 1;
							request_pe_odd = 1;
							//enable_cw_odd = 0;
							request_cw_odd = 0;
						end else begin
							//enable_pe_odd = 0;
							request_pe_odd = 0;
							//enable_cw_odd = 1;
							request_cw_odd = 1;
						end
						cwri_odd = 0;
					end else begin
						//enable_pe_odd = 0;
						request_pe_odd = 0;
						//enable_cw_odd = 0;
						request_cw_odd = 0;
						cwri_odd = 1;
					end
					/*if (cwsi) begin
						if (cwdi[55:48] == 8'b00000000) begin
							enable_pe_odd = 1;
							//request_pe_odd = 1;
							enable_cw_odd = 0;
							//request_cw_odd = 0;
						end else begin
							enable_pe_odd = 0;
							//request_pe_odd = 0;
							enable_cw_odd = 1;
							//request_cw_odd = 1;
						end
						cwri_odd = 0;
					end else begin
						enable_pe_odd = 0;
						//request_pe_odd = 0;
						enable_cw_odd = 0;
						//request_cw_odd = 0;
						cwri_odd = 1;
					end*/
					if (cwdi[55:48] == 8'b00000000) begin
						enable_pe_odd = grant_pe_odd ? 1:0;
						//request_pe_odd = 1;
						enable_cw_odd = 0;
						//request_cw_odd = 0;
					end else begin
						enable_pe_odd = 0;
						//request_pe_odd = 0;
						enable_cw_odd = grant_cw_odd ? 1:0;
						//request_cw_odd = 1;
					end
				end
			default : 
				begin
					enable_pe_odd = 0;
					request_pe_odd = 0;
					enable_cw_odd = 0;
					request_cw_odd = 0;
					cwri_odd = 1;
				end
		endcase
	end

	always@(state_even, cwsi, grant_pe_even, grant_cw_even) begin
		case(state_even)
			STATE0 : 
				begin
					if (cwsi & !polarity) begin
						if (cwdi[55:48] == 8'b00000000) begin
							enable_pe_even = 1;
							request_pe_even = 1;
							enable_cw_even = 0;
							request_cw_even = 0;
						end else begin
							enable_pe_even = 0;
							request_pe_even = 0;
							enable_cw_even = 1;
							request_cw_even = 1;
						end
						cwri_even = 0;
					end else begin
						enable_pe_even = 0;
						request_pe_even = 0;
						enable_cw_even = 0;
						request_cw_even = 0;
						cwri_even = 1;
					end
				end
			STATE1 : 
				begin
					if (cwsi | (!grant_cw_even & !grant_pe_even)) begin
						if (cwdi[55:48] == 8'b00000000) begin
							//enable_pe_even = 1;
							request_pe_even = 1;
							//enable_cw_even = 0;
							request_cw_even = 0;
						end else begin
							//enable_pe_even = 0;
							request_pe_even = 0;
							//enable_cw_even = 1;
							request_cw_even = 1;
						end
						cwri_even = 0;
					end else begin
						//enable_pe_even = 0;
						request_pe_even = 0;
						//enable_cw_even = 0;
						request_cw_even = 0;
						cwri_even = 1;
					end
					/*if (cwsi) begin
						if (cwdi[55:48] == 8'b00000000) begin
							enable_pe_even = 1;
							//request_pe_even = 1;
							enable_cw_even = 0;
							//request_cw_even = 0;
						end else begin
							enable_pe_even = 0;
							//request_pe_even = 0;
							enable_cw_even = 1;
							//request_cw_even = 1;
						end
						cwri_even = 0;
					end else begin
						enable_pe_even = 0;
						//request_pe_even = 0;
						enable_cw_even = 0;
						//request_cw_even = 0;
						cwri_even = 1;
					end*/
					if (cwdi[55:48] == 8'b00000000) begin
						enable_pe_even = grant_pe_even ? 1:0;
						//request_pe_even = 1;
						enable_cw_even = 0;
						//request_cw_even = 0;
					end else begin
						enable_pe_even = 0;
						//request_pe_even = 0;
						enable_cw_even = grant_cw_even ? 1:0;
						//request_cw_even = 1;
					end
				end
			default : 
				begin
					enable_pe_even = 0;
					request_pe_even = 0;
					enable_cw_even = 0;
					request_cw_even = 0;
					cwri_even = 1;
				end
		endcase
	end




endmodule // cw_input






