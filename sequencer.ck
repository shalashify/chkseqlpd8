// Step Sequencer for Samples

// - Drum patterns can be configured on the fly using LPD8 Sequencer input
// - Supports loading patterns and drum samples
// - Output to LPD8 highights the pads that are playing
// - One MIDI device can be clocked
// - Recording funtionality is provided by an external Chuck Script rec.ck

// Set BPM and calculate a duration of one step
140.0 => float bpm;
4 => int resolution;
minute / bpm / resolution => dur step;

// Root path to samples
"/Users/alec/Recording/Tools/Chuck/Samples/" => string rootPath;

// Path to recording script
"/Users/alec/Recording/Tools/Chuck/rec.ck" => string recScriptPath;

// Drum machine buffer - maximum number of Samples played in parallel
SndBuf samples[6];

// Common gain control and echo effect
Echo e2 => Pan2 p => JCRev jre => blackhole;

Gain g => Echo e1 => dac;
Gain gl => dac.left;
Gain gr => dac.right;

// Dynamic parameter initialization
0.0 => g.gain;
0.0 => gl.gain;
0.0 => gr.gain;
0::ms => e1.delay;
//0::ms => e2.delay;

// Midi Outputs for LPD8 and a clocked device
MidiOut lpd8out;
MidiOut clockout;

// Load available MIDI In and MIDI Out devices
loadMIDI();
loadMIDIOut();

// Sequencer dynamic settings
16 => int patternLength; // Starting pattern length: 16 or 32

// What is currently playing
0 => int currPattern;
6 => int currPreset;
0 => int currSample;

// Temp Variables that are used to control the output (output only if something changes)
-1 => int prevPattern;
-1 => int prevPreset;
-1 => int prevChangeTrack;

// What is currently being changed
-1 => int changeTrack; // Drum track
-1 => int changeStep; // Step (currSample)
-1 => int changeTo; // Change to Off (0) or On (1)
-1 => int lightOnPad; // Pad to highlight
-1 => int eraseMe; // Signal to erase current pattern

// Recording - external Script rec.ck is required
0 => int rec; // Signal to start recording

// Preset includes:
// - Path to Sample Folder
// - Array with max 5 Drum Types, Drum Type Names correspond to the names of Sample Files
// - up to 8 Drum Patterns

// Relative path to the samples folder per Preset
["Drums/Industrial/Set1/",
"Drums/Industrial/Set2/",
"Drums/Breakbeat/Set1/",
"Drums/Breakbeat/Set2/",
"Drums/IDM/Set1/",
"Drums/Vinyl/Set1/",
"Drums/Vinyl/Set2/",
"Drums/Standard/Set1/"
] @=> string availableSets[];

// Available Samples (available .wav Files) per Preset
// Kick-Snare-Closed Hat-Open Hat-Percussion-Tom
[
["Kick", "Snare", "ClosedHat", "OpenHat", "Tom", "Tom2"]
, ["Kick", "Snare", "ClosedHat", "OpenHat", "Tom", "Tom2"]
, ["Kick", "Snare", "ClosedHat", "OpenHat", "Tamb", ""]
, ["Kick01", "Snare01", "ClHat01", "OpHat01", "", ""]
, ["Kick", "Snare", "ClHat", "OpHat", "Bass", "Tom"]
, ["Kick", "Snare", "ClosedHat", "OpenHat", "Shaker", "Tom"]
, ["Kick", "Snare", "ClosedHat", "OpenHat", "Shaker", "Tom"]
, ["Kick", "Snare", "ClosedHat", "OpenHat", "", ""]
] @=> string availableSamples[][];

// Pannings of the samples
["C", "C", "L", "L", "R", "C"] @=> string panSamples[];

