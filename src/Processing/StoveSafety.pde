/*
  StoveSafety
  by Alvin Tran
  
  *Get data from ESP32 to manipulate a sketch in Processing
  *Alert a cook whether their hands are too close to a stove
  *Sound an alarm if their hands are too close
  
  *Map function for printing potValue (Complete)
  *Comments on functions (Complete)
  
  Warnings:
  *Alarm plays if potValue and sensorValue fit the conditions for drawUnsafe() if sketch is started
  *Alarm has a large delay in stopping (Works for project, but really irritating)
 */
 

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      
String portName="/dev/tty.SLAB_USBtoUART";

// Data coming in from the data fields
String [] data;
int switchValue=0;    // index from data fields
int potValue=0;
int sensorValue=0;

// Boolean integer to see if switchValue equals 1
int onOff=0;

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex=0;

//Different colors to be used
color black=color(0, 0, 0);
color red=color(255, 0, 0);
color yellow=color(255, 255, 0);
color white=color(255, 255, 255);
color steelblue=color(70,130,180);
color green=color(0, 255, 0);
color orange=color(255, 120, 0);

//State variables that help determine screen color
int state;
int whiteState=1;
int blackState=2;
int steelblueState=3;
int yellowState=4;
int redState=5;

//Placement of text
int textPlacementX=400;
int textPlacementY=300;

//Original Vertices for triangle
int x1=395;
int y1=130;
int x2=230;
int y2=360;
int x3=570;
int y3=360;

//Timer
Timer blackTimer;
Timer whiteTimer;
Timer steelblueTimer;
Timer yellowTimer;
Timer redTimer;
int timerValue=1000;

//Alarm
import processing.sound.*;
SoundFile alarm;

boolean alarmState;

//Progress bar that correlates with potValue
int hMargin=-2300;
float progressBarWidth=400;    // change according to the width in setup()
float progressBarHeight=20;

//Global variable for font
PFont f;

void setup ( ) {
  size(800, 600);    
  
  // List all the available serial ports
  printArray(Serial.list());
  
  // Set the com port and the baud rate according to the Arduino IDE
  myPort=new Serial(this, Serial.list()[serialIndex], 115200); 
  
  textAlign(CENTER);
  //f is created here
  f=createFont("Comic Sans MS", 36, true);
  
  //Allocating timer
  blackTimer=new Timer(timerValue);  
  whiteTimer=new Timer(timerValue);
  steelblueTimer=new Timer(timerValue);
  yellowTimer=new Timer(timerValue);
  redTimer=new Timer(timerValue);
  
  whiteTimer.start();
  state=whiteState;
  
  // adjust progress bar length to width of sceeen
  progressBarWidth=width-(hMargin*2);  
  
  loadAlarm();
} 

// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) 
  {
    String inBuffer=myPort.readString();  
    
    //print(inBuffer);
    
    // This removes the end-of-line from the string AND casts it to an integer
    inBuffer=(trim(inBuffer));
    
    data=split(inBuffer, ',');
 
    // do an error check here?
    switchValue=int(data[0]);//Not used in this program
    potValue=int(data[1]);
    sensorValue=int(data[2]);
  }
} 

void IsItOn(){//Checks potValue to see whether to turn stove on or off  
  if(potValue>=1000)
  {  
    drawBackground();
  }
  else
  {  
    drawOff();
  }
}

void drawBackground() {//Turns the stove on and checks to see if hand is too close to the stove
  if(sensorValue<=200 && potValue>2500)
  {
    drawUnsafe(); 
    alarmState=true;
    checkAlarm();
  }
  else 
  {
    drawSafe();
    alarmState=false;
    checkAlarm();
  }
}

void drawTemperature()//Displays progress bar at bottom of the screen
{
  //draw fill
  fill(green);
  rect(hMargin, height-100, potValue, progressBarHeight);
  
  // drawOutine
  noFill();
  stroke(128);
  strokeWeight(1);
  rect(hMargin, height-100, progressBarWidth, progressBarHeight);
}

void drawOff(){//Screen that appears if stove is off
  if(state==blackState)
  {
    background(black);      
    
    fill(white);     
    triangle(x1, y1, x2, y2, x3, y3);     
    
    textFont(f);       
    fill(black);
    text(map(potValue, 0, 1000, 0, 100)+" F", textPlacementX, textPlacementY);
    
    if(blackTimer.expired())
    {
      state=whiteState;
      whiteTimer.start();
    }
  }
  else
  {    
    background(white);      
        
    fill(black);
    ellipse(mouseX, mouseY, width/2, width/2);
    
    textFont(f);       
    fill(white);
    text("Stove is off!", textPlacementX, textPlacementY);
    
    if(whiteTimer.expired())
    {
      state=blackState;
      blackTimer.start();
    }
  } 
 }
 
 void drawSafe(){//Screen that appears if stove is on and hand is off the stove    
   if(state==steelblueState)
   {
     background(steelblue);      
     
     textFont(f);       
     fill(white);
     text("All safe!", textPlacementX, textPlacementY);  
     
     if(steelblueTimer.expired())
     {
       state=whiteState;
       whiteTimer.start();
     }
    }
    else 
    {    
      background(white);  
      
      fill(green);
      ellipse(mouseX, mouseY, width/2, width/2);

      textFont(f);       
      fill(steelblue);
      text(map(potValue, 1000, 4095, 100, 600)+" F", textPlacementX, textPlacementY);
      
      if(whiteTimer.expired())
      {
        state=steelblueState;
        steelblueTimer.start();
      }
    }
 }
 
 void drawUnsafe(){//Screen that appears if stove is on and hand is on the stove
   if(state==yellowState)
   {
     background(yellow);     
     fill(red);       
     
     triangle(x1, y1, x2, y2, x3, y3);
      
     textFont(f);       
     fill(black);
     text("I'm burning!", textPlacementX, textPlacementY); 

     if(yellowTimer.expired())
     {
       state=redState;
       redTimer.start();
     }
   }
   else     
   {
     background(red);     
     
     fill(yellow);       
     ellipse(mouseX, mouseY, width/2, width/2);
      
     textFont(f);       
     fill(black);
     text(map(potValue, 1000, 4095, 100, 600)+" F", textPlacementX, textPlacementY);
     
     if(redTimer.expired())
     {
       state=yellowState;
       yellowTimer.start();    
     }
   }
 }

void loadAlarm()//Load audiofile for alarm
{  
  alarm=new SoundFile(this, "Alarm.wav");   
}

void checkAlarm(){//Checks alarmState to see if alarm should be played or stopped
  if(alarmState==true)
  {
    playAlarm();
  }
  else if(alarmState==false)
  {
    stopAlarm();
  }
}

void playAlarm(){//Plays alarm
  alarm.play();
}

void stopAlarm(){//Stops alarm
  alarm.stop();
}

void draw(){  
  if(mousePressed)//Able to check coordinates with mouse
  {
    int x=mouseX;
    int y=mouseY;
    println("X: "+x+" Y: "+y);
  }

  // every loop, look for serial information  
  checkSerial();
  IsItOn();  
  drawTemperature();
} 
