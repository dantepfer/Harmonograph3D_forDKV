//press P to output 3D obj
//add aug (16/20/25) and dim (5/6/7) triads, both natural and equal tempered

//cool thing is 17:19:21 and move the 17 around to 18 and 16 — nice progression

import processing.sound.*;
import nervoussystem.obj.*; //for outputing 3D file
boolean recordObj = false;
import controlP5.*;
import themidibus.*;

ControlP5 cp5;
MidiBus midiBusKeyboard;  //DKV to send notes to
MidiBus midiBusLaunchControl;  //DKV to send notes to

float camSpeed = 50;
float rotIncr = .1;
PVector camDir, camPos; 
float camRotY=-PI; //camera azimuth angle
float camRotX=0; //camera elevation angle
float rotationSpeed = 0.01;
int shouldRotate = 1;

float rotThetaY=0;
float rotThetaX=0;

float baseFreq = 220.0;

float theta1 = 0;  
float theta2 = 0;
float theta3 = 0;
public float theta1Incr = 4.0;
public float theta2Incr = 5.0;
public float theta3Incr = 6.0;
public float thetaScaleFactorMultiplier = 0.006; //was 0.007 before
int iterations = 35000;
int maxIterations = 140000;
int minIterations = 20;
float logSlope = 100;
public float iterationsLog = log(iterations) - logSlope;
int detuneB = 0;
int detuneC = 0;
float detuneAmountPerFrame2 = 0.00002;
float detuneAmountPerFrame3 = -0.00002;
float mouseDeltaX=0;
float mouseDeltaY=0;

float twelthRootOfTwo = 1.05946309436;

int scaleFactor = 400;
PFont myFont;
CheckBox checkBox;
Slider iterationSlider;

int mySlowCounter = 1;
int cameraFollowsTraveller = 0;
int travellerOn = 1;
PVector travellerModelOrig = new PVector(0,0,0);
PVector travellerModelDest = new PVector(0,0,0);
int travellerLength = 2; //at least 2!

int showAxes = 0;

public float phaseB = 0;
public float phaseC = 0;

SinOsc[] sine = new SinOsc[3];

IntList notesDown;
int middleAFrequency = 440;
String triadName = "";
int highestTriadNote = 72; //don't listen to midi above this for triad notes
int lowestTriadNote = 21; //don't listen to midi above this for triad notes

int midiControllerFaderNumbers[] = {41, 42, 43, 44, 45, 46, 47, 48}; //midi controller number for the faders 
int midiControllerButtonNumbers[] = {1, 2, 3, 4, 5, 6, 7, 8}; //midi controller number for the buttons 

float sineVolume = 0.2; 