// Gains of the Samples
[1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float gainSamples[];

// Load samples and assign to the chain before echo
loadSamples();

// Configure Drum Patterns per Preset
[
//--1---2---3---4---5---6---7---8---9--10--11--12--13--14--15--16
[ // #1 Blank
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #2 Metronome
[1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #3 Motorik
[1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0],
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #4 Trip Hop
[0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
[1,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[1,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #5
[1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #6 Slow Industrial
[1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,1],
[0,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0],
[0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
// #7 Dreamy Industrial
[
[1,0,0,0,0,1,0,0,0,0,1,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,1,0,0,0],
[0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #8 Hip Hop
[1,0,0,0,0,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,1,0],
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #9 IDM
[1,0,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,0,1,1,1,1,1,1,1],
[0,1,0,0,1,0,0,1,0,0,0,0,1,1,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1,1,0,0],
[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
[0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #10 The Funky Drummer
[1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0],
[0,0,0,0,1,0,0,1,0,1,0,1,1,0,0,1,0,0,0,0,1,0,0,1,0,1,0,1,1,0,0,1],
[1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,1],
[0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
],
[ // #11 Cold Sweat
[1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0],
[0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,1],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
]
] @=> int drumPatterns[][][];

// 1 - hard motorik 100+ bpm
// 2 - hiphop 90-110 bpm
// 3 - triphop 70-90 bpm
// 4 - motorik base industrial any bpm
// 5 - slow industrial 80-110 bpm
// 6 - the funky drummer
// 7 - cold sweat

if(drumPatterns[0][0].cap() == 0 || samples.cap() == 0) {
  <<< "[dac] no patterns or samples loaded" >>>;
  me.exit();
}

// <<<"Sequencer is waiting for Input">>>;

// Output Message for LPD8 to manage the lights on the pads
MidiMsg msgout;

// Temp variables
int onOff;
int recordingId;
int startRec;
string strPattern;

-1 => recordingId;
0 => int clockIsTicking;

sendMIDIClockTick();
sendMIDIClockTick();
sendMIDIClockTick();
sendMIDIClockTick();
sendMIDIClockTick();
sendMIDIClockTick();

// Endless cycle that goes when current pattern is set to a non-negative value
while(true) {
  // i = column (step), j = row (sample)
    for( 0 => int i; i < patternLength; i++) {

    -1 => lightOnPad;
    // Recording starts from the beginning of the pattern
    if( i == 0 && rec == 1 ) {
            2 => rec; // Set the flag that the recording is running

            // Recording is performed by an external Chuck Script
            Machine.add(recScriptPath) => recordingId;
    }

        for( 0 => int j; j < samples.cap(); j++) {
      // For each 1 in the pattern get the name of the current sample basing on the row number in the pattern (j)
      if(currPattern >= 0 && drumPatterns[currPattern][j][i] == 1) {
        j => currSample;
        if(samples[currSample] != NULL) {
          0 => samples[currSample].pos;
          gainSamples[currSample] => samples[currSample].gain;
          1.0 => samples[currSample].rate;
        }
            }
            strPattern + " " + drumPatterns[currPattern][j][i] => strPattern;
        }

        // If current track is the one that is currently being changed then save the number of the current step
        if(currPattern >= 0 && changeTrack != -1) {
            i => lightOnPad;
            drumPatterns[currPattern][changeTrack][i] => onOff;
        } else {
            -1 => lightOnPad;
            0 => onOff;
        }

    // Turn any light on the track off
    lightPad(lightOnPad, 0);

    //MidiClock - endless cycle that sends MIDI Clock Out basing on the current step duration
    if (clockIsTicking == 0) {
          sendMIDIClockStart();
          1 => clockIsTicking;
    } else {
          sendMIDIClockTick();
    }

    // For each step advance time let the samples sound and let the MIDI Clock tick!
    sendMIDIClockTick();
    sendMIDIClockTick();
    sendMIDIClockTick();
    sendMIDIClockTick();
    sendMIDIClockTick();

    if(rec == 2) { // For running recording
      <<< "[rec]: Recording ", strPattern >>>; // Output pattern
      if(i == patternLength-1) { // Stop recording if this is the last step of the sequence
        0 => rec;
                if(recordingId != -1) {
                    Machine.remove(recordingId);
                }
      }
    }

        // Turn the "light on" if the track has a sample on a current position and "light off" if not
    lightPad(lightOnPad, onOff);

        -1 => lightOnPad;
    "" => strPattern;
    }

  // Output actual information on the setup after a sequence has played
    if(currPattern >= 0 && prevPattern != currPattern) {
         <<< "[dac] Pattern",currPattern, patternLength, "steps", bpm, "bpm" >>>;
         currPattern => prevPattern;
         if(changeTrack >= 0 && changeTrack != prevChangeTrack) {
            changeTrack => prevChangeTrack;
      <<< "[seq] Editing Track ", changeTrack >>>;
        }
    }
}

// Loads Samples for Drum Patterns
fun void loadSamples(){
  0 => int j;

  // Loading samples
  for(0 => int i; i < availableSamples[currPreset].cap(); i++) {
    if(availableSamples[currPreset][i] != "" && availableSets[currPreset] != ""){
      rootPath + availableSets[currPreset] + availableSamples[currPreset][i] + ".wav" => samples[j].read;
            // Assign samples to different chains for panning
            if (panSamples[i] != "") {
                if(panSamples[i] == "L") {
                    samples[j] => gr;
                } else if (panSamples[i] == "R") {
                    samples[j] => gl;
                } else {
                    samples[j] => g;
                }
            } else {
               samples[j] => g;
            }
            j++;
    }
  }

  // In case no samples have been loaded
  if(j == 0) {
    -1 => currPattern;
    <<< "[seq] No samples found, current pattern set to -1 ">>>;
  } else {
    <<< "[seq]", j, "Samples loaded for preset", currPreset >>>;
  }
}

// Load Midi Out devices
// LPD8 is the Out that receives info which pads to highlight
// Clockout device is the one that is being clocked

fun void loadMIDIOut(){
  // devices to open
  MidiOut mout[4];

    // number of devices
    int outdevices;

    // connect Midi Out devices
    for( 0 => int i; i < mout.cap(); i++ ) {
        mout[i].printerr( 0 ); // no error

        // Open the device and check its name; LPD8 is assigned to the lpd8out, any other device is assigned the clockout
        if( mout[i].open(i) ) {
             //<<< "[midiout] device ", i, ": ", mout[i].name(), " opened" >>>;
            if(mout[i].name() == "LPD8" ) {
                lpd8out.open(i);
                <<< "[midiout] Sequencer", i, ":", lpd8out.name(), "opened" >>>;
                outdevices++;
            } else if(mout[i].name() == "Steinberg UR22 Port1" ) {
                clockout.open(i);
                <<< "[midiout] Clocked device", i, ":", clockout.name(), "opened" >>>;
                outdevices++;
            }
            //outdevices++;
        }
        else break;
    }

    if( outdevices == 0 ) {
        <<< "[midi] No MIDI Out devices" >>>;
        me.exit();
    }
}

// Loads MIDI In Devices
fun void loadMIDI(){
  // devices to open (chuck --probe)
  MidiIn min[3];

  // number of devices
  int devices;

  // connect midi devices and open a shread for each event parser
  for( 0 => int i; i < min.cap(); i++ ) {
    min[i].printerr( 0 ); // no error
    // open the device
    if( min[i].open( i ) ) {
      if(min[i].name() == "LPD8" ) {
                <<< "[midiin] Sequencer", i, ":", min[i].name(), "opened" >>>;
                spork ~ waitMIDI( min[i], i);
            }
      devices++;
    }
    else break;
  }

  if( devices == 0 ) {
    <<< "[midiin] No MIDI devices" >>>;
    me.exit();
  }
}

// Processing of MIDI events to control the unit generators
fun void processMIDI (int deviceid, int msgdata1, int msgdata2, int msgdata3)
{
  // Dummy variables for storing the attribute values
  float varf;
  dur vard;
  int vari;
  int z;

    // Debugging of the midi-in // <<< "[tmp]", msgdata1, " / ", msgdata2 >>>;

  // ------------- Program Change Mode ------------- //
  // Preset 1, any pad: Load samples
  if (msgdata2 >= 36 && msgdata2 <= 43 ){
    msgdata2-36 => vari;
      if (vari+1 > availableSets.cap()) {
      <<< "[seq] Samples set", vari, "not found" >>>;
    } else {
      vari => currPreset;
      loadSamples();
      <<< "[seq] Samples set", currPreset >>>;
    }
  }
  // Preset 2, any pad: Change drum pattern to a precofigured one
    else if (msgdata2 >= 28 && msgdata2 <= 35){
        msgdata2-28 => vari;
        if(vari+1 > drumPatterns.cap()) {
            <<< "[seq] Drum pattern", vari, "not found" >>>;
        } else {
      vari => currPattern;
      <<< "[seq] Drum pattern", currPattern >>>;
        }
    }
  // Preset 3, pad 1: Change the pattern length 16 <> 32
    else if (msgdata2 == 20) {
        if(patternLength == 16) {
            32 => patternLength;
        } else {
            16 => patternLength;
        }
        <<< "[seq] Pattern length", patternLength >>>;
    }
  // Preset 3, pad 2: Start/end the recording
  else if (msgdata2 == 21) {
        if(rec == 0) {
            1 => rec;
        } else {
            0 => rec;
        }
        <<< "[seq] Recording mode", rec >>>;
    }
    // Preset 3, pad 3, double tap: Erase current pattern
    else if (msgdata2 == 22) {
        if(eraseMe == -1) {
            1 => eraseMe;
            <<< "[seq] Confirm to erase" >>>;
        } else if(eraseMe == 1) {
            2 => eraseMe;
            erasePattern();
            <<< "[seq] Pattern erased" >>>;
            -1 => eraseMe;
        }
    }
  // ------------- Control Change Mode ------------- //
  // Preset 1/2/3/4, any pad, on pad pressed: Select a Drum Track to change
    else if (msgdata2 >= 44 && msgdata2 <= 51 && msgdata1 == 176) {
        msgdata2-44 => vari;
        if(vari+1 > availableSamples[currPreset].cap()) {
       <<< "[seq] Track", vari, "not found" >>>;
        } else {
      vari => changeTrack;
            <<< "[seq] Editing track", changeTrack >>>;
       }
    }
  // ------------- Pad Mode ------------- //
    // Preset 1/2/3/4, any pad, on pad pressed: Set/unset the step of the sequence
    else if (msgdata2 >= 52 && msgdata2 <= 83 && msgdata1 == 144){
        msgdata2-52 => vari;
    vari => changeStep;
    changePattern();
    <<< "[seq] Editing step", changeStep, "/", changeTrack >>>;
    }
  // ------------- Knobs ------------- //
    // Preset 1/2/3, knob 1: Master gain
  else if(msgdata2 == 1) {
        1.0 / 127.0 * msgdata3  => varf;
        varf => g.gain;
        varf => gl.gain;
        varf => gr.gain;
        <<< "[par] Gain", varf >>>;
    }
  // Preset 1/2/3, knob 2: Master BPM
    else if(msgdata2 == 2) {
        60.0 + msgdata3  => bpm;
        <<< "[par] BPM", bpm >>>;
        minute / bpm / resolution => step;
    }
  // Preset 1/2/3, knob 3-8: Gain of the respective drum track
    else if(msgdata2 >= 3 && msgdata2 <= 8) {
        1.0 / 127.0 * msgdata3  => varf;
        <<< "[par] Sample Gain", varf >>>;
        varf => gainSamples[msgdata2-3];
    }
    // Preset 4, knob 1: Echo 1
    else if(msgdata2 == 120) {
        step * msgdata3 / 127 => vard;
        vard => e1.delay;
        <<< "[par] Delay 1", vard >>>;
    }
    // Preset 4, knob 2: Echo 1
    else if(msgdata2 == 121) {
        1.0 / 127.0 * msgdata3 => varf;
        varf => jre.mix;
        <<< "[par] Reverb", varf >>>;
    } else {
    // do nothing
  }
}

// Erase playing pattern
fun void erasePattern()
{
    if(currPattern != -1 && eraseMe == 2) {
        for( 0 => int z; z < patternLength; z++) {
            for( 0 => int x; x < samples.cap(); x++) {
                0 => drumPatterns[currPattern][x][z];
            }
       }
       -1 => eraseMe;
    }
}

// Logic for editing the Steps of the Patters
fun void changePattern ()
{
  // Check whether change signal was sent
    if(changeTrack != -1 && changeStep != -1) {
        if(drumPatterns[currPattern][changeTrack][changeStep] == 1) {
      0 => changeTo;
        } else if(drumPatterns[currPattern][changeTrack][changeStep] == 0) {
      1 => changeTo;
        }
        changeTo => drumPatterns[currPattern][changeTrack][changeStep];
        <<< "[seq] Step", changeStep , "to", changeTo >>>;
        -1 => eraseMe;
    }
}

// Sends MIDI Out to turn the lights on the Pads on (onOff=1) and off (onOff=0)
fun void lightPad ( int padNumber, int onOff ){
  if (padNumber != -1) {
        if (onOff == 1) {
      144 => msgout.data1;  // 144 light On for channel 1
    } else {
            128 => msgout.data1;  // 128 light Off for channel 1
        }
        // Set the MIDI Note (Pad number)
        52 + padNumber => msgout.data2;
        127 => msgout.data3;
        // Send MIDI out
        lpd8out.send(msgout);
  }
}

// Handler for a MIDI In event
fun void waitMIDI ( MidiIn min, int deviceid )
{
    MidiMsg msg;
    while( true )
    {
        min => now;
        while( min.recv( msg ) )
        {
            // <<< "[midi] ", deviceid, ":", msg.data1, msg.data2, msg.data3 >>>;
            processMIDI(deviceid, msg.data1, msg.data2, msg.data3 );
    }
    }
}

// Send MIDI Clock
// the clocking interval is based on the current step duration
// changing the step duration (i.e. changing BPM) outside of the function will result in changing the clock tick
fun void sendMIDIClockTick() {
   // while (true) {
        MidiMsg midiMsg;
        0xf8 => midiMsg.data1; // MIDI clock
        0 => midiMsg.data2;
        0 => midiMsg.data3;
        clockout.send(midiMsg); // Send a message to the clocked device
        step/6 => now; // maybe after send?
   // }
}

// Send MIDI Clock
// the clocking interval is based on the current step duration
// changing the step duration (i.e. changing BPM) outside of the function will result in changing the clock tick
fun void sendMIDIClockStart() {
    // while (true) {
    MidiMsg midiMsg;
    0xfa => midiMsg.data1; // MIDI clock
    0 => midiMsg.data2;
    0 => midiMsg.data3;
    clockout.send(midiMsg); // Send a message to the clocked device
   // step/6 => now; // maybe after send?
    // }
}
