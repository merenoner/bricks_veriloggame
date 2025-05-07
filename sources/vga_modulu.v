`timescale 1ns / 1ps

module vga_modulu(
    input clk_100MHz,   
    input reset,        
    output video_on,    // tarama yapýlan nokta görüntü alýnacak kýsým mý?
    output hsync,       // horizontal sync
    output vsync,       // vertical sync
    output p_tick,      // 4 kat yavaþ clk, ekran yenileme hýzýný algýlayacak
    output [9:0] x,     // ekraný tarayacak x ve y
    output [9:0] y      
    );
    
    // 640x480 display olacak, kaydýrmalara ek 800x525 yapýlmýþ (kaynak github)
    
    parameter HD = 640;             // **horizontal display area width in pixels
    parameter HF = 48;              // **horizontal front porch width in pixels
    parameter HB = 16;              // **horizontal back porch width in pixels
    parameter HR = 96;              // **horizontal retrace width in pixels
    parameter HMAX = HD+HF+HB+HR-1; // **max value of horizontal counter = 799
   
    parameter VD = 480;             // **vertical display area length in pixels 
    parameter VF = 10;              // **vertical front porch length in pixels  
    parameter VB = 33;              // **vertical back porch length in pixels   
    parameter VR = 2;               // **vertical retrace length in pixels  
    parameter VMAX = VD+VF+VB+VR-1; // **max value of vertical counter = 524   
    
    // p_tick için yavaþ clk
	reg  [1:0] r_25MHz;
	wire w_25MHz;
	always @(posedge clk_100MHz or posedge reset)
		if(reset)
		  r_25MHz <= 0;
		else
		  r_25MHz <= r_25MHz + 1;
	
	assign w_25MHz = (r_25MHz == 0) ? 1 : 0; // **assert tick 1/4 of the time
    
    
    // Counter Registers, two each for buffering to avoid glitches
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    
    // Output Buffers
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;
    
    // Register Control
    always @(posedge clk_100MHz or posedge reset)
        if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end
        else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
         
    //yatay sayaç kontrol
    always @(posedge w_25MHz or posedge reset)      
        if(reset)
            h_count_next = 0;
        else
            if(h_count_reg == HMAX)                 
                h_count_next = 0;
            else
                h_count_next = h_count_reg + 1;         
  
    //dikey sayaç kontrol
    always @(posedge w_25MHz or posedge reset)
        if(reset)
            v_count_next = 0;
        else
            if(h_count_reg == HMAX)                 // **end of horizontal scan
                if((v_count_reg == VMAX))           // **end of vertical scan
                    v_count_next = 0;
                else
                    v_count_next = v_count_reg + 1;
        
    // display dýþýnda retrace area taramasý (boþluk tarama)
    assign h_sync_next = (h_count_reg >= (HD+HB) && h_count_reg <= (HD+HB+HR-1));
    assign v_sync_next = (v_count_reg >= (VD+VB) && v_count_reg <= (VD+VB+VR-1));
    
    // display içi tarama
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD);
            
    //aktarýlan çýktýlar, pixel_gen ve ana modülde kullanýlacak
    assign hsync  = h_sync_reg;
    assign vsync  = v_sync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = w_25MHz;
            
endmodule
