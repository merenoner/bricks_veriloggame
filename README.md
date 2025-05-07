Project Content: piksel_gen.v, vga_modulu.v, ana_modul.v, debouncer.v, const_pong.xdc

Additional file: The schematic image where the main module is explained

Game: A game where the goal is to destroy all bricks with 5 lives, using paddle control

Used buttons: T18 and U17 on the FPGA for paddle control,
        T17 for reset

Display on FPGA: The number of destroyed bricks is shown on screen during gameplay

Used resources: For heart and game over images and for understanding VGA working principle;
        https://github.com/jconenna/Yoshis-Nightmare

Module explanations:

piksel_gen:
This is the module where the game algorithm is built. The main always block determines especially in which direction the ball should move, calculates the remaining lives and destroyed bricks.

The shapes of the ball and other elements are created using read-only memory. x_ball_next and y_ball_next are updated according to the refresh value. Then, blocks are created and the positions where blocks will be placed are defined. To make the blocks disappear when hit, we used a flag array. So when a block is hit once, the value is updated and the color of the block is matched with the background. Hitting the same block again is prevented with if-else blocks. Inside these blocks, the score outputs skor_onlar and skor_birler are updated accordingly. The obtained score values are then used to generate display output on the FPGA via seven segment.

For the ball hitting the top or bottom wall, delta values were assigned, and collision movement is handled with if-else blocks. The movement is continued using the refresh value. At the start, the life count is set to 5. Every time the ball passes the paddle, the life is reduced as checked in the else-if blocks.

Hearts are displayed just like the bricks, based on the remaining lives and position. Paddle movement is checked when the refresh signal is 1, allowing vertical movement.

For the losing condition, gameover_on value is assigned, and the game over text from the resource is integrated into the code using case statements and assigned to the color_data value. The same logic is used for the hearts, assigning the result to color_data2.

In the final always block, RGB values are determined. When video_on signal is 1, each visual element on screen is assigned a color.

vga_modulu:

This module is designed to produce a VGA output for all operations. A 640x480 screen resolution is defined. To allow proper assignment even during blanking, an extra non-displayed but scanned region is created. This module scans that region, and if it's a displayable point, it outputs x and y coordinates.

In the pipeline, these outputs are passed to the piksel_gen module, which assigns RGB values based on the coordinates. The structure and use of this module were inspired by the provided GitHub resource.

ana_modul:

This is the top-level module where a simple pipeline and the game are implemented. The interaction of modules is shown in the schematic image. Seven segment display is also handled in this module.

Inputs and outputs required for the vga_modulu are created using wire and reg and connected accordingly. The outputs from there are then passed as inputs to the piksel_gen module. To prevent signal noise, debouncer modules are used.

const_pong.xdc:

As shown in the included image, necessary pin assignments for VGA, seven segment display, and input buttons are made.
