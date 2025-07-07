#include <Servo.h>
#include <math.h>

const int echoPin = A0;
const int thresholdDistance = 200;
const int scanSpeed = 50;

Servo Rad_serv;
Servo Gun_serv;
Servo Firing_serv;

int sensorValue = 0;
float voltage = 0;
float distance = 0;
int pos = 0;
int i = 0;
bool detected = false;

const float gunOffsetX = -10.0; 

void setup() {
  Rad_serv.attach(9);
  Gun_serv.attach(8);
  Firing_serv.attach(10);
  Serial.begin(9600);
}

void loop() {
  if (!detected) {
    for (pos = 50; pos <= 180; pos++) {
      Rad_serv.write(pos);
      delay(scanSpeed);
      distance = getDistanceCM(analogRead(echoPin));
      sendSerial(pos, distance);

      if (distance < thresholdDistance && distance > 100) {
        detected = true;
        aimGun(pos, distance);
        delay(3000);
        for (i = 0; i < 5; i++){
            delay(1000);
            Firing_serv.write(0);
            delay(1000);
            Firing_serv.write(180); 
        }
        break;
      }
    }

    if (!detected) {
      for (pos = 180; pos >= 50; pos--) {
        Rad_serv.write(pos);
        delay(scanSpeed);
        distance = getDistanceCM(analogRead(echoPin));
        sendSerial(pos, distance);

        if (distance < thresholdDistance && distance > 100) {
          detected = true;
          aimGun(pos, distance);
          delay(3000);
          for (i = 0; i < 5; i++){
            delay(1000);
            Firing_serv.write(0);
            delay(1000);
            Firing_serv.write(180); 
          }
          break;
        }
      }
    }
  }
}

float getDistanceCM(int sensorValue) {
  float voltage = sensorValue * (5.0 / 1023.0);
  float distanceCM = 27.61 * pow(voltage, -1.10); 
  return distanceCM; 
}

void sendSerial(int angle, float dist) {
  Serial.print(angle);
  Serial.print(',');
  Serial.print(dist);
  Serial.println('.');
}


void aimGun(int radarAngle, float targetDistance) {

  float theta = radians(radarAngle);

  float targetX = cos(theta) * targetDistance;
  float targetY = sin(theta) * targetDistance;

  float relX = targetX - gunOffsetX;
  float relY = targetY;

  float gunAngleRad = atan2(relY, relX);
  float gunAngleDeg = degrees(gunAngleRad);

  gunAngleDeg = constrain(gunAngleDeg, 0, 180);

  Gun_serv.write(gunAngleDeg + 20);
  
}