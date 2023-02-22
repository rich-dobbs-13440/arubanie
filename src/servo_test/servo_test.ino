#include <Servo.h>  //Servo library


// sudo usermod -a -G dialout rich
// Add to: /etc/rc.local

//sudo chmod a+rw /dev/ttyACM0

Servo servo_test;  //initialize a servo object for the connected servo
Servo servo_air_flow; 
Servo servo_paint_flow; 

int angle = 0;  // Variable used for testing
int angle_air_flow = 90;
// 10: Servo all the way back () 
// 170: All the way forward (off): 

int paint_flow_angle(float flow_fraction) {
  int angle_min_flow = 175; // Based on current geometry
  int angle_max_flow = 60; // Based on current geometry
  int range = angle_min_flow - angle_max_flow;
  int angle = angle_min_flow - int(flow_fraction*range);
  return max(min(angle, angle_min_flow), angle_max_flow); 
}

float paint_flow_fraction = 0.0;
//int angle_paint_flow = paint_flow_angle(air_flow_fraction);

void loop_for_servo_testing();
void loop_for_paint_flow_testing();

void setup() {
  servo_test.attach(9);  // attach the signal pin of servo to pin9 of arduino

  servo_air_flow.attach(8);
  servo_air_flow.write(angle_air_flow);

  servo_paint_flow.attach(7);
  //servo_paint_flow.write(180); // Forward position to attach servo arm
  //servo_paint_flow.write(90); //Midpoint to make sure direction of rotation correct
  //servo_paint_flow.write(60); // Trial and error to find end of range
  servo_paint_flow.write(paint_flow_angle(paint_flow_fraction));
}


void loop() {
  //loop_for_servo_testing();
  loop_for_paint_flow_testing();
}

void loop_for_paint_flow_testing() {
  for (paint_flow_fraction=0; paint_flow_fraction< 1; paint_flow_fraction+=0.005) 
  {
      servo_paint_flow.write(paint_flow_angle(paint_flow_fraction));
      delay(2);
  }
  delay(5000);
  servo_paint_flow.write(paint_flow_angle(0));
  delay(5000);
}

void loop_for_servo_testing() {
  // Currently only used for testing

  for (angle = 0; angle < 180; angle += 1)  // command to move from 0 degrees to 180 degrees
  {
    servo_test.write(angle);  //command to rotate the servo to the specified angle
    delay(15);
  }

  delay(1000);

  for (angle = 180; angle >= 1; angle -= 5)  // command to move from 180 degrees to 0 degrees
  {
    servo_test.write(angle);  //command to rotate the servo to the specified angle
    delay(5);
  }

  delay(1000);
}
