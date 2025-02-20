`timescale 1ns/1ps
module TPU_optimized_tb;
    reg clk;
    reg control;
    reg [(8*4)-1:0] data_arr;
    reg [(8*4)-1:0] wt_arr;
    wire [(24*4)-1:0] acc_out;  // 4 outputs, each ACC_WIDTH bits

    // Instantiate the optimized TPU module
    TPU_optimized #(4, 8, 24) uut (
        .clk(clk),
        .control(control),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .acc_out(acc_out)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        control = 0;
        data_arr = 0;
        wt_arr = 0;
        #10;
        
        control = 1;
        // Set data_arr: d0=1, d1=2, d2=3, d3=4 (concatenated with d3 at MSB)
        data_arr = {8'd4, 8'd3, 8'd2, 8'd1};
        // Set wt_arr: w0=10, w1=20, w2=30, w3=40 (w3 at MSB)
        wt_arr = {8'd40, 8'd30, 8'd20, 8'd10};
        
        // Wait enough clock cycles for the data to propagate through the array.
        #50;
        
        $display("Optimized TPU Final Output:");
        $display("Output Column 0: %0d (Expected: 100)", acc_out[23:0]);
        $display("Output Column 1: %0d (Expected: 200)", acc_out[47:24]);
        $display("Output Column 2: %0d (Expected: 300)", acc_out[71:48]);
        $display("Output Column 3: %0d (Expected: 400)", acc_out[95:72]);
        
        $stop;
    end
endmodule