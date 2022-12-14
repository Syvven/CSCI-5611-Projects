/* autogenerated by Processing revision 1286 on 2022-09-22 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class FallingBalls extends PApplet {

// //Simulation-Driven Animation
// //CSCI 5611 Example - Bouncing Balls
// // Stephen J. Guy <sjguy@umn.edu>

// static int numParticles = 60;

// float r = 5;
// //Inital positions and velocities of masses
// Vec2 pos[] = new Vec2[numParticles];
// Vec2 vel[] = new Vec2[numParticles];
// Vec2 circles[] = new Vec2[3];

// float sphereRadius = 60;
// float cor = 0.8;
// Vec2 grav = new Vec2(0,9.8);
// float fric = 0.005;
// float accel = 0.01;

// void setup(){
//   size(640,480);
//   surface.setTitle("Falling Balls [CSCI 5611 Example]");
  
//   //Initial boid positions and velocities
//   for (int i = 0; i < numParticles; i++){
//     pos[i] = new Vec2(200+random(300),100+random(200));
//     vel[i] = new Vec2(random(40),100+random(20)); 
//   }

//   circles[0] = new Vec2(100, 400);
//   circles[1] = new Vec2(500, 400);
//   circles[2] = new Vec2(300, 400);
  
//   strokeWeight(2); //Draw thicker lines 
// }

// void update(float dt){
//     Vec2 norm = new Vec2(0,0);
//     for (int i = 0; i <  numParticles; i++){
//         pos[i].add(vel[i].times(dt));
//         if (pos[i].y > height - r){
//             norm.x = 0; norm.y = -1;
//             pos[i].y = height - r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//             vel[i] = interpolate(vel[i], new Vec2(0, vel[i].y), fric);
//         }
//         if (pos[i].y < r){
//             norm.x = 0; norm.y = 1;
//             pos[i].y = r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//         }
//         if (pos[i].x > width - r){
//             norm.x = -1; norm.y = 0;
//             pos[i].x = width - r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//         }
//         if (pos[i].x < r){
//             norm.x = 1; norm.y = 0;
//             pos[i].x = r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//         }
//         for (int j = 0; j < 3; j++) {
//             Vec2 spherePos = circles[j];
//             if (pos[i].distanceTo(spherePos) < (sphereRadius+r)){
//                 //TODO: Code to bounce the balls off of a sphere goes here...
//                 //Find sphere normal at point of contact
//                 //Move along the normal be to no longer colliding with the sphere
//                 //Compute the bounce equation
//                 norm = pos[i].minus(spherePos);
//                 norm.normalize();
//                 pos[i] = spherePos.plus(norm.times(sphereRadius + r).times(1.01)); 
//                 vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor)); // Vf = Vi - N(VdotN)(1+a)
//             }
//         }
//         vel[i] = vel[i].plus(grav);
//     }
// }


// void draw(){
//   update(1.0/frameRate);
  
//   background(255); //White background
//   stroke(0,0,0);
//   fill(10,120,10);
//   for (int i = 0; i < numParticles; i++){
//     circle(pos[i].x, pos[i].y, r*2); 
//   }
  
//   fill(180,60,40);
//   for (int i = 0; i < 3; i++) {
//     circle(circles[i].x, circles[i].y, sphereRadius*2);
//   }
// }
// //Mouse Follow
// //CSCI 5611 Mouse Following with Vec2 [Starter]
// //Instructor: Stephen J. Guy <sjguy@umn.edu>


// // Here is what you should discuss & try to code as a group:
// //  1. Initially, the code shows a dark red circle with a purple-ish outline.
// //     Change the program to draw a red circle with a black outline instead.
// // Done
// //
// //  2. Find the Processing.org reference pages for the circle command. 
// //     Why am I multiplying the radius by 2? (Note: these reference pages are 
// //     very useful, be sure to check them out for general Processing help.)
// //  Ans.
// //     the radius actually sets width and height instead of radius
// //
// //  3. Change the background color to be white instead green.
// // Done
// //
// //  4. Have the ball follow the user's mouse. You should do this by setting
// //      dir to be the vector pointing from the ball's current position (pos)
// //      to the mouse's current position (mousePos).
// // Done
// //
// //  5. Try to get some keyboard input working:  
// //        -When the user presses the 'd' key, double the speed the ball moves. 
// //        -When the user presses the 'h' key, half the speed the ball moves. 
// //  6. The simple approach is Step 4 will leave the ball jittering when it
// //     reaches the mouse. Find a strategy to fix the jitter so the ball stops
// //     completely when it is nicely centered on the mouse.
// //  7. Currently, the variable 'speed' doesn't have a well defined unit and its
// //     effect depends on the framerate. Fix this by using dt in the update function
// //     to make sure the speed value means "pixels per second". Set the speed to
// //     100 pixels per second. Make sure the ball takes about 6.4 seconds to make
// //     it 640 pixels across the screen.
     
// // As a challenge:
// //  1. Give the ball a maximum acceleration (i.e. limit how fast it's velocity can change).
// //  2. Draw an image (sprite) instead of a circle. Try to orient it in the direction of travel.


// int strokeWidth = 2;
// void setup(){
//   size(640,480);
//   surface.setTitle("Mouse Following [CSCI 5611 Example]");
  
//   //Initial circle position
//   pos = new Vec2(200,200);
//   r = 50;
  
//   vel = new Vec2(0.0,0.0); //intial velocity
  
//   strokeWeight(strokeWidth); //Draw thicker lines 
// }

// Vec2 pos; //Circle position
// Vec2 vel; //Circle velocity
// float r;  //Circle radius

// float speed = 100;
// float accel = 0.1;

// void update(float dt){
//   Vec2 mousePos = new Vec2(mouseX, mouseY);
//   Vec2 dir = mousePos.minus(pos); //Should be vector pointing from pos to MousePos
//   if (pos.distanceTo(mousePos) > 1) {
//     if (dir.length() > 0) dir.normalize();
//     dir.mul(dt*speed);
//     vel = interpolate(vel, dir, accel);
//     pos.add(vel);
//   }
// }

// void draw(){
//   update(1/frameRate);
//   background(255,255,255); //White background
//   stroke(0, 0, 0);
//   fill(100,20,10);
//   circle(pos.x, pos.y,r*2); //Question: Why is it radius*2 ?
// }

// void keyPressed(){
//   if (key == 'd'){
//     speed *= 2;
//     println("Doubling ball speed");
//   }
//   if (key == 'h'){
//     speed *= 0.5;
//     println("Halving ball speed");
//   }
//   println("Speed is now:",speed);
// }




// //Begin the Vec2 Library
// //Normally I would put this in a differen tab, but having it here allows you to
// // copy and paste a single file for shared editing and for submission

// public class Vec2 {
//   public float x, y;
  
//   public Vec2(float x, float y){
//     this.x = x;
//     this.y = y;
//   }
  
//   public String toString(){
//     return "(" + x+ "," + y +")";
//   }
  
//   public float length(){
//     return sqrt(x*x+y*y);
//   }
  
//   public float lengthSqr(){
//     return x*x+y*y;
//   }
  
//   public Vec2 plus(Vec2 rhs){
//     return new Vec2(x+rhs.x, y+rhs.y);
//   }
  
//   public void add(Vec2 rhs){
//     x += rhs.x;
//     y += rhs.y;
//   }
  
//   public Vec2 minus(Vec2 rhs){
//     return new Vec2(x-rhs.x, y-rhs.y);
//   }
  
//   public void subtract(Vec2 rhs){
//     x -= rhs.x;
//     y -= rhs.y;
//   }
  
//   public Vec2 times(float rhs){
//     return new Vec2(x*rhs, y*rhs);
//   }
  
//   public void mul(float rhs){
//     x *= rhs;
//     y *= rhs;
//   }
  
//   public void clampToLength(float maxL){
//     float magnitude = sqrt(x*x + y*y);
//     if (magnitude > maxL){
//       x *= maxL/magnitude;
//       y *= maxL/magnitude;
//     }
//   }
  
//   public void setToLength(float newL){
//     float magnitude = sqrt(x*x + y*y);
//     x *= newL/magnitude;
//     y *= newL/magnitude;
//   }
  
//   public void normalize(){
//     float magnitude = sqrt(x*x + y*y);
//     x /= magnitude;
//     y /= magnitude;
//   }
  
//   public Vec2 normalized(){
//     float magnitude = sqrt(x*x + y*y);
//     return new Vec2(x/magnitude, y/magnitude);
//   }
  
//   public float distanceTo(Vec2 rhs){
//     float dx = rhs.x - x;
//     float dy = rhs.y - y;
//     return sqrt(dx*dx + dy*dy);
//   }
// }

// Vec2 interpolate(Vec2 a, Vec2 b, float t){
//   return a.plus((b.minus(a)).times(t));
// }

// float interpolate(float a, float b, float t){
//   return a + ((b-a)*t);
// }

// float dot(Vec2 a, Vec2 b){
//   return a.x*b.x + a.y*b.y;
// }

// Vec2 projAB(Vec2 a, Vec2 b){
//   return b.times(a.x*b.x + a.y*b.y);
// }
//Mouse Follow
//CSCI 5611 Mouse Following with Vec2 [Starter]
//Instructor: Stephen J. Guy <sjguy@umn.edu>


// Here is what you should discuss & try to code as a group:
//  1. Initially, the code shows a dark red circle with a purple-ish outline.
//     Change the program to draw a red circle with a black outline instead.
//  Done

//  2. Find the Processing.org reference pages for the circle command. 
//     Why am I multiplying the radius by 2? (Note: these reference pages are 
//     very useful, be sure to check them out for general Processing help.)
//  Ans.
//     the radius actually sets width and height instead of radius

//  3. Change the background color to be white instead green.
//  Done

//  4. Have the ball follow the user's mouse. You should do this by setting
//      dir to be the vector pointing from the ball's current position (pos)
//      to the mouse's current position (mousePos).
//  Done

//  5. Try to get some keyboard input working:  
//        -When the user presses the 'd' key, double the speed the ball moves. 
//        -When the user presses the 'h' key, half the speed the ball moves. 
//  Done

//  6. The simple approach is Step 4 will leave the ball jittering when it
//     reaches the mouse. Find a strategy to fix the jitter so the ball stops
//     completely when it is nicely centered on the mouse.
//  Done

//  7. Currently, the variable 'speed' doesn't have a well defined unit and its
//     effect depends on the framerate. Fix this by using dt in the update function
//     to make sure the speed value means "pixels per second". Set the speed to
//     100 pixels per second. Make sure the ball takes about 6.4 seconds to make
//     it 640 pixels across the screen.
//  Done
     
// As a challenge:
//  1. Give the ball a maximum acceleration (i.e. limit how fast it's velocity can change).
//  Done

//  2. Draw an image (sprite) instead of a circle. Try to orient it in the direction of travel.
//  Done


int strokeWidth = 2;
PImage img;
PImage img2;
PImage bg;
Vec2 pos; //Image position
Vec2 vel; //Image velocity
Vec2 img_dir; //Image direction
float w, h;

 public void setup(){
  /* size commented out by preprocessor */;
  surface.setTitle("Mouse Following Image [CSCI 5611 Example]");
  surface.setResizable(true);
  //Initial circle position
  pos = new Vec2(200,200);
  
  vel = new Vec2(0.0f,0.0f); //intial velocity

  img = loadImage("cat.png");
  img.resize(img.width/3, img.height/3);
  img_dir = new Vec2(-1, 0);

  bg = loadImage("space.png");
  bg.resize(width, height);
  w = width;
  h = height;
  
  strokeWeight(strokeWidth); //Draw thicker lines 
}

float speed = 100;
float accel = 0.03f;
float rot = 1;

 public void update(float dt){
    Vec2 mousePos = new Vec2(mouseX, mouseY);
    Vec2 dir = mousePos.minus(pos); //Should be vector pointing from pos to MousePos
    if (dir.length() > speed*dt) {
        if (dir.length() > 0) dir.normalize();
        dir.mul(speed*dt);
        vel = interpolate(vel, dir, accel);
        pos.add(vel);
        // rot = atan2(img_dir.y - vel.y,img_dir.x - vel.x);
        rot = rotateTo(img_dir, vel);
    } else {
        vel.x = 0; vel.y = 0;
        pos.x = mouseX; pos.y = mouseY;
    }
}

 public void draw(){
    update(1/frameRate);
    if (width != w || height != h) {
      bg.resize(width, height);
    }
    background(bg); //White background
    stroke(0, 0, 0);
    fill(100,20,10);

    imageMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(rot);
    image(img, 0,0); //Question: Why is it radius*2 ?
    popMatrix();
    imageMode(CORNER);
}

 public void keyPressed(){
  if (key == 'd'){
    speed *= 2;
    println("Doubling ball speed");
  }
  if (key == 'h'){
    speed *= 0.5f;
    println("Halving ball speed");
  }
  println("Speed is now:",speed);
}




