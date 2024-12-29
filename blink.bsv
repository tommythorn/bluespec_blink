// Copyright © 2024 Tommy Thorn <tommy-github2@thorn.ws>
//
// Near-simplest possible example to show ULX3S blinking and writing
// to the serial port

// For the toplevel module, the interface defines the Verilog ports.
// Inputs are read with Action methods and output are written with
// Value methods.  These can be tought of as implicitly invoked by the system
// so it should not be concerning to see no explicit users of them here.
interface Blink;
  (* prefix="" *)           method Action  readButtons((* port="btn" *) Bit#(7) buttons);
  (* result="led" *)        method Bit#(8) led();
  (* result="ftdi_rxd" *)   method Bit#(1) uart_tx(); // Yes, serial tx/rx naming is bad
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
  SerialTx tx <- mkSimpleSerialTx();

  Reg#(Bit#(7))  buttons <- mkRegU;
  Reg#(Bit#(8))  leds    <- mkRegU;

  rule generate_new(buttons[0] == 0);
    tx.send(8'd64 | zeroExtend(leds[5:0]));
    leds <= leds + 1;
  endrule

  // This is just exporting mkSimpleSerialTx.tx to top-level
  method Bit#(1) uart_tx();
    return tx.uart_tx();
  endmethod

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

interface SerialTx;
  method Action send(Bit#(8) ch);
  method Bit#(1) uart_tx();
endinterface

// Serial 8N1 TX
// Max macOS: 230400 @ 25 MHz => divide by 109, 0.5% error, OK
//     Linux:  2Mbps @ 25 MHz => divide by  13, 3.8% error, OK
// Max Linux:  3Mbps @ 25 MHz => divide by   8, 4.2% error, fails
module mkSimpleSerialTx(SerialTx);
  Reg#(Bit#(8))  txBit   <- mkRegU;
  Reg#(Bit#(1))  tx      <- mkReg(1);
  Reg#(UInt#(8))  cyclec <- mkReg(0);
  Reg#(UInt#(4))  bitc    <- mkReg(0);

  rule pass_time(cyclec != 0);
    cyclec <= cyclec - 1;
  endrule

  rule shift_bits(cyclec == 0 && bitc != 0);
    tx <= txBit[0];
    txBit <= {1'd1, txBit[7:1]};
    bitc <= bitc - 1;
    cyclec <= 109 - 1;
  endrule

  method Action send(Bit#(8) ch) if (cyclec == 0 && bitc == 0);
    tx <= 0;
    txBit <= ch;
    bitc <= 9;
    cyclec <= 109 - 1;
  endmethod

  method Bit#(1) uart_tx();
    return tx;
  endmethod
endmodule
