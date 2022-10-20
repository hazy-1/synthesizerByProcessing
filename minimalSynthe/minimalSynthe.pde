import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioOutput out;

//テンポと拍数
int bpm = 160;
int beat = 16;
int count = 0;  


Beats[] beats;
Beats beattest;
Synthesizer synthe;

String[] pitchList = {"C#4", "D#4", "F#4", "G#4", "A#4"};


void setup(){
  size(displayWidth, displayHeight);
  pixelDensity(displayDensity());

  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  out.setTempo(bpm);

  synthe = new Synthesizer();

  synthe.setSyntheSounds();
}


void draw(){
  background(255);
  fill(255);
  stroke(0);
  strokeWeight(1);
  strokeCap(SQUARE);

  synthe.dispButtons();
  dispWave();
}


class Beats extends SyntheInterface implements Instrument {
  String pitch;
  boolean[] playable;

  Beats(int height, String pitch){
    //親クラスのコンストラクタ
    super(height, 16, 50, 20);

    this.pitch = pitch;
    playable = new boolean[beat];
    for(int i = 0; i < beat; i++) {
      playable[i] = false;
    }
    
  }

  //Interface実装
  void noteOn(float duration){
    playable[count] = (buttonTrigger[count])?true:false;
    if(playable[count]) out.playNote(0, 0.25, new Synthe(pitch));
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
    // sqWave = new Oscil(30.0, 0.4, Waves.SAW);
  }

  void noteOn(float duration){
    sineWave.patch(out);
    // sqWave.patch(out);
  }
  
  void noteOff(){
    sineWave.unpatch(out);
    // sqWave.unpatch(out);
  }
}


class SyntheInterface{
  int button_width, button_height, button_num, margin, button_margin;
  boolean[] buttonTrigger;
  PVector[][] button_pos;

  SyntheInterface(int button_height, int button_num, int margin, int button_margin){
    buttonTrigger = new boolean[beat];

    button_width = (displayWidth-(margin*2)-(button_margin*(button_num-1)))/button_num;
    this.button_height = button_height;
    this.button_num = button_num;
    this.margin = margin;
    this.button_margin = button_margin;
    
    for(int i = 0; i < this.button_num; i++){
      buttonTrigger[i] = false;
    }
  }

  void calcButtonPos() { 
    button_pos = new PVector[button_num][4];
    println("Hi");

    for(int i = 0; i < button_num; i++) {      
      button_pos[i][0] =  new PVector(margin + i * (button_width + button_margin), button_height);
      button_pos[i][1] =  new PVector(margin + i * (button_width + button_margin) + button_width, button_height);
      button_pos[i][2] =  new PVector(margin + i * (button_width + button_margin) + button_width, button_height + button_width);
      button_pos[i][3] =  new PVector(margin + i * (button_width + button_margin), button_height + button_width);
      // println(button_pos[i]);
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

class Synthesizer {
  int soundNum;

  Synthesizer() {
    soundNum = 5;
    beats = new Beats[soundNum];
    // pitchList = new String[soundNum]; 
  }

  void setSyntheSounds() {
    for(int i = 0;  i < soundNum; i++){
      
      beats[i] = new Beats(displayHeight-(i*100)-100, pitchList[i]);
      beats[i].calcButtonPos();
      beats[i].dispButtons();

      out.playNote(0, 0.25, beats[i]);
    }
  }

  void clickImp() {
    for(int i = 0;  i < soundNum; i++) {
      beats[i].getClick();
    }
  }

  void dispButtons() {
    for(int i = 0;  i < soundNum; i++) {
      beats[i].dispButtons();
    }
  }
}

void mousePressed() {
  synthe.clickImp();
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
