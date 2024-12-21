// Near-simplest possible example to show ULX3S blinking

interface Blink;
  (* prefix="" *)           method Action  readButtons((* port="btn" *) Bit#(7) buttons);
  (* result="led" *)        method Bit#(8) led();
  // Tie GPIO0, keep board from rebooting
  (* result="wifi_gpio0" *) method Bool dont_reboot();
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

  rule count(buttons[0] == 1);
    counter <= counter + 1;
    if (counter == 0) leds <= leds + 1;
  endrule

  method Bit#(8) led();
    return leds;
  endmethod

  method Bool dont_reboot();
    return True;
  endmethod

  method Action readButtons(Bit#(7) buttons_in);
    buttons <= buttons_in;
  endmethod
endmodule
