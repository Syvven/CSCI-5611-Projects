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
