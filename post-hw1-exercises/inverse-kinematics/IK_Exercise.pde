//Inverse Kinematics
//CSCI 5611 IK [Solution]
// Stephen J. Guy <sjguy@umn.edu>

/*
INTRODUCTION:
Rather than making an artist control every aspect of a characters animation, we will often specify 
key points (e.g., center of mass and hand position) and let an optimizer find the right angles for 
all of the joints in the character's skelton. This is called Inverse Kinematics (IK). Here, we start 
with some simple IK code and try to improve the results a bit to get better motion.

TODO:
Step 1. Change the joint lengths and colors to look more like a human arm. Try to match 
        the length ratios of your own arm/hand, and try to match your own skin tone in the rendering.
      Done

Step 2: Add an angle limit to the wrist joint, and limit it to be within +/- 90 degrees relative
        to the lower arm.
        -Be careful to put the joint limits for the wrist *before* you compute the new end effoctor
         position for the next link in CCD
      Done

Step 3: Add an angle limit to the shoulder joint to limit the joint to be between 0 and 90 degrees, 
        this should stop the top of the arm from moving off screen.
      Done

Step 4: Cap the acceleration of each joint so the joints can only update slowly. Try to tweak the 
        acceleration cap to be different for each joint to get a good effect on the arm motion.
      Done

Step 5: Try adding a 4th limb to the IK chain.
      Done


CHALLENGE:

1. Go back to the 3-limb arm, can you make it look more human-like. Try adding a simple body to 
   the scene using circles and rectangles. Can you make a scene where the character picks up 
   something and moves it somewhere?
  Done
2. Create a more full skeleton. How do you handle the torso having two different arms?


*/

void setup(){
  size(1000,1000);
  surface.setTitle("Inverse Kinematics [CSCI 5611 Example]");
}

//Root
Vec2 root = new Vec2(135,150);

//Upper Arm
float l0 = 70; 
float a0 = 0.3; //Shoulder joint
float acc0 = 0.3;

//Lower Arm
float l1 = 60;
float a1 = 0.3; //Elbow joint
float acc1 = 0.3;

//Hand
float l2 = 50;
float a2 = 0.3; //Wrist joint
float acc2 = 0.5;

float l3 = 30;
float a3 = 0.3;
float acc3 = 0.6;

Vec2 start_l1, start_l2, start_l3, endPoint;

Vec2 c = new Vec2(300, 100);

void solve(){
  Vec2 goal = new Vec2(mouseX, mouseY);
  
  Vec2 startToGoal, startToEndEffector;
  float dotProd, angleDiff;

  //Update wrist joint
  // startToGoal = goal.minus(start_l3);
  // startToEndEffector = endPoint.minus(start_l3);
  // dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
  // dotProd = clamp(dotProd,-1,1);
  // angleDiff = acos(dotProd) * acc3;
  // if (cross(startToGoal,startToEndEffector) < 0)
  //   a3 += angleDiff;
  // else
  //   a3 -= angleDiff;
  // /*TODO: Wrist joint limits here*/
  // if (a3 > radians(90)) a3 = radians(90);
  // if (a3 < radians(-90)) a3 = radians(-90);
  // fk(); //Update link positions with fk (e.g. end effector changed)
  
  //Update wrist joint
  startToGoal = goal.minus(start_l2);
  startToEndEffector = endPoint.minus(start_l2);
  dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
  dotProd = clamp(dotProd,-1,1);
  angleDiff = acos(dotProd) * acc2;
  if (cross(startToGoal,startToEndEffector) < 0)
    a2 += angleDiff;
  else
    a2 -= angleDiff;
  /*TODO: Wrist joint limits here*/
  if (a2 > radians(90)) a2 = radians(90);
  if (a2 < radians(-90)) a2 = radians(-90);
  fk(); //Update link positions with fk (e.g. end effector changed)
  
  
  
  //Update elbow joint
  startToGoal = goal.minus(start_l1);
  startToEndEffector = endPoint.minus(start_l1);
  dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
  dotProd = clamp(dotProd,-1,1);
  angleDiff = acos(dotProd) * acc1;
  if (cross(startToGoal,startToEndEffector) < 0)
    a1 += angleDiff;
  else
    a1 -= angleDiff;
  fk(); //Update link positions with fk (e.g. end effector changed)
  
  
  //Update shoulder joint
  startToGoal = goal.minus(root);
  if (startToGoal.length() < .0001) return;
  startToEndEffector = endPoint.minus(root);
  dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
  dotProd = clamp(dotProd,-1,1);
  angleDiff = acos(dotProd) * acc0;
  if (cross(startToGoal,startToEndEffector) < 0)
    a0 += angleDiff;
  else
    a0 -= angleDiff;
  /*TODO: Shoulder joint limits here*/
  if (a0 < radians(-45)) a0 = radians(-45);
  if (a0 > radians(90)) a0 = radians(90);
  fk(); //Update link positions with fk (e.g. end effector changed)
 
  println("Angle 0:",a0,"Angle 1:",a1,"Angle 2:",a2);
}