void setup() {
  //size(1400, 800, P3D);
  fullScreen(P3D, 1);
  //pixelDensity(displayDensity());
  pixelDensity(2);
  smooth();
  
  notesDown = new IntList();
  
  frameRate(64);
  
  MidiBus.list();
  //midiBusKeyboard = new MidiBus(this, "Port1", "Port1");  //change 2nd one for DKV if not using MIDI interface
  midiBusKeyboard = new MidiBus(this, "CME U2MIDI", "Port1");  //change 2nd one for DKV if not using MIDI interface
  midiBusLaunchControl = new MidiBus(this, "Launch Control", "");  
  
  
  camDir = new PVector(0,0,-1);
  camPos = new PVector(width/2,height/2,1200);
  myFont = createFont("Serif-15",15); 
  
  
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  
  ////this is cool when number of ticks is not same as interval — eg 20 ticks when range is 1,21 — so that it's all a little out of tune
  //cp5.addSlider("theta1Incr")
  //  .setPosition(20,50)
  //  .setRange(1,25)
  //  .setSize(20,300)
  //  .setNumberOfTickMarks(25)
  //  .showTickMarks(false)
  //  .setColorCaptionLabel(0) 
  //  .setCaptionLabel("   a") 
  //;
  
  //  cp5.addSlider("theta2Incr")
  //   .setPosition(50,50)
  //   .setRange(1,25)
  //   .setSize(20,300)
  //   .setNumberOfTickMarks(25)
  //   .showTickMarks(false)
  //   .setColorCaptionLabel(0) 
  //  .setCaptionLabel("   b") 
  //;
  
  //  cp5.addSlider("theta3Incr")
  //   .setPosition(80,50)
  //   .setRange(1,25)
  //   .setSize(20,300)
  //   .setNumberOfTickMarks(25)
  //   .showTickMarks(false)
  //   .setColorCaptionLabel(0) 
  //   .setCaptionLabel("   c") 
  //;
  
//checkBox = cp5.addCheckBox("checkBox")
  //              .setPosition(20, 400)
  //              .setSize(20, 20)
  //              .setItemsPerRow(1)
  //              .setSpacingColumn(40)
  //              .setSpacingRow(10)
  //              .addItem("rotate", 0)
  //              .addItem("detuneB", 0)
  //              .addItem("detuneC", 0)
  //              .addItem("follow traveller",0)
  //              .addItem("traveller",0)
  //              .addItem("show axes",0)
  //              .setColorLabels(0)
  //     ;
       
 //iterationSlider = cp5.addSlider("iterationsLog")
  //   .setPosition(width-50,50)
  //   .setRange(log(minIterations)-logSlope,log(maxIterations)-logSlope)
  //   .setSize(20, height -100)
  //   .setColorCaptionLabel(0)
  //   .setCaptionLabel(" ITER") 
  //;
  
 //cp5.addSlider("thetaScaleFactorMultiplier")
  //   .setPosition(width-80,50)
  //   .setRange(0.001, 0.25)
  //   .setSize(20, 300)
  //   .setColorCaptionLabel(0)
  //   .setCaptionLabel("DETAIL") 
  //;
  
 //cp5.addSlider("phaseB")
  //   .setPosition(20,700)
  //   .setRange(0, PI/2)
  //   .setSize(20, 140)
  //   .setColorCaptionLabel(0)
  //   .setCaptionLabel("PhaseB") 
  //;
  //cp5.addSlider("phaseC")
  //   .setPosition(50,700)
  //   .setRange(0, PI/2)
  //   .setSize(20, 140)
  //   .setColorCaptionLabel(0)
  //   .setCaptionLabel("PhaseC") 
  //;
  
  //cp5.addButton("Natural_Major_Triad")
  //   .setValue(0)
  //   .setPosition(20,640)
  //   .setSize(200,19)
  //   ;
     
  //cp5.addButton("Equal_Tempered_Major_Triad")
  //   .setValue(0)
  //   .setPosition(20,670)
  //   .setSize(200,19)
  //   ;
     
  //cp5.addButton("Natural_Minor_Triad")
  //   .setValue(0)
  //   .setPosition(20,580)
  //   .setSize(200,19)
  //   ;
     
  //cp5.addButton("Equal_Tempered_Minor_Triad")
  //   .setValue(0)
  //   .setPosition(20,610)
  //   .setSize(200,19)
  //   ;
  
  //     if(travellerOn==1){
  //       checkBox.toggle(4);
  //       println("HELLO!");
  //     }
       
  //     if(shouldRotate==1){
  //       checkBox.toggle(0);
  //       println("HELLO!!!!!");
  //     }
  
     
  for (int i = 0; i<3; i++){
     sine[i] = new SinOsc(this);
  }
  //.set(freq, amp, add, pos)
  sine[0].set(baseFreq, sineVolume, 0, 0);
  sine[1].set(baseFreq*theta2Incr/theta1Incr, sineVolume, 0, 0);
  sine[2].set(baseFreq*theta3Incr/theta1Incr, sineVolume, 0, 0);
  
    for (int i = 0; i<3; i++){
     sine[i].play();
  }
  
  
}


