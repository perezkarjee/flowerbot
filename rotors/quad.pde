#include <Servo.h>

#define MAXANGLE 160

typedef struct {
  int pinpwm;
  int range[2];
} ESCRecord;

ESCRecord escconf[4];
Servo escservos[4];
int angle = 0;

void config() {
  escconf[0] = (ESCRecord) {3, {836, 2400}};
  escconf[1] = (ESCRecord) {9, {836, 2400}};
  escconf[2] = (ESCRecord) {10, {836, 2400}};
  escconf[3] = (ESCRecord) {11, {836, 2400}};
}

void arm() {
  for(int esc = 0; esc < 4; esc++) {
    escservos[esc].attach(escconf[esc].pinpwm, \
                          escconf[esc].range[0], \
                          escconf[esc].range[1]);
    escservos[esc].write(0);
    delay(15);
  }
}

void cycle() {
  Serial.print("Cycle ESC Number ");
  for(int esc = 0; esc < 4; esc++) {
    Serial.print(esc);
    for(int angle = 0; angle <= MAXANGLE; angle++) {
      escservos[esc].write(angle);
      delay(15);
    }
    for(int angle = MAXANGLE; angle >= 0; angle--) {
      escservos[esc].write(angle);
      delay(15);
    }
  }
  Serial.println("");
}

void setup() {
  delay(1000);
  Serial.begin(9600);

  Serial.println("Wait for your input! [s] to init...");
  while(Serial.available() <= 0)
    delay(1000);
  int incomingByte = Serial.read();

  Serial.println("Start the system...");

  config(); 
  arm();
  delay(5000);

  if(incomingByte == 115) {
    Serial.println("Traverses all angles upward and downward.");  
    cycle();
    delay(1000);
  }
  Serial.println("Start loop...");
}

void setspeed(int angles[4]) {
  for(int esc = 0; esc < 4; esc++) {
    escservos[esc].write(angles[esc]);
    delay(120);
  }
}

void loop() { 
  if(Serial.available() > 0) {
    int incomingByte = Serial.read();
    if(incomingByte == 43)      // sends the character '+'
      angle++;                  // increases the speed
    else if(incomingByte == 45) // sends the character '-'
      angle--;                  // decreases the speed
    else if(incomingByte == 48) // sends the character '0'
      angle = 0;                // set the speed to zero
    
    if(angle < 0)
      angle = 0;
    if(angle > MAXANGLE)
      angle = MAXANGLE;
      
    Serial.print("Set the angle to: ");
    Serial.println(angle);
  }
    
  int angles[4] = {angle, angle, angle, angle};
  setspeed(angles);
}
