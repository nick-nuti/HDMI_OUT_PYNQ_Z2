
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/02/2024 12:15:09 AM
// Design Name:
// Module Name: nnuti_axi3_traffic_generator
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

parameter SIZE_OF_BYTE=8;
parameter DEVICE_MEM_DATA_W=32;

module axi_traffic_gen #(
    parameter PIX_SIZE_IN_BYTES = 4,
    parameter ADDR_W=32,
    parameter DATA_W=64,
    parameter FRAME_W = 1920,
    parameter FRAME_H = 1080,
    parameter ADDR_START = 32'h10000000
)
(
  /**************** Write Address Channel Signals ****************/
  output reg [ADDR_W-1:0]              m_axi_awaddr, // address (done)
  output reg [3-1:0]                   m_axi_awprot = 3'b000, // protection - privilege and securit level of transaction
  output reg                           m_axi_awvalid, // (done)
  input  wire                          m_axi_awready, // (done)
  output reg [3-1:0]                   m_axi_awsize = $clog2(DATA_W/SIZE_OF_BYTE), //3'b011, // burst size - size of each transfer in the burst 3'b011 for 8 bytes
  output reg [2-1:0]                   m_axi_awburst = 2'b01, // fixed burst = 00, incremental = 01, wrapped burst = 10
  output reg [4-1:0]                   m_axi_awcache = 4'b0000, //4'b0011, // cache type - how transaction interacts with caches
  output reg [4-1:0]                   m_axi_awlen, // number of data transfers in the burst (0-255) (done)
  output reg [1-1:0]                   m_axi_awlock = 1'b0, // lock type - indicates if transaction is part of locked sequence
  output reg [4-1:0]                   m_axi_awqos = 4'b0000, // quality of service - transaction indication of priority level
  output reg [4-1:0]                   m_axi_awregion = 4'b0000, // region identifier - identifies targetted region
  /**************** Write Data Channel Signals ****************/
  output reg [DATA_W-1:0]              m_axi_wdata, // (done)
  output reg [DATA_W/SIZE_OF_BYTE-1:0]            m_axi_wstrb, // (done)
  output reg                           m_axi_wvalid, // set to 1 when data is ready to be transferred (done)
  input  wire                          m_axi_wready, // (done)
  output reg                           m_axi_wlast, // if awlen=0 then set wlast (done)
  /**************** Write Response Channel Signals ****************/
  input  wire [2-1:0]                  m_axi_bresp, // (done) write response - status of the write transaction (00 = okay, 01 = exokay, 10 = slverr, 11 = decerr)
  input  wire                          m_axi_bvalid, // (done) write response valid - 0 = response not valid, 1 = response is valid
  output reg                           m_axi_bready, // (done) write response ready - 0 = not ready, 1 = ready
  /**************** System Signals ****************/
  input wire                           aclk,
  input wire                           aresetn,

(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 vsync INTERRUPT" *)
(* X_INTERFACE_PARAMETER = "SENSITIVITY EDGE_RISING" *)  
  output wire                          vsync
 
  // driven input from my logic
  /*
  input  wire                          user_start,
  input  wire [3:0]                    user_burst_len_in,
  input  wire                          user_pixels_1_2, //0 = 1 pixel, 1 = 2 pixels
  input  wire [DATA_W-1:0]             user_data_in,
  input  wire [ADDR_W-1:0]             user_addr_in,
  output reg                           user_free,
  output reg                           user_stall_data, // can this be caused by all of these: m_axi_awready, m_axi_awvalid, m_axi_wvalid, m_axi_wready
  output reg  [1:0]                    user_status
  */
  
    );
    
    parameter ADDR_END   = ADDR_START + (FRAME_W*FRAME_H*PIX_SIZE_IN_BYTES)-PIX_SIZE_IN_BYTES; //32'h107E8FFC 
    
    reg                           user_start;
    wire [3:0]                    user_burst_len_in;
    wire                          user_pixels_1_2; //0 = 1 pixel, 1 = 2 pixels
    wire [DATA_W-1:0]             user_data_in;
    wire [ADDR_W-1:0]             user_addr_in;
    reg                           user_free;
    reg                           user_stall_data; // can this be caused by all of these: m_axi_awready, m_axi_awvalid, m_axi_wvalid, m_axi_wready
    reg  [1:0]                    user_status;
   
    //typedef enum {IDLE, WRITE, WRITE_RESPONSE} custom_axi_fsm;
    localparam IDLE           = 2'b00;
    localparam WRITE          = 2'b01;
    localparam WRITE_RESPONSE = 2'b10;
       
    //custom_axi_fsm axi_cs, axi_ns;
    reg [1:0] axi_cs, axi_ns;
    reg [7:0]  data_counter;
       
    always @ (posedge aclk or negedge aresetn)
    begin
        if(~aresetn)
        begin
            axi_cs <= IDLE;
        end
       
        else
        begin
            axi_cs <= axi_ns;
        end
    end
   
    always @ (*)
    begin
        case(axi_cs)
        
        IDLE:
        begin
            if(m_axi_awready & user_start)
            begin
                axi_ns = WRITE;
            end
           
            else
            begin
                axi_ns = IDLE;
            end
        end
       
        WRITE:
        begin
            if((data_counter == user_burst_len_in) && m_axi_wready)
            begin
                axi_ns = WRITE_RESPONSE;
            end
           
            else
            begin
                axi_ns = WRITE;
            end
        end
       
        WRITE_RESPONSE:
        begin
            if(m_axi_bvalid) axi_ns = IDLE;
            else axi_ns = WRITE_RESPONSE;
        end
       
        default: axi_ns = IDLE;
        endcase
    end

// ---------------------------------------------------
   
    always @ (posedge aclk)
    begin
//
        if(axi_cs == IDLE || axi_cs == WRITE_RESPONSE) data_counter <= 'h0;
       
        else if(axi_cs == WRITE && m_axi_wready && data_counter < user_burst_len_in)
        begin
            data_counter <= data_counter + 1'b1;
        end
       
        else data_counter <= data_counter;
//
    end
    
    always @ (*)
    begin
        m_axi_awvalid = ((axi_cs==IDLE) && (axi_ns==WRITE)) ? 1 : 0;
        m_axi_awlen   = ((axi_cs==IDLE) && (axi_ns==WRITE)) ? user_burst_len_in : 0;
        m_axi_wvalid  = (axi_cs==WRITE) ? 1 : 0;
        m_axi_awaddr  = ((axi_cs==IDLE) && (axi_ns==WRITE)) ? user_addr_in : 0;
        m_axi_wdata   = (axi_cs==WRITE) ? user_data_in : 0;
        m_axi_wstrb   = (user_pixels_1_2) ? 8'b11111111 : 8'b00001111;
        m_axi_wlast   = ((axi_cs==WRITE)&&(data_counter == user_burst_len_in)) ? 1'b1 : 1'b0;
        m_axi_bready  = ((axi_cs == WRITE_RESPONSE)&& m_axi_bvalid) ? 1'b1 : 'h0;
    end
   
// ---------------------------------------------------

    always @ (posedge aclk)
    begin
        user_status <= ((axi_cs == WRITE_RESPONSE)&& m_axi_bvalid) ? m_axi_bresp : 'h0;
    end

    always @ (*)
    begin
        user_stall_data = (~m_axi_wready) ? 1'b0 : 1'b1;
        user_free       = (axi_ns == IDLE) ? 1'b1 : 1'b0;
    end
    
    //FRAME GEN
        
    reg [7:0] R, G, B;
    
    reg [31:0] pixel_cnt;
    
    reg [4:0] color_combination;
    
    reg vsync_dff;
           
    assign user_pixels_1_2 = 1;
    assign user_burst_len_in = 15;
    assign user_data_in = {2{8'hFF,R,B,G}};
    assign user_addr_in = pixel_cnt;
    //
    //assign vsync = (pixel_cnt >= (ADDR_END - ((user_burst_len_in+1)<<1))) ? 1'b1 : 1'b0;
    assign vsync = (pixel_cnt >= ADDR_END) ? 1'b1 : 1'b0;
    
    always@(posedge aclk or negedge aresetn)
    begin
        
        if(~aresetn)
        begin
            user_start <= 1'b0;
            
            R <= 8'h00;
            G <= 8'h00;
            B <= 8'h00;
            
            color_combination <= 'h0;
            
            pixel_cnt <= ADDR_START;
            
            vsync_dff <= 0;
        end
        
        else
        begin
            
            //if(vsync) vsync_dff <= 1;
            //else if(user_free) vsync_dff <= 0;
            //else vsync_dff <= vsync_dff;
        
            user_start <= 1'b1;
            
            if(user_free)
            begin
                if(vsync)
                begin
                    pixel_cnt <= ADDR_START;
                    
                    if(color_combination == 6)
                    begin
                        color_combination <= 0;
                    end
                    
                    else
                    begin
                        color_combination <= color_combination + 1;
                    end
                end
                
                else
                begin
                    //pixel_cnt <= pixel_cnt + ((user_burst_len_in+1)<<1); // 1 needs to change with DATA_W and ADDR_W
                    pixel_cnt <= pixel_cnt + ((user_burst_len_in+1)*(DATA_W/SIZE_OF_BYTE));
                    color_combination <= color_combination;
                end
            end
            
            else
            begin
                pixel_cnt <= pixel_cnt;
                
                color_combination <= color_combination;
            end
            
            case(color_combination)
                0: 
                begin
                    R <= 8'hFF;
                    G <= 8'h00;
                    B <= 8'h00;
                end
                1: 
                begin
                    R <= 8'hFF;
                    G <= 8'h01;
                    B <= 8'b01;
                end
                2: 
                begin
                    R <= 8'hFF;
                    G <= 8'h00;
                    B <= 8'h00;
                end
                3: 
                begin
                    R <= 8'hFF;
                    G <= 8'h01;
                    B <= 8'h01;
                end
                4: 
                begin
                    R <= 8'hFF;
                    G <= 8'h00;
                    B <= 8'h00;
                end
                5: 
                begin
                    R <= 8'hFF;
                    G <= 8'h01;
                    B <= 8'h01;
                end
                6: 
                begin
                    R <= 8'hFF;
                    G <= 8'h00;
                    B <= 8'h00;
                end
                7: 
                begin
                    R <= 8'hFF;
                    G <= 8'h01;
                    B <= 8'h01;
                end
                8: 
                begin
                    R <= 8'hFF;
                    G <= 8'h00;
                    B <= 8'h00;
                end
                default:
                begin
                    R <= 8'hFF;
                    G <= 8'h00;
                    B <= 8'h00;
                end
            endcase

        end
    end

endmodule
