import processing.serial.*;
import java.util.Map;

Serial serialPort;
String SERIAL_TERMINATOR = "\n";

boolean[] lightsArray = {
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
};
int NO_LIGHTS = lightsArray.length;

int waveWidths[] = {   0,     1,    0,    1,    0,    3,    5,    1,    3,    5,    3,   12,     2,     1,    0};
int durations[]  = {6000, 24000, 2000, 4000, 2000, 7000, 7000, 4000, 5000, 5000, 7000, 4000, 10000, 12000, 5000};
int NO_ANIMATIONS = waveWidths.length;

int waveWidth;
int duration;
int lightIndex = 0;
int sequenceIndex = 0;

int time;
int interval;

boolean animPlaying = false;

void setup() {
  size(650, 250);
  
  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  serialPort = new Serial(this, portName, 9600);
  println("connected to:");
  println(portName);
  
  time = millis();
  
  mouseX = width / 2;
  mouseY = height / 2;
  
  ellipseMode(CENTER);
  
  set_anim_state_from_sequence();
}

void draw() {
  background(127);
  draw_lights(lightsArray);
  
  //set_anim_state_from_mouse();
  drawAnimState();
  
  if (millis() - time > interval) {
    if (animPlaying){
      lightsArray = anim_wave();
    }
    time = millis();
  }
}

void set_anim_state_from_mouse(){
  waveWidth = int(map(mouseX, 0, width, 0, 12));
  duration = int(map(mouseY, 0, height, 0, 12000));
  interval = duration / NO_LIGHTS;
}

void set_anim_state_from_sequence(){
  if (sequenceIndex < NO_ANIMATIONS) {
    waveWidth = waveWidths[sequenceIndex];
    duration  = durations[sequenceIndex];
    interval  = duration / NO_LIGHTS;
  }
}

void drawAnimState() {
  fill(0);
  text("sequence:", 40, 100);
  text(sequenceIndex, 110, 100);
  text("waveWidth:", 40, 120);
  text(waveWidth, 110, 120);
  text("duration:", 40, 140);
  text(duration, 110, 140);
}

boolean[] anim_wave() {
  println("***");
  print("si: ");
  println(sequenceIndex);
  
  print("li: ");
  println(lightIndex);
  
  if (lightIndex >= 0 && waveWidth < NO_LIGHTS + 1) {
    
    // turn on
    int onFrom = lightIndex - waveWidth + 1;
    int onTo = lightIndex;
    
    print("onFrom: ");
    println(onFrom);
    print("onTo: ");
    println(onTo);
    
    for(int j = onFrom; j <= onTo; j++){
      int toTurnOn = j;
      if(toTurnOn >= 0 && toTurnOn < NO_LIGHTS) {         
        lightsArray[toTurnOn] = true;
      }
    }
    
    // turn off
    int toTurnOff = onFrom - 1;
    if(toTurnOff >= 0 && toTurnOff < NO_LIGHTS) {
      print("off: ");
      println(toTurnOff);
      lightsArray[toTurnOff] = false;
    }
  } 
  else {
    println("index out of bounds");
  }  
  
  // increment lightIndex
  lightIndex++;
  if(lightIndex == NO_LIGHTS + waveWidth) { // on end
    next_anim();
    lightIndex = 0;
  }
  
  return lightsArray;
}

void next_anim(){
  sequenceIndex++;
  sequenceIndex = wrapAround(sequenceIndex, NO_ANIMATIONS);
  set_anim_state_from_sequence();
}

void send_animState(){
  serialOut("w"+waveWidth);
  serialOut("d"+duration);
}

void toggleAnim() {
  animPlaying = !animPlaying;
}

void resetAnim() {
  allOff();
  lightIndex = 0;
  sequenceIndex = 0;
}

void allOff() {
  for(int i = 0; i < NO_LIGHTS; i++){         
    lightsArray[i] = false;
  }
}

int wrapAround(int index, int total) {
  if (index < 0) {
    return total + index;
  }
  else if (index > total - 1) {
    return index - total;
  }
  else {
    return index;
  }
}

void draw_lights(boolean[] lightsArray) {
  for (int i = 0; i < lightsArray.length; i++) {
      if (lightsArray[i]){
        fill(255);
      } else {
        fill(0);
      }
      ellipse(50 + i * 50, 50, 20, 20);
  }
}

void serialOut(String message){
  serialPort.write(message);
  serialPort.write(SERIAL_TERMINATOR);
  println("sent over Serial:");
  println(message);
}

// event handlers

void keyPressed() {
  if(key == ' '){
    toggleAnim();
    serialOut("t0");
  }
  else if(key == 'o'){
    serialOut("o0");
    resetAnim();
  }
  else if(key == 'w'){
    serialOut("w1");
  }
  else if(key == '1'){
    serialOut("w"+1);
  }
  else if(key == '6'){
    serialOut("w"+6);
  }
}