//Begin the Vec2 Library
//Normally I would put this in a differen tab, but having it here allows you to
// copy and paste a single file for shared editing and for submission

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

 public Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

 public float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

 public float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

 public Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

 public float rotateTo(Vec2 a, Vec2 b) {
    float cross = a.x*b.y-a.y*b.x;
    // float first = cross.x+cross.y+cross.z;
    return atan2(cross, dot(a,b));
}
// //Vector Library
// //CSCI 5611 Vector 2 Library [Example]
// // Stephen J. Guy <sjguy@umn.edu>

// public class Vec2 {
//   public float x, y;
  
//   public Vec2(float x, float y){
//     this.x = x;
//     this.y = y;
//   }
  
//   public String toString(){
//     return "(" + x+ "," + y +")";
//   }
  
//   public float length(){
//     return sqrt(x*x+y*y);
//   }
  
//   public Vec2 plus(Vec2 rhs){
//     return new Vec2(x+rhs.x, y+rhs.y);
//   }
  
//   public void add(Vec2 rhs){
//     x += rhs.x;
//     y += rhs.y;
//   }
  
//   public Vec2 minus(Vec2 rhs){
//     return new Vec2(x-rhs.x, y-rhs.y);
//   }
  
//   public void subtract(Vec2 rhs){
//     x -= rhs.x;
//     y -= rhs.y;
//   }
  