void draw() {

  background(0);
  stroke(255);
  
  if(detuneB==1){
    theta2Incr += detuneAmountPerFrame2;
  }
    if(detuneC==1){
    theta3Incr += detuneAmountPerFrame3;
  }
   
    int j = mySlowCounter;
    float thetaScaleFactor = 5/((theta1Incr+theta2Incr+theta3Incr)/3.0) * thetaScaleFactorMultiplier;
    PVector[] travellerCoords = new PVector[travellerLength];
    for (int i = 0; i<travellerLength; i++){ 
      travellerCoords[i] = new PVector(sin(theta1+(j+i*2)*theta1Incr*thetaScaleFactor)*scaleFactor, 
        sin(theta2+(j+i*2)*theta2Incr*thetaScaleFactor+phaseB)*scaleFactor, 
        sin(theta3+(j+i*2)*theta3Incr*thetaScaleFactor+phaseC)*scaleFactor);
    }
    PVector camDirTemp=camDir;
    PVector camPosTemp=camPos;
    if (cameraFollowsTraveller==1){
      camDirTemp = PVector.sub(travellerModelDest, travellerModelOrig);
      camPosTemp = travellerModelOrig;
      float fov = PI/3.0;
      float cameraZ = (height/2.0) / tan(fov/2.0);
      perspective(fov, float(width)/float(height), 
                  cameraZ/100.0, cameraZ*10.0);
    }else{
      perspective(); //resets it
      checkCameraInput();
      camDirTemp=camDir;
      camPosTemp=camPos;
      float fov = PI/3.0;
      float cameraZ = (height/2.0) / tan(fov/2.0);
      perspective(fov, float(width)/float(height), 
                  cameraZ/100.0, cameraZ*100.0);
    }
   
     camera(camPosTemp.x, camPosTemp.y, camPosTemp.z, // eyeX, eyeY, eyeZ
         camPosTemp.x+camDirTemp.x,camPosTemp.y+camDirTemp.y,camPosTemp.z+camDirTemp.z, // centerX, centerY, centerZ (where we are looking)
         0.0, 1.0, 0.0); // upX, upY, upZ
         
  translate(width/2, height/2, 0);
            
  decrementRotation();
  rotThetaY += mouseDeltaX/100.0;
  rotThetaX -= mouseDeltaY/100.0;
            
  if (shouldRotate==1){
    rotThetaY += rotationSpeed;
  }
  
  rotateX(rotThetaX);
  rotateY(rotThetaY);
  
  //AXES
  if (showAxes == 1){
    float axesLength = 1.0;
    int axesAlpha = 100;
    stroke(255,0,0,axesAlpha);
    strokeWeight(4);
    line(scaleFactor,scaleFactor,scaleFactor,-axesLength*scaleFactor,scaleFactor,scaleFactor);
    line(scaleFactor,scaleFactor,scaleFactor,scaleFactor,-axesLength*scaleFactor,scaleFactor);
    line(scaleFactor,scaleFactor,scaleFactor,scaleFactor,scaleFactor,-axesLength*scaleFactor);
    textSize(32);
    fill(255, 0, 0, axesAlpha);
    text("A: "+str(theta1Incr),-axesLength*scaleFactor,scaleFactor,scaleFactor);
    text("B: "+str(theta2Incr),scaleFactor,-axesLength*scaleFactor,scaleFactor);
    text("C: "+str(theta3Incr),scaleFactor,scaleFactor,-axesLength*scaleFactor);
    fill(255, 0, 0,axesAlpha);
    pushMatrix();
    translate(travellerCoords[0].x,scaleFactor,scaleFactor);
    sphere(5);
    popMatrix();
    pushMatrix();
    translate(scaleFactor,travellerCoords[0].y,scaleFactor);
    sphere(5);
    popMatrix();
    pushMatrix();
    translate(scaleFactor,scaleFactor,travellerCoords[0].z);
    sphere(5);
    popMatrix();
  }

  if (recordObj) {
    beginRecord("nervoussystem.obj.OBJExport", "Harmonograph3DExport.obj"); 
  }  
  

    for (int i=0; i<iterations; i++){
    stroke(255,255);
    strokeWeight(0.5);
    line(sin(theta1+i*theta1Incr*thetaScaleFactor)*scaleFactor, sin(theta2+i*theta2Incr*thetaScaleFactor+phaseB)*scaleFactor, sin(theta3+i*theta3Incr*thetaScaleFactor+phaseC)*scaleFactor,
    sin(theta1+(i+1)*theta1Incr*thetaScaleFactor)*scaleFactor, sin(theta2+(i+1)*theta2Incr*thetaScaleFactor+phaseB)*scaleFactor, sin(theta3+(i+1)*theta3Incr*thetaScaleFactor+phaseC)*scaleFactor);
    }
    
  if (recordObj) {
    endRecord();
    recordObj = false;
  }
  
  //traveller guy
  if (travellerOn==1){
    strokeWeight(8);
    for (int i = 0; i<travellerLength-1; i++){
    line(travellerCoords[i].x, travellerCoords[i].y, travellerCoords[i].z, travellerCoords[i+1].x, travellerCoords[i+1].y, travellerCoords[i+1].z);
    }
  }
    
    //save transformed coordinates for use by the camera in the next iteration
   travellerModelOrig.x = modelX(travellerCoords[0].x,travellerCoords[0].y,travellerCoords[0].z);
   travellerModelOrig.y = modelY(travellerCoords[0].x,travellerCoords[0].y,travellerCoords[0].z);
   travellerModelOrig.z = modelZ(travellerCoords[0].x,travellerCoords[0].y,travellerCoords[0].z);
   travellerModelDest.x = modelX(travellerCoords[travellerLength-1].x,travellerCoords[travellerLength-1].y,travellerCoords[travellerLength-1].z);
   travellerModelDest.y = modelY(travellerCoords[travellerLength-1].x,travellerCoords[travellerLength-1].y,travellerCoords[travellerLength-1].z);
   travellerModelDest.z = modelZ(travellerCoords[travellerLength-1].x,travellerCoords[travellerLength-1].y,travellerCoords[travellerLength-1].z);

    mySlowCounter = mySlowCounter + 1;
    if (mySlowCounter > iterations){
      mySlowCounter = 1;
    }
  

  
  camera(); //anything after this is rendered in 2D
  
  textFont(myFont); 
  fill(150);
  text("a:"+str(theta1Incr)+"    b:"+str(theta2Incr)+"    c:"+str(theta3Incr)+"     "+triadName,20,20);
  
    //text("camposX:"+str(camPos.x)+"    camposY:"+str(camPos.y)+"    camposZ:"+str(camPos.z),800,20);
    //text("travelX:"+str(origin.x)+"    travelY:"+str(origin.y)+"    travelZ:"+str(origin.z),800,40);
    
  
  cp5.draw();
  
  sine[0].amp(sineVolume);
  sine[1].amp(sineVolume);
  sine[2].amp(sineVolume);
  
  sine[0].freq(baseFreq);
  sine[1].freq(baseFreq*theta2Incr/theta1Incr);
  sine[2].freq(baseFreq*theta3Incr/theta1Incr);
  

}

