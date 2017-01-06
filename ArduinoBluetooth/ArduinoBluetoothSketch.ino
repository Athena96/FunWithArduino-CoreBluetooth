#include <Servo.h>
#include <SoftwareSerial.h>

// Create servo object to control the servo
Servo myservo;
SoftwareSerial bluetoothDevice(4,5);

int STOP = 90;

void setup() {
  // put your setup code here, to run once:
  myservo.attach(9);        // Attach the servo object to pin 9
  myservo.write(STOP);         // Initialize servo position to 0

  bluetoothDevice.begin(9600);
}

void loop() {
  // See if new position data is available
  if (bluetoothDevice.available()) {
    myservo.write(bluetoothDevice.read());  // Write position to servo
  }
}