//   public Vec2 times(float rhs){
//     return new Vec2(x*rhs, y*rhs);
//   }
  
//   public void mul(float rhs){
//     x *= rhs;
//     y *= rhs;
//   }
  
//   public void clampToLength(float maxL){
//     float magnitude = sqrt(x*x + y*y);
//     if (magnitude > maxL){
//       x *= maxL/magnitude;
//       y *= maxL/magnitude;
//     }
//   }
  
//   public void setToLength(float newL){
//     float magnitude = sqrt(x*x + y*y);
//     x *= newL/magnitude;
//     y *= newL/magnitude;
//   }
  
//   public void normalize(){
//     float magnitude = sqrt(x*x + y*y);
//     x /= magnitude;
//     y /= magnitude;
//   }
  
//   public Vec2 normalized(){
//     float magnitude = sqrt(x*x + y*y);
//     return new Vec2(x/magnitude, y/magnitude);
//   }
  
//   public float distanceTo(Vec2 rhs){
//     float dx = rhs.x - x;
//     float dy = rhs.y - y;
//     return sqrt(dx*dx + dy*dy);
//   }
// }

// Vec2 interpolate(Vec2 a, Vec2 b, float t){
//   return a.plus((b.minus(a)).times(t));
//   // a + ((b-a)*t)
// }

// float interpolate(float a, float b, float t){
//   return a + ((b-a)*t);
// }

// float dot(Vec2 a, Vec2 b){
//   return a.x*b.x + a.y*b.y;
// }

// Vec2 projAB(Vec2 a, Vec2 b){
//   return b.times(a.x*b.x + a.y*b.y);
// }


  public void settings() { size(640, 480); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "FallingBalls" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
