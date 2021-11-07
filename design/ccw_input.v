//EE577b Project Phase 1 router - ccw input module design
//Author: Sihao Chen
//Date: Oct.6.2021
//Add pe channel to original only supporting ccw
//Add seperate request signals for even and odd vc 

module ccw_input(ccwsi, ccwri, ccwdi, 
	request_ccw_odd, request_ccw_even, request_pe_odd, request_pe_even, 
	grant_ccw_odd, grant_ccw_even, grant_pe_odd, grant_pe_even, 
	data_out_even_ccw, data_out_odd_ccw, data_out_even_pe, data_out_odd_pe, 
	rst, clk, polarity);
	parameter DATA_WIDTH = 64;
	parameter STATE0 = 2'b01;
	parameter STATE1 = 2'b10;
	input ccwsi, grant_ccw_odd, grant_ccw_even, grant_pe_odd, grant_pe_even, rst, clk, polarity;
	output reg ccwri, request_ccw_odd, request_ccw_even, request_pe_odd, request_pe_even;
	input [DATA_WIDTH-1:0] ccwdi;
	output reg [DATA_WIDTH-1:0] data_out_even_ccw, data_out_odd_ccw, data_out_even_pe, data_out_odd_pe;

	reg [1:0] state_even, state_odd, next_state_even, next_state_odd;
	reg enable_ccw_even, enable_ccw_odd, enable_pe_even, enable_pe_odd;

	reg ccwri_odd, ccwri_even;
	always@(*) begin
		//if (polarity) ccwri = ccwri_odd;
		//else ccwri = ccwri_even;
		ccwri = ccwri_even & ccwri_odd;
	end

	//buffer data for ccw channel
	always@(negedge clk) begin
		if (rst) begin
			data_out_odd_ccw <= 0;
		end else if (enable_ccw_odd) begin
				data_out_odd_ccw <= ccwdi;
		end else begin
			data_out_odd_ccw <= data_out_odd_ccw;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_out_even_ccw <= 0;
		end else if (enable_ccw_even) begin
				data_out_even_ccw <= ccwdi;
		end else begin
			data_out_even_ccw <= data_out_even_ccw;
		end
	end
	//buffer data for pe channel
	always@(negedge clk) begin
		if (rst) begin
			data_out_odd_pe <= 0;
		end else if (enable_pe_odd) begin
				data_out_odd_pe <= ccwdi;
		end else begin
			data_out_odd_pe <= data_out_odd_pe;
		end
	end
	always@(negedge clk) begin
		if (rst) begin
			data_out_even_pe <= 0;
		end else if (enable_pe_even) begin
				data_out_even_pe <= ccwdi;
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

	// For odd vc, only when ccwsi and polarity both asserted, we use two state machines to indicated seperated vc channels
	always@(state_odd, ccwsi, grant_ccw_odd, grant_pe_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if (ccwsi & polarity) next_state_odd = STATE1;
					else next_state_odd = STATE0;
				end
			STATE1 : 
				begin
					if (grant_ccw_odd | grant_pe_odd) next_state_odd = STATE0; // either one of grant signal is asserted
					else next_state_odd = STATE1;
				end
			default : next_state_odd = STATE0;
		endcase
	end

	always@(state_even, ccwsi, grant_pe_odd, grant_ccw_odd) begin
		case(state_even)
			STATE0 : 
				begin
					if (ccwsi & !polarity) next_state_even = STATE1;
					else next_state_even = STATE0;
				end
			STATE1 : 
				begin
					if (grant_ccw_even | grant_pe_even) next_state_even = STATE0; // either one of grant signal is asserted
					else next_state_even = STATE1;
				end
			default : next_state_even = STATE0;
		endcase
	end
	// As long as ccwsi is asserted, generate enable signal for input buffer get packect from ccwdi and generate request signal to let output buffer know data is ready 
	always@(state_odd, ccwsi, grant_pe_odd, grant_ccw_odd) begin
		case(state_odd)
			STATE0 : 
				begin
					if (ccwsi & polarity) begin
						if (ccwdi[55:48] == 8'b00000000) begin
							enable_pe_odd = 1;
							request_pe_odd = 1;
							enable_ccw_odd = 0;
							request_ccw_odd = 0;
						end else begin
							enable_pe_odd = 0;
							request_pe_odd = 0;
							enable_ccw_odd = 1;
							request_ccw_odd = 1;
						end
						ccwri_odd = 0;
					end else begin
						enable_pe_odd = 0;
						request_pe_odd = 0;
						enable_ccw_odd = 0;
						request_ccw_odd = 0;
						ccwri_odd = 1;
					end
				end
			STATE1 : 
				begin
					if (ccwsi | (!grant_pe_odd & !grant_ccw_odd)) begin
						if (ccwdi[55:48] == 8'b00000000) begin
							//enable_pe_odd = 1;
							request_pe_odd = 1;
							//enable_ccw_odd = 0;
							request_ccw_odd = 0;
						end else begin
							//enable_pe_odd = 0;
							request_pe_odd = 0;
							//enable_ccw_odd = 1;
							request_ccw_odd = 1;
						end
						ccwri_odd = 0;
					end else begin 
						//enable_pe_odd = 0;
						request_pe_odd = 0;
						//enable_ccw_odd = 0;
						request_ccw_odd = 0;
						ccwri_odd = 1;
					end
					/*if (ccwsi) begin
						if (ccwdi[55:48] == 8'b00000000) begin
							enable_pe_odd = 1;
							//request_pe_odd = 1;
							enable_ccw_odd = 0;
							//request_ccw_odd = 0;
						end else begin
							enable_pe_odd = 0;
							//request_pe_odd = 0;
							enable_ccw_odd = 1;
							//request_ccw_odd = 1;
						end
						ccwri_odd = 0;
					end else begin 
						enable_pe_odd = 0;
						//request_pe_odd = 0;
						enable_ccw_odd = 0;
						//request_ccw_odd = 0;
						ccwri_odd = 1;
					end*/
					if (ccwdi[55:48] == 8'b00000000) begin
						enable_pe_odd = grant_pe_odd ? 1:0;
						//request_pe_odd = 1;
						enable_ccw_odd = 0;
						//request_ccw_odd = 0;
					end else begin
						enable_pe_odd = 0;
						//request_pe_odd = 0;
						enable_ccw_odd = grant_ccw_odd ? 1:0;
						//request_ccw_odd = 1;
					end
				end
			default : 
				begin
					enable_pe_odd = 0;
					request_pe_odd = 0;
					enable_ccw_odd = 0;
					request_ccw_odd = 0;
					ccwri_odd = 1;
				end
		endcase
	end

	always@(state_even, ccwsi, grant_pe_even, grant_ccw_even) begin
		case(state_even)
			STATE0 : 
				begin
					if (ccwsi & !polarity) begin
						if (ccwdi[55:48] == 8'b00000000) begin
							enable_pe_even = 1;
							request_pe_even = 1;
							enable_ccw_even = 0;
							request_ccw_even = 0;
						end else begin
							enable_pe_even = 0;
							request_pe_even = 0;
							enable_ccw_even = 1;
							request_ccw_even = 1;
						end
						ccwri_even = 0;
					end else begin
						enable_pe_even = 0;
						request_pe_even = 0;
						enable_ccw_even = 0;
						request_ccw_even = 0;
						ccwri_even = 1;
					end
				end
			STATE1 : 
				begin
					if (ccwsi | (!grant_pe_even & !grant_ccw_even)) begin
						if (ccwdi[55:48] == 8'b00000000) begin
							//enable_pe_even = 1;
							request_pe_even = 1;
							//enable_ccw_even = 0;
							request_ccw_even = 0;
						end else begin
							//enable_pe_even = 0;
							request_pe_even = 0;
							//enable_ccw_even = 1;
							request_ccw_even = 1;
						end
						ccwri_even = 0;
					end else begin
						//enable_pe_even = 0;
						request_pe_even = 0;
						//enable_ccw_even = 0;
						request_ccw_even = 0;
						ccwri_even = 1;
					end
					/*if (ccwsi) begin
						if (ccwdi[55:48] == 8'b00000000) begin
							enable_pe_even = 1;
							//request_pe_even = 1;
							enable_ccw_even = 0;
							//request_ccw_even = 0;
						end else begin
							enable_pe_even = 0;
							//request_pe_even = 0;
							enable_ccw_even = 1;
							//request_ccw_even = 1;
						end
						ccwri_even = 0;
					end else begin
						enable_pe_even = 0;
						//request_pe_even = 0;
						enable_ccw_even = 0;
						//request_ccw_even = 0;
						ccwri_even = 1;
					end*/
					if (ccwdi[55:48] == 8'b00000000) begin
						enable_pe_even = grant_pe_even ? 1:0;
						//request_pe_even = 1;
						enable_ccw_even = 0;
						//request_ccw_even = 0;
					end else begin
						enable_pe_even = 0;
						//request_pe_even = 0;
						enable_ccw_even = grant_ccw_even ? 1:0;
						//request_ccw_even = 1;
					end
				end
			default : 
				begin
					enable_pe_even = 0;
					request_pe_even = 0;
					enable_ccw_even = 0;
					request_ccw_even = 0;
					ccwri_even = 1;
				end
		endcase
	end




endmodule // ccw_input






