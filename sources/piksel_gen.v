`timescale 1ns / 1ps

module piksel_gen(
    input clk,  
    input reset,    
    input up,
    input down,
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [3:0] kalan_can,
    output reg [11:0] rgb,
    output reg [3:0] skor_birler, skor_onlar
    );
    
    
    // map için max pixeller
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // taramanýn bittiðini kontrol eden wire, buna göre bir pixel hareket edecek
    wire yenile;
    assign yenile = ((y == 481) && (x == 0)) ? 1 : 0;
    
       
    // tuðlalarýn arkasýnda kalan duvar
    parameter X_WALL_L = 25;    
    parameter X_WALL_R = 42;
    
    parameter tugla_sayisi = 12;
    
    parameter X_BRICK_L = 45;
    parameter X_BRICK_R = 75;
    parameter Y_BRICK_D = 0;
    parameter Y_BRICK_U = 70;
    
    parameter X_BRICK2_L = 45;
    parameter X_BRICK2_R = 75;
    parameter Y_BRICK2_D = 80;
    parameter Y_BRICK2_U = 150;
   
    parameter X_BRICK3_L = 45;
    parameter X_BRICK3_R = 75;
    parameter Y_BRICK3_D = 160;
    parameter Y_BRICK3_U = 230;
    
    parameter X_BRICK4_L = 45;
    parameter X_BRICK4_R = 75;
    parameter Y_BRICK4_D = 240;
    parameter Y_BRICK4_U = 310;
    
    parameter X_BRICK5_L = 45;
    parameter X_BRICK5_R = 75;
    parameter Y_BRICK5_D = 320;
    parameter Y_BRICK5_U = 390;
    
    parameter X_BRICK6_L = 45;
    parameter X_BRICK6_R = 75;
    parameter Y_BRICK6_D = 400;
    parameter Y_BRICK6_U = 470;
    
    // ikinci sütun tuðlalarý
    
    parameter X_BRICK7_L = 95;
    parameter X_BRICK7_R = 125;
    parameter Y_BRICK7_D = 35;
    parameter Y_BRICK7_U = 115;
    
    parameter X_BRICK8_L = 95; 
    parameter X_BRICK8_R = 125;
    parameter Y_BRICK8_D = 195;
    parameter Y_BRICK8_U = 275;
    
    parameter X_BRICK9_L = 95; 
    parameter X_BRICK9_R = 125;
    parameter Y_BRICK9_D = 375;
    parameter Y_BRICK9_U = 455;
    
    // üçüncü sütun
    
    parameter X_BRICK10_L = 135; 
    parameter X_BRICK10_R = 165;
    parameter Y_BRICK10_D = 115;
    parameter Y_BRICK10_U = 195;
    
    parameter X_BRICK11_L = 135; 
    parameter X_BRICK11_R = 165;
    parameter Y_BRICK11_D = 275;
    parameter Y_BRICK11_U = 355;
    
    parameter X_BRICK12_L = 175; 
    parameter X_BRICK12_R = 205;
    parameter Y_BRICK12_D = 195;
    parameter Y_BRICK12_U = 275;
    
    // PADDLE
    // paddle sað ve sol x deðerleri
    parameter X_PAD_L = 597;
    parameter X_PAD_R = 603;
    
    // paddle alt ve üst (y) deðerleri, hamleyle deðiþecek ama yüksekliði 100
    wire [9:0] y_pad_t, y_pad_b;
    parameter PAD_HEIGHT = 100;
    reg [9:0] y_pad_reg, y_pad_next;
    
    // hamle sýrasýnda ilerleme (pixel ekleme) hýzýmýz
    parameter PAD_HIZ = 3;
    
    // TOP
    // top 8*8 kare yer kaplýyor
    parameter BALL_SIZE = 8;
    // topun en sað - en sol konumu
    wire [9:0] x_ball_l, x_ball_r;
    // topun en üst - taban konumlarý
    wire [9:0] y_ball_t, y_ball_b;
    
    // deðiþen atamalar için reg-nextler
    reg [9:0] y_ball_reg, x_ball_reg;
    reg [9:0] y_ball_next, x_ball_next;
    
    
    // ilerleme miktarýnýn tutulacaðý deðerler ve onlarýn nextleri, çarpýþmada ilerlemeyi (hýz) eksi yapmak için ya da arttýrmak için
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    
    
    // standart hýzlarýn parametreleri
    parameter TOP_HIZ_POS = 2;
    parameter TOP_HIZ_NEG = -2;
    
    reg gameover = 0;
    reg gameover_next=0;
    
    reg [tugla_sayisi - 1 : 0] flag;
    reg [tugla_sayisi - 1 : 0] flag_n;   //tuðlalara deðdiðini kontrol edecek bayrak deðerleri
    
    reg [3:0] skor_birler_n, skor_onlar_n; //skor tutacak deðer
    reg [3:0] kalan_can_next;
    
    
    
    integer i;
    initial begin
        for(i=0; i<tugla_sayisi; i=i+1)begin
            flag[i] = 1;
        end
        kalan_can = 5;
        
        gameover=0;
        skor_birler = 0;
        skor_onlar = 0;
        
        x_ball_next = 400;
        y_ball_next = 240;
    end
    
    reg [11:0] brick_rgb [0:tugla_sayisi -1];
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            x_ball_reg <= 400;
            y_ball_reg <= 240;
            x_delta_reg <= 10'h001;
            y_delta_reg <= 10'h001;
            skor_onlar <= 0;
            skor_birler <= 0;
            kalan_can <= 5;
            gameover <= 0;
            
            for(i=0; i<tugla_sayisi; i=i+1)begin
                flag[i] <= 1;
            end
        end
        else begin
            skor_birler <= skor_birler_n;
            skor_onlar <= skor_onlar_n;
            kalan_can <= kalan_can_next;
            gameover <= gameover_next;
            
            for(i=0; i<tugla_sayisi; i=i+1)begin
                flag[i] <= flag_n[i];
            end
            
            y_pad_reg <= y_pad_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
            
            for(i=0; i<tugla_sayisi; i=i+1)begin
                brick_rgb[i] <= flag[i] ? 12'hBBB : 12'hFFF;
            end
            
        end
        
        
    // küre þekli vermek için read only mem
    wire [2:0] rom_addr, rom_col;   // 
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    // top þekli
    
    always @* begin
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    end
    
     
        
    
    // rgb atama için x-y konumu hangisine denk geliyor bunun statüsünü belirlemek için kullanacaðýmýz kablolar ve atamalar
    wire wall_on, pad_on, sq_ball_on, ball_on, gameover_on,
                                        brick_on, brick2_on, brick3_on, brick4_on, brick5_on, brick6_on,
                                        heart_on, heart_on2, heart_on3, heart_on4, heart_on5,
                                        brick7_on, brick8_on, brick9_on, brick10_on, brick11_on, brick12_on;
    wire [11:0] wall_rgb, pad_rgb, ball_rgb, bg_rgb;
    
    
    wire [4:0] row_2; assign row_2 = y - 16; 
    wire [3:0] col_2; assign col_2 = x - 282;
    reg [11:0] color_data2;
    assign heart_on=(x >= 266 && x < 282 && y >= 16 && y < 32 && kalan_can_next>0) ? 1:0;
    assign heart_on2=(x >= 282 && x < 298 && y >= 16 && y < 32&& kalan_can_next>1) ? 1:0;
    assign heart_on3=(x >= 298 && x < 314 && y >= 16 && y < 32&& kalan_can_next>2) ? 1:0;
    assign heart_on4=(x >= 314 && x < 330 && y >= 16 && y < 32&& kalan_can_next>3) ? 1:0;
    assign heart_on5=(x >= 330 && x < 346 && y >= 16 && y < 32&& kalan_can_next>4) ? 1:0;
    always @*
	case ({row_2, col_2})
		9'b000000000: color_data2 = 12'b011011011110;
		9'b000000001: color_data2 = 12'b011011011110;
		9'b000000010: color_data2 = 12'b011011011110;
		9'b000000011: color_data2 = 12'b011011011110;
		9'b000000100: color_data2 = 12'b011011011110;
		9'b000000101: color_data2 = 12'b011011011110;
		9'b000000110: color_data2 = 12'b011011011110;
		9'b000000111: color_data2 = 12'b011011011110;
		9'b000001000: color_data2 = 12'b011011011110;
		9'b000001001: color_data2 = 12'b011011011110;
		9'b000001010: color_data2 = 12'b011011011110;
		9'b000001011: color_data2 = 12'b011011011110;
		9'b000001100: color_data2 = 12'b011011011110;
		9'b000001101: color_data2 = 12'b011011011110;
		9'b000001110: color_data2 = 12'b011011011110;
		9'b000001111: color_data2 = 12'b011011011110;

		9'b000010000: color_data2 = 12'b011011011110;
		9'b000010001: color_data2 = 12'b011011011110;
		9'b000010010: color_data2 = 12'b011011011110;
		9'b000010011: color_data2 = 12'b011011011110;
		9'b000010100: color_data2 = 12'b011011011110;
		9'b000010101: color_data2 = 12'b011011011110;
		9'b000010110: color_data2 = 12'b011011011110;
		9'b000010111: color_data2 = 12'b011011011110;
		9'b000011000: color_data2 = 12'b011011011110;
		9'b000011001: color_data2 = 12'b011011011110;
		9'b000011010: color_data2 = 12'b011011011110;
		9'b000011011: color_data2 = 12'b011011011110;
		9'b000011100: color_data2 = 12'b011011011110;
		9'b000011101: color_data2 = 12'b011011011110;
		9'b000011110: color_data2 = 12'b011011011110;
		9'b000011111: color_data2 = 12'b011011011110;

		9'b000100000: color_data2 = 12'b011011011110;
		9'b000100001: color_data2 = 12'b011011011110;
		9'b000100010: color_data2 = 12'b011011011110;
		9'b000100011: color_data2 = 12'b111111111111;
		9'b000100100: color_data2 = 12'b111111111111;
		9'b000100101: color_data2 = 12'b111111111111;
		9'b000100110: color_data2 = 12'b011011011110;
		9'b000100111: color_data2 = 12'b011011011110;
		9'b000101000: color_data2 = 12'b011011011110;
		9'b000101001: color_data2 = 12'b011011011110;
		9'b000101010: color_data2 = 12'b111111111111;
		9'b000101011: color_data2 = 12'b111111111111;
		9'b000101100: color_data2 = 12'b111111111111;
		9'b000101101: color_data2 = 12'b011011011110;
		9'b000101110: color_data2 = 12'b011011011110;
		9'b000101111: color_data2 = 12'b011011011110;

		9'b000110000: color_data2 = 12'b011011011110;
		9'b000110001: color_data2 = 12'b011011011110;
		9'b000110010: color_data2 = 12'b111111111111;
		9'b000110011: color_data2 = 12'b000000000000;
		9'b000110100: color_data2 = 12'b000000000000;
		9'b000110101: color_data2 = 12'b000000000000;
		9'b000110110: color_data2 = 12'b111111111111;
		9'b000110111: color_data2 = 12'b011011011110;
		9'b000111000: color_data2 = 12'b011011011110;
		9'b000111001: color_data2 = 12'b111111111111;
		9'b000111010: color_data2 = 12'b000000000000;
		9'b000111011: color_data2 = 12'b000000000000;
		9'b000111100: color_data2 = 12'b000000000000;
		9'b000111101: color_data2 = 12'b111111111111;
		9'b000111110: color_data2 = 12'b011011011110;
		9'b000111111: color_data2 = 12'b011011011110;

		9'b001000000: color_data2 = 12'b011011011110;
		9'b001000001: color_data2 = 12'b111111111111;
		9'b001000010: color_data2 = 12'b000000000000;
		9'b001000011: color_data2 = 12'b111100000000;
		9'b001000100: color_data2 = 12'b111100000000;
		9'b001000101: color_data2 = 12'b111100000000;
		9'b001000110: color_data2 = 12'b000000000000;
		9'b001000111: color_data2 = 12'b111111111111;
		9'b001001000: color_data2 = 12'b111111111111;
		9'b001001001: color_data2 = 12'b000000000000;
		9'b001001010: color_data2 = 12'b111100000000;
		9'b001001011: color_data2 = 12'b111100000000;
		9'b001001100: color_data2 = 12'b111100000000;
		9'b001001101: color_data2 = 12'b000000000000;
		9'b001001110: color_data2 = 12'b111111111111;
		9'b001001111: color_data2 = 12'b011011011110;

		9'b001010000: color_data2 = 12'b011011011110;
		9'b001010001: color_data2 = 12'b111111111111;
		9'b001010010: color_data2 = 12'b000000000000;
		9'b001010011: color_data2 = 12'b111100000000;
		9'b001010100: color_data2 = 12'b111100000000;
		9'b001010101: color_data2 = 12'b111100000000;
		9'b001010110: color_data2 = 12'b111100000000;
		9'b001010111: color_data2 = 12'b000000000000;
		9'b001011000: color_data2 = 12'b000000000000;
		9'b001011001: color_data2 = 12'b111100000000;
		9'b001011010: color_data2 = 12'b111100000000;
		9'b001011011: color_data2 = 12'b111100000000;
		9'b001011100: color_data2 = 12'b111100000000;
		9'b001011101: color_data2 = 12'b000000000000;
		9'b001011110: color_data2 = 12'b111111111111;
		9'b001011111: color_data2 = 12'b011011011110;

		9'b001100000: color_data2 = 12'b011011011110;
		9'b001100001: color_data2 = 12'b111111111111;
		9'b001100010: color_data2 = 12'b000000000000;
		9'b001100011: color_data2 = 12'b111100000000;
		9'b001100100: color_data2 = 12'b111100000000;
		9'b001100101: color_data2 = 12'b111100000000;
		9'b001100110: color_data2 = 12'b111100000000;
		9'b001100111: color_data2 = 12'b111100000000;
		9'b001101000: color_data2 = 12'b111100000000;
		9'b001101001: color_data2 = 12'b111100000000;
		9'b001101010: color_data2 = 12'b111100000000;
		9'b001101011: color_data2 = 12'b111100000000;
		9'b001101100: color_data2 = 12'b111100000000;
		9'b001101101: color_data2 = 12'b000000000000;
		9'b001101110: color_data2 = 12'b111111111111;
		9'b001101111: color_data2 = 12'b011011011110;

		9'b001110000: color_data2 = 12'b011011011110;
		9'b001110001: color_data2 = 12'b111111111111;
		9'b001110010: color_data2 = 12'b000000000000;
		9'b001110011: color_data2 = 12'b111100000000;
		9'b001110100: color_data2 = 12'b111100000000;
		9'b001110101: color_data2 = 12'b111100000000;
		9'b001110110: color_data2 = 12'b111100000000;
		9'b001110111: color_data2 = 12'b111100000000;
		9'b001111000: color_data2 = 12'b111100000000;
		9'b001111001: color_data2 = 12'b111100000000;
		9'b001111010: color_data2 = 12'b111100000000;
		9'b001111011: color_data2 = 12'b111100000000;
		9'b001111100: color_data2 = 12'b111100000000;
		9'b001111101: color_data2 = 12'b000000000000;
		9'b001111110: color_data2 = 12'b111111111111;
		9'b001111111: color_data2 = 12'b011011011110;

		9'b010000000: color_data2 = 12'b011011011110;
		9'b010000001: color_data2 = 12'b011011011110;
		9'b010000010: color_data2 = 12'b111111111111;
		9'b010000011: color_data2 = 12'b000000000000;
		9'b010000100: color_data2 = 12'b111100000000;
		9'b010000101: color_data2 = 12'b111100000000;
		9'b010000110: color_data2 = 12'b111100000000;
		9'b010000111: color_data2 = 12'b111100000000;
		9'b010001000: color_data2 = 12'b111100000000;
		9'b010001001: color_data2 = 12'b111100000000;
		9'b010001010: color_data2 = 12'b111100000000;
		9'b010001011: color_data2 = 12'b111100000000;
		9'b010001100: color_data2 = 12'b000000000000;
		9'b010001101: color_data2 = 12'b111111111111;
		9'b010001110: color_data2 = 12'b011011011110;
		9'b010001111: color_data2 = 12'b011011011110;

		9'b010010000: color_data2 = 12'b011011011110;
		9'b010010001: color_data2 = 12'b011011011110;
		9'b010010010: color_data2 = 12'b011011011110;
		9'b010010011: color_data2 = 12'b111111111111;
		9'b010010100: color_data2 = 12'b000000000000;
		9'b010010101: color_data2 = 12'b111100000000;
		9'b010010110: color_data2 = 12'b111100000000;
		9'b010010111: color_data2 = 12'b111100000000;
		9'b010011000: color_data2 = 12'b111100000000;
		9'b010011001: color_data2 = 12'b111100000000;
		9'b010011010: color_data2 = 12'b111100000000;
		9'b010011011: color_data2 = 12'b000000000000;
		9'b010011100: color_data2 = 12'b111111111111;
		9'b010011101: color_data2 = 12'b011011011110;
		9'b010011110: color_data2 = 12'b011011011110;
		9'b010011111: color_data2 = 12'b011011011110;

		9'b010100000: color_data2 = 12'b011011011110;
		9'b010100001: color_data2 = 12'b011011011110;
		9'b010100010: color_data2 = 12'b011011011110;
		9'b010100011: color_data2 = 12'b011011011110;
		9'b010100100: color_data2 = 12'b111111111111;
		9'b010100101: color_data2 = 12'b000000000000;
		9'b010100110: color_data2 = 12'b111100000000;
		9'b010100111: color_data2 = 12'b111100000000;
		9'b010101000: color_data2 = 12'b111100000000;
		9'b010101001: color_data2 = 12'b111100000000;
		9'b010101010: color_data2 = 12'b000000000000;
		9'b010101011: color_data2 = 12'b111111111111;
		9'b010101100: color_data2 = 12'b011011011110;
		9'b010101101: color_data2 = 12'b011011011110;
		9'b010101110: color_data2 = 12'b011011011110;
		9'b010101111: color_data2 = 12'b011011011110;

		9'b010110000: color_data2 = 12'b011011011110;
		9'b010110001: color_data2 = 12'b011011011110;
		9'b010110010: color_data2 = 12'b011011011110;
		9'b010110011: color_data2 = 12'b011011011110;
		9'b010110100: color_data2 = 12'b011011011110;
		9'b010110101: color_data2 = 12'b111111111111;
		9'b010110110: color_data2 = 12'b000000000000;
		9'b010110111: color_data2 = 12'b111100000000;
		9'b010111000: color_data2 = 12'b111100000000;
		9'b010111001: color_data2 = 12'b000000000000;
		9'b010111010: color_data2 = 12'b111111111111;
		9'b010111011: color_data2 = 12'b011011011110;
		9'b010111100: color_data2 = 12'b011011011110;
		9'b010111101: color_data2 = 12'b011011011110;
		9'b010111110: color_data2 = 12'b011011011110;
		9'b010111111: color_data2 = 12'b011011011110;

		9'b011000000: color_data2 = 12'b011011011110;
		9'b011000001: color_data2 = 12'b011011011110;
		9'b011000010: color_data2 = 12'b011011011110;
		9'b011000011: color_data2 = 12'b011011011110;
		9'b011000100: color_data2 = 12'b011011011110;
		9'b011000101: color_data2 = 12'b011011011110;
		9'b011000110: color_data2 = 12'b111111111111;
		9'b011000111: color_data2 = 12'b000000000000;
		9'b011001000: color_data2 = 12'b000000000000;
		9'b011001001: color_data2 = 12'b111111111111;
		9'b011001010: color_data2 = 12'b011011011110;
		9'b011001011: color_data2 = 12'b011011011110;
		9'b011001100: color_data2 = 12'b011011011110;
		9'b011001101: color_data2 = 12'b011011011110;
		9'b011001110: color_data2 = 12'b011011011110;
		9'b011001111: color_data2 = 12'b011011011110;

		9'b011010000: color_data2 = 12'b011011011110;
		9'b011010001: color_data2 = 12'b011011011110;
		9'b011010010: color_data2 = 12'b011011011110;
		9'b011010011: color_data2 = 12'b011011011110;
		9'b011010100: color_data2 = 12'b011011011110;
		9'b011010101: color_data2 = 12'b011011011110;
		9'b011010110: color_data2 = 12'b011011011110;
		9'b011010111: color_data2 = 12'b111111111111;
		9'b011011000: color_data2 = 12'b111111111111;
		9'b011011001: color_data2 = 12'b011011011110;
		9'b011011010: color_data2 = 12'b011011011110;
		9'b011011011: color_data2 = 12'b011011011110;
		9'b011011100: color_data2 = 12'b011011011110;
		9'b011011101: color_data2 = 12'b011011011110;
		9'b011011110: color_data2 = 12'b011011011110;
		9'b011011111: color_data2 = 12'b011011011110;

		9'b011100000: color_data2 = 12'b011011011110;
		9'b011100001: color_data2 = 12'b011011011110;
		9'b011100010: color_data2 = 12'b011011011110;
		9'b011100011: color_data2 = 12'b011011011110;
		9'b011100100: color_data2 = 12'b011011011110;
		9'b011100101: color_data2 = 12'b011011011110;
		9'b011100110: color_data2 = 12'b011011011110;
		9'b011100111: color_data2 = 12'b011011011110;
		9'b011101000: color_data2 = 12'b011011011110;
		9'b011101001: color_data2 = 12'b011011011110;
		9'b011101010: color_data2 = 12'b011011011110;
		9'b011101011: color_data2 = 12'b011011011110;
		9'b011101100: color_data2 = 12'b011011011110;
		9'b011101101: color_data2 = 12'b011011011110;
		9'b011101110: color_data2 = 12'b011011011110;
		9'b011101111: color_data2 = 12'b011011011110;

		9'b011110000: color_data2 = 12'b011011011110;
		9'b011110001: color_data2 = 12'b011011011110;
		9'b011110010: color_data2 = 12'b011011011110;
		9'b011110011: color_data2 = 12'b011011011110;
		9'b011110100: color_data2 = 12'b011011011110;
		9'b011110101: color_data2 = 12'b011011011110;
		9'b011110110: color_data2 = 12'b011011011110;
		9'b011110111: color_data2 = 12'b011011011110;
		9'b011111000: color_data2 = 12'b011011011110;
		9'b011111001: color_data2 = 12'b011011011110;
		9'b011111010: color_data2 = 12'b011011011110;
		9'b011111011: color_data2 = 12'b011011011110;
		9'b011111100: color_data2 = 12'b011011011110;
		9'b011111101: color_data2 = 12'b011011011110;
		9'b011111110: color_data2 = 12'b011011011110;
		9'b011111111: color_data2 = 12'b011011011110;

		9'b100000000: color_data2 = 12'b011011011110;
		9'b100000001: color_data2 = 12'b011011011110;
		9'b100000010: color_data2 = 12'b011011011110;
		9'b100000011: color_data2 = 12'b011011011110;
		9'b100000100: color_data2 = 12'b011011011110;
		9'b100000101: color_data2 = 12'b011011011110;
		9'b100000110: color_data2 = 12'b011011011110;
		9'b100000111: color_data2 = 12'b011011011110;
		9'b100001000: color_data2 = 12'b011011011110;
		9'b100001001: color_data2 = 12'b011011011110;
		9'b100001010: color_data2 = 12'b011011011110;
		9'b100001011: color_data2 = 12'b011011011110;
		9'b100001100: color_data2 = 12'b011011011110;
		9'b100001101: color_data2 = 12'b011011011110;
		9'b100001110: color_data2 = 12'b011011011110;
		9'b100001111: color_data2 = 12'b011011011110;

		9'b100010000: color_data2 = 12'b011011011110;
		9'b100010001: color_data2 = 12'b011011011110;
		9'b100010010: color_data2 = 12'b011011011110;
		9'b100010011: color_data2 = 12'b011011011110;
		9'b100010100: color_data2 = 12'b011011011110;
		9'b100010101: color_data2 = 12'b011011011110;
		9'b100010110: color_data2 = 12'b011011011110;
		9'b100010111: color_data2 = 12'b011011011110;
		9'b100011000: color_data2 = 12'b011011011110;
		9'b100011001: color_data2 = 12'b011011011110;
		9'b100011010: color_data2 = 12'b011011011110;
		9'b100011011: color_data2 = 12'b011011011110;
		9'b100011100: color_data2 = 12'b011011011110;
		9'b100011101: color_data2 = 12'b011011011110;
		9'b100011110: color_data2 = 12'b011011011110;
		9'b100011111: color_data2 = 12'b011011011110;

		9'b100100000: color_data2 = 12'b011011011110;
		9'b100100001: color_data2 = 12'b011011011110;
		9'b100100010: color_data2 = 12'b011011011110;
		9'b100100011: color_data2 = 12'b111111111111;
		9'b100100100: color_data2 = 12'b111111111111;
		9'b100100101: color_data2 = 12'b111111111111;
		9'b100100110: color_data2 = 12'b011011011110;
		9'b100100111: color_data2 = 12'b011011011110;
		9'b100101000: color_data2 = 12'b011011011110;
		9'b100101001: color_data2 = 12'b011011011110;
		9'b100101010: color_data2 = 12'b111111111111;
		9'b100101011: color_data2 = 12'b111111111111;
		9'b100101100: color_data2 = 12'b111111111111;
		9'b100101101: color_data2 = 12'b011011011110;
		9'b100101110: color_data2 = 12'b011011011110;
		9'b100101111: color_data2 = 12'b011011011110;

		9'b100110000: color_data2 = 12'b011011011110;
		9'b100110001: color_data2 = 12'b011011011110;
		9'b100110010: color_data2 = 12'b111111111111;
		9'b100110011: color_data2 = 12'b000000000000;
		9'b100110100: color_data2 = 12'b000000000000;
		9'b100110101: color_data2 = 12'b000000000000;
		9'b100110110: color_data2 = 12'b111111111111;
		9'b100110111: color_data2 = 12'b011011011110;
		9'b100111000: color_data2 = 12'b011011011110;
		9'b100111001: color_data2 = 12'b111111111111;
		9'b100111010: color_data2 = 12'b000000000000;
		9'b100111011: color_data2 = 12'b000000000000;
		9'b100111100: color_data2 = 12'b000000000000;
		9'b100111101: color_data2 = 12'b111111111111;
		9'b100111110: color_data2 = 12'b011011011110;
		9'b100111111: color_data2 = 12'b011011011110;

		9'b101000000: color_data2 = 12'b011011011110;
		9'b101000001: color_data2 = 12'b111111111111;
		9'b101000010: color_data2 = 12'b000000000000;
		9'b101000011: color_data2 = 12'b000000000000;
		9'b101000100: color_data2 = 12'b000000000000;
		9'b101000101: color_data2 = 12'b000000000000;
		9'b101000110: color_data2 = 12'b000000000000;
		9'b101000111: color_data2 = 12'b111111111111;
		9'b101001000: color_data2 = 12'b111111111111;
		9'b101001001: color_data2 = 12'b000000000000;
		9'b101001010: color_data2 = 12'b000000000000;
		9'b101001011: color_data2 = 12'b000000000000;
		9'b101001100: color_data2 = 12'b000000000000;
		9'b101001101: color_data2 = 12'b000000000000;
		9'b101001110: color_data2 = 12'b111111111111;
		9'b101001111: color_data2 = 12'b011011011110;

		9'b101010000: color_data2 = 12'b011011011110;
		9'b101010001: color_data2 = 12'b111111111111;
		9'b101010010: color_data2 = 12'b000000000000;
		9'b101010011: color_data2 = 12'b000000000000;
		9'b101010100: color_data2 = 12'b000000000000;
		9'b101010101: color_data2 = 12'b000000000000;
		9'b101010110: color_data2 = 12'b000000000000;
		9'b101010111: color_data2 = 12'b000000000000;
		9'b101011000: color_data2 = 12'b000000000000;
		9'b101011001: color_data2 = 12'b000000000000;
		9'b101011010: color_data2 = 12'b000000000000;
		9'b101011011: color_data2 = 12'b000000000000;
		9'b101011100: color_data2 = 12'b000000000000;
		9'b101011101: color_data2 = 12'b000000000000;
		9'b101011110: color_data2 = 12'b111111111111;
		9'b101011111: color_data2 = 12'b011011011110;

		9'b101100000: color_data2 = 12'b011011011110;
		9'b101100001: color_data2 = 12'b111111111111;
		9'b101100010: color_data2 = 12'b000000000000;
		9'b101100011: color_data2 = 12'b000000000000;
		9'b101100100: color_data2 = 12'b000000000000;
		9'b101100101: color_data2 = 12'b000000000000;
		9'b101100110: color_data2 = 12'b000000000000;
		9'b101100111: color_data2 = 12'b000000000000;
		9'b101101000: color_data2 = 12'b000000000000;
		9'b101101001: color_data2 = 12'b000000000000;
		9'b101101010: color_data2 = 12'b000000000000;
		9'b101101011: color_data2 = 12'b000000000000;
		9'b101101100: color_data2 = 12'b000000000000;
		9'b101101101: color_data2 = 12'b000000000000;
		9'b101101110: color_data2 = 12'b111111111111;
		9'b101101111: color_data2 = 12'b011011011110;

		9'b101110000: color_data2 = 12'b011011011110;
		9'b101110001: color_data2 = 12'b111111111111;
		9'b101110010: color_data2 = 12'b000000000000;
		9'b101110011: color_data2 = 12'b000000000000;
		9'b101110100: color_data2 = 12'b000000000000;
		9'b101110101: color_data2 = 12'b000000000000;
		9'b101110110: color_data2 = 12'b000000000000;
		9'b101110111: color_data2 = 12'b000000000000;
		9'b101111000: color_data2 = 12'b000000000000;
		9'b101111001: color_data2 = 12'b000000000000;
		9'b101111010: color_data2 = 12'b000000000000;
		9'b101111011: color_data2 = 12'b000000000000;
		9'b101111100: color_data2 = 12'b000000000000;
		9'b101111101: color_data2 = 12'b000000000000;
		9'b101111110: color_data2 = 12'b111111111111;
		9'b101111111: color_data2 = 12'b011011011110;

		9'b110000000: color_data2 = 12'b011011011110;
		9'b110000001: color_data2 = 12'b011011011110;
		9'b110000010: color_data2 = 12'b111111111111;
		9'b110000011: color_data2 = 12'b000000000000;
		9'b110000100: color_data2 = 12'b000000000000;
		9'b110000101: color_data2 = 12'b000000000000;
		9'b110000110: color_data2 = 12'b000000000000;
		9'b110000111: color_data2 = 12'b000000000000;
		9'b110001000: color_data2 = 12'b000000000000;
		9'b110001001: color_data2 = 12'b000000000000;
		9'b110001010: color_data2 = 12'b000000000000;
		9'b110001011: color_data2 = 12'b000000000000;
		9'b110001100: color_data2 = 12'b000000000000;
		9'b110001101: color_data2 = 12'b111111111111;
		9'b110001110: color_data2 = 12'b011011011110;
		9'b110001111: color_data2 = 12'b011011011110;

		9'b110010000: color_data2 = 12'b011011011110;
		9'b110010001: color_data2 = 12'b011011011110;
		9'b110010010: color_data2 = 12'b011011011110;
		9'b110010011: color_data2 = 12'b111111111111;
		9'b110010100: color_data2 = 12'b000000000000;
		9'b110010101: color_data2 = 12'b000000000000;
		9'b110010110: color_data2 = 12'b000000000000;
		9'b110010111: color_data2 = 12'b000000000000;
		9'b110011000: color_data2 = 12'b000000000000;
		9'b110011001: color_data2 = 12'b000000000000;
		9'b110011010: color_data2 = 12'b000000000000;
		9'b110011011: color_data2 = 12'b000000000000;
		9'b110011100: color_data2 = 12'b111111111111;
		9'b110011101: color_data2 = 12'b011011011110;
		9'b110011110: color_data2 = 12'b011011011110;
		9'b110011111: color_data2 = 12'b011011011110;

		9'b110100000: color_data2 = 12'b011011011110;
		9'b110100001: color_data2 = 12'b011011011110;
		9'b110100010: color_data2 = 12'b011011011110;
		9'b110100011: color_data2 = 12'b011011011110;
		9'b110100100: color_data2 = 12'b111111111111;
		9'b110100101: color_data2 = 12'b000000000000;
		9'b110100110: color_data2 = 12'b000000000000;
		9'b110100111: color_data2 = 12'b000000000000;
		9'b110101000: color_data2 = 12'b000000000000;
		9'b110101001: color_data2 = 12'b000000000000;
		9'b110101010: color_data2 = 12'b000000000000;
		9'b110101011: color_data2 = 12'b111111111111;
		9'b110101100: color_data2 = 12'b011011011110;
		9'b110101101: color_data2 = 12'b011011011110;
		9'b110101110: color_data2 = 12'b011011011110;
		9'b110101111: color_data2 = 12'b011011011110;

		9'b110110000: color_data2 = 12'b011011011110;
		9'b110110001: color_data2 = 12'b011011011110;
		9'b110110010: color_data2 = 12'b011011011110;
		9'b110110011: color_data2 = 12'b011011011110;
		9'b110110100: color_data2 = 12'b011011011110;
		9'b110110101: color_data2 = 12'b111111111111;
		9'b110110110: color_data2 = 12'b000000000000;
		9'b110110111: color_data2 = 12'b000000000000;
		9'b110111000: color_data2 = 12'b000000000000;
		9'b110111001: color_data2 = 12'b000000000000;
		9'b110111010: color_data2 = 12'b111111111111;
		9'b110111011: color_data2 = 12'b011011011110;
		9'b110111100: color_data2 = 12'b011011011110;
		9'b110111101: color_data2 = 12'b011011011110;
		9'b110111110: color_data2 = 12'b011011011110;
		9'b110111111: color_data2 = 12'b011011011110;

		9'b111000000: color_data2 = 12'b011011011110;
		9'b111000001: color_data2 = 12'b011011011110;
		9'b111000010: color_data2 = 12'b011011011110;
		9'b111000011: color_data2 = 12'b011011011110;
		9'b111000100: color_data2 = 12'b011011011110;
		9'b111000101: color_data2 = 12'b011011011110;
		9'b111000110: color_data2 = 12'b111111111111;
		9'b111000111: color_data2 = 12'b000000000000;
		9'b111001000: color_data2 = 12'b000000000000;
		9'b111001001: color_data2 = 12'b111111111111;
		9'b111001010: color_data2 = 12'b011011011110;
		9'b111001011: color_data2 = 12'b011011011110;
		9'b111001100: color_data2 = 12'b011011011110;
		9'b111001101: color_data2 = 12'b011011011110;
		9'b111001110: color_data2 = 12'b011011011110;
		9'b111001111: color_data2 = 12'b011011011110;

		9'b111010000: color_data2 = 12'b011011011110;
		9'b111010001: color_data2 = 12'b011011011110;
		9'b111010010: color_data2 = 12'b011011011110;
		9'b111010011: color_data2 = 12'b011011011110;
		9'b111010100: color_data2 = 12'b011011011110;
		9'b111010101: color_data2 = 12'b011011011110;
		9'b111010110: color_data2 = 12'b011011011110;
		9'b111010111: color_data2 = 12'b111111111111;
		9'b111011000: color_data2 = 12'b111111111111;
		9'b111011001: color_data2 = 12'b011011011110;
		9'b111011010: color_data2 = 12'b011011011110;
		9'b111011011: color_data2 = 12'b011011011110;
		9'b111011100: color_data2 = 12'b011011011110;
		9'b111011101: color_data2 = 12'b011011011110;
		9'b111011110: color_data2 = 12'b011011011110;
		9'b111011111: color_data2 = 12'b011011011110;

		9'b111100000: color_data2 = 12'b011011011110;
		9'b111100001: color_data2 = 12'b011011011110;
		9'b111100010: color_data2 = 12'b011011011110;
		9'b111100011: color_data2 = 12'b011011011110;
		9'b111100100: color_data2 = 12'b011011011110;
		9'b111100101: color_data2 = 12'b011011011110;
		9'b111100110: color_data2 = 12'b011011011110;
		9'b111100111: color_data2 = 12'b011011011110;
		9'b111101000: color_data2 = 12'b011011011110;
		9'b111101001: color_data2 = 12'b011011011110;
		9'b111101010: color_data2 = 12'b011011011110;
		9'b111101011: color_data2 = 12'b011011011110;
		9'b111101100: color_data2 = 12'b011011011110;
		9'b111101101: color_data2 = 12'b011011011110;
		9'b111101110: color_data2 = 12'b011011011110;
		9'b111101111: color_data2 = 12'b011011011110;

		9'b111110000: color_data2 = 12'b011011011110;
		9'b111110001: color_data2 = 12'b011011011110;
		9'b111110010: color_data2 = 12'b011011011110;
		9'b111110011: color_data2 = 12'b011011011110;
		9'b111110100: color_data2 = 12'b011011011110;
		9'b111110101: color_data2 = 12'b011011011110;
		9'b111110110: color_data2 = 12'b011011011110;
		9'b111110111: color_data2 = 12'b011011011110;
		9'b111111000: color_data2 = 12'b011011011110;
		9'b111111001: color_data2 = 12'b011011011110;
		9'b111111010: color_data2 = 12'b011011011110;
		9'b111111011: color_data2 = 12'b011011011110;
		9'b111111100: color_data2 = 12'b011011011110;
		9'b111111101: color_data2 = 12'b011011011110;
		9'b111111110: color_data2 = 12'b011011011110;
		9'b111111111: color_data2 = 12'b011011011110;

		default: color_data2 = 12'b000000000000;
	endcase

    
    
    
    //gezilen koordinatlar nesne içinde mi? kontrolü
    assign brick_on = ((X_BRICK_L <= x) && (x <= X_BRICK_R) && (Y_BRICK_D <= y) && (y <= Y_BRICK_U)) ? 1 : 0;
    assign brick2_on = ((X_BRICK2_L <= x) && (x <= X_BRICK2_R) && (Y_BRICK2_D <= y) && (y <= Y_BRICK2_U)) ? 1 : 0;
    assign brick3_on = ((X_BRICK3_L <= x) && (x <= X_BRICK3_R) && (Y_BRICK3_D <= y) && (y <= Y_BRICK3_U)) ? 1 : 0;
    assign brick4_on = ((X_BRICK4_L <= x) && (x <= X_BRICK4_R) && (Y_BRICK4_D <= y) && (y <= Y_BRICK4_U)) ? 1 : 0;
    assign brick5_on = ((X_BRICK5_L <= x) && (x <= X_BRICK5_R) && (Y_BRICK5_D <= y) && (y <= Y_BRICK5_U)) ? 1 : 0;
    assign brick6_on = ((X_BRICK6_L <= x) && (x <= X_BRICK6_R) && (Y_BRICK6_D <= y) && (y <= Y_BRICK6_U)) ? 1 : 0;
    assign brick7_on = ((X_BRICK7_L <= x) && (x <= X_BRICK7_R) && (Y_BRICK7_D <= y) && (y <= Y_BRICK7_U)) ? 1 : 0;
    assign brick8_on = ((X_BRICK8_L <= x) && (x <= X_BRICK8_R) && (Y_BRICK8_D <= y) && (y <= Y_BRICK8_U)) ? 1 : 0;
    assign brick9_on = ((X_BRICK9_L <= x) && (x <= X_BRICK9_R) && (Y_BRICK9_D <= y) && (y <= Y_BRICK9_U)) ? 1 : 0;
    assign brick10_on = ((X_BRICK10_L <= x) && (x <= X_BRICK10_R) && (Y_BRICK10_D <= y) && (y <= Y_BRICK10_U)) ? 1 : 0;
    assign brick11_on = ((X_BRICK11_L <= x) && (x <= X_BRICK11_R) && (Y_BRICK11_D <= y) && (y <= Y_BRICK11_U)) ? 1 : 0;
    assign brick12_on = ((X_BRICK12_L <= x) && (x <= X_BRICK12_R) && (Y_BRICK12_D <= y) && (y <= Y_BRICK12_U)) ? 1 : 0;
    
    // pixel within wall boundaries
    assign wall_on = ((X_WALL_L <= x) && (x <= X_WALL_R)) ? 1 : 0;
    
    
    
    // kaybetme durumu için kablolar
    
    assign gameover_on = (x >= 282 && x < 360 && y >= 72 && y < 86 && gameover_next) ? 1 : 0;
    wire [3:0] row_reg; assign row_reg = y - 72; 
    wire [6:0] col_reg; assign col_reg = x - 282;
    reg [11:0] color_data;
    
    always @*
	case ({row_reg, col_reg})
		11'b00000000000: color_data = 12'b011011011110;
		11'b00000000001: color_data = 12'b111111000000;
		11'b00000000010: color_data = 12'b111111000000;
		11'b00000000011: color_data = 12'b111111000000;
		11'b00000000100: color_data = 12'b111111000000;
		11'b00000000101: color_data = 12'b011011011110;
		11'b00000000110: color_data = 12'b011011011110;
		11'b00000000111: color_data = 12'b011011011110;
		11'b00000001000: color_data = 12'b011011011110;
		11'b00000001001: color_data = 12'b111111000000;
		11'b00000001010: color_data = 12'b111111000000;
		11'b00000001011: color_data = 12'b111111000000;
		11'b00000001100: color_data = 12'b111111000000;
		11'b00000001101: color_data = 12'b011011011110;
		11'b00000001110: color_data = 12'b011011011110;
		11'b00000001111: color_data = 12'b011011011110;
		11'b00000010000: color_data = 12'b111111000000;
		11'b00000010001: color_data = 12'b111111000000;
		11'b00000010010: color_data = 12'b011011011110;
		11'b00000010011: color_data = 12'b011011011110;
		11'b00000010100: color_data = 12'b011011011110;
		11'b00000010101: color_data = 12'b011011011110;
		11'b00000010110: color_data = 12'b011011011110;
		11'b00000010111: color_data = 12'b111111000000;
		11'b00000011000: color_data = 12'b111111000000;
		11'b00000011001: color_data = 12'b011011011110;
		11'b00000011010: color_data = 12'b111111000000;
		11'b00000011011: color_data = 12'b111111000000;
		11'b00000011100: color_data = 12'b111111000000;
		11'b00000011101: color_data = 12'b111111000000;
		11'b00000011110: color_data = 12'b111111000000;
		11'b00000011111: color_data = 12'b111111000000;
		11'b00000100000: color_data = 12'b011011011110;
		11'b00000100001: color_data = 12'b011011011110;
		11'b00000100010: color_data = 12'b011011011110;
		11'b00000100011: color_data = 12'b011011011110;
		11'b00000100100: color_data = 12'b011011011110;
		11'b00000100101: color_data = 12'b011011011110;
		11'b00000100110: color_data = 12'b011011011110;
		11'b00000100111: color_data = 12'b011011011110;
		11'b00000101000: color_data = 12'b011011011110;
		11'b00000101001: color_data = 12'b011011011110;
		11'b00000101010: color_data = 12'b011011011110;
		11'b00000101011: color_data = 12'b011011011110;
		11'b00000101100: color_data = 12'b011011011110;
		11'b00000101101: color_data = 12'b011011011110;
		11'b00000101110: color_data = 12'b011011011110;
		11'b00000101111: color_data = 12'b011011011110;
		11'b00000110000: color_data = 12'b011011011110;
		11'b00000110001: color_data = 12'b111111000000;
		11'b00000110010: color_data = 12'b111111000000;
		11'b00000110011: color_data = 12'b111111000000;
		11'b00000110100: color_data = 12'b111111000000;
		11'b00000110101: color_data = 12'b011011011110;
		11'b00000110110: color_data = 12'b011011011110;
		11'b00000110111: color_data = 12'b011011011110;
		11'b00000111000: color_data = 12'b111111000000;
		11'b00000111001: color_data = 12'b111111000000;
		11'b00000111010: color_data = 12'b011011011110;
		11'b00000111011: color_data = 12'b011011011110;
		11'b00000111100: color_data = 12'b111111000000;
		11'b00000111101: color_data = 12'b111111000000;
		11'b00000111110: color_data = 12'b011011011110;
		11'b00000111111: color_data = 12'b011011011110;
		11'b00001000000: color_data = 12'b111111000000;
		11'b00001000001: color_data = 12'b111111000000;
		11'b00001000010: color_data = 12'b111111000000;
		11'b00001000011: color_data = 12'b111111000000;
		11'b00001000100: color_data = 12'b111111000000;
		11'b00001000101: color_data = 12'b111111000000;
		11'b00001000110: color_data = 12'b011011011110;
		11'b00001000111: color_data = 12'b111111000000;
		11'b00001001000: color_data = 12'b111111000000;
		11'b00001001001: color_data = 12'b111111000000;
		11'b00001001010: color_data = 12'b111111000000;
		11'b00001001011: color_data = 12'b111111000000;
		11'b00001001100: color_data = 12'b111111000000;
		11'b00001001101: color_data = 12'b011011011110;

		11'b00010000000: color_data = 12'b111111000000;
		11'b00010000001: color_data = 12'b111111000000;
		11'b00010000010: color_data = 12'b111111000000;
		11'b00010000011: color_data = 12'b111111000000;
		11'b00010000100: color_data = 12'b111111000000;
		11'b00010000101: color_data = 12'b111111000000;
		11'b00010000110: color_data = 12'b011011011110;
		11'b00010000111: color_data = 12'b011011011110;
		11'b00010001000: color_data = 12'b111111000000;
		11'b00010001001: color_data = 12'b111111000000;
		11'b00010001010: color_data = 12'b111111000000;
		11'b00010001011: color_data = 12'b111111000000;
		11'b00010001100: color_data = 12'b111111000000;
		11'b00010001101: color_data = 12'b111111000000;
		11'b00010001110: color_data = 12'b011011011110;
		11'b00010001111: color_data = 12'b011011011110;
		11'b00010010000: color_data = 12'b111111000000;
		11'b00010010001: color_data = 12'b111111000000;
		11'b00010010010: color_data = 12'b111111000000;
		11'b00010010011: color_data = 12'b011011011110;
		11'b00010010100: color_data = 12'b011011011110;
		11'b00010010101: color_data = 12'b011011011110;
		11'b00010010110: color_data = 12'b111111000000;
		11'b00010010111: color_data = 12'b111111000000;
		11'b00010011000: color_data = 12'b111111000000;
		11'b00010011001: color_data = 12'b011011011110;
		11'b00010011010: color_data = 12'b111111000000;
		11'b00010011011: color_data = 12'b111111000000;
		11'b00010011100: color_data = 12'b111111000000;
		11'b00010011101: color_data = 12'b111111000000;
		11'b00010011110: color_data = 12'b111111000000;
		11'b00010011111: color_data = 12'b111111000000;
		11'b00010100000: color_data = 12'b011011011110;
		11'b00010100001: color_data = 12'b011011011110;
		11'b00010100010: color_data = 12'b011011011110;
		11'b00010100011: color_data = 12'b011011011110;
		11'b00010100100: color_data = 12'b011011011110;
		11'b00010100101: color_data = 12'b011011011110;
		11'b00010100110: color_data = 12'b011011011110;
		11'b00010100111: color_data = 12'b011011011110;
		11'b00010101000: color_data = 12'b011011011110;
		11'b00010101001: color_data = 12'b011011011110;
		11'b00010101010: color_data = 12'b011011011110;
		11'b00010101011: color_data = 12'b011011011110;
		11'b00010101100: color_data = 12'b011011011110;
		11'b00010101101: color_data = 12'b011011011110;
		11'b00010101110: color_data = 12'b011011011110;
		11'b00010101111: color_data = 12'b011011011110;
		11'b00010110000: color_data = 12'b111111000000;
		11'b00010110001: color_data = 12'b111111000000;
		11'b00010110010: color_data = 12'b111111000000;
		11'b00010110011: color_data = 12'b111111000000;
		11'b00010110100: color_data = 12'b111111000000;
		11'b00010110101: color_data = 12'b111111000000;
		11'b00010110110: color_data = 12'b011011011110;
		11'b00010110111: color_data = 12'b011011011110;
		11'b00010111000: color_data = 12'b111111000000;
		11'b00010111001: color_data = 12'b111111000000;
		11'b00010111010: color_data = 12'b011011011110;
		11'b00010111011: color_data = 12'b011011011110;
		11'b00010111100: color_data = 12'b111111000000;
		11'b00010111101: color_data = 12'b111111000000;
		11'b00010111110: color_data = 12'b011011011110;
		11'b00010111111: color_data = 12'b011011011110;
		11'b00011000000: color_data = 12'b111111000000;
		11'b00011000001: color_data = 12'b111111000000;
		11'b00011000010: color_data = 12'b111111000000;
		11'b00011000011: color_data = 12'b111111000000;
		11'b00011000100: color_data = 12'b111111000000;
		11'b00011000101: color_data = 12'b111111000000;
		11'b00011000110: color_data = 12'b011011011110;
		11'b00011000111: color_data = 12'b111111000000;
		11'b00011001000: color_data = 12'b111111000000;
		11'b00011001001: color_data = 12'b111111000000;
		11'b00011001010: color_data = 12'b111111000000;
		11'b00011001011: color_data = 12'b111111000000;
		11'b00011001100: color_data = 12'b111111000000;
		11'b00011001101: color_data = 12'b111111000000;

		11'b00100000000: color_data = 12'b111111000000;
		11'b00100000001: color_data = 12'b111111000000;
		11'b00100000010: color_data = 12'b011011011110;
		11'b00100000011: color_data = 12'b011011011110;
		11'b00100000100: color_data = 12'b111111000000;
		11'b00100000101: color_data = 12'b111111000000;
		11'b00100000110: color_data = 12'b011011011110;
		11'b00100000111: color_data = 12'b011011011110;
		11'b00100001000: color_data = 12'b111111000000;
		11'b00100001001: color_data = 12'b111111000000;
		11'b00100001010: color_data = 12'b011011011110;
		11'b00100001011: color_data = 12'b011011011110;
		11'b00100001100: color_data = 12'b111111000000;
		11'b00100001101: color_data = 12'b111111000000;
		11'b00100001110: color_data = 12'b011011011110;
		11'b00100001111: color_data = 12'b011011011110;
		11'b00100010000: color_data = 12'b111111000000;
		11'b00100010001: color_data = 12'b111111000000;
		11'b00100010010: color_data = 12'b111111000000;
		11'b00100010011: color_data = 12'b011011011110;
		11'b00100010100: color_data = 12'b011011011110;
		11'b00100010101: color_data = 12'b011011011110;
		11'b00100010110: color_data = 12'b111111000000;
		11'b00100010111: color_data = 12'b111111000000;
		11'b00100011000: color_data = 12'b111111000000;
		11'b00100011001: color_data = 12'b011011011110;
		11'b00100011010: color_data = 12'b111111000000;
		11'b00100011011: color_data = 12'b111111000000;
		11'b00100011100: color_data = 12'b011011011110;
		11'b00100011101: color_data = 12'b011011011110;
		11'b00100011110: color_data = 12'b011011011110;
		11'b00100011111: color_data = 12'b011011011110;
		11'b00100100000: color_data = 12'b011011011110;
		11'b00100100001: color_data = 12'b011011011110;
		11'b00100100010: color_data = 12'b011011011110;
		11'b00100100011: color_data = 12'b011011011110;
		11'b00100100100: color_data = 12'b011011011110;
		11'b00100100101: color_data = 12'b011011011110;
		11'b00100100110: color_data = 12'b011011011110;
		11'b00100100111: color_data = 12'b011011011110;
		11'b00100101000: color_data = 12'b011011011110;
		11'b00100101001: color_data = 12'b011011011110;
		11'b00100101010: color_data = 12'b011011011110;
		11'b00100101011: color_data = 12'b011011011110;
		11'b00100101100: color_data = 12'b011011011110;
		11'b00100101101: color_data = 12'b011011011110;
		11'b00100101110: color_data = 12'b011011011110;
		11'b00100101111: color_data = 12'b011011011110;
		11'b00100110000: color_data = 12'b111111000000;
		11'b00100110001: color_data = 12'b111111000000;
		11'b00100110010: color_data = 12'b011011011110;
		11'b00100110011: color_data = 12'b011011011110;
		11'b00100110100: color_data = 12'b111111000000;
		11'b00100110101: color_data = 12'b111111000000;
		11'b00100110110: color_data = 12'b011011011110;
		11'b00100110111: color_data = 12'b011011011110;
		11'b00100111000: color_data = 12'b111111000000;
		11'b00100111001: color_data = 12'b111111000000;
		11'b00100111010: color_data = 12'b011011011110;
		11'b00100111011: color_data = 12'b011011011110;
		11'b00100111100: color_data = 12'b111111000000;
		11'b00100111101: color_data = 12'b111111000000;
		11'b00100111110: color_data = 12'b011011011110;
		11'b00100111111: color_data = 12'b011011011110;
		11'b00101000000: color_data = 12'b111111000000;
		11'b00101000001: color_data = 12'b111111000000;
		11'b00101000010: color_data = 12'b011011011110;
		11'b00101000011: color_data = 12'b011011011110;
		11'b00101000100: color_data = 12'b011011011110;
		11'b00101000101: color_data = 12'b011011011110;
		11'b00101000110: color_data = 12'b011011011110;
		11'b00101000111: color_data = 12'b111111000000;
		11'b00101001000: color_data = 12'b111111000000;
		11'b00101001001: color_data = 12'b011011011110;
		11'b00101001010: color_data = 12'b011011011110;
		11'b00101001011: color_data = 12'b011011011110;
		11'b00101001100: color_data = 12'b111111000000;
		11'b00101001101: color_data = 12'b111111000000;

		11'b00110000000: color_data = 12'b111111110000;
		11'b00110000001: color_data = 12'b111111110000;
		11'b00110000010: color_data = 12'b011011011110;
		11'b00110000011: color_data = 12'b011011011110;
		11'b00110000100: color_data = 12'b111111110000;
		11'b00110000101: color_data = 12'b111111110000;
		11'b00110000110: color_data = 12'b011011011110;
		11'b00110000111: color_data = 12'b011011011110;
		11'b00110001000: color_data = 12'b111111110000;
		11'b00110001001: color_data = 12'b111111110000;
		11'b00110001010: color_data = 12'b011011011110;
		11'b00110001011: color_data = 12'b011011011110;
		11'b00110001100: color_data = 12'b111111110000;
		11'b00110001101: color_data = 12'b111111110000;
		11'b00110001110: color_data = 12'b011011011110;
		11'b00110001111: color_data = 12'b011011011110;
		11'b00110010000: color_data = 12'b111111110000;
		11'b00110010001: color_data = 12'b111111110000;
		11'b00110010010: color_data = 12'b111111110000;
		11'b00110010011: color_data = 12'b011011011110;
		11'b00110010100: color_data = 12'b011011011110;
		11'b00110010101: color_data = 12'b011011011110;
		11'b00110010110: color_data = 12'b111111110000;
		11'b00110010111: color_data = 12'b111111110000;
		11'b00110011000: color_data = 12'b111111110000;
		11'b00110011001: color_data = 12'b011011011110;
		11'b00110011010: color_data = 12'b111111110000;
		11'b00110011011: color_data = 12'b111111110000;
		11'b00110011100: color_data = 12'b011011011110;
		11'b00110011101: color_data = 12'b011011011110;
		11'b00110011110: color_data = 12'b011011011110;
		11'b00110011111: color_data = 12'b011011011110;
		11'b00110100000: color_data = 12'b011011011110;
		11'b00110100001: color_data = 12'b011011011110;
		11'b00110100010: color_data = 12'b011011011110;
		11'b00110100011: color_data = 12'b011011011110;
		11'b00110100100: color_data = 12'b011011011110;
		11'b00110100101: color_data = 12'b011011011110;
		11'b00110100110: color_data = 12'b011011011110;
		11'b00110100111: color_data = 12'b011011011110;
		11'b00110101000: color_data = 12'b011011011110;
		11'b00110101001: color_data = 12'b011011011110;
		11'b00110101010: color_data = 12'b011011011110;
		11'b00110101011: color_data = 12'b011011011110;
		11'b00110101100: color_data = 12'b011011011110;
		11'b00110101101: color_data = 12'b011011011110;
		11'b00110101110: color_data = 12'b011011011110;
		11'b00110101111: color_data = 12'b011011011110;
		11'b00110110000: color_data = 12'b111111110000;
		11'b00110110001: color_data = 12'b111111110000;
		11'b00110110010: color_data = 12'b011011011110;
		11'b00110110011: color_data = 12'b011011011110;
		11'b00110110100: color_data = 12'b111111110000;
		11'b00110110101: color_data = 12'b111111110000;
		11'b00110110110: color_data = 12'b011011011110;
		11'b00110110111: color_data = 12'b011011011110;
		11'b00110111000: color_data = 12'b111111110000;
		11'b00110111001: color_data = 12'b111111110000;
		11'b00110111010: color_data = 12'b011011011110;
		11'b00110111011: color_data = 12'b011011011110;
		11'b00110111100: color_data = 12'b111111110000;
		11'b00110111101: color_data = 12'b111111110000;
		11'b00110111110: color_data = 12'b011011011110;
		11'b00110111111: color_data = 12'b011011011110;
		11'b00111000000: color_data = 12'b111111110000;
		11'b00111000001: color_data = 12'b111111110000;
		11'b00111000010: color_data = 12'b011011011110;
		11'b00111000011: color_data = 12'b011011011110;
		11'b00111000100: color_data = 12'b011011011110;
		11'b00111000101: color_data = 12'b011011011110;
		11'b00111000110: color_data = 12'b011011011110;
		11'b00111000111: color_data = 12'b111111110000;
		11'b00111001000: color_data = 12'b111111110000;
		11'b00111001001: color_data = 12'b011011011110;
		11'b00111001010: color_data = 12'b011011011110;
		11'b00111001011: color_data = 12'b011011011110;
		11'b00111001100: color_data = 12'b111111110000;
		11'b00111001101: color_data = 12'b111111110000;

		11'b01000000000: color_data = 12'b111111110000;
		11'b01000000001: color_data = 12'b111111110000;
		11'b01000000010: color_data = 12'b011011011110;
		11'b01000000011: color_data = 12'b011011011110;
		11'b01000000100: color_data = 12'b111111110000;
		11'b01000000101: color_data = 12'b111111110000;
		11'b01000000110: color_data = 12'b011011011110;
		11'b01000000111: color_data = 12'b011011011110;
		11'b01000001000: color_data = 12'b111111110000;
		11'b01000001001: color_data = 12'b111111110000;
		11'b01000001010: color_data = 12'b011011011110;
		11'b01000001011: color_data = 12'b011011011110;
		11'b01000001100: color_data = 12'b111111110000;
		11'b01000001101: color_data = 12'b111111110000;
		11'b01000001110: color_data = 12'b011011011110;
		11'b01000001111: color_data = 12'b011011011110;
		11'b01000010000: color_data = 12'b111111110000;
		11'b01000010001: color_data = 12'b111111110000;
		11'b01000010010: color_data = 12'b111111110000;
		11'b01000010011: color_data = 12'b111111110000;
		11'b01000010100: color_data = 12'b011011011110;
		11'b01000010101: color_data = 12'b111111110000;
		11'b01000010110: color_data = 12'b111111110000;
		11'b01000010111: color_data = 12'b111111110000;
		11'b01000011000: color_data = 12'b111111110000;
		11'b01000011001: color_data = 12'b011011011110;
		11'b01000011010: color_data = 12'b111111110000;
		11'b01000011011: color_data = 12'b111111110000;
		11'b01000011100: color_data = 12'b011011011110;
		11'b01000011101: color_data = 12'b011011011110;
		11'b01000011110: color_data = 12'b011011011110;
		11'b01000011111: color_data = 12'b011011011110;
		11'b01000100000: color_data = 12'b011011011110;
		11'b01000100001: color_data = 12'b011011011110;
		11'b01000100010: color_data = 12'b011011011110;
		11'b01000100011: color_data = 12'b011011011110;
		11'b01000100100: color_data = 12'b011011011110;
		11'b01000100101: color_data = 12'b011011011110;
		11'b01000100110: color_data = 12'b011011011110;
		11'b01000100111: color_data = 12'b011011011110;
		11'b01000101000: color_data = 12'b011011011110;
		11'b01000101001: color_data = 12'b011011011110;
		11'b01000101010: color_data = 12'b011011011110;
		11'b01000101011: color_data = 12'b011011011110;
		11'b01000101100: color_data = 12'b011011011110;
		11'b01000101101: color_data = 12'b011011011110;
		11'b01000101110: color_data = 12'b011011011110;
		11'b01000101111: color_data = 12'b011011011110;
		11'b01000110000: color_data = 12'b111111110000;
		11'b01000110001: color_data = 12'b111111110000;
		11'b01000110010: color_data = 12'b011011011110;
		11'b01000110011: color_data = 12'b011011011110;
		11'b01000110100: color_data = 12'b111111110000;
		11'b01000110101: color_data = 12'b111111110000;
		11'b01000110110: color_data = 12'b011011011110;
		11'b01000110111: color_data = 12'b011011011110;
		11'b01000111000: color_data = 12'b111111110000;
		11'b01000111001: color_data = 12'b111111110000;
		11'b01000111010: color_data = 12'b011011011110;
		11'b01000111011: color_data = 12'b011011011110;
		11'b01000111100: color_data = 12'b111111110000;
		11'b01000111101: color_data = 12'b111111110000;
		11'b01000111110: color_data = 12'b011011011110;
		11'b01000111111: color_data = 12'b011011011110;
		11'b01001000000: color_data = 12'b111111110000;
		11'b01001000001: color_data = 12'b111111110000;
		11'b01001000010: color_data = 12'b011011011110;
		11'b01001000011: color_data = 12'b011011011110;
		11'b01001000100: color_data = 12'b011011011110;
		11'b01001000101: color_data = 12'b011011011110;
		11'b01001000110: color_data = 12'b011011011110;
		11'b01001000111: color_data = 12'b111111110000;
		11'b01001001000: color_data = 12'b111111110000;
		11'b01001001001: color_data = 12'b011011011110;
		11'b01001001010: color_data = 12'b011011011110;
		11'b01001001011: color_data = 12'b011011011110;
		11'b01001001100: color_data = 12'b111111110000;
		11'b01001001101: color_data = 12'b111111110000;

		11'b01010000000: color_data = 12'b111111110000;
		11'b01010000001: color_data = 12'b111111110000;
		11'b01010000010: color_data = 12'b011011011110;
		11'b01010000011: color_data = 12'b011011011110;
		11'b01010000100: color_data = 12'b011011011110;
		11'b01010000101: color_data = 12'b011011011110;
		11'b01010000110: color_data = 12'b011011011110;
		11'b01010000111: color_data = 12'b011011011110;
		11'b01010001000: color_data = 12'b111111110000;
		11'b01010001001: color_data = 12'b111111110000;
		11'b01010001010: color_data = 12'b011011011110;
		11'b01010001011: color_data = 12'b011011011110;
		11'b01010001100: color_data = 12'b111111110000;
		11'b01010001101: color_data = 12'b111111110000;
		11'b01010001110: color_data = 12'b011011011110;
		11'b01010001111: color_data = 12'b011011011110;
		11'b01010010000: color_data = 12'b111111110000;
		11'b01010010001: color_data = 12'b111111110000;
		11'b01010010010: color_data = 12'b111111110000;
		11'b01010010011: color_data = 12'b111111110000;
		11'b01010010100: color_data = 12'b011011011110;
		11'b01010010101: color_data = 12'b111111110000;
		11'b01010010110: color_data = 12'b111111110000;
		11'b01010010111: color_data = 12'b111111110000;
		11'b01010011000: color_data = 12'b111111110000;
		11'b01010011001: color_data = 12'b011011011110;
		11'b01010011010: color_data = 12'b111111110000;
		11'b01010011011: color_data = 12'b111111110000;
		11'b01010011100: color_data = 12'b011011011110;
		11'b01010011101: color_data = 12'b011011011110;
		11'b01010011110: color_data = 12'b011011011110;
		11'b01010011111: color_data = 12'b011011011110;
		11'b01010100000: color_data = 12'b011011011110;
		11'b01010100001: color_data = 12'b011011011110;
		11'b01010100010: color_data = 12'b011011011110;
		11'b01010100011: color_data = 12'b011011011110;
		11'b01010100100: color_data = 12'b011011011110;
		11'b01010100101: color_data = 12'b011011011110;
		11'b01010100110: color_data = 12'b011011011110;
		11'b01010100111: color_data = 12'b011011011110;
		11'b01010101000: color_data = 12'b011011011110;
		11'b01010101001: color_data = 12'b011011011110;
		11'b01010101010: color_data = 12'b011011011110;
		11'b01010101011: color_data = 12'b011011011110;
		11'b01010101100: color_data = 12'b011011011110;
		11'b01010101101: color_data = 12'b011011011110;
		11'b01010101110: color_data = 12'b011011011110;
		11'b01010101111: color_data = 12'b011011011110;
		11'b01010110000: color_data = 12'b111111110000;
		11'b01010110001: color_data = 12'b111111110000;
		11'b01010110010: color_data = 12'b011011011110;
		11'b01010110011: color_data = 12'b011011011110;
		11'b01010110100: color_data = 12'b111111110000;
		11'b01010110101: color_data = 12'b111111110000;
		11'b01010110110: color_data = 12'b011011011110;
		11'b01010110111: color_data = 12'b011011011110;
		11'b01010111000: color_data = 12'b111111110000;
		11'b01010111001: color_data = 12'b111111110000;
		11'b01010111010: color_data = 12'b011011011110;
		11'b01010111011: color_data = 12'b011011011110;
		11'b01010111100: color_data = 12'b111111110000;
		11'b01010111101: color_data = 12'b111111110000;
		11'b01010111110: color_data = 12'b011011011110;
		11'b01010111111: color_data = 12'b011011011110;
		11'b01011000000: color_data = 12'b111111110000;
		11'b01011000001: color_data = 12'b111111110000;
		11'b01011000010: color_data = 12'b011011011110;
		11'b01011000011: color_data = 12'b011011011110;
		11'b01011000100: color_data = 12'b011011011110;
		11'b01011000101: color_data = 12'b011011011110;
		11'b01011000110: color_data = 12'b011011011110;
		11'b01011000111: color_data = 12'b111111110000;
		11'b01011001000: color_data = 12'b111111110000;
		11'b01011001001: color_data = 12'b011011011110;
		11'b01011001010: color_data = 12'b011011011110;
		11'b01011001011: color_data = 12'b111111110000;
		11'b01011001100: color_data = 12'b111111110000;
		11'b01011001101: color_data = 12'b111111110000;

		11'b01100000000: color_data = 12'b111111111111;
		11'b01100000001: color_data = 12'b111111111111;
		11'b01100000010: color_data = 12'b011011011110;
		11'b01100000011: color_data = 12'b011011011110;
		11'b01100000100: color_data = 12'b011011011110;
		11'b01100000101: color_data = 12'b011011011110;
		11'b01100000110: color_data = 12'b011011011110;
		11'b01100000111: color_data = 12'b011011011110;
		11'b01100001000: color_data = 12'b111111111111;
		11'b01100001001: color_data = 12'b111111111111;
		11'b01100001010: color_data = 12'b011011011110;
		11'b01100001011: color_data = 12'b011011011110;
		11'b01100001100: color_data = 12'b111111111111;
		11'b01100001101: color_data = 12'b111111111111;
		11'b01100001110: color_data = 12'b011011011110;
		11'b01100001111: color_data = 12'b011011011110;
		11'b01100010000: color_data = 12'b111111111111;
		11'b01100010001: color_data = 12'b111111111111;
		11'b01100010010: color_data = 12'b011011011110;
		11'b01100010011: color_data = 12'b111111111111;
		11'b01100010100: color_data = 12'b111111111111;
		11'b01100010101: color_data = 12'b111111111111;
		11'b01100010110: color_data = 12'b011011011110;
		11'b01100010111: color_data = 12'b111111111111;
		11'b01100011000: color_data = 12'b111111111111;
		11'b01100011001: color_data = 12'b011011011110;
		11'b01100011010: color_data = 12'b111111111111;
		11'b01100011011: color_data = 12'b111111111111;
		11'b01100011100: color_data = 12'b111111111111;
		11'b01100011101: color_data = 12'b111111111111;
		11'b01100011110: color_data = 12'b111111111111;
		11'b01100011111: color_data = 12'b111111111111;
		11'b01100100000: color_data = 12'b011011011110;
		11'b01100100001: color_data = 12'b011011011110;
		11'b01100100010: color_data = 12'b011011011110;
		11'b01100100011: color_data = 12'b011011011110;
		11'b01100100100: color_data = 12'b011011011110;
		11'b01100100101: color_data = 12'b011011011110;
		11'b01100100110: color_data = 12'b011011011110;
		11'b01100100111: color_data = 12'b011011011110;
		11'b01100101000: color_data = 12'b011011011110;
		11'b01100101001: color_data = 12'b011011011110;
		11'b01100101010: color_data = 12'b011011011110;
		11'b01100101011: color_data = 12'b011011011110;
		11'b01100101100: color_data = 12'b011011011110;
		11'b01100101101: color_data = 12'b011011011110;
		11'b01100101110: color_data = 12'b011011011110;
		11'b01100101111: color_data = 12'b011011011110;
		11'b01100110000: color_data = 12'b111111111111;
		11'b01100110001: color_data = 12'b111111111111;
		11'b01100110010: color_data = 12'b011011011110;
		11'b01100110011: color_data = 12'b011011011110;
		11'b01100110100: color_data = 12'b111111111111;
		11'b01100110101: color_data = 12'b111111111111;
		11'b01100110110: color_data = 12'b011011011110;
		11'b01100110111: color_data = 12'b011011011110;
		11'b01100111000: color_data = 12'b111111111111;
		11'b01100111001: color_data = 12'b111111111111;
		11'b01100111010: color_data = 12'b011011011110;
		11'b01100111011: color_data = 12'b011011011110;
		11'b01100111100: color_data = 12'b111111111111;
		11'b01100111101: color_data = 12'b111111111111;
		11'b01100111110: color_data = 12'b011011011110;
		11'b01100111111: color_data = 12'b011011011110;
		11'b01101000000: color_data = 12'b111111111111;
		11'b01101000001: color_data = 12'b111111111111;
		11'b01101000010: color_data = 12'b111111111111;
		11'b01101000011: color_data = 12'b111111111111;
		11'b01101000100: color_data = 12'b111111111111;
		11'b01101000101: color_data = 12'b111111111111;
		11'b01101000110: color_data = 12'b011011011110;
		11'b01101000111: color_data = 12'b111111111111;
		11'b01101001000: color_data = 12'b111111111111;
		11'b01101001001: color_data = 12'b111111111111;
		11'b01101001010: color_data = 12'b111111111111;
		11'b01101001011: color_data = 12'b111111111111;
		11'b01101001100: color_data = 12'b111111111111;
		11'b01101001101: color_data = 12'b011011011110;

		11'b01110000000: color_data = 12'b111111111111;
		11'b01110000001: color_data = 12'b111111111111;
		11'b01110000010: color_data = 12'b011011011110;
		11'b01110000011: color_data = 12'b011011011110;
		11'b01110000100: color_data = 12'b011011011110;
		11'b01110000101: color_data = 12'b011011011110;
		11'b01110000110: color_data = 12'b011011011110;
		11'b01110000111: color_data = 12'b011011011110;
		11'b01110001000: color_data = 12'b111111111111;
		11'b01110001001: color_data = 12'b111111111111;
		11'b01110001010: color_data = 12'b111111111111;
		11'b01110001011: color_data = 12'b111111111111;
		11'b01110001100: color_data = 12'b111111111111;
		11'b01110001101: color_data = 12'b111111111111;
		11'b01110001110: color_data = 12'b011011011110;
		11'b01110001111: color_data = 12'b011011011110;
		11'b01110010000: color_data = 12'b111111111111;
		11'b01110010001: color_data = 12'b111111111111;
		11'b01110010010: color_data = 12'b011011011110;
		11'b01110010011: color_data = 12'b111111111111;
		11'b01110010100: color_data = 12'b111111111111;
		11'b01110010101: color_data = 12'b111111111111;
		11'b01110010110: color_data = 12'b011011011110;
		11'b01110010111: color_data = 12'b111111111111;
		11'b01110011000: color_data = 12'b111111111111;
		11'b01110011001: color_data = 12'b011011011110;
		11'b01110011010: color_data = 12'b111111111111;
		11'b01110011011: color_data = 12'b111111111111;
		11'b01110011100: color_data = 12'b111111111111;
		11'b01110011101: color_data = 12'b111111111111;
		11'b01110011110: color_data = 12'b111111111111;
		11'b01110011111: color_data = 12'b111111111111;
		11'b01110100000: color_data = 12'b011011011110;
		11'b01110100001: color_data = 12'b011011011110;
		11'b01110100010: color_data = 12'b011011011110;
		11'b01110100011: color_data = 12'b011011011110;
		11'b01110100100: color_data = 12'b011011011110;
		11'b01110100101: color_data = 12'b011011011110;
		11'b01110100110: color_data = 12'b011011011110;
		11'b01110100111: color_data = 12'b011011011110;
		11'b01110101000: color_data = 12'b011011011110;
		11'b01110101001: color_data = 12'b011011011110;
		11'b01110101010: color_data = 12'b011011011110;
		11'b01110101011: color_data = 12'b011011011110;
		11'b01110101100: color_data = 12'b011011011110;
		11'b01110101101: color_data = 12'b011011011110;
		11'b01110101110: color_data = 12'b011011011110;
		11'b01110101111: color_data = 12'b011011011110;
		11'b01110110000: color_data = 12'b111111111111;
		11'b01110110001: color_data = 12'b111111111111;
		11'b01110110010: color_data = 12'b011011011110;
		11'b01110110011: color_data = 12'b011011011110;
		11'b01110110100: color_data = 12'b111111111111;
		11'b01110110101: color_data = 12'b111111111111;
		11'b01110110110: color_data = 12'b011011011110;
		11'b01110110111: color_data = 12'b011011011110;
		11'b01110111000: color_data = 12'b111111111111;
		11'b01110111001: color_data = 12'b111111111111;
		11'b01110111010: color_data = 12'b011011011110;
		11'b01110111011: color_data = 12'b011011011110;
		11'b01110111100: color_data = 12'b111111111111;
		11'b01110111101: color_data = 12'b111111111111;
		11'b01110111110: color_data = 12'b011011011110;
		11'b01110111111: color_data = 12'b011011011110;
		11'b01111000000: color_data = 12'b111111111111;
		11'b01111000001: color_data = 12'b111111111111;
		11'b01111000010: color_data = 12'b111111111111;
		11'b01111000011: color_data = 12'b111111111111;
		11'b01111000100: color_data = 12'b111111111111;
		11'b01111000101: color_data = 12'b111111111111;
		11'b01111000110: color_data = 12'b011011011110;
		11'b01111000111: color_data = 12'b111111111111;
		11'b01111001000: color_data = 12'b111111111111;
		11'b01111001001: color_data = 12'b111111111111;
		11'b01111001010: color_data = 12'b111111111111;
		11'b01111001011: color_data = 12'b111111111111;
		11'b01111001100: color_data = 12'b011011011110;
		11'b01111001101: color_data = 12'b011011011110;

		11'b10000000000: color_data = 12'b111111110000;
		11'b10000000001: color_data = 12'b111111110000;
		11'b10000000010: color_data = 12'b011011011110;
		11'b10000000011: color_data = 12'b111111110000;
		11'b10000000100: color_data = 12'b111111110000;
		11'b10000000101: color_data = 12'b111111110000;
		11'b10000000110: color_data = 12'b011011011110;
		11'b10000000111: color_data = 12'b011011011110;
		11'b10000001000: color_data = 12'b111111110000;
		11'b10000001001: color_data = 12'b111111110000;
		11'b10000001010: color_data = 12'b111111110000;
		11'b10000001011: color_data = 12'b111111110000;
		11'b10000001100: color_data = 12'b111111110000;
		11'b10000001101: color_data = 12'b111111110000;
		11'b10000001110: color_data = 12'b011011011110;
		11'b10000001111: color_data = 12'b011011011110;
		11'b10000010000: color_data = 12'b111111110000;
		11'b10000010001: color_data = 12'b111111110000;
		11'b10000010010: color_data = 12'b011011011110;
		11'b10000010011: color_data = 12'b111111110000;
		11'b10000010100: color_data = 12'b111111110000;
		11'b10000010101: color_data = 12'b111111110000;
		11'b10000010110: color_data = 12'b011011011110;
		11'b10000010111: color_data = 12'b111111110000;
		11'b10000011000: color_data = 12'b111111110000;
		11'b10000011001: color_data = 12'b011011011110;
		11'b10000011010: color_data = 12'b111111110000;
		11'b10000011011: color_data = 12'b111111110000;
		11'b10000011100: color_data = 12'b011011011110;
		11'b10000011101: color_data = 12'b011011011110;
		11'b10000011110: color_data = 12'b011011011110;
		11'b10000011111: color_data = 12'b011011011110;
		11'b10000100000: color_data = 12'b011011011110;
		11'b10000100001: color_data = 12'b011011011110;
		11'b10000100010: color_data = 12'b011011011110;
		11'b10000100011: color_data = 12'b011011011110;
		11'b10000100100: color_data = 12'b011011011110;
		11'b10000100101: color_data = 12'b011011011110;
		11'b10000100110: color_data = 12'b011011011110;
		11'b10000100111: color_data = 12'b011011011110;
		11'b10000101000: color_data = 12'b011011011110;
		11'b10000101001: color_data = 12'b011011011110;
		11'b10000101010: color_data = 12'b011011011110;
		11'b10000101011: color_data = 12'b011011011110;
		11'b10000101100: color_data = 12'b011011011110;
		11'b10000101101: color_data = 12'b011011011110;
		11'b10000101110: color_data = 12'b011011011110;
		11'b10000101111: color_data = 12'b011011011110;
		11'b10000110000: color_data = 12'b111111110000;
		11'b10000110001: color_data = 12'b111111110000;
		11'b10000110010: color_data = 12'b011011011110;
		11'b10000110011: color_data = 12'b011011011110;
		11'b10000110100: color_data = 12'b111111110000;
		11'b10000110101: color_data = 12'b111111110000;
		11'b10000110110: color_data = 12'b011011011110;
		11'b10000110111: color_data = 12'b011011011110;
		11'b10000111000: color_data = 12'b111111110000;
		11'b10000111001: color_data = 12'b111111110000;
		11'b10000111010: color_data = 12'b011011011110;
		11'b10000111011: color_data = 12'b011011011110;
		11'b10000111100: color_data = 12'b111111110000;
		11'b10000111101: color_data = 12'b111111110000;
		11'b10000111110: color_data = 12'b011011011110;
		11'b10000111111: color_data = 12'b011011011110;
		11'b10001000000: color_data = 12'b111111110000;
		11'b10001000001: color_data = 12'b111111110000;
		11'b10001000010: color_data = 12'b011011011110;
		11'b10001000011: color_data = 12'b011011011110;
		11'b10001000100: color_data = 12'b011011011110;
		11'b10001000101: color_data = 12'b011011011110;
		11'b10001000110: color_data = 12'b011011011110;
		11'b10001000111: color_data = 12'b111111110000;
		11'b10001001000: color_data = 12'b111111110000;
		11'b10001001001: color_data = 12'b011011011110;
		11'b10001001010: color_data = 12'b011011011110;
		11'b10001001011: color_data = 12'b111111110000;
		11'b10001001100: color_data = 12'b111111110000;
		11'b10001001101: color_data = 12'b011011011110;

		11'b10010000000: color_data = 12'b111111110000;
		11'b10010000001: color_data = 12'b111111110000;
		11'b10010000010: color_data = 12'b011011011110;
		11'b10010000011: color_data = 12'b111111110000;
		11'b10010000100: color_data = 12'b111111110000;
		11'b10010000101: color_data = 12'b111111110000;
		11'b10010000110: color_data = 12'b011011011110;
		11'b10010000111: color_data = 12'b011011011110;
		11'b10010001000: color_data = 12'b111111110000;
		11'b10010001001: color_data = 12'b111111110000;
		11'b10010001010: color_data = 12'b011011011110;
		11'b10010001011: color_data = 12'b011011011110;
		11'b10010001100: color_data = 12'b111111110000;
		11'b10010001101: color_data = 12'b111111110000;
		11'b10010001110: color_data = 12'b011011011110;
		11'b10010001111: color_data = 12'b011011011110;
		11'b10010010000: color_data = 12'b111111110000;
		11'b10010010001: color_data = 12'b111111110000;
		11'b10010010010: color_data = 12'b011011011110;
		11'b10010010011: color_data = 12'b011011011110;
		11'b10010010100: color_data = 12'b111111110000;
		11'b10010010101: color_data = 12'b011011011110;
		11'b10010010110: color_data = 12'b011011011110;
		11'b10010010111: color_data = 12'b111111110000;
		11'b10010011000: color_data = 12'b111111110000;
		11'b10010011001: color_data = 12'b011011011110;
		11'b10010011010: color_data = 12'b111111110000;
		11'b10010011011: color_data = 12'b111111110000;
		11'b10010011100: color_data = 12'b011011011110;
		11'b10010011101: color_data = 12'b011011011110;
		11'b10010011110: color_data = 12'b011011011110;
		11'b10010011111: color_data = 12'b011011011110;
		11'b10010100000: color_data = 12'b011011011110;
		11'b10010100001: color_data = 12'b011011011110;
		11'b10010100010: color_data = 12'b011011011110;
		11'b10010100011: color_data = 12'b011011011110;
		11'b10010100100: color_data = 12'b011011011110;
		11'b10010100101: color_data = 12'b011011011110;
		11'b10010100110: color_data = 12'b011011011110;
		11'b10010100111: color_data = 12'b011011011110;
		11'b10010101000: color_data = 12'b011011011110;
		11'b10010101001: color_data = 12'b011011011110;
		11'b10010101010: color_data = 12'b011011011110;
		11'b10010101011: color_data = 12'b011011011110;
		11'b10010101100: color_data = 12'b011011011110;
		11'b10010101101: color_data = 12'b011011011110;
		11'b10010101110: color_data = 12'b011011011110;
		11'b10010101111: color_data = 12'b011011011110;
		11'b10010110000: color_data = 12'b111111110000;
		11'b10010110001: color_data = 12'b111111110000;
		11'b10010110010: color_data = 12'b011011011110;
		11'b10010110011: color_data = 12'b011011011110;
		11'b10010110100: color_data = 12'b111111110000;
		11'b10010110101: color_data = 12'b111111110000;
		11'b10010110110: color_data = 12'b011011011110;
		11'b10010110111: color_data = 12'b011011011110;
		11'b10010111000: color_data = 12'b111111110000;
		11'b10010111001: color_data = 12'b111111110000;
		11'b10010111010: color_data = 12'b011011011110;
		11'b10010111011: color_data = 12'b011011011110;
		11'b10010111100: color_data = 12'b111111110000;
		11'b10010111101: color_data = 12'b111111110000;
		11'b10010111110: color_data = 12'b011011011110;
		11'b10010111111: color_data = 12'b011011011110;
		11'b10011000000: color_data = 12'b111111110000;
		11'b10011000001: color_data = 12'b111111110000;
		11'b10011000010: color_data = 12'b011011011110;
		11'b10011000011: color_data = 12'b011011011110;
		11'b10011000100: color_data = 12'b011011011110;
		11'b10011000101: color_data = 12'b011011011110;
		11'b10011000110: color_data = 12'b011011011110;
		11'b10011000111: color_data = 12'b111111110000;
		11'b10011001000: color_data = 12'b111111110000;
		11'b10011001001: color_data = 12'b011011011110;
		11'b10011001010: color_data = 12'b011011011110;
		11'b10011001011: color_data = 12'b011011011110;
		11'b10011001100: color_data = 12'b111111110000;
		11'b10011001101: color_data = 12'b111111110000;

		11'b10100000000: color_data = 12'b111111110000;
		11'b10100000001: color_data = 12'b111111110000;
		11'b10100000010: color_data = 12'b011011011110;
		11'b10100000011: color_data = 12'b011011011110;
		11'b10100000100: color_data = 12'b111111110000;
		11'b10100000101: color_data = 12'b111111110000;
		11'b10100000110: color_data = 12'b011011011110;
		11'b10100000111: color_data = 12'b011011011110;
		11'b10100001000: color_data = 12'b111111110000;
		11'b10100001001: color_data = 12'b111111110000;
		11'b10100001010: color_data = 12'b011011011110;
		11'b10100001011: color_data = 12'b011011011110;
		11'b10100001100: color_data = 12'b111111110000;
		11'b10100001101: color_data = 12'b111111110000;
		11'b10100001110: color_data = 12'b011011011110;
		11'b10100001111: color_data = 12'b011011011110;
		11'b10100010000: color_data = 12'b111111110000;
		11'b10100010001: color_data = 12'b111111110000;
		11'b10100010010: color_data = 12'b011011011110;
		11'b10100010011: color_data = 12'b011011011110;
		11'b10100010100: color_data = 12'b111111110000;
		11'b10100010101: color_data = 12'b011011011110;
		11'b10100010110: color_data = 12'b011011011110;
		11'b10100010111: color_data = 12'b111111110000;
		11'b10100011000: color_data = 12'b111111110000;
		11'b10100011001: color_data = 12'b011011011110;
		11'b10100011010: color_data = 12'b111111110000;
		11'b10100011011: color_data = 12'b111111110000;
		11'b10100011100: color_data = 12'b011011011110;
		11'b10100011101: color_data = 12'b011011011110;
		11'b10100011110: color_data = 12'b011011011110;
		11'b10100011111: color_data = 12'b011011011110;
		11'b10100100000: color_data = 12'b011011011110;
		11'b10100100001: color_data = 12'b011011011110;
		11'b10100100010: color_data = 12'b011011011110;
		11'b10100100011: color_data = 12'b011011011110;
		11'b10100100100: color_data = 12'b011011011110;
		11'b10100100101: color_data = 12'b011011011110;
		11'b10100100110: color_data = 12'b011011011110;
		11'b10100100111: color_data = 12'b011011011110;
		11'b10100101000: color_data = 12'b011011011110;
		11'b10100101001: color_data = 12'b011011011110;
		11'b10100101010: color_data = 12'b011011011110;
		11'b10100101011: color_data = 12'b011011011110;
		11'b10100101100: color_data = 12'b011011011110;
		11'b10100101101: color_data = 12'b011011011110;
		11'b10100101110: color_data = 12'b011011011110;
		11'b10100101111: color_data = 12'b011011011110;
		11'b10100110000: color_data = 12'b111111110000;
		11'b10100110001: color_data = 12'b111111110000;
		11'b10100110010: color_data = 12'b011011011110;
		11'b10100110011: color_data = 12'b011011011110;
		11'b10100110100: color_data = 12'b111111110000;
		11'b10100110101: color_data = 12'b111111110000;
		11'b10100110110: color_data = 12'b011011011110;
		11'b10100110111: color_data = 12'b011011011110;
		11'b10100111000: color_data = 12'b011011011110;
		11'b10100111001: color_data = 12'b111111110000;
		11'b10100111010: color_data = 12'b111111110000;
		11'b10100111011: color_data = 12'b111111110000;
		11'b10100111100: color_data = 12'b111111110000;
		11'b10100111101: color_data = 12'b011011011110;
		11'b10100111110: color_data = 12'b011011011110;
		11'b10100111111: color_data = 12'b011011011110;
		11'b10101000000: color_data = 12'b111111110000;
		11'b10101000001: color_data = 12'b111111110000;
		11'b10101000010: color_data = 12'b011011011110;
		11'b10101000011: color_data = 12'b011011011110;
		11'b10101000100: color_data = 12'b011011011110;
		11'b10101000101: color_data = 12'b011011011110;
		11'b10101000110: color_data = 12'b011011011110;
		11'b10101000111: color_data = 12'b111111110000;
		11'b10101001000: color_data = 12'b111111110000;
		11'b10101001001: color_data = 12'b011011011110;
		11'b10101001010: color_data = 12'b011011011110;
		11'b10101001011: color_data = 12'b011011011110;
		11'b10101001100: color_data = 12'b111111110000;
		11'b10101001101: color_data = 12'b111111110000;

		11'b10110000000: color_data = 12'b111111000000;
		11'b10110000001: color_data = 12'b111111000000;
		11'b10110000010: color_data = 12'b011011011110;
		11'b10110000011: color_data = 12'b011011011110;
		11'b10110000100: color_data = 12'b111111000000;
		11'b10110000101: color_data = 12'b111111000000;
		11'b10110000110: color_data = 12'b011011011110;
		11'b10110000111: color_data = 12'b011011011110;
		11'b10110001000: color_data = 12'b111111000000;
		11'b10110001001: color_data = 12'b111111000000;
		11'b10110001010: color_data = 12'b011011011110;
		11'b10110001011: color_data = 12'b011011011110;
		11'b10110001100: color_data = 12'b111111000000;
		11'b10110001101: color_data = 12'b111111000000;
		11'b10110001110: color_data = 12'b011011011110;
		11'b10110001111: color_data = 12'b011011011110;
		11'b10110010000: color_data = 12'b111111000000;
		11'b10110010001: color_data = 12'b111111000000;
		11'b10110010010: color_data = 12'b011011011110;
		11'b10110010011: color_data = 12'b011011011110;
		11'b10110010100: color_data = 12'b111111000000;
		11'b10110010101: color_data = 12'b011011011110;
		11'b10110010110: color_data = 12'b011011011110;
		11'b10110010111: color_data = 12'b111111000000;
		11'b10110011000: color_data = 12'b111111000000;
		11'b10110011001: color_data = 12'b011011011110;
		11'b10110011010: color_data = 12'b111111000000;
		11'b10110011011: color_data = 12'b111111000000;
		11'b10110011100: color_data = 12'b011011011110;
		11'b10110011101: color_data = 12'b011011011110;
		11'b10110011110: color_data = 12'b011011011110;
		11'b10110011111: color_data = 12'b011011011110;
		11'b10110100000: color_data = 12'b011011011110;
		11'b10110100001: color_data = 12'b011011011110;
		11'b10110100010: color_data = 12'b011011011110;
		11'b10110100011: color_data = 12'b011011011110;
		11'b10110100100: color_data = 12'b011011011110;
		11'b10110100101: color_data = 12'b011011011110;
		11'b10110100110: color_data = 12'b011011011110;
		11'b10110100111: color_data = 12'b011011011110;
		11'b10110101000: color_data = 12'b011011011110;
		11'b10110101001: color_data = 12'b011011011110;
		11'b10110101010: color_data = 12'b011011011110;
		11'b10110101011: color_data = 12'b011011011110;
		11'b10110101100: color_data = 12'b011011011110;
		11'b10110101101: color_data = 12'b011011011110;
		11'b10110101110: color_data = 12'b011011011110;
		11'b10110101111: color_data = 12'b011011011110;
		11'b10110110000: color_data = 12'b111111000000;
		11'b10110110001: color_data = 12'b111111000000;
		11'b10110110010: color_data = 12'b011011011110;
		11'b10110110011: color_data = 12'b011011011110;
		11'b10110110100: color_data = 12'b111111000000;
		11'b10110110101: color_data = 12'b111111000000;
		11'b10110110110: color_data = 12'b011011011110;
		11'b10110110111: color_data = 12'b011011011110;
		11'b10110111000: color_data = 12'b011011011110;
		11'b10110111001: color_data = 12'b111111000000;
		11'b10110111010: color_data = 12'b111111000000;
		11'b10110111011: color_data = 12'b111111000000;
		11'b10110111100: color_data = 12'b111111000000;
		11'b10110111101: color_data = 12'b011011011110;
		11'b10110111110: color_data = 12'b011011011110;
		11'b10110111111: color_data = 12'b011011011110;
		11'b10111000000: color_data = 12'b111111000000;
		11'b10111000001: color_data = 12'b111111000000;
		11'b10111000010: color_data = 12'b011011011110;
		11'b10111000011: color_data = 12'b011011011110;
		11'b10111000100: color_data = 12'b011011011110;
		11'b10111000101: color_data = 12'b011011011110;
		11'b10111000110: color_data = 12'b011011011110;
		11'b10111000111: color_data = 12'b111111000000;
		11'b10111001000: color_data = 12'b111111000000;
		11'b10111001001: color_data = 12'b011011011110;
		11'b10111001010: color_data = 12'b011011011110;
		11'b10111001011: color_data = 12'b011011011110;
		11'b10111001100: color_data = 12'b111111000000;
		11'b10111001101: color_data = 12'b111111000000;

		11'b11000000000: color_data = 12'b111111000000;
		11'b11000000001: color_data = 12'b111111000000;
		11'b11000000010: color_data = 12'b111111000000;
		11'b11000000011: color_data = 12'b111111000000;
		11'b11000000100: color_data = 12'b111111000000;
		11'b11000000101: color_data = 12'b111111000000;
		11'b11000000110: color_data = 12'b011011011110;
		11'b11000000111: color_data = 12'b011011011110;
		11'b11000001000: color_data = 12'b111111000000;
		11'b11000001001: color_data = 12'b111111000000;
		11'b11000001010: color_data = 12'b011011011110;
		11'b11000001011: color_data = 12'b011011011110;
		11'b11000001100: color_data = 12'b111111000000;
		11'b11000001101: color_data = 12'b111111000000;
		11'b11000001110: color_data = 12'b011011011110;
		11'b11000001111: color_data = 12'b011011011110;
		11'b11000010000: color_data = 12'b111111000000;
		11'b11000010001: color_data = 12'b111111000000;
		11'b11000010010: color_data = 12'b011011011110;
		11'b11000010011: color_data = 12'b011011011110;
		11'b11000010100: color_data = 12'b011011011110;
		11'b11000010101: color_data = 12'b011011011110;
		11'b11000010110: color_data = 12'b011011011110;
		11'b11000010111: color_data = 12'b111111000000;
		11'b11000011000: color_data = 12'b111111000000;
		11'b11000011001: color_data = 12'b011011011110;
		11'b11000011010: color_data = 12'b111111000000;
		11'b11000011011: color_data = 12'b111111000000;
		11'b11000011100: color_data = 12'b111111000000;
		11'b11000011101: color_data = 12'b111111000000;
		11'b11000011110: color_data = 12'b111111000000;
		11'b11000011111: color_data = 12'b111111000000;
		11'b11000100000: color_data = 12'b011011011110;
		11'b11000100001: color_data = 12'b011011011110;
		11'b11000100010: color_data = 12'b011011011110;
		11'b11000100011: color_data = 12'b011011011110;
		11'b11000100100: color_data = 12'b011011011110;
		11'b11000100101: color_data = 12'b011011011110;
		11'b11000100110: color_data = 12'b011011011110;
		11'b11000100111: color_data = 12'b011011011110;
		11'b11000101000: color_data = 12'b011011011110;
		11'b11000101001: color_data = 12'b011011011110;
		11'b11000101010: color_data = 12'b011011011110;
		11'b11000101011: color_data = 12'b011011011110;
		11'b11000101100: color_data = 12'b011011011110;
		11'b11000101101: color_data = 12'b011011011110;
		11'b11000101110: color_data = 12'b011011011110;
		11'b11000101111: color_data = 12'b011011011110;
		11'b11000110000: color_data = 12'b111111000000;
		11'b11000110001: color_data = 12'b111111000000;
		11'b11000110010: color_data = 12'b111111000000;
		11'b11000110011: color_data = 12'b111111000000;
		11'b11000110100: color_data = 12'b111111000000;
		11'b11000110101: color_data = 12'b111111000000;
		11'b11000110110: color_data = 12'b011011011110;
		11'b11000110111: color_data = 12'b011011011110;
		11'b11000111000: color_data = 12'b011011011110;
		11'b11000111001: color_data = 12'b011011011110;
		11'b11000111010: color_data = 12'b111111000000;
		11'b11000111011: color_data = 12'b111111000000;
		11'b11000111100: color_data = 12'b011011011110;
		11'b11000111101: color_data = 12'b011011011110;
		11'b11000111110: color_data = 12'b011011011110;
		11'b11000111111: color_data = 12'b011011011110;
		11'b11001000000: color_data = 12'b111111000000;
		11'b11001000001: color_data = 12'b111111000000;
		11'b11001000010: color_data = 12'b111111000000;
		11'b11001000011: color_data = 12'b111111000000;
		11'b11001000100: color_data = 12'b111111000000;
		11'b11001000101: color_data = 12'b111111000000;
		11'b11001000110: color_data = 12'b011011011110;
		11'b11001000111: color_data = 12'b111111000000;
		11'b11001001000: color_data = 12'b111111000000;
		11'b11001001001: color_data = 12'b011011011110;
		11'b11001001010: color_data = 12'b011011011110;
		11'b11001001011: color_data = 12'b011011011110;
		11'b11001001100: color_data = 12'b111111000000;
		11'b11001001101: color_data = 12'b111111000000;

		11'b11010000000: color_data = 12'b011011011110;
		11'b11010000001: color_data = 12'b111111000000;
		11'b11010000010: color_data = 12'b111111000000;
		11'b11010000011: color_data = 12'b111111000000;
		11'b11010000100: color_data = 12'b011011011110;
		11'b11010000101: color_data = 12'b111111000000;
		11'b11010000110: color_data = 12'b011011011110;
		11'b11010000111: color_data = 12'b011011011110;
		11'b11010001000: color_data = 12'b111111000000;
		11'b11010001001: color_data = 12'b111111000000;
		11'b11010001010: color_data = 12'b011011011110;
		11'b11010001011: color_data = 12'b011011011110;
		11'b11010001100: color_data = 12'b111111000000;
		11'b11010001101: color_data = 12'b111111000000;
		11'b11010001110: color_data = 12'b011011011110;
		11'b11010001111: color_data = 12'b011011011110;
		11'b11010010000: color_data = 12'b111111000000;
		11'b11010010001: color_data = 12'b111111000000;
		11'b11010010010: color_data = 12'b011011011110;
		11'b11010010011: color_data = 12'b011011011110;
		11'b11010010100: color_data = 12'b011011011110;
		11'b11010010101: color_data = 12'b011011011110;
		11'b11010010110: color_data = 12'b011011011110;
		11'b11010010111: color_data = 12'b111111000000;
		11'b11010011000: color_data = 12'b111111000000;
		11'b11010011001: color_data = 12'b011011011110;
		11'b11010011010: color_data = 12'b111111000000;
		11'b11010011011: color_data = 12'b111111000000;
		11'b11010011100: color_data = 12'b111111000000;
		11'b11010011101: color_data = 12'b111111000000;
		11'b11010011110: color_data = 12'b111111000000;
		11'b11010011111: color_data = 12'b111111000000;
		11'b11010100000: color_data = 12'b011011011110;
		11'b11010100001: color_data = 12'b011011011110;
		11'b11010100010: color_data = 12'b011011011110;
		11'b11010100011: color_data = 12'b011011011110;
		11'b11010100100: color_data = 12'b011011011110;
		11'b11010100101: color_data = 12'b011011011110;
		11'b11010100110: color_data = 12'b011011011110;
		11'b11010100111: color_data = 12'b011011011110;
		11'b11010101000: color_data = 12'b011011011110;
		11'b11010101001: color_data = 12'b011011011110;
		11'b11010101010: color_data = 12'b011011011110;
		11'b11010101011: color_data = 12'b011011011110;
		11'b11010101100: color_data = 12'b011011011110;
		11'b11010101101: color_data = 12'b011011011110;
		11'b11010101110: color_data = 12'b011011011110;
		11'b11010101111: color_data = 12'b011011011110;
		11'b11010110000: color_data = 12'b011011011110;
		11'b11010110001: color_data = 12'b111111000000;
		11'b11010110010: color_data = 12'b111111000000;
		11'b11010110011: color_data = 12'b111111000000;
		11'b11010110100: color_data = 12'b111111000000;
		11'b11010110101: color_data = 12'b011011011110;
		11'b11010110110: color_data = 12'b011011011110;
		11'b11010110111: color_data = 12'b011011011110;
		11'b11010111000: color_data = 12'b011011011110;
		11'b11010111001: color_data = 12'b011011011110;
		11'b11010111010: color_data = 12'b111111000000;
		11'b11010111011: color_data = 12'b111111000000;
		11'b11010111100: color_data = 12'b011011011110;
		11'b11010111101: color_data = 12'b011011011110;
		11'b11010111110: color_data = 12'b011011011110;
		11'b11010111111: color_data = 12'b011011011110;
		11'b11011000000: color_data = 12'b111111000000;
		11'b11011000001: color_data = 12'b111111000000;
		11'b11011000010: color_data = 12'b111111000000;
		11'b11011000011: color_data = 12'b111111000000;
		11'b11011000100: color_data = 12'b111111000000;
		11'b11011000101: color_data = 12'b111111000000;
		11'b11011000110: color_data = 12'b011011011110;
		11'b11011000111: color_data = 12'b111111000000;
		11'b11011001000: color_data = 12'b111111000000;
		11'b11011001001: color_data = 12'b011011011110;
		11'b11011001010: color_data = 12'b011011011110;
		11'b11011001011: color_data = 12'b011011011110;
		11'b11011001100: color_data = 12'b111111000000;
		11'b11011001101: color_data = 12'b111111000000;

		default: color_data = 12'b000000000000;
	endcase
    
   
    // objelerin renkleri
    assign wall_rgb = 12'hF00;      // kýrmýzý duvar
    assign pad_rgb  = 12'h000;      // siyah paddle
    assign ball_rgb = 12'hF0F;      // pembe top
    assign bg_rgb   = 12'hFFF;      // beyaz background 
    
    assign y_pad_t = y_pad_reg;                             // paddle üst kýsým
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              // paddle alt kýsým
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     // pixel paddle içinde ise on
                    (y_pad_t <= y) && (y <= y_pad_b);
                    
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;
        if(yenile)
            if(up & (y_pad_t > PAD_HIZ))
                y_pad_next = y_pad_reg - PAD_HIZ;  //yukarý yön
            else if(down & (y_pad_b < (Y_MAX - PAD_HIZ)))
                y_pad_next = y_pad_reg + PAD_HIZ;  //aþaðý yön
    end
    
    
    
    // her çevrimde konum güncellemeleri, topun sað kýsmýndan x, üst kýsmýndan y alýnýr - atanýr
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    
    // piksel topun tanýmlandýðý 8x8 kare içinde kontrol
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
                        
    // 8x8 içerisinde 3 bitlik konumu alýyoruz, topun tam þekli için
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // dikey (case ile rom_data arrayine atamalar)
    assign rom_col = x[2:0] - x_ball_l[2:0];    // yatay
    assign rom_bit = rom_data[rom_col];         // tam olarak bakýlmasý gereken 1 pixel
    
    assign ball_on = sq_ball_on & rom_bit;      // 1 ise ball_on = 1; renk atamasý yap, deðilse arkaplan
    
    
    
    
    // topun pozisyonunu belirleyen blok; skor - can - çarpýþma kontrolleri
    always @* begin
        skor_birler_n = skor_birler;
        skor_onlar_n= skor_onlar;
        
        kalan_can_next = kalan_can;
        gameover_next = gameover;
        
        x_ball_next = (yenile) ? x_ball_reg + x_delta_reg: x_ball_reg;
        y_ball_next = (yenile) ? y_ball_reg + y_delta_reg: y_ball_reg;
    
        for(i=0; i<tugla_sayisi; i=i+1)begin
            flag_n[i] = flag[i];
        end
        // flagler tuðlanýn çarpýþma yaþayýp yaþamadýðýný kontrol eder, bir kez çarpýþmada yok edebilmek için
        
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        
        
        if (10*skor_onlar_n + skor_birler_n == tugla_sayisi) begin
            for(i=0; i<tugla_sayisi; i=i+1)begin
                flag_n[i] = 1;
            end
            x_ball_next = 300;
            x_delta_next = 0;
            // kazandý
        end
        
        
        
        
        
        if(y_ball_t < 1)                                            // tavanla çarp
            y_delta_next = TOP_HIZ_POS - 1;                     
        else if(y_ball_b > Y_MAX)                                   // tabanla çarp
            y_delta_next = TOP_HIZ_NEG + 1;                       
        else if(x_ball_l <= X_WALL_R)                               // sol duvarla
            x_delta_next = TOP_HIZ_POS;                  
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b))     // paddle ile
            x_delta_next = TOP_HIZ_NEG;                       
        
        //brick kontrol
        else if((X_BRICK_L <= x_ball_r) && (x_ball_l <= X_BRICK_R) &&
                (Y_BRICK_D <= y_ball_b) && (y_ball_t <= Y_BRICK_U) && flag[0])begin
                x_delta_next = TOP_HIZ_POS;
                flag_n[0] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
            
        else if((X_BRICK2_L <= x_ball_r) && (x_ball_l <= X_BRICK2_R) &&
                (Y_BRICK2_D <= y_ball_b) && (y_ball_t <= Y_BRICK2_U) && flag[1])begin
                 x_delta_next = TOP_HIZ_POS;
                 flag_n[1] = 0;
                 
                 if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                 else begin
                        skor_onlar_n = 1;
                        skor_birler_n = 0; // 9'dan 10'a
                 end
                    
                end
           
            
        else if((X_BRICK3_L <= x_ball_r) && (x_ball_l <= X_BRICK3_R) &&
                (Y_BRICK3_D <= y_ball_b) && (y_ball_t <= Y_BRICK3_U) && flag[2])begin
                 x_delta_next = TOP_HIZ_POS;
                 flag_n[2] = 0;
                 if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                 else begin
                    skor_onlar_n = 1;
                    skor_birler_n = 0; // 9'dan 10'a
                 end
                 end
            

        else if((X_BRICK4_L <= x_ball_r) && (x_ball_l <= X_BRICK4_R) &&
                (Y_BRICK4_D <= y_ball_b) && (y_ball_t <= Y_BRICK4_U) && flag[3])begin
                x_delta_next = TOP_HIZ_POS;
                flag_n[3] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
                
        else if((X_BRICK5_L <= x_ball_r) && (x_ball_l <= X_BRICK5_R) &&
                (Y_BRICK5_D <= y_ball_b) && (y_ball_t <= Y_BRICK5_U) && flag[4])begin
                x_delta_next = TOP_HIZ_POS;
                flag_n[4] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
                
                
        else if((X_BRICK6_L <= x_ball_r) && (x_ball_l <= X_BRICK6_R) &&
                (Y_BRICK6_D <= y_ball_b) && (y_ball_t <= Y_BRICK6_U) && flag[5])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[5] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
              
        else if((X_BRICK7_L <= x_ball_r) && (x_ball_l <= X_BRICK7_R) &&
                (Y_BRICK7_D <= y_ball_b) && (y_ball_t <= Y_BRICK7_U) && flag[6])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[6] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
        
        
        
        else if((X_BRICK8_L <= x_ball_r) && (x_ball_l <= X_BRICK8_R) &&
                (Y_BRICK8_D <= y_ball_b) && (y_ball_t <= Y_BRICK8_U) && flag[7])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[7] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
        
        else if((X_BRICK9_L <= x_ball_r) && (x_ball_l <= X_BRICK9_R) &&
                (Y_BRICK9_D <= y_ball_b) && (y_ball_t <= Y_BRICK9_U) && flag[8])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[8] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end
                
        else if((X_BRICK10_L <= x_ball_r) && (x_ball_l <= X_BRICK10_R) &&
                (Y_BRICK10_D <= y_ball_b) && (y_ball_t <= Y_BRICK10_U) && flag[9])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[9] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end        
        
        else if((X_BRICK11_L <= x_ball_r) && (x_ball_l <= X_BRICK11_R) &&
                (Y_BRICK11_D <= y_ball_b) && (y_ball_t <= Y_BRICK11_U) && flag[10])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[10] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end 
        
        else if((X_BRICK12_L <= x_ball_r) && (x_ball_l <= X_BRICK12_R) &&
                (Y_BRICK12_D <= y_ball_b) && (y_ball_t <= Y_BRICK12_U) && flag[11])begin
                x_delta_next = TOP_HIZ_POS; 
                flag_n[11] = 0;
                if(skor_birler != 9) skor_birler_n = skor_birler_n + 1;
                else begin
                    skor_onlar_n = skor_onlar_n + 1;
                    skor_birler_n = 0; // 9'dan 10'a
                end
                end 
        
        else if((X_MAX+1  <= x_ball_r)&&(kalan_can>0)) begin
            
                kalan_can_next = kalan_can - 1;
                x_ball_next = 300;
                x_delta_next = 1;
                gameover_next = 0;
        end
        
        
        
        
        if (kalan_can_next ==0)begin
                gameover_next = 1;
                x_delta_next = 0;
                x_ball_next = 300;
        end
        
                   
    end                    
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else
            if(wall_on)
                rgb = wall_rgb;     // wall color
            else if(pad_on)
                rgb = pad_rgb;      // paddle color
            else if(ball_on)
                rgb = ball_rgb;     // ball color
                
            else if(gameover_on)
                rgb = color_data;
                
            else if(brick_on)           // tuðlalar
                rgb = brick_rgb[0];
            else if(brick2_on)
                rgb = brick_rgb[1];
            else if(brick3_on)
                rgb = brick_rgb[2];
            else if(brick4_on)
                rgb = brick_rgb[3];
            else if(brick5_on)
                rgb = brick_rgb[4];
            else if(brick6_on)
                rgb = brick_rgb[5];
            else if(heart_on )
               rgb = color_data2; 
            else if(heart_on2) 
                rgb=color_data2;    
            else if(heart_on3) 
                rgb=color_data2; 
            else if(heart_on4) 
                rgb=color_data2;
             else if(heart_on5) 
                rgb=color_data2;
    
                
            else if(brick7_on)           
                rgb = brick_rgb[6];
            else if(brick8_on)
                rgb = brick_rgb[7];
            else if(brick9_on)
                rgb = brick_rgb[8];
            else if(brick10_on)
                rgb = brick_rgb[9];
            else if(brick11_on)
                rgb = brick_rgb[10];
            else if(brick12_on)
                rgb = brick_rgb[11];
            
            else
                rgb = bg_rgb;       // background
       
endmodule