void fk(){
  start_l1 = new Vec2(cos(a0)*l0,sin(a0)*l0).plus(root);
  start_l2 = new Vec2(cos(a0+a1)*l1,sin(a0+a1)*l1).plus(start_l1);
  // start_l3 = new Vec2(cos(a0+a1+a2)*l2,sin(a0+a1+a2)*l2).plus(start_l2);
  // endPoint = new Vec2(cos(a0+a1+a2+a3)*l3,sin(a0+a1+a2+a3)*l3).plus(start_l3);
  endPoint = new Vec2(cos(a0+a1+a2)*l2,sin(a0+a1+a2)*l2).plus(start_l2);
}

float armW = 20;
void draw(){
  fk();
  solve();
  
  background(250,250,250);
  
  fill(230, 199, 154);

  pushMatrix();
  translate(100, 100);
  circle(0,0,100);
  popMatrix();

  pushMatrix();
  translate(100, 150);
  rect(-35, 0, 70, 150);
  popMatrix();

  fill(0,0,186);
  if (holding) {
    c = endPoint.plus(dir);
  }

  pushMatrix();
  translate(c.x, c.y);
  circle(0,0,50);
  popMatrix();

  fill(230, 199, 154);

  pushMatrix();
  translate(root.x,root.y);
  rotate(a0);
  rect(0, -armW/2, l0, armW);
  popMatrix();
  
  pushMatrix();
  translate(start_l1.x,start_l1.y);
  rotate(a0+a1);
  rect(0, -armW/2, l1, armW);
  popMatrix();
  
  pushMatrix();
  translate(start_l2.x,start_l2.y);
  rotate(a0+a1+a2);
  rect(0, -armW/2, l2, armW);
  popMatrix();

  pushMatrix();
  translate(endPoint.x, endPoint.y);
  rotate(a0+a1+a2+radians(0));
  rect(0, -armW/2, 25, 5);
  popMatrix();

  pushMatrix();
  translate(endPoint.x, endPoint.y);
  rotate(a0+a1+a2+radians(0));
  rect(0, -armW/2+5, 25, 5);
  popMatrix();

  pushMatrix();
  translate(endPoint.x, endPoint.y);
  rotate(a0+a1+a2+radians(20));
  rect(0, -armW/2+10, 25, 5);
  popMatrix();

  pushMatrix();
  translate(endPoint.x, endPoint.y);
  rotate(a0+a1+a2+radians(40));
  rect(0, -armW/2+15, 25, 5);
  popMatrix();
  
  // pushMatrix();
  // translate(start_l3.x, start_l3.y);
  // rotate(a0+a1+a2+a3);
  // rect(0, -armW/2, l3, armW);
  // popMatrix();
}

boolean holding = false;
Vec2 dir = new Vec2(0,0);
float dist = 0;
void mousePressed() {
  if (!holding && endPoint.distanceTo(c) < 50) {
    holding = true;
    dir = c.minus(endPoint);
  }
}

void mouseReleased() {
  if (holding) {
    holding = false;
  }
}



//-----------------
// Vector Library
//-----------------

//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public float length(){
    return sqrt(x*x+y*y);
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void clampToLength(float maxL){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(float newL){
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public void normalize(){
    float magnitude = sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx*dx + dy*dy);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

float cross(Vec2 a, Vec2 b){
  return a.x*b.y - a.y*b.x;
}


Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

float clamp(float f, float min, float max){
  if (f < min) return min;
  if (f > max) return max;
  return f;
}
