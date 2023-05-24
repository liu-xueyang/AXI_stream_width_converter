module axis_dwidth_downsizer #(
  parameter WIDTH      = 32, // output width
  parameter NUM_REG    =  2 // Scale factor
)(
    input  logic aclk,                    // input wire aclk
    input  logic aresetn,              // input wire aresetn
    input  logic s_axis_tvalid,  // input wire s_axis_tvalid
    output logic s_axis_tready,  // output wire s_axis_tready
    input  logic [WIDTH*NUM_REG-1:0] s_axis_tdata,    // input wire [63 : 0] s_axis_tdata
    input  logic s_axis_tlast,   

    output logic m_axis_tvalid,  // output wire m_axis_tvalid
    input  logic m_axis_tready,  // input wire m_axis_tready
    output logic [WIDTH-1:0] m_axis_tdata,    // output wire [31 : 0] m_axis_tdata
    output logic m_axis_tlast
);
  // Define the states as enum
    localparam READY = 0;
    localparam SHIFT = 1;
    localparam LAST = 2;

  logic [NUM_REG*WIDTH - 1:0] s_reg;
  logic [32:0] cnt;
  // Define state register and next state variables
  logic [1:0] state_reg;
//   logic [1:0] next_state;
    
  always @(posedge aclk) begin
    m_axis_tdata <= s_reg[WIDTH - 1:0];
    if (aresetn == 0) begin
      state_reg       <= READY;
      cnt             <=  0;
      s_axis_tready   <=  1;
      m_axis_tvalid   <=  0;
      s_reg           <= '0;
    end else begin
    //   m_axis_tdata    <= s_reg;
      // State transitions and outputs
      case (state_reg)
        READY:
          begin
            cnt <=  0;
            if (s_axis_tvalid == 1) begin
              s_reg       <= s_axis_tdata;
              state_reg   <= SHIFT;
              s_axis_tready <= 0;
              m_axis_tvalid <= 1;
            end
          end
        SHIFT:
          begin
            if (cnt < NUM_REG - 1  & m_axis_tready == 1) begin
                cnt   <= cnt + 1;
                s_reg <= s_reg >> WIDTH;
            end else if (cnt < NUM_REG - 1 & m_axis_tready == 0) 
                state_reg <= SHIFT;
            else begin
                state_reg <= LAST;
	            m_axis_tvalid <= 0;
	        end
          end
        LAST:
          begin
            if (m_axis_tready == 1) begin
                state_reg     <= READY;
                s_axis_tready <= 1;	
	        end
          end
        
        // Define transitions for other states
      endcase
    end
  end
endmodule