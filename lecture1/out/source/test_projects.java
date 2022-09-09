/* autogenerated by Processing revision 1286 on 2022-09-08 */
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

public class test_projects extends PApplet {

// // /////////////////////////////////////////////
// //          LECTURE #1 9/7/2022              //
// // /////////////////////////////////////////////

// //Mouse Follow
// //CSCI 5611 Mouse Following with Vec2 [Starter]
// //Instructor: Stephen J. Guy <sjguy@umn.edu>


// //Here is what you should discuss & try to code as a group:
// //  1. Initially, the code shows a dark red circle with a purple-ish outline.
// //     Change the program to draw a red circle with a black outline instead.
// //  2. Find the Processing.org reference pages for the circle command. 
// //     Why am I multiplying the radius by 2? (Note: these reference pages are 
// //     very useful, be sure to check them out for general Processing help.)
// //  3. Change the background color to be white instead green.
// //  4. Have the ball follow the user's mouse. You should do this by setting
// //      dir to be the vector pointing from the ball's current position (pos)
// //      to the mouse's current position (mousePos).
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
     
// //As a challenge:
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

// float speed = 4;

// void update(float dt){
//   Vec2 mousePos = new Vec2(mouseX, mouseY);
//   Vec2 dir = new Vec2(0,0); //Should be vector pointing from pos to MousePos
//   if (dir.length() > 0) dir.normalize();
//   vel = dir.times(speed);
//   pos.add(vel);
// }

// void draw(){
//   update(1/frameRate);
//   background(0,200,70); //White background
//   stroke(100,0,200);
//   fill(100,20,10);
//   circle(pos.x, pos.y,r*2); //Question: Why is it radius*2 ?
// }

// void keyPressed(){
//   if (key == 'd'){
//     println("Doubling ball speed");
//   }
//   if (key == 'h'){
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


// // /**
// //  * Geometry
// //  * by Marius Watz.
// //  *
// //  * Using sin/cos, blends colors, and draws a series of
// //  * rotating arcs on the screen.
// // */

// // final int COUNT = 150;

// // float[] pt;
// // int[] style;


// // void setup() {
// //   size(1024, 768, P3D);
// //   background(255);
// //   //randomSeed(100);  // use this to get the same result each time

// //   pt = new float[6 * COUNT]; // rotx, roty, deg, rad, w, speed
// //   style = new int[2 * COUNT]; // color, render style

// //   // Set up arc shapes
// //   int index = 0;
// //   for (int i = 0; i < COUNT; i++) {
// //     pt[index++] = random(TAU); // Random X axis rotation
// //     pt[index++] = random(TAU); // Random Y axis rotation

// //     pt[index++] = random(60,80); // Short to quarter-circle arcs
// //     if (random(100) > 90) {
// //       pt[index] = floor(random(8,27)) * 10;
// //     }

// //     pt[index++] = int(random(2,50)*5); // Radius. Space them out nicely

// //     pt[index++] = random(4,32); // Width of band
// //     if (random(100) > 90) {
// //       pt[index] = random(40,60); // Width of band
// //     }

// //     pt[index++] = radians(random(5,30)) / 5; // Speed of rotation

// //     /*
// //     // alternate color scheme
// //     float prob = random(100);
// //     if (prob < 30) {
// //       style[i*2] = colorBlended(random(1), 255,0,100, 255,0,0, 210);
// //     } else if (prob < 70) {
// //       style[i*2] = colorBlended(random(1), 0,153,255, 170,225,255, 210);
// //     } else if (prob < 90) {
// //       style[i*2] = colorBlended(random(1), 200,255,0, 150,255,0, 210);
// //     } else {
// //       style[i*2] = color(255,255,255, 220);
// //     }
// //     */

// //     float prob = random(100);
// //     if (prob < 50) {
// //       style[i*2] = colorBlended(random(1), 200,255,0, 50,120,0, 210);
// //     } else if (prob <90) {
// //       style[i*2] = colorBlended(random(1), 255,100,0, 255,255,0, 210);
// //     } else {
// //       style[i*2] = color(255,255,255, 220);
// //     }

// //     style[i*2+1] = floor(random(100)) % 3;
// //   }
// // }


// // void draw() {
// //   background(0);

// //   translate(width/2, height/2, 0);
// //   rotateX(PI / 6);
// //   rotateY(PI / 6);

// //   int index = 0;
// //   for (int i = 0; i < COUNT; i++) {
// //     pushMatrix();
// //     rotateX(pt[index++]);
// //     rotateY(pt[index++]);

// //     if (style[i*2+1] == 0) {
// //       stroke(style[i*2]);
// //       noFill();
// //       strokeWeight(1);
// //       arcLine(0, 0, pt[index++], pt[index++], pt[index++]);

// //     } else if(style[i*2+1] == 1) {
// //       fill(style[i*2]);
// //       noStroke();
// //       arcLineBars(0, 0, pt[index++], pt[index++], pt[index++]);

// //     } else {
// //       fill(style[i*2]);
// //       noStroke();
// //       arc(0, 0, pt[index++], pt[index++], pt[index++]);
// //     }

// //     // increase rotation
// //     pt[index-5] += pt[index] / 10;
// //     pt[index-4] += pt[index++] / 20;

// //     popMatrix();
// //   }
// // }


// // // Get blend of two colors
// // int colorBlended(float fract,
// //                  float r, float g, float b,
// //                  float r2, float g2, float b2, float a) {
// //   return color(r + (r2 - r) * fract,
// //                g + (g2 - g) * fract,
// //                b + (b2 - b) * fract, a);
// // }


// // // Draw arc line
// // void arcLine(float x, float y, float degrees, float radius, float w) {
// //   int lineCount = floor(w/2);

// //   for (int j = 0; j < lineCount; j++) {
// //     beginShape();
// //     for (int i = 0; i < degrees; i++) {  // one step for each degree
// //       float angle = radians(i);
// //       vertex(x + cos(angle) * radius,
// //              y + sin(angle) * radius);
// //     }
// //     endShape();
// //     radius += 2;
// //   }
// // }


// // // Draw arc line with bars
// // void arcLineBars(float x, float y, float degrees, float radius, float w) {
// //   beginShape(QUADS);
// //   for (int i = 0; i < degrees/4; i += 4) {  // degrees, but in steps of 4
// //     float angle = radians(i);
// //     vertex(x + cos(angle) * radius,
// //            y + sin(angle) * radius);
// //     vertex(x + cos(angle) * (radius+w),
// //            y + sin(angle) * (radius+w));

// //     angle = radians(i+2);
// //     vertex(x + cos(angle) * (radius+w),
// //            y + sin(angle) * (radius+w));
// //     vertex(x + cos(angle) * radius,
// //            y + sin(angle) * radius);
// //   }
// //   endShape();
// // }


// // // Draw solid arc
// // void arc(float x, float y, float degrees, float radius, float w) {
// //   beginShape(QUAD_STRIP);
// //   for (int i = 0; i < degrees; i++) {
// //     float angle = radians(i);
// //     vertex(x + cos(angle) * radius,
// //            y + sin(angle) * radius);
// //     vertex(x + cos(angle) * (radius+w),
// //            y + sin(angle) * (radius+w));
// //   }
// //   endShape();
// // }

//Simulation-Driven Animation
//CSCI 5611 Example - Bouncing Balls
// Stephen J. Guy <sjguy@umn.edu>

static int numParticles = 60;

float r = 5;
//Inital positions and velocities of masses
Vec2 pos[] = new Vec2[numParticles];
Vec2 vel[] = new Vec2[numParticles];
Vec2 circles[] = new Vec2[3];

float sphereRadius = 60;
float cor = 0.89f;
Vec2 grav = new Vec2(0,5);
float accel = 0.01f;

