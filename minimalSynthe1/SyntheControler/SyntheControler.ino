int rotateUpDownA = 0; //0PIN
int rotateUpDownB = 1; //1PIN

int rotateRightLeftA = 2; //2PIN
int rotateRightLeftB = 3; //3PIN

int BPM = 60;
int Hz = 30;

boolean rotateUp = false;
boolean rotateDown = false;

boolean rotateLeft= false;
boolean rotateRight = false;

void setup() {
  pinMode(rotateUpDownA, INPUT_PULLUP);
  pinMode(rotateUpDownB, INPUT_PULLUP);
  
  pinMode(rotateRightLeftA, INPUT_PULLUP);
  pinMode(rotateRightLeftB, INPUT_PULLUP);


  attachInterrupt(digitalPinToInterrupt(rotateUpDownA), UpDownPulse, RISING);
  attachInterrupt(digitalPinToInterrupt(rotateRightLeftA), RightLeftPulse, RISING);
  
  //Arduinoでのピン番号とハードウエアの割り込み番号が実際には違うため、digitalPinToInterrupt(2)によりデジタルピン2番の番号をハードウエアのint0に変換
  Serial.begin(38400);
}

void loop() {
  rotateUpDown();
  rotateRightLieft();
//  calcZoomDist();

  Serial.write(Hz);
  
  

  delay(10);
}

//上下の回転パルスを感知
void UpDownPulse() {
  if(digitalRead(rotateUpDownB)==0 && digitalRead(rotateUpDownA)==1){
    rotateUp = true;               
  } else if(digitalRead(rotateUpDownB)==1 && digitalRead(rotateUpDownA)==1){
    rotateDown = true;
  }
}

//上下の回転パルスに合わせて回転
void rotateUpDown(){
  if(rotateUp){
      BPM += 1;
      if(BPM > 200){
        BPM = 200;
      }
      rotateUp = false;
  } 
  else if(rotateDown){
  BPM -= 1;
  rotateDown = false;  
   
  }
}

//左右の回転パルスを感知
void RightLeftPulse() {
  if(digitalRead(rotateRightLeftB)==0 && digitalRead(rotateRightLeftA)==1){
    rotateRight = true;               
  } else if(digitalRead(rotateRightLeftB)==1 && digitalRead(rotateRightLeftA)==1){
    rotateLeft = true;
  }
}

//左右の回転パルスに合わせて回転
void rotateRightLieft(){
  if(rotateLeft){
    Hz -= 2;
    rotateLeft = false;  
    
  } else if(rotateRight){
    Hz += 2;
    rotateRight = false;  
  }
}
