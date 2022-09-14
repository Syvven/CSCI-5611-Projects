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