 public void setup(){
  /* size commented out by preprocessor */;
  surface.setTitle("Falling Balls [CSCI 5611 Example]");
  
  //Initial boid positions and velocities
  for (int i = 0; i < numParticles; i++){
    pos[i] = new Vec2(200+random(300),100+random(200));
    vel[i] = new Vec2(random(40),100+random(20)); 
  }

  circles[0] = new Vec2(100, 400);
  circles[1] = new Vec2(500, 400);
  circles[2] = new Vec2(300, 400);
  
  strokeWeight(2); //Draw thicker lines 
}

 public void update(float dt){
    Vec2 norm = new Vec2(0,0);
    for (int i = 0; i <  numParticles; i++){
        pos[i].add(vel[i].times(dt));
        if (pos[i].y > height - r){
            norm.x = 0; norm.y = -1;
            pos[i].y = height - r;
            vel[i] = vel[i].minus(norm.times(dot(vel[i], norm)).times(1+cor));
        }
        if (pos[i].y < r){
            norm.x = 0; norm.y = 1;
            pos[i].y = r;
            vel[i] = vel[i].minus(norm.times(dot(vel[i], norm)).times(1+cor));
        }
        if (pos[i].x > width - r){
            norm.x = -1; norm.y = 0;
            pos[i].x = width - r;
            vel[i] = vel[i].minus(norm.times(dot(vel[i], norm)).times(1+cor));
        }
        if (pos[i].x < r){
            norm.x = 1; norm.y = 0;
            pos[i].x = r;
            vel[i] = vel[i].minus(norm.times(dot(vel[i], norm)).times(1+cor));
        }
        for (int j = 0; j < 3; j++) {
            Vec2 spherePos = circles[j];
            if (pos[i].distanceTo(spherePos) < (sphereRadius+r)){
                //TODO: Code to bounce the balls off of a sphere goes here...
                //Find sphere normal at point of contact
                //Move along the normal be to no longer colliding with the sphere
                //Compute the bounce equation
                norm = pos[i].minus(spherePos);
                norm.normalize();
                pos[i] = spherePos.plus(norm.times(sphereRadius + r).times(1.01f)); 
                vel[i] = vel[i].minus(norm.times(dot(vel[i], norm)).times(1+cor)); // Vf = Vi - N(VdotN)(1+a)
            }
        }
        
        vel[i] = vel[i].plus(grav);
    }
}


 public void draw(){
  update(1.0f/frameRate);
  
  background(255); //White background
  stroke(0,0,0);
  fill(10,120,10);
  for (int i = 0; i < numParticles; i++){
    circle(pos[i].x, pos[i].y, r*2); 
  }
  
  fill(180,60,40);
  for (int i = 0; i < 3; i++) {
    circle(circles[i].x, circles[i].y, sphereRadius*2);
  }
}
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
// float accel = 0.5;

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


  public void settings() { size(640, 480); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "test_projects" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
