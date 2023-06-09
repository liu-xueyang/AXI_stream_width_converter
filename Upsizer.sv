module axis_dwidth_upsizer #(
  parameter WIDTH      = 32, // input width
  parameter NUM_REG    =  2 // Scale factor
)(
    input  logic aclk,                    // input wire aclk
    input  logic aresetn,              // input wire aresetn
    input  logic s_axis_tvalid,  // input wire s_axis_tvalid
    output logic s_axis_tready,  // output wire s_axis_tready
    input  logic [WIDTH-1:0] s_axis_tdata,    // input wire [31 : 0] s_axis_tdata
    input  logic s_axis_tlast,   

    output logic m_axis_tvalid,  // output wire m_axis_tvalid
    input  logic m_axis_tready,  // input wire m_axis_tready
    output logic [WIDTH*NUM_REG-1:0] m_axis_tdata,    // output wire [63 : 0] m_axis_tdata
    output logic m_axis_tlast
);
  // Define the states as enum
    localparam READY = 0;
    localparam LOAD = 1;
    localparam WRTARRAY = 2;

  logic [NUM_REG*WIDTH - 1:0] s_reg;
  logic [32:0] cnt;
  // Define state register and next state variables
  logic [1:0] state_reg;
  logic m_axis_tlast_local;
//   logic [1:0] next_state;
  always @(posedge aclk) begin
    if (aresetn == 0) begin
      state_reg       <= READY;
      cnt             <=  0;
      s_axis_tready   <=  1;
      m_axis_tvalid   <=  0;
      m_axis_tlast    <=  0;
      m_axis_tlast_local <= 0;
      s_reg           <= '0;
    end else begin
      m_axis_tdata    <= s_reg;
      if (s_axis_tlast == 1) m_axis_tlast_local <= 1;
      // State transitions and outputs
      case (state_reg)
        READY:
          begin
            cnt <=  0;
            if (s_axis_tvalid == 1) begin
              s_reg[WIDTH-1:0] <= s_axis_tdata;
              state_reg   <= LOAD;
              cnt           <= cnt + 1;
            end
          end
        LOAD:
          begin
            if (cnt < NUM_REG & m_axis_tlast_local == 1) begin
              s_reg <= (s_reg << WIDTH);
              cnt            <= cnt + 1;
              state_reg      <= LOAD;
            end else if (cnt < NUM_REG  & s_axis_tvalid == 1) begin
              s_reg <= (s_reg << WIDTH) | s_axis_tdata;
              cnt            <= cnt + 1;
              state_reg      <= LOAD;
            end else if (cnt < NUM_REG & s_axis_tvalid == 0) 
              state_reg <= LOAD;
            else begin
              state_reg       <= WRTARRAY;
              s_axis_tready   <= 0;
              m_axis_tvalid   <= 1;
              m_axis_tlast    <= m_axis_tlast_local;
              cnt <= 0;
            end
          end
        WRTARRAY:
          begin
            if (m_axis_tready == 1) begin
              state_reg       <= READY;
              m_axis_tvalid <= 0;
              s_axis_tready   <= 1;
              m_axis_tlast    <= 0;
              m_axis_tlast_local <= 0;
            end
          end
      endcase
    end
  end
endmodule