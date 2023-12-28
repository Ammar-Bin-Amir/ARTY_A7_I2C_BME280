`timescale 1ns/1ns

module wrapper_tb;
    
    reg clk;
    reg rst;
    // Registers Selector
    reg [4:0] register_selector;
    // I2C
    wire scl;
    wire sda_out;
    reg sda_in;
    // Data
    wire [7:0] data;

    wrapper uut (
        .clk (clk),
        .rst (rst),
        .register_selector (register_selector),
        .scl (scl),
        .sda_out (sda_out),
        .sda_in (sda_in),
        .data (data)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        sda_in = 0;
        #10 rst = 1;
        #50 rst = 0;
        for (integer i = 0; i < 16; i = i + 1) begin
            #1000 register_selector = i;
        end
        #1000 $finish;
    end
    
    initial begin
        $dumpfile("./temp/wrapper_tb.vcd");
        $dumpvars(0,wrapper_tb);
    end

endmodule