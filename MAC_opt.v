module MAC_opt #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 24
)
(
    input                      clk,
    input                      control,
    input                      reset,
    input  [ACC_WIDTH-1:0]     acc_in,
    input  [DATA_WIDTH-1:0]    data_in,
    input  [DATA_WIDTH-1:0]    wt_path_in,
    output reg [ACC_WIDTH-1:0] acc_out,
    output [DATA_WIDTH-1:0]    data_out,
    output [DATA_WIDTH-1:0]    wt_path_out
);
    // Propagate data and weight to next stage
    assign data_out    = data_in;
    assign wt_path_out = wt_path_in;
    
    // Multiply-accumulate: if reset, clear; if control, accumulate product; else hold value.
    always @(posedge clk) begin
        if (reset)
            acc_out <= {ACC_WIDTH{1'b0}};
        else if (control)
            acc_out <= acc_in + (data_in * wt_path_in);
        else
            acc_out <= acc_in;
    end
endmodule
