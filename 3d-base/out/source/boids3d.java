/* autogenerated by Processing revision 1286 on 2022-09-18 */
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

public class boids3d extends PApplet {

// Testing for 3d and eventually making a 3d boid simulation

int kiwiFrames = 4;
PShape kiwi;
PShape[] shapes = new PShape[kiwiFrames];
int[] times = new int[kiwiFrames];

Camera camera;

// float angle;
// float concentration;
// float viewOff;

// PVector half = new PVector();
// PVector mouse = new PVector();

 public void setup() {
    /* size commented out by preprocessor */;
    surface.setTitle("3d Stuff");
    surface.setResizable(true);
    surface.setLocation(500,500);
    strokeWeight(5);

    camera = new Camera();
    oneeighty = radians(180);

    // angle = QUARTER_PI;
    // viewOff = height * .86602;

    // half.set(width * .5, height * .5);

    String base = "data/kiwi";
    for (int i = 1; i <= kiwiFrames; i++) {
        String file = base + i + ".obj";
        println(file);
        shapes[i-1] = loadShape(file);
    }
    times[0] = 5; times[2] = 5;
    times[1] = 2; times[3] = 2;
}

 public void reset() {
    
}

 public void drawBounds() {
    // x axis --> red
    stroke(255,0,0);
    line(0,0,0,3000,0,0);
    line(0,0,0,-3000,0,0);
    

    // y axis --> green
    stroke(0,255,0);
    line(0,0,0,0,3000,0);
    line(0,0,0,0,-3000,0);

    // z axis --> blue
    stroke(0,0,255);
    line(0,0,0,0,0,3000);
    line(0,0,0,0,0,-3000);
}

 public void checkPressed() {

}

 public void update() {
    
}

// Kiwi Frame Info
// -> Frames 1 and 3 around for 5 frams
// -> 2 and 4 are 2 frames


float oneeighty;
float total_time = 0;
int switchframe = 0;
int frame = 0;
float kiwi_framerate = 28;
 public void draw() {
    total_time += 1/frameRate;
    if (total_time > 1/kiwi_framerate) {
        total_time = 0;
        switchframe++;
        if (switchframe == times[frame]) {
            switchframe = 0;
            frame = (frame+1)%4;
        }
    }

    background(50);

    // Sets the default ambient 
    // and directional light
    colorMode(HSB, 360, 100, 100);
    lightFalloff(1,0,0);
    lightSpecular(0,0,10);
    ambientLight(0,0,100);
    directionalLight(128,128,128, 0,0,0);
    colorMode(RGB, 255, 255, 255);

    // concentration = map(cos(frameCount * .01), -1, 1, 12, 100);
    // mouse.set(mouseX - half.x, mouseY - half.y, viewOff);
    // mouse.normalize();

    // // Flash light.
    // spotLight(
    //     191, 170, 133,
    //     0, 0, viewOff,
    //     mouse.x, mouse.y, -1,
    //     angle, concentration
    // );

    camera.Update(1.0f/frameRate);

    // used for understanding where the bounds of the scene are
    drawBounds();
    checkPressed();
    update();

    fill(255);
    pushMatrix();
    fill(255,0,0);
    translate(0,0, 0);
    shape(shapes[frame], 0, 0);
    popMatrix();
}

 public void mouseWheel(MouseEvent event) {
    
}

 public void keyPressed()
{
  camera.HandleKeyPressed();
}

 public void keyReleased()
{
  camera.HandleKeyReleased();
}

// CSCI 5611 Vector 3 Library
// Noah J Hendrickson <hend0800@umn.edu>

public class Vec3 {
    public float x, y, z;

    public Vec3(float x, float y, float z){
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public String toString(){
        return "(" + x + "," + y + "," + z + ")";
    }

    public float length(){
        return sqrt(x*x+y*y+z*z);
    }

    public Vec3 plus(Vec3 rhs){
        return new Vec3(x+rhs.x, y+rhs.y, z+rhs.z);
    }

    public void add(Vec3 rhs){
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
    }

    public Vec3 minus(Vec3 rhs){
        return new Vec3(x-rhs.x, y-rhs.y, z-rhs.z);
    }

    public void subtract(Vec3 rhs){
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
    }

    public Vec3 times(float rhs){
        return new Vec3(x*rhs, y*rhs, z*rhs);
    }

    public void mul(float rhs){
        x *= rhs;
        y *= rhs;
        z *= rhs;
    }

    public void clampToLength(float maxL){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > maxL){
            x *= maxL/magnitude;
            y *= maxL/magnitude;
            z *= maxL/magnitude;
        }
    }

    public void setToLength(float newL){
        float magnitude = sqrt(x*x + y*y);
        x *= newL/magnitude;
        y *= newL/magnitude;
        z *= newL/magnitude;
    }

    public void normalize(){
        float magnitude = sqrt(x*x + y*y + z*z);
        x /= magnitude;
        y /= magnitude;
        z /= magnitude;
    }

    public Vec3 normalized(){
        float magnitude = sqrt(x*x + y*y + z*z);
        return new Vec3(x/magnitude, y/magnitude, z/magnitude);
    }

    public float distanceTo(Vec3 rhs){
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        float dz = rhs.z - z;
        return sqrt(dx*dx + dy*dy + dz*dz);
    }

    public void rotateAroundZ(float rad) {
        x = cos(rad)*x-sin(rad)*y;
        y = sin(rad)*x+cos(rad)*y;
        z = z;
    }

    public void rotateAroundY(float rad) {
        x = cos(rad)*x+sin(rad)*z;
        y = y;
        z = -sin(rad)*x+cos(rad)*z;
    }

    public void rotateAroundX(float rad) {
        x = x;
        y = cos(rad)*y-sin(rad)*z;
        z = sin(rad)*y+cos(rad)*z;
    }

