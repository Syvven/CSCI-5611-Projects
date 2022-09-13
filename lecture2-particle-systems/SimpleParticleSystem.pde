//Simulation-Driven Animation
//CSCI 5611 Example - Bouncing Balls [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused! Press space to run it.

//TODO:
//  1. The balls start red, make them blue instead.
//  Done

//  2. Randomize the initial particle velocities so that xVel starts in the range (30,90),
//     and yVel starts in the range (-190, -200)
//  Done

//  3. There is currently a small cap on the number of particles that can be spawned. 
//     Raise it up to 400.
//  Done

//  4. Currently, pressing the 'r' key prints that it's resetting the particle system,
//     but it doesn’t actually reset anything yet. Fix that by having the simulation
//     reset when the user presses 'r'.
//  Done

//  5. Pressing the arrow keys will move the big red ball, but sometimes we would like
//     to move it faster. Adjust the code so that holding 'shift' while an arrow key
//     is pressed will make the red ball move twice as fast.
//  Done

//  6. The red ball only moves up/down/left/right. Change the code so that is two keys
//     are pressed simultaneously the red ball will move diagonally.
//  Done

//  7. A common pitfall in games is that the diagonal motion is actually faster than
//     horizontal motion (because you just add the vectors). Make sure your code solving 
//     Step 6 does not have that issue, and that the red ball moves diagonally at the same 
//     speed it move horizontally or vertically.
//  Done

//  8. The small blue balls (particles) have momentum, but they are missing the effect
//     of acceleration due to gravity. Add gravity to the simulation. 
//     Two things to consider in your implementation:
//        -Check to make sure that your particles move in a smooth, clear parabolic arc.
//        -When choosing the magnitude of your gravity vector think very carefully about
//         what the units mean. Don’t just pick 9.8 for gravity unless you are sure it
//         makes sense in the units of the scene you are simulated (hint: how many meters
//         long do you envision a pixel is in your scene).
//  Done

//  9. The current code for bouncing the particles off of the red ball assumes the red
///    ball is stationary. If the ball is moving (e.g., controlled by the user) it should
//     impart some momentum on the particles. Update the collision response to capture this
//     effect in some way. There is no perfect answer here, but try to find something that
//     looks natural.

//Challenge:
//  1. Delete particles which have been around too long (and allow new ones to be created)
//  2. Change the color of the particles over time
//  3. Change the color of the particles as a function of the bounce 



//Simulation paramaters
static int maxParticles = 400;
float sphereRadius = 60;
float r = 5;
float genRate = 20;
float obstacleSpeed = 200;
float obstacleVertSpeed = sqrt((200*200)/2);
float COR = 0.7;
float friction = 0.005;
Vec2 gravity = new Vec2(0,10);

//Initalalize variable
Vec2 spherePos;
Vec2 pos[];
Vec2 vel[];
int numParticles;

void reset() {
  spherePos = new Vec2(300,400);
  pos = new Vec2[maxParticles];
  vel = new Vec2[maxParticles];
  numParticles = 0;
}

void setup(){
  reset();
  size(640,480);
  surface.setTitle("Particle System [CSCI 5611 Example]");
  strokeWeight(2); //Draw thicker lines 
}

Vec2 obstacleVel = new Vec2(0,0);
boolean movingVert;

void update(float dt){
  float toGen_float = genRate * dt;
  int toGen = int(toGen_float);
  float fractPart = toGen_float - toGen;
  if (random(1) < fractPart) toGen += 1;
  if (numParticles < maxParticles) {
    for (int i = 0; i < toGen; i++){
      pos[numParticles] = new Vec2(20+random(20),200+random(20));
      vel[numParticles] = new Vec2(30+random(60),-200+random(10)); 
      numParticles += 1;
    }
  }
  
  if ((upPressed && (leftPressed || rightPressed)) || (downPressed && (leftPressed || rightPressed))) {
    movingVert = true;
  } else {
    movingVert = false;
  }
  
  float obx = 0;
  float oby = 0;

  if (!movingVert) {
    if (leftPressed) obx -= obstacleSpeed;
    if (rightPressed) obx += obstacleSpeed;
    if (upPressed) oby -= obstacleSpeed;
    if (downPressed) oby += obstacleSpeed;
  } else {
    if (leftPressed) obx -= obstacleVertSpeed;
    if (rightPressed) obx += obstacleVertSpeed;
    if (upPressed) oby -= obstacleVertSpeed;
    if (downPressed) oby += obstacleVertSpeed;
  }
  

  obstacleVel = new Vec2(obx, oby);
  obstacleVel.normalized();
  spherePos.add(obstacleVel.times(dt));
  
  for (int i = 0; i <  numParticles; i++){
    boolean frictioned = false;
    Vec2 acc = gravity; //Gravity
    
    pos[i].add(vel[i].times(dt)); //Update position based on velocity
    
    if (pos[i].y > height - r){
      pos[i].y = height - r;
      vel[i].y *= -COR;
      vel[i] = interpolate(vel[i], new Vec2(0, vel[i].y), friction);
    }
    if (pos[i].y < r){
      pos[i].y = r;
      vel[i].y *= -COR;
    }
    if (pos[i].x > width - r){
      pos[i].x = width - r;
      vel[i].x *= -COR;
    }
    if (pos[i].x < r){
      pos[i].x = r;
      vel[i].x *= -COR;
    }
    
    if (pos[i].distanceTo(spherePos) < (sphereRadius+r)){
      Vec2 normal = (pos[i].minus(spherePos)).normalized();
      pos[i] = spherePos.plus(normal.times(sphereRadius+r).times(1.01));
      Vec2 velNormal = normal.times(dot(vel[i],normal));
      vel[i].subtract(velNormal.times(1 + COR));
    }

    vel[i].add(acc);
  }
  
}

boolean leftPressed, rightPressed, upPressed, downPressed, shiftPressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true; 
  if (keyCode == DOWN) downPressed = true;
  if (keyCode == SHIFT) {
    if (!shiftPressed) {
      obstacleSpeed *= 2;
      obstacleVertSpeed *= 2;
    }
    shiftPressed = true;
  }
  if (key == ' ') paused = !paused;
}

void keyReleased(){
  if (key == 'r'){
    reset();
    println("Reseting the System");
  }
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) upPressed = false; 
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == SHIFT) {
    shiftPressed = false;
    obstacleSpeed *= 0.5;
    obstacleVertSpeed *= 0.5;
  }
}


boolean paused = true;
void draw(){
  if (!paused) update(1.0/frameRate);
  
  background(255); //White background
  stroke(0,0,0);
  fill(255,255,0);
  for (int i = 0; i < numParticles; i++){
    circle(pos[i].x, pos[i].y, r*2); //(x, y, diameter)
  }
  
  fill(180,60,40);
  circle(spherePos.x, spherePos.y, sphereRadius*2); //(x, y, diameter)
}






// Begin the Vec2 Libraray

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

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}
