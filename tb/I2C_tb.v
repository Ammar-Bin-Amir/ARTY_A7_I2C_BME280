`timescale 1ns/1ns

module i2c_tb;
    
    reg clk;
    reg rst;
    reg [2:0] address;
    reg [7:0] write_data;
    reg we;
    reg re;
    wire [7:0] read_data;

    i2c uut (
        .clk (clk),
        .rst (rst),
        .address (address),
        .write_data (write_data),
        .we (we),
        .re (re),
        .read_data (read_data)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        #10 rst = 1;
        #50 rst = 0;
        #100 we = 1'b1; re = 1'b1;
        // Write Data
        // Invalid Slave Address, Register Address
        #50 address = 1; write_data = 7'b111_1110;
        #20 address = 2; write_data = 1'b0;
        #20 address = 3; write_data = 8'h45;
        #20 address = 4; write_data = $random;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        // Valid Slave Address, Invalid Register Address
        #500 address = 1; write_data = 7'b111_0110;
        #20 address = 2; write_data = 1'b0;
        #20 address = 3; write_data = 8'h45;
        #20 address = 4; write_data = $random;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        // Valid Slave Address, Register Address
        #1000 address = 1; write_data = 7'b111_0110;
        #20 address = 2; write_data = 1'b0;
        #20 address = 3; write_data = 8'hE0;
        #20 address = 4; write_data = $random;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        // Read Data
        // // Invalid Slave Address, Register Address
        #2000 address = 1; write_data = 7'b111_1111;
        #20 address = 2; write_data = 1'b1;
        #20 address = 3; write_data = 8'h54;
        #20 address = 4; write_data = $random;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        #1000 address = 5;
        // Valid Slave Address, Invalid Register Address
        #50 address = 1; write_data = 7'b110_0111;
        #20 address = 2; write_data = 1'b1;
        #20 address = 3; write_data = 8'h54;
        #20 address = 4; write_data = $random;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        #1500 address = 5;
        // Valid Slave Address, Register Address
        #50 address = 1; write_data = 7'b111_0111;
        #20 address = 2; write_data = 1'b1;
        #20 address = 3; write_data = 8'hD0;
        #20 address = 4; write_data = $random;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        #2000 address = 5;
        #1000 $finish;
    end
    
    initial begin
        $dumpfile("./temp/I2C_tb.vcd");
        $dumpvars(0,i2c_tb);
    end

endmodule