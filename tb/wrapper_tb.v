`timescale 1ns/1ns

module wrapper_tb;
    
    reg clk;
    reg rst;
    reg en;
    // Registers Selector
    reg [3:0] register_selector;
    // I2C
    wire scl;
    wire tristate;
    wire sda_out;
    reg sda_in;
    // Data
    wire [7:0] data;

    wrapper uut (
        .clk (clk),
        .rst (rst),
        .en (en),
        .register_selector (register_selector),
        .scl (scl),
        .tristate (trisate),
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
            #3000 register_selector = i;
            #100 en = 1;
            #100 en = 0;
        end
        #3000 $finish;
    end
    
    initial begin
        $dumpfile("./temp/wrapper_tb.vcd");
        $dumpvars(0,wrapper_tb);
    end

endmodule