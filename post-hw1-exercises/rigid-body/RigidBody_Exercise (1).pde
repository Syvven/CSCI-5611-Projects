//Rigid Body Dynamics
//CSCI 5611 Physical Simulation [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

//To use: Click to apply a force to the box at the point where the mouse is clicked.
//        Box will turn red while the click force is being applied.  

//TODO:
//  1. Currently, the simulation begins with the box tilted at an angle. Inspect
//     the variables that set the box's initial conditions and update the simulation
//     to start with the box vertically upright.
//  2. Right now, the box leaves the scene and doesn't come back. Fix it so that 
//     when you press the 'r' key the box resets its state. Be sure to update the
//     center to (200,200), the angle to 0, momentum to 0, and angular_momentum to 0 
//  3. The function apply_force() currently only does half of its job. It updates the
//     variable "total_force", but it also needs to update "total_torque". You can
//     compute the torque to apply in two steps:
//           1) displacement = force's position - object's center of mass
//           2) torque = cross(displacement,force)
//     This gives more torque to an object the further away from the center you push.
//  4. The previous step computes the torque we need to apply to the object, but
//     doesn't actually apply the torque yet. We need to update update_physics() to
//     handle torques. Here are the steps I recommend:
//           1) Update the angular momentum: torque is the derivative of angular momentum
//               just as force is the derivative of momentum
//           2) Compute the angular velocity: ang_velocity = angular_momentum/rotational_inertia
//           3) Update the orientation of the box: ang_velocity is the derivative of orientation
//           4) Reset the total torque back to 0 
//     You should now have working rotational dynamics!
//  5. We are still missing collisions between our box and the environment. I've
//     provided a helper function called "collisionTest()" that returns a custom struct
//     that reports information about the box and collisions with the far wall. Currently
//     we call this function, but don't use the results. I've provided a second helper
//     function called "resolveCollision()" that will update the box based on the collision.
//     Take the results from collisionTest() and provide them to resolveCollision().
//     The box should now bounce naturally off the right wall.
//  6. The collisionTest() function checks if any of the 4 corners hits the right wall.
//     Update this function to also test for collison against the left wall.
//     Test your implementation to make sure the box bounces off both walls.


//Challenge:
//  1. Currently the user's force only points rightwards. Use the arrow keys to change
//     the direction of the user's force arrow.
//  2. Allow the box to bounce off the top and bottom walls.
//  3. Add a second box to the scene! Break this into a few steps
//       1) Allow the new box to interact with the 4 walls and the click force
//       2) Detect if the corner of one box is inside the other box
//       3) Use the resources mentioned in resolveCollision() to update that function for object-object collisions
//     If you get this working, you'll have the basics of an impressive 2D physics engine
//  4. Other ideas: Allow other shapes besides boxes, add friction, add gravity

void setup(){
  size(600,400);
}

//Set inital conditions
float w = 50;
float h = 200;
float box_bounce = 0.8; //Coef. of restitution

float mass = 1;                         //Resistance to change in momentum/velocity
float rot_inertia = mass*(w*w+h*h)/12;  //Resistance to change in angular momentum/angular velocity

Vec2 momentum = new Vec2(0,0);          //Speed the box is translating (derivative of position)
float angular_momentum = 0;             //Speed the box is rotating (derivative of angle)

Vec2 center = new Vec2(200,200);        //Current position of center of mass
float angle = 0.4; /*radians*/          //Current rotation amount (orientation)

Vec2 total_force = new Vec2(0,0);       //Forces change position (center of mass)
float total_torque = 0;                 //Torques change orientation (angle)

Vec2 p1,p2,p3,p4;                       //4 corners of the box -- computed in updateCornerPositions()

//----------
// Physics Functions
void apply_force(Vec2 force, Vec2 applied_position){
  total_force.add(force);
  //TODO: also update total_torque
}

void update_physics(float dt){
  //Update center of mass
  momentum.add(total_force.times(dt));     //Linear Momentum = Force * time
  Vec2 box_vel = momentum.times(1.0/mass); //Velocity = Momentum / mass
  center.add(box_vel.times(dt));           //Position += Vel * time
  
  //TODO: update rotation
    //Angular Momentum = Torque * time
    //Angular Velocity = (Angular Momentum)/(Rotational Inertia)
    //Orientation += (Angular Velocity) * time
  
  //Reset forces and torques
  total_force = new Vec2(0,0); //Set forces to 0 after they've been applied
  /*TODO*/ //Set torques to 0 after the forces have been applied
}


class ColideInfo{
  public boolean hit = false;
  public Vec2 hitPoint = new Vec2(0,0);
  public Vec2 objectNormal =  new Vec2(0,0);
}


void updateCornerPositions(){
  Vec2 right = new Vec2(cos(angle),sin(angle)).times(w/2);
  Vec2 up = new Vec2(-sin(angle),cos(angle)).times(-h/2);
  p1 = center.plus(right).plus(up);
  p2 = center.plus(right).minus(up);
  p3 = center.minus(right).plus(up);
  p4 = center.minus(right).minus(up);
}