void checkCameraInput() {
if (keyPressed) {
    if (keyCode == LEFT) {
      camRotY = camRotY + rotIncr;
    } 
    if (keyCode == RIGHT) {
      camRotY = camRotY - rotIncr;
    } 
    if (keyCode == UP) {
      camRotX = camRotX - rotIncr;
    } 
    if (keyCode == DOWN) {
      camRotX = camRotX + rotIncr;
    } 
    if (key == 'a') {
      camDir.mult(camSpeed);
      camPos.add(camDir);
    } 
    if (key == 'z') {
      camDir.mult(camSpeed);
      camPos.sub(camDir);
    } 
 camDir.set(sin(camRotY)*cos(camRotX),sin(camRotX),cos(camRotY)*cos(camRotX));
}

}

void mouseDragged(){
  if((mouseX > width/2 - 400) && (mouseX < width/2 + 400)
  && (mouseY > height/2 - 400) && (mouseY < height/2 + 400)){
       mouseDeltaX=mouseX-pmouseX;
       mouseDeltaY=mouseY-pmouseY;
}
}

void keyPressed() {
  if (key == 'p') {
    recordObj = true; //output 3D obj
  } 
}

//void mouseReleased(){
//       mouseDeltaX=0;
//       mouseDeltaY=0;
//}

void decrementRotation(){
  if (mouseX-pmouseX == 0 && abs(mouseDeltaX) > 0){
    mouseDeltaX /= 2;
  }
    if (mouseY-pmouseY == 0 && abs(mouseDeltaY) > 0){
    mouseDeltaY /= 2;
  }
  
}

//for checkboxes
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(checkBox)) {
      shouldRotate = (int)checkBox.getArrayValue()[0];
      detuneB = (int)checkBox.getArrayValue()[1];
      detuneC = (int)checkBox.getArrayValue()[2];
      cameraFollowsTraveller = (int)checkBox.getArrayValue()[3];
      travellerOn = (int)checkBox.getArrayValue()[4];
      showAxes = (int)checkBox.getArrayValue()[5];
  }
    if (theEvent.isFrom(iterationSlider)) {
      iterations = int(exp(iterationsLog+logSlope));
  }
  
  
}

public void Natural_Major_Triad(int theValue) {
    theta1Incr = 4;
theta2Incr = 5;
theta3Incr = 6;
  cp5.getController("theta1Incr").setValue(theta1Incr);
cp5.getController("theta2Incr").setValue(theta2Incr);
cp5.getController("theta3Incr").setValue(theta3Incr);
}

public void Equal_Tempered_Major_Triad(int theValue) {
  theta1Incr = 4;
theta2Incr = 4.0*pow(twelthRootOfTwo,4);
theta3Incr = 4.0*pow(twelthRootOfTwo,7);
  cp5.getController("theta1Incr").setValue(theta1Incr);
cp5.getController("theta2Incr").setValue(theta2Incr);
cp5.getController("theta3Incr").setValue(theta3Incr);
  theta1Incr = 4;
theta2Incr = 4.0*pow(twelthRootOfTwo,4);
theta3Incr = 4.0*pow(twelthRootOfTwo,7);
}

