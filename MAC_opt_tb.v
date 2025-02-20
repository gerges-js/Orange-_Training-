`timescale 1ns/1ps
module MAC_opt_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 24;
    
    // Signal declarations
    reg clk;
    reg control;
    reg reset;
    reg [ACC_WIDTH-1:0] acc_in;
    reg [DATA_WIDTH-1:0] data_in;
    reg [DATA_WIDTH-1:0] wt_path_in;
    wire [ACC_WIDTH-1:0] acc_out;
    wire [DATA_WIDTH-1:0] data_out;
    wire [DATA_WIDTH-1:0] wt_path_out;
    
    // Instantiate the MAC_opt module
    MAC_opt #(DATA_WIDTH, ACC_WIDTH) uut (
        .clk(clk),
        .control(control),
        .reset(reset),
        .acc_in(acc_in),
        .data_in(data_in),
        .wt_path_in(wt_path_in),
        .acc_out(acc_out),
        .data_out(data_out),
        .wt_path_out(wt_path_out)
    );
    
    // Clock generation: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals and apply reset
        reset = 1;
        control = 0;
        acc_in = 0;
        data_in = 0;
        wt_path_in = 0;
        #10;
        
        // Release reset and enable operation
        reset = 0;
        control = 1;
        
        // Test Case 1: 0 + (3*4) = 12
        acc_in = 0;
        data_in = 8'd3;
        wt_path_in = 8'd4;
        #10;
        $display("Test Case 1: Expected acc_out = 12, Got: %0d", acc_out);
        
        // Test Case 2: Use previous acc_out (12) + (5*6) = 12 + 30 = 42
        acc_in = acc_out;
        data_in = 8'd5;
        wt_path_in = 8'd6;
        #10;
        $display("Test Case 2: Expected acc_out = 42, Got: %0d", acc_out);
        
        // Test Case 3: With control = 0, accumulator should hold its value (42)
        control = 0;
        acc_in = acc_out; // 42
        data_in = 8'd7;   // new inputs, but control is 0
        wt_path_in = 8'd8;
        #10;
        $display("Test Case 3: control=0, Expected acc_out = 42, Got: %0d", acc_out);
        
        // Test Case 4: Assert reset then perform new operation: 0 + (2*10) = 20
        reset = 1; #10;
        reset = 0; 
        control = 1;
        acc_in = 0;
        data_in = 8'd2;
        wt_path_in = 8'd10;
        #10;
        $display("Test Case 4: After reset, Expected acc_out = 20, Got: %0d", acc_out);
        
        $stop;
    end

endmodule
