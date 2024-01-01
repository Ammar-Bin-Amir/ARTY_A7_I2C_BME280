module wrapper (
     input wire clk_pll,
     output wire clk,
    input wire rst,
    input wire en,
    // Registers Selector
    input wire [3:0] register_selector,
    // I2C
    output wire scl,
    output wire tristate,
    inout wire sda,
    // Data
    output wire [7:0] data
);
    
     // PLL Clock
     clk_wiz_0 uut_clk (
         .clk_out1 (clk),
         .clk_in1 (clk_pll)
     );
    
    // InOut Buffer
    wire sda_out;

    assign sda = tristate ? 1'bz : sda_out;
    
    // I2C Master
    reg [6:0] ext_slave_address_in;
    reg ext_read_write_in;
    reg [7:0] ext_register_address_in;
    reg [7:0] ext_data_in;

    i2c_master uut (
        .clk (clk),
        .rst (rst),
        .en (en),
        .scl (scl),
        .ext_slave_address_in (ext_slave_address_in),
        .ext_read_write_in (ext_read_write_in),
        .ext_register_address_in (ext_register_address_in),
        .ext_data_in (ext_data_in),
        .tristate (tristate),
        .sda_out (sda_out),
        .sda_in (sda),
        .ext_data_out (data)
    );

    // Wrapper
    localparam SLAVE_ADDRESS = 7'b111_0110;
    localparam WRITE = 1'b0;
    localparam READ = 1'b1;
    localparam REGISTER_ID = 8'hD0;
    localparam REGISTER_RESET = 8'hE0;
    localparam REGISTER_CNTL_MEAS = 8'hF4;
    localparam REGISTER_CNTL_HUM = 8'hF2;
    localparam REGISTER_CONFIG = 8'hF5;
    localparam REGISTER_PRESS_MSB = 8'hF7;
    localparam REGISTER_PRESS_LSB = 8'hF8;
    localparam REGISTER_PRESS_XLSB = 8'hF9;
    localparam REGISTER_TEMP_MSB = 8'hFA;
    localparam REGISTER_TEMP_LSB = 8'hFB;
    localparam REGISTER_TEMP_XLSB = 8'hFC;
    localparam REGISTER_HUM_MSB = 8'hFD;
    localparam REGISTER_HUM_LSB = 8'hFE;
    
    localparam DISABLE = 4'b0000;
    localparam READ_ID = 4'b0001;
    localparam READ_CNTL_MEAS = 4'b0010;
    localparam READ_CNTL_HUM = 4'b0011;
    localparam READ_CONFIG = 4'b0100;
    localparam WRITE_CNTL_MEAS = 4'b0101;
    localparam NOTHING = 4'b0110;
    localparam WRITE_RESET = 4'b0111;
    localparam READ_PRESS_MSB = 4'b1000;
    localparam READ_PRESS_LSB = 4'b1001;
    localparam READ_PRESS_XLSB = 4'b1010;
    localparam READ_TEMP_MSB = 4'b1011;
    localparam READ_TEMP_LSB = 4'b1100;
    localparam READ_TEMP_XLSB = 4'b1101;
    localparam READ_HUM_MSB = 4'b1110;
    localparam READ_HUM_LSB = 4'b1111;
    
    always @(*) begin
        ext_slave_address_in = 0;
        ext_read_write_in = 0;
        ext_register_address_in = 0;
        ext_data_in = 0;
        if (rst) begin
            ext_slave_address_in = 0;
            ext_read_write_in = 0;
            ext_register_address_in = 0;
            ext_data_in = 0;
        end
        else begin
            if (en == 1'b0) begin
                case (register_selector)
                    // DISABLE: begin
                    
                    // end
                    READ_ID: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_ID;
                    end
                    READ_CNTL_MEAS: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_CNTL_MEAS;
                    end
                    READ_CNTL_HUM: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_CNTL_HUM;
                    end
                    READ_CONFIG: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_CONFIG;
                    end
                    WRITE_CNTL_MEAS: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = WRITE;
                        ext_register_address_in = REGISTER_CNTL_MEAS;
                        ext_data_in = 8'b000_000_11;    // Normal Mode
                    end
                    // NOTHING: begin
                        
                    // end
                    WRITE_RESET: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = WRITE;
                        ext_register_address_in = REGISTER_RESET;
                        ext_data_in = 8'hB6;        // Power-On-Reset
                    end
                    READ_PRESS_MSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_PRESS_MSB;
                    end
                    READ_PRESS_LSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_PRESS_LSB;
                    end
                    READ_PRESS_XLSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_TEMP_XLSB;
                    end
                    READ_TEMP_MSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_TEMP_MSB;
                    end
                    READ_TEMP_LSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_TEMP_LSB;
                    end
                    READ_TEMP_XLSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_TEMP_XLSB;
                    end
                    READ_HUM_MSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_HUM_MSB;
                    end
                    READ_HUM_LSB: begin
                        ext_slave_address_in = SLAVE_ADDRESS;
                        ext_read_write_in = READ;
                        ext_register_address_in = REGISTER_HUM_LSB;
                    end
                    // default: 
                endcase
            end
            else begin
                ext_slave_address_in = SLAVE_ADDRESS;
                ext_read_write_in = 0;
                ext_register_address_in = 0;
                ext_data_in = 0;
            end
        end
    end

endmodule