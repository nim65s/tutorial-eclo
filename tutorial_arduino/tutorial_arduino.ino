#include <SimpleModbusSlave.h>
#include <Servo.h>
#include <Math.h>

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
  AUTOADJUST,   // @ 6
  ADJUSTOFFSET, // @ 7
  ADJUSTTEMP,   // @ 8
  ADJUSTLUM,    // @ 9
  ADJUSTHUM,    // @ 10

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

int processTemperature(int value)
{
    double val = value;
    return 1/(log((1023-val)/val)/3975 + 1/298.14)-273.15;
}

int processHumidity(int value)
{
    if (value < 400) return 0;
    return (value - 300) / 4.5;
}

int processLuminosity(int value)
{
    float vsensor = value * 0.0048828125;
    return 500 / ( 10 * ( (5 - vsensor) / vsensor ));
}

void loop()
{
  // modbus_update() is the only method used in loop(). It returns the total error
  // count since the slave started. You don't have to use it but it's useful
  // for fault finding by the modbus master.
  holdingRegs[TOTAL_ERRORS] = modbus_update(holdingRegs);

  // Temperature, Luminosity & humidity
  holdingRegs[TEMPERATURE] = processTemperature(analogRead(TEMPERATURE));
  holdingRegs[LUMINOSITY]  = processLuminosity(analogRead(LUMINOSITY));
  holdingRegs[HUMIDITY]    = processHumidity(analogRead(HUMIDITY));

  // Button
  if (digitalRead(12) == HIGH) holdingRegs[BUTTON] = 1;

  // servo
  float servo;
  if (!holdingRegs[AUTOADJUST]) servo = holdingRegs[SERVOCOMMAND];
  else
  {
      servo  = holdingRegs[ADJUSTOFFSET];
      servo += holdingRegs[ADJUSTTEMP] * holdingRegs[TEMPERATURE];
      servo += holdingRegs[ADJUSTLUM]  * holdingRegs[LUMINOSITY];
      servo += holdingRegs[ADJUSTHUM]  * holdingRegs[HUMIDITY];
  }
  if (servo <  0 ) servo =  0 ;
  if (servo > 100) servo = 100;
  myservo.write(servo);
  holdingRegs[SERVOANGLE] = myservo.read();
}

// vim:set ft=c:
