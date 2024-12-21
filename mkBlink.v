//
// Generated by Bluespec Compiler, version 2024.07 (build b4f31db)
//
// On Sat Dec 21 01:17:52 PST 2024
//
//
// Ports:
// Name                         I/O  size props
// led                            O     8 reg
// wifi_gpio0                     O     1 const
// clk_25mhz                      I     1 clock
// user_programn                  I     1 reset
// btn                            I     7 reg
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkBlink(clk_25mhz,
	       user_programn,

	       btn,

	       led,

	       wifi_gpio0);
  input  clk_25mhz;
  input  user_programn;

  // action method readButtons
  input  [6 : 0] btn;

  // value method led
  output [7 : 0] led;

  // value method dont_reboot
  output wifi_gpio0;

  // signals for module outputs
  wire [7 : 0] led;
  wire wifi_gpio0;

  // register buttons
  reg [6 : 0] buttons;
  wire [6 : 0] buttons$D_IN;
  wire buttons$EN;

  // register counter
  reg [19 : 0] counter;
  wire [19 : 0] counter$D_IN;
  wire counter$EN;

  // register leds
  reg [7 : 0] leds;
  wire [7 : 0] leds$D_IN;
  wire leds$EN;

  // value method led
  assign led = leds ;

  // value method dont_reboot
  assign wifi_gpio0 = 1'd1 ;

  // register buttons
  assign buttons$D_IN = btn ;
  assign buttons$EN = 1'd1 ;

  // register counter
  assign counter$D_IN = counter + 20'd1 ;
  assign counter$EN = buttons[0] ;

  // register leds
  assign leds$D_IN = leds + 8'd1 ;
  assign leds$EN = buttons[0] && counter == 20'd0 ;

  // handling of inlined registers

  always@(posedge clk_25mhz)
  begin
    if (user_programn == `BSV_RESET_VALUE)
      begin
        buttons <= `BSV_ASSIGNMENT_DELAY 7'd0;
	counter <= `BSV_ASSIGNMENT_DELAY 20'd0;
	leds <= `BSV_ASSIGNMENT_DELAY 8'd0;
      end
    else
      begin
        if (buttons$EN) buttons <= `BSV_ASSIGNMENT_DELAY buttons$D_IN;
	if (counter$EN) counter <= `BSV_ASSIGNMENT_DELAY counter$D_IN;
	if (leds$EN) leds <= `BSV_ASSIGNMENT_DELAY leds$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    buttons = 7'h2A;
    counter = 20'hAAAAA;
    leds = 8'hAA;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkBlink
