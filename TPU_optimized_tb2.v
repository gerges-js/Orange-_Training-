`timescale 1ns/1ps
module TPU_optimized_tb2;
    reg clk;
    reg control;
    reg [(8*4)-1:0] data_arr;
    reg [(8*4)-1:0] wt_arr;
    wire [(24*4)-1:0] acc_out;  // 4 outputs, each 24 bits

    // Instantiate the optimized TPU module
    TPU_optimized #(4, 8, 24) uut (
        .clk(clk),
        .control(control),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .acc_out(acc_out)
    );

    // Clock generation: 10ns period (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        control = 0;
        data_arr = 0;
        wt_arr = 0;
        #10;
        
        control = 1;
        // Set data_arr: d0=5, d1=10, d2=15, d3=20
        data_arr = {8'd20, 8'd15, 8'd10, 8'd5};
        // Set wt_arr: w0=2, w1=3, w2=4, w3=5
        wt_arr = {8'd5, 8'd4, 8'd3, 8'd2};
        
        // Wait for sufficient clock cycles for data propagation
        #50;
        
        $display("Test Case 2 (Optimized TPU) Output:");
        $display("Output Column 0: %0d (Expected: 100)", acc_out[23:0]);
        $display("Output Column 1: %0d (Expected: 150)", acc_out[47:24]);
        $display("Output Column 2: %0d (Expected: 200)", acc_out[71:48]);
        $display("Output Column 3: %0d (Expected: 250)", acc_out[95:72]);
        
        $stop;
    end
endmodule
