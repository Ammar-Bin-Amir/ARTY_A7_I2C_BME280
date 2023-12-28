module i2c_slave (
    input wire clk,
    input wire rst,
    // Serial Clock
    input wire scl,
    // Serial Data
    input wire sda_out,
    output reg sda_in
);
    
    /* BIT COUNTER */

    reg [5:0] bit_count;

    always @(posedge clk or rst) begin
        if (rst) begin
            bit_count <= 0;
        end
        else begin
            if ((current_state == IDLE) || (current_state == START) || (current_state == STOP)) begin
                bit_count <= 0;
            end
            else if ((repeated_start_signal == 1'b1)) begin
                bit_count <= 0;
            end
            else begin
                if (scl == 1'b1) begin
                bit_count <= bit_count + 1;
                end
                else begin
                    bit_count <= bit_count;
                end
            end
        end
    end

    reg [5:0] accelerated_bit_count;

    always @(posedge clk or rst) begin
        if (rst) begin
            accelerated_bit_count <= 0;
        end
        else begin
            if ((current_state == IDLE) || (current_state == START) || (current_state == STOP)) begin
                accelerated_bit_count <= 0;
            end
            else if ((repeated_start_signal == 1'b1)) begin
                accelerated_bit_count <= 0;
            end
            else begin
                if (scl == 1'b0) begin
                accelerated_bit_count <= accelerated_bit_count + 1;
                end
                else begin
                    accelerated_bit_count <= accelerated_bit_count;
                end
            end
        end
    end
    
    /* SLAVE ADDRESS & READ / WRITE */
    
    reg [7:0] slave_address_save;
    reg read_write_save;

    always @(posedge scl or rst) begin
        if (rst) begin
            slave_address_save <= 0;
            read_write_save <= 0;
        end
        else begin
            if (current_state == SLAVE_ADDRESS) begin
                if ((bit_count >= 0) && (bit_count <= 7)) begin
                    slave_address_save <= {slave_address_save[6:0],sda_out};
                    if (bit_count == 7) begin
                        read_write_save <= sda_out;
                    end
                    else begin
                        read_write_save <= read_write_save;
                    end
                end
                else begin
                    slave_address_save <= slave_address_save;
                    read_write_save <= read_write_save;
                end
            end
            else begin
                slave_address_save <= slave_address_save;
                read_write_save <= read_write_save;
            end
        end
    end

    /* SLAVE ADDRESS ACKNOWLEDGEMENT */

    // BME280 Address: 111011x; 0x76 OR 0x77
    localparam [6:0] SLAVE_ADDRESS_MIN = 7'b111_0110;
    localparam [6:0] SLAVE_ADDRESS_MAX = 7'b111_0111;
    
    reg slave_address_check;

    always @(*) begin
        if (rst) begin
            slave_address_check = 0;
        end
        else begin
            if ((slave_address_save[7:1] >= SLAVE_ADDRESS_MIN) && (slave_address_save[7:1] <= SLAVE_ADDRESS_MAX)) begin
                if (accelerated_bit_count == 8) begin
                    slave_address_check = 1;
                end
                else begin
                    slave_address_check = 0;
                end
            end
            else if (current_state == STOP) begin
                slave_address_check = 0;
            end
            else begin
                slave_address_check = 0;
            end
        end
    end

    /* REGISTER ADDRESS */
    
    reg [7:0] register_address_save;

    always @(posedge scl or rst) begin
        if (rst) begin
            register_address_save <= 0;
        end
        else begin
            if (current_state == REGISTER_ADDRESS) begin
                if ((bit_count >= 9) && (bit_count <= 16)) begin
                    register_address_save <= {register_address_save[6:0],sda_out};
                end
                else begin
                    register_address_save <= register_address_save;
                end
            end
            else begin
                register_address_save <= register_address_save;
            end
        end
    end

    /* REGISTER ADDRESS ACKNOWLEDGEMENT */

    // BME280 Register Addresses: 0x88 ---> 0xA1 and 0xD0 and 0xE0 ---> 0xFE
    localparam [7:0] REGISTER_ADDRESS_MIN = 8'h88;
    localparam [7:0] REGISTER_ADDRESS_MAX = 8'hFF;
    
    reg register_address_check;

    always @(*) begin
        if (rst) begin
            register_address_check = 0;
        end
        else begin
            if ((register_address_save >= REGISTER_ADDRESS_MIN) && (register_address_save <= REGISTER_ADDRESS_MAX)) begin
                if (accelerated_bit_count == 17) begin
                    register_address_check = 1;
                end
                else begin
                    register_address_check = 0;
                end
            end
            else begin
                register_address_check = 0;
            end
        end
    end

    /* WRITE DATA */
    
    reg [7:0] data_write;

    always @(posedge scl or rst) begin
        if (rst) begin
            data_write <= 0;
        end
        else begin
            if (read_write_save == 0) begin
                if (current_state == DATA_BYTE) begin
                    if ((bit_count >= 18) && (bit_count <= 25)) begin
                        data_write <= {data_write[6:0],sda_out};
                    end
                    else begin
                        data_write <= data_write;
                    end
                end
                else begin
                    data_write <= data_write;
                end
            end
            else begin
                data_write <= data_write;
            end
        end
    end

    /* READ DATA */

    reg [7:0] data_read;

    always @(negedge scl or rst) begin
        if (rst) begin
            data_read <= 0;
        end
        else begin
            if (read_write_save == 1) begin
                if (current_state == REGISTER_ADDRESS) begin
                    if ((bit_count >= 9) && (bit_count <= 16)) begin
                        data_read <= data_write;
                    end
                end
                else if ((current_state == DATA_BYTE) || (current_state == DATA_BYTE_ACKNOWLEDGE)) begin
                    if ((bit_count >= 19) && (bit_count <= 26)) begin
                        data_read <= {data_read[6:0],1'b0};
                    end
                    else begin
                        data_read <= data_read;
                    end
                end
                else begin
                    data_read <= data_read;
                end
            end
            else begin
                data_read <= data_read;
            end
        end
    end

    /* DATA ACKNOWLEDGEMENT */
    
    reg data_check;

    always @(*) begin
        if (rst) begin
            data_check = 0;
        end
        else begin
            if (accelerated_bit_count == 26) begin
                data_check = 1;
            end
            else begin
                data_check = 0;
            end
        end
    end
    
    /* ACKNOWLEDGEMENT */

    reg ack;

    always @(negedge scl or rst) begin
        if (rst) begin
            ack <= 1;
        end
        else begin
            // Slave Address Acknowledgement
            if (bit_count == 8) begin
                if (slave_address_check == 1'b1) begin
                    ack <= 0;
                end
                else begin
                    ack <= 1;
                end
            end
            // Register Address Acknowledgement
            else if (bit_count == 17) begin
                if (register_address_check == 1'b1) begin
                    ack <= 0;
                end
                else begin
                    ack <= 1;
                end
            end
            // Data Acknowledgement
            else if (bit_count == 26) begin
                if (data_check == 1'b1) begin
                    ack <= 0;
                end
                else begin
                    ack <= 1;
                end
            end
            else begin
                ack <= 1;
            end
        end
    end
    
    /* FINITE STATE MACHINE */

    localparam IDLE = 4'h0;
    localparam START = 4'h1;
    localparam SLAVE_ADDRESS = 4'h2;
    localparam SLAVE_ADDRESS_ACKNOWLEDGE = 4'h3;
    localparam REGISTER_ADDRESS = 4'h4;
    localparam REGISTER_ADDRESS_ACKNOWLEDGE = 4'h5;
    localparam DATA_BYTE = 4'h6;
    localparam DATA_BYTE_ACKNOWLEDGE = 4'h7;
    localparam STOP = 4'he;
    localparam REPEATED_START = 4'hf;

    reg [3:0] current_state, next_state;
    reg repeated_start_indication;
    reg delayed_repeated_start_indication;
    wire repeated_start_signal;

    assign repeated_start_signal = repeated_start_indication & ~delayed_repeated_start_indication;

    always @(posedge clk or rst) begin
        if (rst) begin
            current_state <= 0;
            delayed_repeated_start_indication <= 0;
        end
        else begin
            current_state <= next_state;
            delayed_repeated_start_indication <= repeated_start_indication;
        end
    end

    always @(*) begin
        if (rst) begin
            next_state = 0;
            repeated_start_indication = 0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    sda_in = 1;
                    if ((scl == 1'b1) && (sda_out == 1'b0)) begin
                        repeated_start_indication = 0;
                        next_state = SLAVE_ADDRESS;
                    end
                end
                START: begin
                    next_state = IDLE;
                end
                SLAVE_ADDRESS: begin
                    sda_in = 1;
                    if (accelerated_bit_count == 8) begin
                        next_state = SLAVE_ADDRESS_ACKNOWLEDGE;
                    end
                end
                SLAVE_ADDRESS_ACKNOWLEDGE: begin
                    sda_in = ack;
                    // ACK
                    if ((accelerated_bit_count == 9) && (sda_in == 1'b0)) begin
                        next_state = REGISTER_ADDRESS;
                    end
                    // NACK
                    if ((accelerated_bit_count == 9) && (sda_in == 1'b1)) begin
                        next_state = STOP;
                    end
                end
                REGISTER_ADDRESS: begin
                    sda_in = 1;
                    if (accelerated_bit_count == 17) begin
                        next_state = REGISTER_ADDRESS_ACKNOWLEDGE;
                    end
                end
                REGISTER_ADDRESS_ACKNOWLEDGE: begin
                    sda_in = ack;
                    // ACK
                    if ((accelerated_bit_count == 18) && (sda_in == 1'b0)) begin
                        next_state = DATA_BYTE;
                    end
                    // NACK
                    if ((accelerated_bit_count == 18) && (sda_in == 1'b1)) begin
                        next_state = STOP;
                    end
                end
                DATA_BYTE: begin
                    // Repeated Start Detection
                    if ((accelerated_bit_count == 18) && (scl == 1'b1) && (sda_out == 1'b0)) begin
                        repeated_start_indication = 1;
                        next_state = SLAVE_ADDRESS;
                    end
                    // Write
                    if (read_write_save == 0) begin
                        sda_in = 1;
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_in = data_read[7];
                    end
                    // Next State
                    if (accelerated_bit_count == 26) begin
                        next_state = DATA_BYTE_ACKNOWLEDGE;
                    end
                end
                DATA_BYTE_ACKNOWLEDGE: begin
                    // Write
                    if (read_write_save == 0) begin
                        sda_in = ack;
                        // ACK
                        if ((accelerated_bit_count == 27) && (sda_in == 1'b0)) begin
                            next_state = STOP;
                        end
                        // NACK
                        if ((accelerated_bit_count == 27) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_in = 1;
                        if ((accelerated_bit_count == 27) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                end
                STOP: begin
                    sda_in = 1;
                    if (sda_out == 1'b1) begin
                        next_state = START;
                    end
                end
                REPEATED_START: begin
                    next_state = IDLE;
                end
                default: next_state = IDLE;
            endcase
        end
    end

endmodule