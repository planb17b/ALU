module PC(signExtOut, uncondBranch, branch, output0, address);
input signExtOut, uncondBranch, branch, output0;
output address;
endmodule

module InstMem(address, instruction);
input address;
output instruction;
endmodule

module Register(readReg1, readReg2, writeData, regWrite, aluSrc, signExtIn, signExtOut, readData1, readData2);
input readReg1, readReg2, writeData, regWrite, aluSrc, signExtIn;
output signExtOut, readData1, readData2;
endmodule

module Controller(instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
input [31:0]instruction;
output reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl;
reg reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite;
reg [4:0]reg1, reg2, writeReg;
reg [3:0]aluControl;

always @* begin
reg1 = instruction[9:5];
reg2 = instruction[20:16];
writeReg = instruction[4:0];
aluControl = 4'b0;
{reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, aluControl} = {9{1'bx}};


if(instruction[31:26] == 6'b000101 || instruction[31:26] == 6'b100101) begin	//B and BL opcodes hard coded
	uncondBranch = 1'b1;
	{branch, memRead, memWrite, regWrite} = {4{1'b0}};
end
if(instruction[31:26] == 6'b101101)begin	//CB types have a distinct first 6 bits
	branch = 1'b1;
	{uncondBranch, memRead, memWrite, aluSrc, regWrite} = {5{1'b0}};
	if(instruction[24] == 1'b0)begin	//CBZ's 24th bit is a 0 CBNZ is a 1 alu Opcode
		aluControl = 4'b0111;
	end
end
if(instruction[31] == 1'b1 && instruction[23] == 1'b1)begin	//mov type opcodes are 9 bits and start and end with a 1
	//code for mov. have to find somewhere.
end
if(instruction[31:27] == 5'b11111)begin	//D type opcodes begin with 5 1's
	{aluSrc, memReg} = {2{1'b1}};
	branch = 1'b0;
	aluControl = 4'b0010;
	if(instruction[22] == 1'b1)begin	//Load has its 22nd bit as a 1 Store does not
		{regWrite, memRead} = {2{1'b1}};
		{reg2logic, memWrite} = {2{1'b0}};
	end
	else begin
		{regWrite, memRead} = {2{1'b0}};
		{reg2logic, memWrite} = {2{1'b1}};
	end
end
if(instruction[31:21] == 11'b10001011000 || instruction[31:21] == 11'b11001011000 || instruction[31:21] == 11'b10001010000 || instruction[31:21] == 11'b10101010000 || instruction[31:21] == 11'b11101010000)begin	//this is hardcoded because it is already 10 o'clock and I can't find patterns its the R type
	{reg2logic, aluSrc, memReg, memRead, memWrite, branch} = {6{1'b0}};
	regWrite = 1'b1;
	aluControl = 4'b0110;	//aluControl bits depend on what opcode is being delt with (sub, and, or, etc)
	if(instruction[30] == 1'b1)begin
		aluControl = 4'b0110;
	end
	if(instruction[29] == 1'b1)begin
		aluControl = 4'b0001;
	end
	if(instruction[30] == 1'b0 && instruction[24] == 1'b1)begin
		aluControl = 4'b0010;
	end
	if({instruction[30], instruction[29], instruction[24]} == {3{1'b0}})begin
		aluControl = 4'b0000;
	end
end
if(instruction[31:22] == 10'b1001000100 ||instruction[31:22] == 10'b1101000100 || instruction[31:22] == 10'b1001001000 || instruction[31:22] == 10'b1011001000 || instruction[31:22] == 10'b1101001000)begin	//I type hardcoded because I am already a day late on this and can't find patterns
	{memReg, memRead, memWrite, branch} = {4{1'b0}};
	{aluSrc, regWrite} = {2{1'b1}};
	aluControl = 4'b0110;	//aluControl bits depend on what opcode is being delt with (sub, and, or, etc)
	if(instruction[30] == 1'b1)begin
		aluControl = 4'b0110;
	end
	if(instruction[29] == 1'b1)begin
		aluControl = 4'b0001;
	end
	if(instruction[30] == 1'b0 && instruction[24] == 1'b1)begin
		aluControl = 4'b0010;
	end
	if({instruction[30], instruction[29], instruction[24]} == {3{1'b0}})begin
		aluControl = 4'b0000;
	end
end
if(reg2logic == 1'b1)begin	//the multiplexer for reg2
	reg2 = instruction[4:0];
end
end
endmodule

module ControllerTest;
reg [31:0]instruction;
wire reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite;
wire [4:0]reg1, reg2, writeReg;
wire [3:0]aluControl;

Controller contol(instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);

initial begin 

instruction = 32'b10001011000101010000001010001001;
#2 $display("Instruction: %b, Add X9,X20,X21 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b11001011000110000000000100101011;
#2 $display("Instruction: %b, Sub X11,X9,X24 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10010001000000000001001111100000;
#2 $display("Instruction: %b, AddI X0,X31,#4 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b00010100000000000000000000000001;
#2 $display("Instruction: %b, Branch Address: 1,#4 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10010100000000000000000000000001;
#2 $display("Instruction: %b, BranchL Address: 1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10110100000000000000000000100001;
#2 $display("Instruction: %b, CBZ X1,1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10110101000000000000000000100001;
#2 $display("Instruction: %b, CBNZ X1,1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b11111000010000000000010000100001;
#2 $display("Instruction: %b, LDUR X1,1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b11111000000000000000010000100001;
#2 $display("Instruction: %b, STUR X1,1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b11010001000000000000010000100001;
#2 $display("Instruction: %b, SUBI X1,X1,#5 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10001010000000010000010000100001;
#2 $display("Instruction: %b, AND X1,X1,X1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10010010000000000000010000100001;
#2 $display("Instruction: %b, ANDI X1,X1,#1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10101010000000010000010000100001;
#2 $display("Instruction: %b, ORR X1,X1,X1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b10110010000000000000010000100001;
#2 $display("Instruction: %b, ORRI X1,X1,#1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b11101010000000010000010000100001;
#2 $display("Instruction: %b, EOR X1,X1,X1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);
instruction = 32'b11010010000000000000010000100001;
#2 $display("Instruction: %b, EORI X1,X1,#1 Control bits: reg2Logic: %b, uncondBranch: %b, branch: %b, memRead: %b, memReg: %b, memWrite: %b, aluSrc: %b, regWrite: %b, MultiBit outputs: reg1: %d, reg2: %d, writeReg: %d, aluControl: %b", instruction, reg2logic, uncondBranch, branch, memRead, memReg, memWrite, aluSrc, regWrite, reg1, reg2, writeReg, aluControl);

end
endmodule

module ALU(reg1, reg2, aluControl, output0, aluResult);
input [31:0]reg1, reg2;
input [3:0]aluControl;
output output0, aluResult;
reg output0 = 1'b0;
reg [31:0]aluResult;
always @* begin
if(aluControl == 4'b0010)
	aluResult = reg1 + reg2;
else if(aluControl == 4'b1010)
	aluResult = reg1 - reg2;
else if(aluControl == 4'b0110)
	aluResult = reg1 & reg2;
else if(aluControl == 4'b0100)
	aluResult = reg1 | reg2;
else if(aluControl == 4'b1001)
	aluResult = reg1 ^ reg2;
else if(aluControl == 4'b0101)
	aluResult = ~(reg1 | reg2);
else if(aluControl == 4'b1100)
	aluResult = ~(reg1 & reg2);
else if(aluControl == 4'b1101)
	aluResult = reg1 + reg2;
else if(aluControl == 4'b0111)
	aluResult = reg1 - reg2;
	if(aluResult == 0)
		output0 = 1'b1;
end
endmodule

module ALUTest;
reg [31:0]reg1, reg2;
reg [3:0]aluControl;
wire output0;
wire [31:0]aluResult;

ALU alu0(reg1, reg2, aluControl, output0, aluResult);

initial begin
reg1 = 32'b0101; reg2 = 32'b0100; aluControl = 4'b0010;
#50 $display("reg1: %x, reg2: %x, aluControl: LDUR/STUR/ADD %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b0111;
#50 $display("reg1: %x, reg2: %x, aluControl: CBZ %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b1010;
#50 $display("reg1: %x, reg2: %x, aluControl: SUB %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b0110;
#50 $display("reg1: %x, reg2: %x, aluControl: AND %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b0100;
#50 $display("reg1: %x, reg2: %x, aluControl: ORR %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b1001;
#50 $display("reg1: %x, reg2: %x, aluControl: EOR %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b0101;
#50 $display("reg1: %x, reg2: %x, aluControl: NOR %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b1100;
#50 $display("reg1: %x, reg2: %x, aluControl: NAND %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b1101;
#50 $display("reg1: %x, reg2: %x, aluControl: MOV %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
aluControl = 4'b0111; reg1 = 32'b0100;
#50 $display("reg1: %x, reg2: %x, aluControl: CBZ %x, output0: %x, aluResult: %x", reg1, reg2, aluControl, output0, aluResult);
end
endmodule

module Multiplex(data0, data1, control, dataout);
input data0, data1, control;
output dataout;
endmodule

module DataMem(address, writeData, memWrite, memToReg, readData);
input address, writeData, memWrite, memToReg;
output readData;
endmodule