    public Vec3 rotatedAroundZ(float rad) {
        float newx = cos(rad)*x-sin(rad)*y;
        float newy = sin(rad)*x+cos(rad)*y;
        float newz = z;
        return new Vec3(newx, newy, newz);
    }

    public Vec3 rotatedAroundY(float rad) {
        float newx = cos(rad)*x+sin(rad)*z;
        float newy = y;
        float newz = -sin(rad)*x+cos(rad)*z;
        return new Vec3(newx, newy, newz);
    }

    public Vec3 rotatedAroundX(float rad) {
        float newx = x;
        float newy = cos(rad)*y-sin(rad)*z;
        float newz = sin(rad)*y+cos(rad)*z;
        return new Vec3(newx, newy, newz);
    }
}

 public Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return a.plus((b.minus(a)).times(t));
  // a + ((b-a)*t)
}

 public float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

 public float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}

 public Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(a.x*b.x + a.y*b.y + a.z*b.z);
}
// Created for CSCI 5611 by Liam Tyler

// WASD keys move the camera relative to its current orientation
// Arrow keys rotate the camera's orientation
// Holding shift boosts the move speed

class Camera
{
  Camera()
  {
    position      = new PVector( 0, 0, 0 ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 30;
    turnSpeed     = 1.3f; // radians/sec
    boostSpeed    = 5;  // extra speed boost for when you press shift
    
    // dont need to change these
    shiftPressed = false;
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    verticalMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1f;
    farPlane         = 10000;
  }
  
   public void Update(float dt)
  {
    theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
    
    // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    float maxAngleInRadians = 85 * PI / 180;
    phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    if (negativeMovement.mag() > 0) negativeMovement.normalize();
    if (positiveMovement.mag() > 0) positiveMovement.normalize();
    if (verticalMovement.mag() > 0) verticalMovement.normalize();

    if (shiftPressed){
      positiveMovement.mult(boostSpeed);
      negativeMovement.mult(boostSpeed);
      verticalMovement.mult(boostSpeed);
    }

    PVector velocity   = new PVector( 
      negativeMovement.x + positiveMovement.x + verticalMovement.x, 
      negativeMovement.y + positiveMovement.y + verticalMovement.y, 
      negativeMovement.z + positiveMovement.z 
    );

    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( position.x, position.y, position.z,
            position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
            upDir.x, upDir.y, upDir.z );
  }
  
  // only need to change if you want difrent keys for the controls
   public void HandleKeyPressed()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 1;
    if ( key == 's' || key == 'S' ) negativeMovement.z = -1;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = -1;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 1;
    if ( key == 'q' || key == 'Q' ) positiveMovement.y = 1;
    if ( key == 'e' || key == 'E' ) negativeMovement.y = -1;
    if ( key == ' ' ) verticalMovement.y = -1;
    if ( key == 'r' || key == 'R' ){
      Camera defaults = new Camera();
      position = defaults.position;
      theta = defaults.theta;
      phi = defaults.phi;
    }
    
    if ( keyCode == LEFT )  negativeTurn.x = 1;
    if ( keyCode == RIGHT ) positiveTurn.x = -0.5f;
    if ( keyCode == UP )    positiveTurn.y = 0.5f;
    if ( keyCode == DOWN )  negativeTurn.y = -1;
    if ( keyCode == CONTROL ) verticalMovement.y = 1;
    
    if ( keyCode == SHIFT ) shiftPressed = true; 
  }
  
  // only need to change if you want difrent keys for the controls
   public void HandleKeyReleased()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 0;
    if ( key == 'q' || key == 'Q' ) positiveMovement.y = 0;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 0;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = 0;
    if ( key == 's' || key == 'S' ) negativeMovement.z = 0;
    if ( key == 'e' || key == 'E' ) negativeMovement.y = 0;
    if ( key == ' ' ) verticalMovement.y = 0;
    
    if ( keyCode == LEFT  ) negativeTurn.x = 0;
    if ( keyCode == RIGHT ) positiveTurn.x = 0;
    if ( keyCode == UP    ) positiveTurn.y = 0;
    if ( keyCode == DOWN  ) negativeTurn.y = 0;
    if ( keyCode == CONTROL ) verticalMovement.y = 0;
    
    if ( keyCode == SHIFT ){
      shiftPressed = false;
      positiveMovement.mult(1.0f/boostSpeed);
      negativeMovement.mult(1.0f/boostSpeed);
    }
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  float boostSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector verticalMovement;
  PVector negativeTurn;
  PVector positiveTurn;
  boolean shiftPressed;
};




// ----------- Example using Camera class -------------------- //
// Camera camera;

// void setup()
// {
//   size(600, 600, P3D);
//   camera = new Camera();
// }

// void keyPressed()
// {
//   camera.HandleKeyPressed();
// }

// void keyReleased()
// {
//   camera.HandleKeyReleased();
// }

// void draw() {
//   background(255);
//   noLights();

//   camera.Update(1.0/frameRate);
  
//   // draw six cubes surrounding the origin (front, back, left, right, top, bottom)
//   fill( 0, 0, 255 );
//   pushMatrix();
//   translate( 0, 0, -50 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 0, 0, 50 );
//   box( 20 );
//   popMatrix();
  
//   fill( 255, 0, 0 );
//   pushMatrix();
//   translate( -50, 0, 0 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 50, 0, 0 );
//   box( 20 );
//   popMatrix();
  
//   fill( 0, 255, 0 );
//   pushMatrix();
//   translate( 0, 50, 0 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 0, -50, 0 );
//   box( 20 );
//   popMatrix();
// }


  public void settings() { size(1200, 1200, P3D); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "boids3d" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}