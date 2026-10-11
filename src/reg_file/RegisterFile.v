

module RegisterFile(
    input  wire        clk,
    input  wire        rst,
    input  wire        write_en,
    input  wire [4:0]  write_addr,
    input  wire [31:0] write_data,
    input  wire [4:0]  read_addr1,
    input  wire [4:0]  read_addr2,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] registers [0:31];

    integer idx;
    initial begin
        for (idx = 0; idx < 32; idx = idx + 1) registers[idx] = 32'd0;
    end


    assign read_data1 = (read_addr1 == 5'd0) ? 32'd0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 5'd0) ? 32'd0 : registers[read_addr2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (idx = 0; idx < 32; idx = idx + 1) registers[idx] <= 32'd0;
        end else if (write_en && write_addr != 5'd0) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule
