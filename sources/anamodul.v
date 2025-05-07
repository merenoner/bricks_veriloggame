`timescale 1ns / 1ps

module anamodul(
    input clk_100MHz,       // 100 MHz sayaç kullanacaðýz, fpga için
    input reset,            
    input up,               // paddle için yukarý ve aþaðý sinyaller
    input down,
    output hsync,           // VGA tarama kontrolü için
    output vsync,           
    output [11:0] rgb,       // VGA baðlama
    output reg [0:6] segment,
    output reg [3:0] basamak
    );
    
    
    wire w_reset, w_up, w_down, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y; //piksel tarama için gereken  wire'lar, bunlar vga controllerdan çýkýp pixelde veri olarak girdi alýnacak
    reg [11:0] rgb_reg; 
    wire [11:0] rgb_next;
    
    //boru hattý
    
    vga_modulu vga(.clk_100MHz(clk_100MHz), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
                       
    
    wire [3:0] skor_birler, skor_onlar;
    piksel_gen piksel(.clk(clk_100MHz), .reset(w_reset), .up(w_up), .down(w_down),
                 .video_on(w_vid_on), .x(w_x), .y(w_y), .rgb(rgb_next), .skor_birler(skor_birler), .skor_onlar(skor_onlar));
                 
                 
    debounce dbR(.clk(clk_100MHz), .btn_in(reset), .btn_out(w_reset)); //sinyalleri düzeltmek için, kaynak github
    
    debounce dbU(.clk(clk_100MHz), .btn_in(up), .btn_out(w_up));
    
    debounce dbD(.clk(clk_100MHz), .btn_in(down), .btn_out(w_down));
    
    
    
    //boru hattý bitiþ, 7-segment için kontroller baþlangýç
    
    
    // skor gösterim için parametreler
    parameter ZERO  = 7'b000_0001;  // 0
    parameter ONE   = 7'b100_1111;  // 1
    parameter TWO   = 7'b001_0010;  // 2 
    parameter THREE = 7'b000_0110;  // 3
    parameter FOUR  = 7'b100_1100;  // 4
    parameter FIVE  = 7'b010_0100;  // 5
    parameter SIX   = 7'b010_0000;  // 6
    parameter SEVEN = 7'b000_1111;  // 7
    parameter EIGHT = 7'b000_0000;  // 8
    parameter NINE  = 7'b000_0100;  // 9
    
    // To select each digit in turn
    reg basamak_secici;     // 2 bit counter for selecting each of 4 digits
    reg [16:0] digit_timer;     // counter for digit refresh
    
    // Logic for controlling digit select and digit timer
    always @(posedge clk_100MHz or posedge reset) begin
        if(reset) begin
            basamak_secici <= 0;
            digit_timer <= 0; 
        end
        else                                        // her bi basamaðý seçmek için 
            if(digit_timer == 99_999) begin         // The period of 100MHz clock is 10ns (1/100,000,000 seconds)
                digit_timer <= 0;                   // 10ns x 100,000 = 1ms
                basamak_secici <=  basamak_secici + 1;
            end
            else
                digit_timer <=  digit_timer + 1;
    end
    
    // Logic for driving the 4 bit anode output based on digit select
    always @(basamak_secici) begin
        case(basamak_secici) 
                0 : basamak = 4'b1110;   // birler
                1 : basamak = 4'b1101;   // onlar
        endcase
    end
    
     always @* begin
        case(basamak_secici)
            0 : begin       // ONES DIGIT
                        case(skor_birler)
                            4'b0000 : segment = ZERO;
                            4'b0001 : segment = ONE;
                            4'b0010 : segment = TWO;
                            4'b0011 : segment = THREE;
                            4'b0100 : segment = FOUR;
                            4'b0101 : segment = FIVE;
                            4'b0110 : segment = SIX;
                            4'b0111 : segment = SEVEN;
                            4'b1000 : segment = EIGHT;
                            4'b1001 : segment = NINE;
                        endcase
                    end
                    
            1 : begin       // TENS DIGIT
                        case(skor_onlar)
                            4'b0000 : segment = ZERO;
                            4'b0001 : segment = ONE;
                            4'b0010 : segment = TWO;
                            4'b0011 : segment = THREE;
                            4'b0100 : segment = FOUR;
                            4'b0101 : segment = FIVE;
                            4'b0110 : segment = SIX;
                            4'b0111 : segment = SEVEN;
                            4'b1000 : segment = EIGHT;
                            4'b1001 : segment = NINE;
                        endcase
                    end
      endcase
    end
    
    // rgb'yi atamak için
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule
