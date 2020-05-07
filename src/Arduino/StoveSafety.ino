/*
  StoveSafety
  by Alvin Tran

  Send potentiometer and LDR sensor data to a sketch in processing
 */

int ledPin=15;
int buttonPin=12;
int potInputPin=A2;
int ldrInputPin=A1;

//-- analog values, track for formatting to serial
int switchValue=0;
int potValue=0;
int ldrValue=0;
int buttonCounter=1;

//-- time between LED flashes, for startup
const int ledFlashDelay=150;

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize pins and input and output
  pinMode(ledPin, OUTPUT);    
  
  pinMode(buttonPin, INPUT);
  pinMode(potInputPin, INPUT);    // technically not needed, but good form
  pinMode(ldrInputPin,INPUT);
  
  Serial.begin(115200);
 // Serial.println( "ButtonLED: Starting" ); 

   blinkLED(4);
}

// the loop function runs over and over again forever
void loop() {
  // gets switch Value AND changed LED
  getSwitchValue();
  getPotValue();
  getLDRValue();  
  //potValue=ldrValue;
  sendSerialData();
 
  // delay so as to not overload serial buffer
  delay(100);
}

//-- blink that number of times
void blinkLED(int numBlinks ) {
  for( int i=0; i<numBlinks; i++ ) 
  {
    digitalWrite(ledPin, HIGH); 
    delay(ledFlashDelay);  
    digitalWrite(ledPin, LOW); 
    delay(ledFlashDelay);  
  }
}

//-- look at the momentary switch (button) and show on/off
//-- display in the serial monitor a well
void getSwitchValue() {//Not used in Processing sketch
  switchValue=digitalRead(buttonPin);
  
  if(switchValue==true) 
  {
     // Button is ON turn the LED ON by making the voltage HIGH
     if(buttonCounter%2==0)
     {
      digitalWrite(ledPin, HIGH); 
     }
    buttonCounter+=1;  
  } 
  else 
  {
    // Button is ON turn the LED ON by making the voltage LOW
    digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW      
  }
}

void getPotValue() {
  potValue=analogRead(potInputPin); 
}

void getLDRValue() {
  ldrValue=analogRead(ldrInputPin); 
}

//-- this could be done as a formatted string, using Serial.printf(), but
//-- we are doing it in a simpler way for the purposes of teaching
void sendSerialData() {
  if(buttonCounter%2==0)// Add switch on or off (Not used in Processing sketch)
  {
    Serial.print(1);
  }
  else if(buttonCounter%2!=0)
  {
    Serial.print(0);
  }

   Serial.print(",");
   Serial.print(potValue);

   Serial.print(",");
   Serial.print(ldrValue);
   
  // end with newline
  Serial.println();
}
