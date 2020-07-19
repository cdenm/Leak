import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscP5 sendOSC;
NetAddress myRemoteLocation;
NetAddress sendLocation;

//trig stuff
float angle = 0.5;
float speed = 0.05;
//radius
float acceleration;


PImage[] water = new PImage[4];
PGraphics m;
PImage[] machine = new PImage[4];

long lastTime = 0;
int frameNumber = 0;
long lastTime2 = 0;
int frameNumber2 = 0;
int counter = 1;

int inputWave = 20;
int inputBell = 255;

float distortion = 0;


Wave myWave;
Drop[] drops = new Drop[100]; // array of drop objects

void setup() {
  frameRate(30);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  sendOSC = new OscP5(this, 4559);
  sendLocation = new NetAddress("127.0.0.1", 4559);
  
  size (750,950, P2D);
  //fullScreen(P2D);
  acceleration = height* 0.95;
  m = createGraphics(width,height, P2D);
  lastTime = millis();
  for (int i = 0; i < drops.length; i++) { // we create the drops 
    drops[i] = new Drop();
  }
  
  //LOAD IMAGES
  for (int i = 0; i < machine.length; i++) {
    machine[i] = loadImage("machine"+i+".png");
    machine[i].resize(width, round(height*0.45));
  }
  for (int i = 0; i < water.length; i++) {
    water[i] = loadImage("water"+i+".png");
    water[i].resize(width, height);
  }
}


void draw () {
  System.out.print("acceleration "+ acceleration + "\n");

  //set background, make random same, translate to middle
  background(inputBell-50);
  
    for (int i = 0; i < drops.length; i++) {
    drops[i].fall(); // sets the shape and speed of drop
    drops[i].show(); // render drop
  }
   if ( millis() - lastTime > 100 ) {
     frameNumber+= 1; 
     if (frameNumber > 3){
       frameNumber = 0;
     }
    lastTime = millis();
    compression();
   }
   image(machine[frameNumber],0,0);
  randomSeed(600);
  
  if (inputWave > 20){
    inputWave = inputWave -1;
  }
  
    if (inputBell < 255){
    inputBell = inputBell +1;
  }

  pushMatrix();
  //translate(0,acceleration);
  if (acceleration > 0){
  acceleration = acceleration - 0.25;}
  else {
    acceleration = height* 0.95; 
    m.beginDraw();
    m.clear();
    m.endDraw();
  }

  
  stroke(0);
   

    //make wave with random x pos for bezier curves
    myWave = new Wave(int(random(width)),int(random(width)));
    //myWave = new Wave(0.5,0.5);

    
    myWave.display();

  
  angle += speed;
  popMatrix();
  

}



class Wave {
  float b1x;
  float b1y;
  float b2x;
  float b2y;
  float sinval;
  float cosval;
 
  
  Wave(float x1, float x2) {

    b1x = x1;
    b2x = x2;
  }
  
  void display() {
    
    //Trig Math for motion
    sinval = sin(random(angle));
    cosval = cos(random(angle));
    float b1y =  ((sinval * inputWave)+acceleration);
    float b2y = ((cosval * inputWave)+acceleration);
    
    //draw string
    fill(0);
    noStroke();
    m.beginDraw();
    m.beginShape();
    m.vertex(0,acceleration);
    m.bezierVertex(b1x,b1y,b2x,b2y,width,acceleration);
    m.vertex(width,height);
    m.vertex(0,height);
    m.endShape(); 
    m.endDraw();
    
    //println(b1x, b1y, b2x, b2y);
    
   if ( millis() - lastTime2 > 150 ) {
     frameNumber2+= counter; 
     if (frameNumber2 == 3){
       counter = -1;
     }
     if (frameNumber2 == 0){
       counter = 1;
     }
    lastTime2 = millis();
   }
    water[frameNumber2].mask(m);
    randomSeed(millis());
    tint(inputBell);
    image(water[frameNumber2],0,0);
    //noTint();
    
    
  }
}

void oscEvent(OscMessage msg) {
  System.out.println("### got a message " + msg);
  System.out.println( msg);
  System.out.println( msg.typetag().length());


  if (msg.checkAddrPattern("/viz/inputWave")==true) {
        inputWave =msg.get(0).intValue();
        System.out.print("input1 "+ inputWave + "\n");
        //compression();
    }
    
    if (msg.checkAddrPattern("/viz/inputBell")==true) {
        inputBell =msg.get(0).intValue();
        System.out.print("input1 "+ inputBell + "\n");
    }  
  }
  
void compression(){ //function to send stop message to Sonic Pi on local machine
  distortion = norm(acceleration, 0, height);
  if (distortion < 0.05){
    distortion = 0.05;
  }
  OscMessage myMessage = new OscMessage("/distortion");
  myMessage.add(distortion);
  sendOSC.send(myMessage, sendLocation); 
  System.out.print("distortion "+ distortion + "\n");

}
