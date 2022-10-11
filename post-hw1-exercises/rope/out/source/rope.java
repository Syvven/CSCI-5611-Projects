/* autogenerated by Processing revision 1286 on 2022-10-10 */
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

public class rope extends PApplet {


//PDEs and Integration
//CSCI 5611 Swinging Rope [Exercise]
//Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused, press "space" to unpause

//TODO:
//  1. The rope moves very slowly now, this is because the timestep is 1/20 of realtime
//      a. Make the timestep realtime (20 times faster than the inital code), what happens?
//      It breaks :(
//      b. Call the small 1/20th timestep update, 20 times each frame (in a for loop) -- why is it different?
//      It works :) and it works because its not a lot of force at once i.e. a smaller timestep for the integration

//  2. When the rope hanging down fully the spacing between the links is not equal, even though they
//     where initalized with an even spacing between each node. What is this?
//      - If this is a bug, fix the corisponding code
//      - If this why is not a bug, explain why this is the expected behavior
//      This is expected because the top balls have more weight pulling them down than the bottom ones

//  3. By default, the rope starts vertically. Change initScene() so it starts at an angle. The rope should
//     then swing backc and forth.
//    Done

//  4. Try changing the mass and the k value. How do they interact wich each other?
//   Higher k will make the length shorter, higher mass will make it longer

//  5. Set the kv value very low, does the rope bounce a lot? What about a high kv (not too high)?
//     Why doesn't the rope stop swinging at high values of kv?
//   Very low --> lots of bounce, Very high --> not a lot of bounce
//   The rope doesnt stop swinging because kv only works along the rope direction
   
//  6. Add friction/drag so that the rope eventually stops. An easy friction model is a scaled force 
//     in the opposite direction of a nodes current velocity. 
//   

//Challenge:
//  - Set the top of the rope to be wherever the user's mouse is, and allow the user to drag the rope around the scene.
//     Done

//  - Keep the top of the rope fixed, but allow the user to click and drag one of the balls of the rope to move it around.
//     Done

//  - Place a medium-sized, static 2D ball in the scene, have the nodes on the rope experience a "bounce" force if they collide with this ball.


//Create Window
String windowTitle = "Swinging Rope";
 public void setup() {
  /* size commented out by preprocessor */;
  surface.setTitle(windowTitle);
  initScene();
}

//Simulation Parameters
float floor = 500;
Vec2 gravity = new Vec2(0,400);
float radius = 10;
Vec2 stringTop = new Vec2(200,50);
float restLen = 10;
float mass = 0.01f; //TRY-IT: How does changing mass affect resting length of the rope?
float k = 1000; //TRY-IT: How does changing k affect resting length of the rope?
float kv = 200; //TRY-IT: How big can you make kv? --> 500 max
float kfric = 20;

//Initial positions and velocities of masses
static int maxNodes = 100;
Vec2 pos[] = new Vec2[maxNodes];
Vec2 vel[] = new Vec2[maxNodes];
Vec2 acc[] = new Vec2[maxNodes];

Vec2 obstPos;
float obstRad = 50;

int numNodes = 100;

boolean mouseHeld = false;

 public void initScene(){
  obstPos = new Vec2(width/2, height/2);
  for (int i = 0; i < numNodes; i++){
    pos[i] = new Vec2(0,0);
    pos[i].x = stringTop.x + 1*i;
    pos[i].y = stringTop.y + 1*i; //Make each node a little lower
    vel[i] = new Vec2(0,0);
  }
}

 public void update(float dt){

  if (mouseHeld) {
    // dragging around rope from any position
    // defaults to top if not over a node
    pos[heldNode].x = mouseX; pos[heldNode].y = mouseY;
  }

  //Reset accelerations each timestep (momenum only applies to velocity)
  for (int i = 0; i < numNodes; i++){
    acc[i] = new Vec2(0,0);
    acc[i].add(gravity);
  }
  
  //Compute (damped) Hooke's law for each spring
  for (int i = 0; i < numNodes-1; i++){
    Vec2 diff = pos[i+1].minus(pos[i]);
    float stringF = -k*(diff.length() - restLen);
    //println(stringF,diff.length(),restLen);
    
    Vec2 stringDir = diff.normalized();
    float projVbot = dot(vel[i], stringDir);
    float projVtop = dot(vel[i+1], stringDir);
    float dampF = -kv*(projVtop - projVbot);

    Vec2 dampFric = new Vec2(0,0);
    dampFric.x = -kfric*(vel[i].x-(i==0?0:vel[i-1].x));
    dampFric.y = -kfric*(vel[i].y-(i==0?0:vel[i-1].y));
    
    stringDir.x = stringDir.x * (stringF+dampF);
    stringDir.y = stringDir.y * (stringF+dampF);
    Vec2 force = new Vec2(stringDir.x, stringDir.y);

    acc[i].add(force.times(-1.0f/mass));
    acc[i].add(dampFric);
    acc[i+1].add(force.times(1.0f/mass));
  }

  //Eulerian integration
  for (int i = 1; i < numNodes; i++){
    if (heldNode != i) {
      vel[i].add(acc[i].times(dt));
      pos[i].add(vel[i].times(dt));
    }
  }
  
  //Collision detection and response
  for (int i = 0; i < numNodes; i++){
    if (pos[i].y+radius > floor){
      vel[i].y *= -.1f;
      pos[i].y = floor - radius;
    }
    if (pos[i].distanceTo(obstPos) < (3+obstRad)) {
      Vec2 dir = pos[i].minus(obstPos);
      dir.normalize();
      pos[i] = obstPos.plus(dir.times(3+obstRad).times(1.01f));
      Vec2 velNorm = dir.times(dot(vel[i],dir));
      vel[i].subtract(velNorm.times(1+0.1f));
    }
    // if (pos[i].x+radius > width){
    //   pos[i].x = width - radius;
    // }
    // if (pos[i].x-radius < 0) {
    //   pos[i].x = radius;
    // }
  }
}

//Draw the scene: one sphere per mass, one line connecting each pair
boolean paused = true;
 public void draw() {
  background(255,255,255);
  if (!paused) {
    // b --> this works
    for (int i = 0; i < 720; i++) {
      update(1/(720*frameRate));
    }
    
    // a --> this breaks
    // update(1/frameRate);
  }
  fill(0,0,0);
  
  pushMatrix();
    translate(obstPos.x, obstPos.y);
    sphere(obstRad);
  popMatrix();

  for (int i = 0; i < numNodes-1; i++){
    // pushMatrix();
      line(pos[i].x,pos[i].y,pos[i+1].x,pos[i+1].y);
      // translate(pos[i+1].x,pos[i+1].y);
      // sphere(radius);
    // popMatrix();
  }
  
  if (paused)
    surface.setTitle(windowTitle + " [PAUSED]");
  else
    surface.setTitle(windowTitle + " "+ nf(frameRate,0,2) + "FPS");
}

 public void keyPressed(){
  if (key == ' ') paused = !paused;
  if (key == 'r') initScene();
}

int heldNode = 0;
 public void mousePressed() {
  mouseHeld = true;
  Vec2 msPos = new Vec2(mouseX, mouseY);
  for (int i = 0; i < numNodes; i++) {
    if (msPos.distanceTo(pos[i]) < radius) {
      heldNode = i;
      return;
    }
  }
}

 public void mouseReleased() {
  mouseHeld = false;
  heldNode = 0;
}


///////////////////
// Vec2D Library
///////////////////

public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ ", " + y +")";
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
  
  public void normalize(){
    float magnitude = sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
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


  public void settings() { size(400, 500, P3D); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "rope" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
