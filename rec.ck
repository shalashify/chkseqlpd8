dac => Gain g => WvOut2 w => blackhole;

"chuck-session" => w.autoPrefix;
"special:auto" => w.wavFilename;
<<<"writing to file: ", w.filename()>>>;

// any gain you want for the output
1.0 => g.gain;

// temporary workaround to automatically close file on remove-shred
null @=> w;

// infinite time loop
while( true ) 100::ms => now;
