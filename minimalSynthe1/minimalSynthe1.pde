import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;



Minim minim;
AudioOutput out;

int bpm = 160;
int beat = 16;
int count = 0;

boolean[] playable;
boolean[] buttonTrigger;

SyntheInterface base_buttons;

String[] pitch_list = {"C4", "F4", "G4", "C4", "C4", "F4", "G4", "C4", "C4", "F4", "G4", "C4", "C4", "F4", "G4", "C4"};

Beats[] beats;

void setup(){
  size(displayWidth, displayHeight);
  pixelDensity(displayDensity());


  playable = new boolean[beat];
  buttonTrigger = new boolean[beat];


  base_buttons = new SyntheInterface(16, 50, 20);
  base_buttons.calcButtonPos();
  base_buttons.dispButtons();


  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  out.setTempo(bpm);

  // Beats bass = new Beats("A1");

  // beats = new Beats[4];
  // beats[0] = new Beats("A1");

  out.playNote(0, 0.25, new Beats("A4"));
  

 
}


void draw(){
  background(255);
  fill(255);
  stroke(0);
  strokeWeight(1);
  strokeCap(SQUARE);

  base_buttons.dispButtons();
  dispWave();

  fill(01);
  text("BASS", 10, 35);
  textSize(36);
}


class Beats implements Instrument {
  String pitch;
  Beats(String pitch){
    this.pitch = pitch;
  }

  void noteOn(float duration){
    playable[count] = (buttonTrigger[count])?true:false;
    
    if(playable[count]) out.playNote(0, 0.25, new Synthe(pitch_list[count]));
  }
  
  void noteOff(){
    count++;
    if (count == beat) count = 0;

    out.setTempo(bpm);
    out.playNote(0.0, 0.25, this);
  }
}


class Synthe implements Instrument {
  Oscil sineWave, sqWave;

  Synthe(String pitch) {
    sineWave = new Oscil(Frequency.ofPitch(pitch), 1, Waves.TRIANGLE);
    sqWave = new Oscil(30.0, 0.4, Waves.SAW);
  }

  void noteOn(float duration){
    sineWave.patch(out);
    sqWave.patch(out);
  }
  
  void noteOff(){
    sineWave.unpatch(out);
    sqWave.unpatch(out);
  }
}


class SyntheInterface {
  int button_width, button_num, margin, button_margin;
  PVector[][] button_pos;

  SyntheInterface(int button_num, int margin, int button_margin){
    button_width = (displayWidth-(margin*2)-(button_margin*(button_num-1)))/button_num;
    this.button_num = button_num;
    this.margin = margin;
    this.button_margin = button_margin;
    for(int i = 0; i < this.button_num; i++) buttonTrigger[i] = false;
  }

  void calcButtonPos() { 
    button_pos = new PVector[button_num][4];

    for(int i = 0; i < button_num; i++) {      
      button_pos[i][0] =  new PVector(margin + i * (button_width + button_margin), displayHeight/2);
      button_pos[i][1] =  new PVector(margin + i * (button_width + button_margin) + button_width, displayHeight/2);
      button_pos[i][2] =  new PVector(margin + i * (button_width + button_margin) + button_width, displayHeight/2 + button_width);
      button_pos[i][3] =  new PVector(margin + i * (button_width + button_margin), displayHeight/2 + button_width);
    }
  }

   void getClick() {
    for(int i = 0; i < button_num; i++) {
      if(mouseX >= button_pos[i][0].x && mouseX <= button_pos[i][1].x && mouseY >= button_pos[i][0].y && mouseY <= button_pos[i][3].y) {
        buttonTrigger[i] = (buttonTrigger[i])? false: true;
      } 
    }
  }

  void dispButtons() {
    for(int i = 0; i < button_num;  i++){
      if(buttonTrigger[i]) fill(0);
      else noFill();
      rect(button_pos[i][0].x, button_pos[i][0].y, button_width, button_width);
    }
  }
}

void mousePressed() {
  base_buttons.getClick();
}

void dispWave(){
  int baffer = 500;
  float x, y, x_2, y_2;

  strokeWeight(100);
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    x = map(i, 0, out.bufferSize() - 1, 50, displayWidth-50);
    y = map(out.left.get(i), -1, 1, 100, 300);
    x_2 = map(i+1, 1, out.bufferSize(), 50, displayWidth-50);
    y_2 = map(out.left.get(i+1), -1, 1, 100, 300);

    line( x, y, x_2, y_2 );
  }
}
