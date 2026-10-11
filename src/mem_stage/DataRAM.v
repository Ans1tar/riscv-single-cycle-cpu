
module DataRAM(
    input  wire        clk,
    input  wire [31:0] addr,
    input  wire        write_en,
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [31:0] store_data,
    output reg  [31:0] read_data
);

    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;


    localparam F3_LB  = 3'b000;
    localparam F3_LH  = 3'b001;
    localparam F3_LW  = 3'b010;
    localparam F3_LBU = 3'b100;
    localparam F3_LHU = 3'b101;
    localparam F3_SB  = 3'b000;
    localparam F3_SH  = 3'b001;
    localparam F3_SW  = 3'b010;

    reg [7:0] dmem [0:1023];

    integer idx;
    initial begin
        for (idx = 0; idx < 1024; idx = idx + 1) dmem[idx] = 8'b0;
    end


    always @(*) begin
        read_data = 32'd0;
        if (opcode == OP_LOAD) begin
            case (addr[1:0])
                2'b00: begin
                    case (funct3)
                        F3_LB:  read_data = {{24{dmem[addr][7]}},   dmem[addr]};
                        F3_LH:  read_data = {{16{dmem[addr+1][7]}}, dmem[addr+1], dmem[addr]};
                        F3_LW:  read_data = {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]};
                        F3_LBU: read_data = {24'b0, dmem[addr]};
                        F3_LHU: read_data = {16'b0, dmem[addr+1], dmem[addr]};
                    endcase
                end
                2'b01: begin
                    case (funct3)
                        F3_LB:  read_data = {{24{dmem[addr+1][7]}},   dmem[addr+1]};
                        F3_LH:  read_data = {{16{dmem[addr+2][7]}},   dmem[addr+2], dmem[addr+1]};
                        F3_LBU: read_data = {24'b0, dmem[addr+1]};
                        F3_LHU: read_data = {16'b0, dmem[addr+2], dmem[addr+1]};
                    endcase
                end
                2'b10: begin
                    case (funct3)
                        F3_LB:  read_data = {{24{dmem[addr+2][7]}},   dmem[addr+2]};
                        F3_LH:  read_data = {{16{dmem[addr+3][7]}},   dmem[addr+3], dmem[addr+2]};
                        F3_LBU: read_data = {24'b0, dmem[addr+2]};
                        F3_LHU: read_data = {16'b0, dmem[addr+3], dmem[addr+2]};
                    endcase
                end
                2'b11: begin
                    case (funct3)
                        F3_LB:  read_data = {{24{dmem[addr+3][7]}},   dmem[addr+3]};
                        F3_LBU: read_data = {24'b0, dmem[addr+3]};
                    endcase
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (write_en && opcode == OP_STORE) begin
            case (funct3)
                F3_SB: begin
                    dmem[addr] <= store_data[7:0];
                end
                F3_SH: begin
                    dmem[addr+0] <= store_data[7:0];
                    dmem[addr+1] <= store_data[15:8];
                end
                F3_SW: begin
                    dmem[addr+0] <= store_data[7:0];
                    dmem[addr+1] <= store_data[15:8];
                    dmem[addr+2] <= store_data[23:16];
                    dmem[addr+3] <= store_data[31:24];
                end
            endcase
        end
    end

endmodule
