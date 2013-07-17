#include <SimpleModbusSlave.h>
#include <Servo.h>

// Using the enum instruction allows for an easy method for adding and
// removing registers. Doing it this way saves you #defining the size
// of your slaves register array each time you want to add more registers
// and at a glimpse informs you of your slaves register layout.

//////////////// registers of your slave ///////////////////
enum
{
  // just add or remove registers and your good to go...
  // The first register starts at address 0
  TEMPERATURE,  // @ 0
  LUMINOSITY,   // @ 1
  HUMIDITY,     // @ 2
  BUTTON,       // @ 3
  SERVOANGLE,   // @ 4
  SERVOCOMMAND, // @ 5

  TOTAL_ERRORS,
  // leave this one
  TOTAL_REGS_SIZE
  // total number of registers for function 3 and 16 share the same register array
};

Servo myservo;  // create servo object to control a servo

unsigned int holdingRegs[TOTAL_REGS_SIZE]; // function 3 and 16 register array

////////////////////////////////////////////////////////////

void setup()
{
  myservo.attach(13); // The servo is on the pin 13
  myservo.write(0);

  // setup the serial link and the modbus lib
  Serial.begin(9600);
  delay(50);

  modbus_configure(9600, 1, 2, TOTAL_REGS_SIZE);

  delay(50);
  Serial.println("Ready") ;
}

void loop()
{
  // modbus_update() is the only method used in loop(). It returns the total error
  // count since the slave started. You don't have to use it but it's useful
  // for fault finding by the modbus master.
  holdingRegs[TOTAL_ERRORS] = modbus_update(holdingRegs);

  // Temperature, Luminosty & humitidy
  for (byte i = 0; i < 3; i++)
  {
    holdingRegs[i] = analogRead(i);
    delay(10);
  }

  // Button
  if (digitalRead(12) == HIGH) holdingRegs[3] = 1;

  // servo
  holdingRegs[4] = myservo.read();
  delay(10);
  myservo.write(holdingRegs[5]);
  delay(10);
}

// vim:set ft=c:
