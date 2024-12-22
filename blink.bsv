// Copyright © 2024 Tommy Thorn <tommy-github2@thorn.ws>
//
// Near-simplest possible example for blinking LED with Bluespec
// This example is assuming the ULX3S FPGA dev board.

// For the toplevel module, the interface defines the Verilog ports.
// Inputs are read with Action methods and output are written with
// Value methods.  These can be tought of as implicitly invoked by the system
// so it should not be concerning to see no explicit users of them here.
interface Blink;
  (* prefix="" *)           method Action  readButtons((* port="btn" *) Bit#(7) buttons);
  (* result="led" *)        method Bit#(8) led();
  // Tie GPIO0 high, keeping board from rebooting
  (* result="wifi_gpio0" *) method Bool    dont_reboot();
endinterface

(*
   synthesize,
   always_ready,
   always_enabled,
   // This is a bit of a hack, but there's no explicit reset on ULX3S
   // and using `no_default_reset` doesn't work here
   reset_prefix = "user_programn",
   clock_prefix = "clk_25mhz"
*)
module mkBlink(Blink);
  Reg#(Bit#(7))  buttons <- mkReg(0);
  Reg#(Bit#(8))  leds    <- mkReg(0);
  Reg#(Bit#(20)) counter <- mkReg(0);

  // In the current Bluespec implementation, this is basically equivalent to
  //
  //   always @(posedge clk_25mhz) if (!user_programn) ... else if (count(buttons[0] == 1) begin
  //     counter <= counter + 1;
  //     if (counter == 0) leds <= leds + 1;
  //   end
  //
  // In a more more complicated Bluescript design, there will be additional
  // conditions inferred by the compiler.
  rule count(buttons[0] == 1);
    counter <= counter + 1;
    if (counter == 0) leds <= leds + 1;
  endrule

  // As mentioned, for the top-level module, this is just exporting
  // the register to the outputs
  method Bit#(8) led();
    return leds;
  endmethod

  // Similarily, but this is "assign wifi_gpio0 = 1"
  method Bool dont_reboot();
    return True;
  endmethod

  // The compiler turns this into
  //
  //   always @(posedge clk_25mhz) buttons <= btn;
  //  
  // (we ignore the user_programn side)
  method Action readButtons(Bit#(7) buttons_in);
    buttons <= buttons_in;
  endmethod
endmodule
