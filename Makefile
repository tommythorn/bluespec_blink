all: prog

mkBlink.v: blink.bsv
	bsc -verilog blink.bsv

blink.json: mkBlink.v
	yosys -p "synth_ecp5 -json blink.json" mkBlink.v

ulx3s_out.config: blink.json
	nextpnr-ecp5 --85k --json blink.json \
		--lpf ulx3s_v20.lpf \
		--textcfg ulx3s_out.config

ulx3s.bit: ulx3s_out.config
	ecppack ulx3s_out.config ulx3s.bit

prog: ulx3s.bit
	fujprog ulx3s.bit
