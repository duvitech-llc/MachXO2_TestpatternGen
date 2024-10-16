module top (
    input stdby_in,       // Standby input
    output stdby1,        // Standby output
    output osc_clk,       // Oscillator clock output
    output led0, led1, led2, led3, led4, led5, led6, led7, // LED outputs
    output frame_valid,   // Frame valid signal for scope
    output line_valid,        // Line valid signal for scope
    output [9:0] histo_data,  // 10-bit histogram data output
    output histo_valid,       // Histogram data valid signal
    output histo_clock        // Histogram clock signal
);

    wire stby_flag;
    reg [21:0] cnt;

    // Internal Oscillator
    defparam OSCH_inst.NOM_FREQ = "133.00";	// 133 MHz clock

    OSCH OSCH_inst(
        .STDBY(stdby1), 	// 0=Enabled, 1=Disabled also Disabled with Bandgap=OFF
        .OSC(osc_clk),      // Oscillator clock output
        .SEDSTDBY()         // Not required if not using SED
    );

    pwr_cntrllr pcm1 (
        .USERSTDBY(stdby_in), 
        .CLRFLAG(stby_flag), 
        .CFGSTDBY(1'b0),  
        .STDBY(stdby1), 
        .SFLAG(stby_flag)
    );

    // LED Blinking test (Toggle LEDs every 1/2 second)
    always @(posedge osc_clk or posedge stdby_in)
        if (stdby_in)
            cnt <= 0;
        else	
            cnt <= cnt + 1;

    assign led0 = stdby_in ? 1'b1 : cnt[20];
    assign led1 = stdby_in ? 1'b1 : ~cnt[20];
    assign led2 = stdby_in ? 1'b1 : cnt[20];
    assign led3 = stdby_in ? 1'b1 : ~cnt[20];
    assign led4 = stdby_in ? 1'b1 : cnt[20];
    assign led5 = stdby_in ? 1'b1 : ~cnt[20];
    assign led6 = stdby_in ? 1'b1 : cnt[20];
    assign led7 = stdby_in ? 1'b1 : ~cnt[20];

    // Grayscale Color Bar Generator
    wire [9:0] pixel_out;  // 10-bit pixel output
    grayscale_color_bar grayscale_gen (
        .clk(osc_clk),         // 133 MHz clock input
        .reset_n(~stdby_in),   // Active low reset input
        .pixel_out(pixel_out), // Grayscale pixel output
        .line_valid(line_valid),  // Line valid output signal
        .frame_valid(frame_valid) // Frame valid output signal
    );

endmodule