ColideInfo collisionTest(){
  updateCornerPositions(); //Compute the 4 corners: p1,p2,p3,p4
  //We only check if the corners collide
  
  ColideInfo info = new ColideInfo();
  
  if (p1.x > 600){
    info.hitPoint = p1;
    info.hit = true;
    info.objectNormal = new Vec2(-1,0);
  }
  if (p2.x > 600){
    info.hitPoint = p2;
    info.hit = true;
    info.objectNormal = new Vec2(-1,0);
  }
  if (p3.x > 600){
    info.hitPoint = p3;
    info.hit = true;
    info.objectNormal = new Vec2(-1,0);
  }
  if (p4.x > 600){
    info.hitPoint = p4;
    info.hit = true;
    info.objectNormal = new Vec2(-1,0);
  }
  //TODO: Test the 4 corners against the left wall
  
  return info;
}

//Updates momentum & angular_momentum based on collision using an impulse based method
//This method assumes you hit an immovable obstacle which simplifies the math
// see Eqn 8-18 of here: https://www.cs.cmu.edu/~baraff/sigcourse/notesd2.pdf
// or Eqn 9 here: http://www.chrishecker.com/images/e/e7/Gdmphys3.pdf
//for obstacle-obstacle collisions.
void resolveCollision(Vec2 hit_point, Vec2 hit_normal, float dt){
  Vec2 r = hit_point.minus(center);
  Vec2 r_perp = perpendicular(r);
  Vec2 object_vel = momentum.times(1/mass);
  float object_angular_speed = angular_momentum/rot_inertia;
  Vec2 point_vel = object_vel.plus(r_perp.times(object_angular_speed));
  println(point_vel,object_vel);
  float j = -(1+box_bounce)*dot(point_vel,hit_normal);
  j /= (1/mass + pow(dot(r_perp,hit_normal),2)/rot_inertia);
 
  Vec2 impulse = hit_normal.times(j);
  momentum.add(impulse);
  println(momentum);
  angular_momentum += dot(r_perp,impulse);
  update_physics(1.01*dt); //A small hack, better is just to move the object out of collision directly
}

void draw(){
  float dt = 1/frameRate;
  update_physics(dt);
  
  boolean clicked_box = mousePressed && point_in_box(new Vec2(mouseX, mouseY),center,w,h,angle);
  
  if (clicked_box) {
    Vec2 force = new Vec2(1,0).times(100);
    Vec2 hit_point = new Vec2(mouseX, mouseY);
    apply_force(force, hit_point);
  }
  
  ColideInfo info = collisionTest(); //TODO: Use this result below
  
  //TODO the these values based on the results of a collision test
  Boolean hit_something = false; //Did I hit something?
  if (hit_something){
    Vec2 hit_point = new Vec2(0,0);
    Vec2 hit_normal = new Vec2(0,0);
    resolveCollision(hit_point,hit_normal,dt);
  }
  
  Vec2 box_vel = momentum.times(1/mass);
  float box_speed = box_vel.length();
  float box_agular_velocity = angular_momentum/rot_inertia;
  float linear_kinetic_energy = .5*mass*box_speed*box_speed;
  float rotational_kinetic_energy = .5*rot_inertia*box_agular_velocity*box_agular_velocity;
  float total_kinetic_energy = linear_kinetic_energy+rotational_kinetic_energy;
  println("Box Vel:",box_vel,"ang vel:",box_agular_velocity,"linear KE:",linear_kinetic_energy,"rotation KE:",rotational_kinetic_energy,"Total KE:",total_kinetic_energy);
  
  background(200); //Grey background
  
  fill(255);
  if (clicked_box){
    fill(255,200,200);
  }
  pushMatrix();
  translate(center.x,center.y);
  rotate(angle);
  rect(-w/2, -h/2, w, h);
  popMatrix();
  
  fill(0);
  circle(center.x, center.y, 6.0);
  
  circle(p1.x, p1.y, 4.0);
  circle(p2.x, p2.y, 4.0);
  circle(p3.x, p3.y, 4.0);
  circle(p4.x, p4.y, 4.0);
  
  drawArrow(mouseX, mouseY, 100, 0);
}


void keyPressed(){
  if (key == 'r'){
    println("Resetting the simulation");
    return;
  }
}

//Returns true iff the point 'point' is inside the box
boolean point_in_box(Vec2 point, Vec2 box_center, float box_w, float box_h, float box_angle){
  Vec2 relative_pos = point.minus(box_center);
  Vec2 box_right = new Vec2(cos(box_angle),sin(box_angle));
  Vec2 box_up = new Vec2(sin(box_angle),cos(box_angle));
  float point_right = dot(relative_pos,box_right);
  float point_up = dot(relative_pos,box_up);
  if ((abs(point_right) < box_w/2) && (abs(point_up) < box_h/2))
    return true;
  return false;
}

void drawArrow(int cx, int cy, int len, float angle){
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  line(-len,0,0, 0);
  line(0, 0,  - 8, -8);
  line(0, 0,  - 8, 8);
  popMatrix();
}

//---------------
//Vec 2 Library
//---------------

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
  
  public float lengthSqr(){
    return x*x+y*y;
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

//2D cross product is a funny concept
// ...its the 3D cross product but with z = 0
// ... (only the resulting z compontent is not zero so we just store is as a scalar)
float cross(Vec2 a, Vec2 b){
  return a.x*b.y - a.y*b.x;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

Vec2 perpendicular(Vec2 a){
  return new Vec2(-a.y,a.x);
}
