`timescale 1ns/1ps
module TPU_optimized #(
    parameter DEPTH     = 4,
    parameter BIT_WIDTH = 8,
    parameter ACC_WIDTH = 24
)
(
    input clk,
    input control, 
    input [(BIT_WIDTH*DEPTH)-1:0] data_arr,
    input [(BIT_WIDTH*DEPTH)-1:0] wt_arr,
    output reg [(ACC_WIDTH*DEPTH)-1:0] acc_out
);

    // Declare internal 2D arrays for data, weight, and accumulator signals
    wire [BIT_WIDTH-1:0] data_out [0:DEPTH-1][0:DEPTH-1];
    wire [BIT_WIDTH-1:0] wt_out   [0:DEPTH-1][0:DEPTH-1];
    wire [ACC_WIDTH-1:0] acc_temp [0:DEPTH-1][0:DEPTH-1];

    genvar j;
    // Generate top row (row 0)
    generate
        for (j = 0; j < DEPTH; j = j + 1) begin : top_row
            if(j == 0) begin : cell_0_0
                MAC_opt #(BIT_WIDTH, ACC_WIDTH) mac_inst (
                    .clk(clk),
                    .control(control),
                    .reset(1'b0),
                    .acc_in({ACC_WIDTH{1'b0}}),
                    .data_in(data_arr[0*BIT_WIDTH +: BIT_WIDTH]),
                    .wt_path_in(wt_arr[0*BIT_WIDTH +: BIT_WIDTH]),
                    .acc_out(acc_temp[0][0]),
                    .data_out(data_out[0][0]),
                    .wt_path_out(wt_out[0][0])
                );
            end else begin : cell_0_j
                MAC_opt #(BIT_WIDTH, ACC_WIDTH) mac_inst (
                    .clk(clk),
                    .control(control),
                    .reset(1'b0),
                    .acc_in({ACC_WIDTH{1'b0}}),
                    .data_in(data_out[0][j-1]),
                    .wt_path_in(wt_arr[j*BIT_WIDTH +: BIT_WIDTH]),
                    .acc_out(acc_temp[0][j]),
                    .data_out(data_out[0][j]),
                    .wt_path_out(wt_out[0][j])
                );
            end
        end
    endgenerate

    genvar i, k;
    // Generate rows 1 to DEPTH-1
    generate
        for (i = 1; i < DEPTH; i = i + 1) begin : other_rows
            for (k = 0; k < DEPTH; k = k + 1) begin : col_gen
                if(k == 0) begin : cell_i_0
                    // First column: new data from external array, weight from above cell
                    MAC_opt #(BIT_WIDTH, ACC_WIDTH) mac_inst (
                        .clk(clk),
                        .control(control),
                        .reset(1'b0),
                        .acc_in(acc_temp[i-1][0]),
                        .data_in(data_arr[i*BIT_WIDTH +: BIT_WIDTH]),
                        .wt_path_in(wt_out[i-1][0]),
                        .acc_out(acc_temp[i][0]),
                        .data_out(data_out[i][0]),
                        .wt_path_out(wt_out[i][0])
                    );
                end else begin : cell_i_k
                    // Other columns: data from left, weight from above
                    MAC_opt #(BIT_WIDTH, ACC_WIDTH) mac_inst (
                        .clk(clk),
                        .control(control),
                        .reset(1'b0),
                        .acc_in(acc_temp[i-1][k]),
                        .data_in(data_out[i][k-1]),
                        .wt_path_in(wt_out[i-1][k]),
                        .acc_out(acc_temp[i][k]),
                        .data_out(data_out[i][k]),
                        .wt_path_out(wt_out[i][k])
                    );
                end
            end
        end
    endgenerate

    // Aggregate final outputs from the bottom row (row DEPTH-1) into acc_out.
    genvar col;
    generate
        for(col = 0; col < DEPTH; col = col + 1) begin : output_gen
            always @(posedge clk) begin
                acc_out[col*ACC_WIDTH +: ACC_WIDTH] <= acc_temp[DEPTH-1][col];
            end
        end
    endgenerate

endmodule 