public void Natural_Minor_Triad(int theValue) {
    theta1Incr = 10;
theta2Incr = 12;
theta3Incr = 15;
  cp5.getController("theta1Incr").setValue(theta1Incr);
cp5.getController("theta2Incr").setValue(theta2Incr);
cp5.getController("theta3Incr").setValue(theta3Incr);
}

public void Equal_Tempered_Minor_Triad(int theValue) {
  theta1Incr = 10;
theta2Incr = 10.0*pow(twelthRootOfTwo,3);
theta3Incr = 10.0*pow(twelthRootOfTwo,7);
  cp5.getController("theta1Incr").setValue(theta1Incr);
cp5.getController("theta2Incr").setValue(theta2Incr);
cp5.getController("theta3Incr").setValue(theta3Incr);
  theta1Incr = 10;
theta2Incr = 10.0*pow(twelthRootOfTwo,3);
theta3Incr = 10.0*pow(twelthRootOfTwo,7);
}


void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  
  if (pitch < highestTriadNote && pitch > lowestTriadNote) {
    notesDown.append(pitch);
  }
  
  print("On: ");println(notesDown);
  
  if (notesDown.size() == 3){
    notesDown.sort(); //sorts them in ascending order
    int note1 = notesDown.get(0);
    int note2 = notesDown.get(1);
    int note3 = notesDown.get(2);
    for (int i = 0; i<note1; i++){
      //figure out frequency of lowest note with twelthRootOfTwo and assign it to base frequency
      baseFreq = getFreqFromMidiNum(note1);
      
      if (note2 == (note1+4) && note3 == (note2+3)){  //maj triad 
        theta1Incr = 4;
        theta2Incr = 5;
        theta3Incr = 6;
        triadName = "closed major triad";
      } 
      else if (note3 == (note1+16) && note2  == (note1+7)){  //maj triad spaced
        theta1Incr = 4;
        theta3Incr = 10;
        theta2Incr = 6;
        triadName = "open major triad";
      }
      else if (note2 == (note1+3) && note3 == (note2+4)){  //min triad
        theta1Incr = 10;
        theta2Incr = 12;
        theta3Incr = 15;
        triadName = "closed minor triad";
      }
      else if (note3 == (note1+15) && note2 == (note1+7)){  //min triad spaced
        theta1Incr = 10;
        theta3Incr = 24;
        theta2Incr = 15;
        triadName = "open minor triad";
      }
      else if (note2 == (note1+4) && note3 == (note2+4)){  //aug triad
        theta1Incr = 16;
        theta2Incr = 20;
        theta3Incr = 25;
        triadName = "augmented triad";
      }
      else if (note2 == (note1+3) && note3 == (note2+3)){  //dim triad
        theta1Incr = 25;
        theta2Incr = 30;
        theta3Incr = 36;
        triadName = "diminished triad";
      }
      else {
        theta1Incr = 4;
        theta2Incr = getFreqFromMidiNum(note2)*4/getFreqFromMidiNum(note1);
        theta3Incr = getFreqFromMidiNum(note3)*4/getFreqFromMidiNum(note1);
        triadName = "other";
      }
      
      //cp5.getController("theta1Incr").setValue(theta1Incr);
      //cp5.getController("theta2Incr").setValue(theta2Incr);
      //cp5.getController("theta3Incr").setValue(theta3Incr);
      
    }
    
  }
  
    if (pitch == midiControllerButtonNumbers[0] && velocity == 127) {
      detuneB = (detuneB == 1) ? 0 : 1;
      println("helloooo");
    }
    if (pitch == midiControllerButtonNumbers[1] && velocity == 127) {
      detuneC = (detuneC == 1) ? 0 : 1;
    }
    
    if (pitch == midiControllerButtonNumbers[2] && velocity == 127) {
      cameraFollowsTraveller = (cameraFollowsTraveller == 1) ? 0 : 1;
    }
  
  
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  
  for (int i = notesDown.size() - 1; i >= 0; i--) {
    if (notesDown.get(i) == pitch){
      notesDown.remove(i);
    }
    print("Off: ");println(notesDown);
  }
}
//

float getFreqFromMidiNum(int midiNum) {
  //float freq = middleAFrequency / 16.0; //this gives us frequency of A0, which is midinum 21
  //return freq * pow(twelthRootOfTwo,(midiNum-21));
  float freq = middleAFrequency / 4.0; //this gives us frequency of A1, which is midinum 33 (to minimize rounding errors)
  return freq * pow(twelthRootOfTwo,(midiNum-33));
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange

  
    if (number == midiControllerFaderNumbers[0]) {
      sineVolume = value / 127.0 * 0.4;
      print("velocity changed ");
    }
    

}