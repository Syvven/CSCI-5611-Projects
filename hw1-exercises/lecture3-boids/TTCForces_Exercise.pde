//CSCI 5611 - Pathing and Crowd Sim
//Anticipatory Collision Avoidance (TTC-Forces) [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused! Press the spacebar to run it.

/*
TODO:
  1. Currently, there are no forces acting on the agents. Add a goal force that penalizes
     the difference between an agent's current velocity and it's goal velocity.
     i.e., goal_force = goal_vel-current_vel; acc += goal_force
  Done 

  1a. Scale the goal force by the value k_goal. Find a value of k_goal that lets the agents
     smoothly reach their goal without overshooting it first.
     i.e., goal_force = k_goal*(goal_vel-current_vel); acc += goal_force
  Done

  2. Finish the function computeTTC() so that it computes the time-to-collision (TTC) between
     two agents given their positions, velocities and radii. Your implementation should likely
     call rayCircleIntersectTime to compute the time a ray intersects a circle as part of
     determining the time to collision. (i.e., at what time would a ray moving at your
     current relative velocity intersect the Minkowski sum of the obstacle and your reflection?)
     If there is no collision, return a TTC of -1.
     ie., TTC(A,B) = Ray-Disk(A's position, relative velocity, B's position, combined radius)
  Done

  2a. Test computeTTC() with some scenarios where you know the (approximate) true value.
  Done

  3. Compute an avoidance force as follows:
       - Find the ttc between agent "id" and it's neighbor "j" (make sure id != j)
       - If the ttc is negative (or there is no collision) then there is no avoidance force w.r.t agent j
       - Predict where both agent's well be at the moment of collision (time = TTC)
         ie., A_future = A_current + A_vel*ttc; B_future + B_current + B_vel*ttc
       - Find the relative vector between the agents at the moment of collision, normalize it
         i.e, relative_future_direction = (A_future - B_future).normalized()
       - Compute the per-agent avoidance force by scaling this direction by k_avoid and
         dividing by ttc (smaller ttc -> more urgent collisions)
         acc += k_avoid * (1/ttc) * relative_future_direction
      The final force should be the avoidance force for each neighbor plus the overall goal force.
      Try to find a balance between k_avoid and k_goal that gives good behavior. Note: you may need a
      very large value of k_goal to avoid collisions between agents.
  Done

   4. Make the following simulation improvements:
     - Draw agents with a slightly smaller radius than the one used for collisions
     - When an agent reaches its goal, stop it from reacting to other agents
  Done

   5. Finally, place 2 more agents in the scene and try to make an interesting scenario where the
      agents interact with each other.
  Doneish <-- make follow mouse next

CHALLENGE:
  1. Give agents a maximum force and maximum velocity and don't let them violate these constraints.
  Done

  2. Start two agents slightly colliding. Update the approach to better handle collisions.
  Done --> Used separation forces

  3. Add a static obstacle for the agent to avoid (hint: treat it as an agent with 0 velocity).
  Done --> Walls --> Also can add more static obstacles when wanted
*/

// number of agents
static int maxNumAgents = 100;
int numNormalAgents = 97;
int numGoalAgents = 3;
int numAgents = numGoalAgents+numNormalAgents;
float minDistFromGoal = 5;

// goal multipliers
float k_goal = 10;  

// TTC multiplier
float k_avoid = 50;

// max values for velocity and acceleration
float maxVel = 300;
float maxAcc = 500;

float agentRad = 10;
float goalAgentRad = 35;
float agentDrawRad = 5;
float goalAgentDrawRad = 30;
float goalSpeed = 100;

// Boid Force Stuff
// Separation
float sepMaxDist = 20;
float sepScale = 500;

// Cohesion
float cohMaxDist = 40;
float cohScale = 30;

// Alignment
float alignMaxDist = 40;
float alignScale = 30;

// Mouse Forces
float mouseMaxDist = 200;
float mouseScale = 100;
boolean leftHeld = false;
boolean rightHeld = false;

//The agent states
Vec2[] agentPos = new Vec2[maxNumAgents];
Vec2[] agentVel = new Vec2[maxNumAgents];
Vec2[] agentAcc = new Vec2[maxNumAgents];
ArrayList<Vec2> reactiveAgents = new ArrayList<Vec2>();

//The agent goals
Vec2[] goalPos = new Vec2[maxNumAgents];

// Obstacle Things
float obstDrawRadius = 50;
float obstRadius = 55;
int numObst = 2;
Vec2[] obstPos;
Vec2[] obstVel;
float maxTimeToObstacle = 5;

// two points define a line segment
// which is a wall in this scenario
// modify this if you want to make more recangle wall obstacles
int numWalls = 4;
Vec2[][] walls = new Vec2[numWalls][2];
float wallPadding = 20;
float maxTimeToWall = 2;

float epsilon = 0.001;

void setup(){
  // size(850,650);
  int x = displayWidth-100;
  int y = displayHeight-100;
  size(2460, 1340,P3D); //Smoother
  frameRate(144);

  /////////////// Relic of Old Wall Tech /////////////////////////
  // numObst = 0;
  // numObst += (width/obstRadius)*2;
  // int numObstX = int(width/obstRadius);
  // numObst += (height/obstRadius)*2;
  // int numObstY = int(height/obstRadius);

  obstPos = new Vec2[numObst];
  obstVel = new Vec2[numObst];

  for (int i = 0; i < numObst; i++) {
    obstPos[i] = new Vec2(
      random(0, width),
      random(0, height)
    );
    obstVel[i] = new Vec2(0,0);
  }

  // for (int i = 0; i < numObstX; i++) {
  //   obstPos[i*2] = new Vec2(i*obstRadius,0); 
  //   obstPos[i*2+1] = new Vec2(i*obstRadius, height);
  //   obstVel[i*2] = new Vec2(0,0); 
  //   obstVel[i*2+1] = new Vec2(0,0);
  // }

  // for (int i = 0; i < numObstY; i++) {
  //   obstPos[numObstX*2+i*2] = new Vec2(0, i*obstRadius); 
  //   obstPos[numObstX*2+i*2+1] = new Vec2(width, i*obstRadius);
  //   obstVel[numObstX*2+i*2] = new Vec2(0,0); 
  //   obstVel[numObstX*2+i*2+1] = new Vec2(0,0);
  // }
  ////////////////////////////////////////////////////////////////

  //Set initial agent positions and goals
  agentPos[0] = new Vec2(220,610);
  agentPos[1] = new Vec2(310,610);
  agentPos[2] = new Vec2(320,420);
  goalPos[0] = new Vec2(200,420);
  goalPos[1] = new Vec2(120,120);
  goalPos[2] = new Vec2(220,220);

  for (int i = numGoalAgents; i < numAgents; i++) {
    agentPos[i] = new Vec2(
      wallPadding+agentRad+random(width-2*wallPadding-agentRad), 
      wallPadding+agentRad+random(height-2*wallPadding-agentRad)
    );
  }
 
  //Set initial velocities to cary agents towards their goals
  for (int i = 0; i < numAgents; i++){
    if (i >= numGoalAgents) {
      agentVel[i] = new Vec2(random(-100, 100),random(-100, 100));
      agentAcc[i] = new Vec2(0,0);
      if (agentVel[i].length() > 0)
        agentVel[i].clampToLength(goalSpeed);
    } else {
      agentVel[i] = goalPos[i].minus(agentPos[i]);
      if (agentVel[i].length() > 0)
        agentVel[i].clampToLength(goalSpeed);
    }
  }

  walls[0][0] = new Vec2(wallPadding,wallPadding); walls[0][1] = new Vec2(width-wallPadding, wallPadding); // top
  walls[1][0] = new Vec2(wallPadding,height-wallPadding); walls[1][1] = new Vec2(width-wallPadding,height-wallPadding); // bottom
  walls[2][0] = new Vec2(wallPadding,wallPadding); walls[2][1] = new Vec2(wallPadding,height-wallPadding); // left
  walls[3][0] = new Vec2(width-wallPadding,wallPadding); walls[3][1] = new Vec2(width-wallPadding,height-wallPadding); // right

  strokeWeight(0);

  // testComputeTTC();
  // testRayIntersect();
}

void reset() {
  agentPos = new Vec2[maxNumAgents];
  agentVel = new Vec2[maxNumAgents];
  agentAcc = new Vec2[maxNumAgents];
  setup();
}

void testComputeTTC() {
  Vec2 pos1 = new Vec2(0,0); Vec2 pos2 = new Vec2(0, height);
  float radius1 = 100; float radius2 = 100;
  Vec2 vel1 = new Vec2(0, 1); Vec2 vel2 = new Vec2(0, -1);
  print(computeTTC(pos1, vel1, radius1, pos2, vel2, radius2));

}

//Return at what time agents 1 and 2 collide if they keep their current velocities
// or -1 if there is no collision.
float computeTTC(Vec2 pos1, Vec2 vel1, float radius1, Vec2 pos2, Vec2 vel2, float radius2){
  return rayCircleIntersectTime(pos1, radius1+radius2, pos2, vel2.minus(vel1));
}

// Compute attractive forces to draw agents to their goals,
// and avoidance forces to anticipatory avoid collisions
Vec2 computeAgentForces(int id){
  Vec2 acc = new Vec2(0,0);

  // Force due to goal for only first three agents
  if (id < numGoalAgents) {
    Vec2 goal_vel = goalPos[id].minus(agentPos[id]);
    if (goal_vel.length() > minDistFromGoal) {
      goal_vel = goal_vel.normalized().times(goalSpeed);
    } else {
      goal_vel = new Vec2(0,0);
    }
    Vec2 goal_force = goal_vel.minus(agentVel[id]);

    acc.add(goal_force.times(k_goal));
  }
  
  for (int ob = 0; ob < numObst; ob++) {
    float ttc = computeTTC(
      agentPos[id], agentVel[id], (id < numGoalAgents ? goalAgentRad : agentRad),
      obstPos[ob], obstVel[ob], obstRadius
    );

    if (ttc > -1 && ttc < 3) {
      Vec2 futureid = agentPos[id].plus(agentVel[id].times(ttc));
      Vec2 futureob = obstPos[ob];
      Vec2 rfd = (futureid.minus(futureob)).normalized();
      
      acc.add(rfd.times(k_avoid*(1/ttc)));
    }
  }

  // Force due to avoiding collisions
  for (int jd = 0; jd < numAgents; jd++) {
    if (jd != id) {
      float ttc = computeTTC(
        agentPos[id], agentVel[id], ((id < numGoalAgents) ? goalAgentRad : agentRad),
        agentPos[jd], agentVel[jd], ((jd < numGoalAgents) ? goalAgentRad : agentRad)
      );

      if (ttc > -1 && ttc <= maxTimeToObstacle) {
        Vec2 futureid = agentPos[id].plus(agentVel[id].times(ttc));
        Vec2 futurejd = agentPos[jd].plus(agentVel[jd].times(ttc));
        Vec2 rfd = (futureid.minus(futurejd)).normalized();
        
        acc.add(rfd.times(k_avoid*(1/ttc)));
      }
    }
  }

  if (id < numGoalAgents) return acc;

  
  // Forces for walls
  for (int wall = 0; wall < numWalls; wall++) {
    for (int k = 0; k < 50; k++) {
      Vec2 vel1 = agentVel[id].rotated(k*0.03);
      Vec2 vel2 = agentVel[id].rotated(-k*0.03);
      float curr1 = rayLineIntersectDistance(
        agentPos[id], vel1, 
        walls[wall][0], walls[wall][1]
      );
      float curr2 = rayLineIntersectDistance(
        agentPos[id], vel2, 
        walls[wall][0], walls[wall][1]
      );

      float ttc = curr1/vel1.length();
      if (!Float.isNaN(curr1) && ttc <= maxTimeToWall && ttc > 0) {
        Vec2 futureid = agentPos[id].plus(vel1.times(ttc));
        Vec2 wallInt = agentPos[id].plus(vel1.times(curr1));
        Vec2 rfd = (futureid.minus(wallInt));
        rfd.normalize();
        acc.add(rfd.times(k_avoid*(1/ttc)));
      }

      ttc = curr2/vel2.length();
      if (!Float.isNaN(curr2) && ttc <= maxTimeToWall && ttc > 0) {
        Vec2 futureid = agentPos[id].plus(vel2.times(ttc));
        Vec2 wallInt = agentPos[id].plus(vel2.times(curr2));
        Vec2 rfd = (futureid.minus(wallInt));
        rfd.normalize();
        acc.add(rfd.times(k_avoid*(1/ttc)));
      }
    }
  }

  Vec2 mousePos = new Vec2(mouseX, mouseY);
  float mouseDist = agentPos[id].distanceTo(mousePos);
  if (leftHeld && mouseDist <= mouseMaxDist) {
    Vec2 mouseForce = mousePos.minus(agentPos[id]);
    mouseForce.normalize();
    mouseForce.mul(mouseScale);
    acc.add(mouseForce);
  }

  if (rightHeld && mouseDist <= mouseMaxDist) {
    Vec2 mouseForce = agentPos[id].minus(mousePos);
    mouseForce.mul(mouseScale/mouseDist);
    acc.add(mouseForce);
  }

  // Averages for align and cohesion
  Vec2 avgPos = new Vec2(0,0);
  Vec2 avgVel = new Vec2(0,0);
  float num_neighbors_c = 0;
  float num_neighbors_a = 0;

  for (int jd = 0; jd < numAgents; jd++) {
    if (jd != id) {
      float dist = agentPos[id].distanceTo(agentPos[jd]);

      // calculation of separation force
      if ((jd < numGoalAgents && dist <= sepMaxDist+goalAgentRad) || dist <= sepMaxDist) {
        Vec2 sepForce = agentPos[id].minus(agentPos[jd]);
        sepForce.mul(sepScale/dist);
        acc.add(sepForce);
      }

      // averages for cohesion and alignment
      if (jd >= numGoalAgents) {
        if (dist <= cohMaxDist) {
          avgPos.add(agentPos[jd]);
          num_neighbors_c++;
        }

        if (dist <= alignMaxDist) {
          avgVel.add(agentVel[jd]);
          num_neighbors_a++;
        }
      }
    }
  }

  // // obstacle separation forces for when they get stuck in the obstacle
  // // uncomment if using obstacles
  for (int ob = 0; ob < numObst; ob++) {
    float dist = agentPos[id].distanceTo(obstPos[ob]);
    if (dist <= obstRadius+agentRad) {
      Vec2 sepForce = agentPos[id].minus(obstPos[ob]);
      sepForce.mul(sepScale/dist);
      acc.add(sepForce);
    }
  }

  // calculation of cohesion force
  if (num_neighbors_c > 0) {
    avgPos.x /= num_neighbors_c; avgPos.y /= num_neighbors_c;
    Vec2 cohForce = avgPos.minus(agentPos[id]);
    cohForce.normalize();
    cohForce.mul(cohScale);

    acc.add(cohForce);
  }

  // calculation of alignment force
  if (num_neighbors_a > 0) {
    avgVel.x /= num_neighbors_a; avgVel.y /= num_neighbors_a;
    Vec2 alignForce = avgVel.minus(agentVel[id]);
    alignForce.normalize();
    acc.add(alignForce.times(alignScale));
  }

  return acc;
}

//Update agent positions & velocities based acceleration
void moveAgent(float dt){
  //Compute accelerations for every agents
  for (int id = 0; id < numAgents; id++){
    agentAcc[id] = computeAgentForces(id);
  }

  //Update position and velocity using (Eulerian) numerical integration
  for (int i = 0; i < numAgents; i++){
    if (i >= numGoalAgents || (agentPos[i].distanceTo(goalPos[i]) > minDistFromGoal)) {
      agentPos[i].add(agentVel[i].times(dt));
      agentVel[i].add(agentAcc[i].times(dt));
      if (agentVel[i].length() > maxVel) {
        agentVel[i] = agentVel[i].normalized().times(maxVel);
      }
      agentPos[i].x = agentPos[i].x < 0 ? width : (agentPos[i].x > width ? 0 : agentPos[i].x);
      agentPos[i].y = agentPos[i].y < 0 ? height : (agentPos[i].y > height ? 0 : agentPos[i].y);
    } else {
      agentVel[i].x = 0; agentVel[i].y = 0;
    }
  }
  // test_circ_pos.add(test_circ_vel.times(dt));
  // test_circ_pos.x = test_circ_pos.x < 0 ? width : (test_circ_pos.x > width ? 0 : test_circ_pos.x);
  // test_circ_pos.y = test_circ_pos.y < 0 ? height : (test_circ_pos.y > height ? 0 : test_circ_pos.y);
}

// Vec2 test_circ_pos = new Vec2(0, 0);
// Vec2 test_circ_vel = new Vec2(-100,100);

boolean paused = true;
void draw(){
  background(255,255,255); //White background
  strokeWeight(0);
  //Update agent if not paused
  if (!paused){
    moveAgent(1.0/frameRate);
  }
 
  //Draw orange goal rectangle
  fill(255,150,50);
  for (int i = 0; i < numGoalAgents; i++){
    rect(goalPos[i].x-10, goalPos[i].y-10, 20, 20);
  }
 
  //Draw the green goal agents
  fill(20,200,150);
  // // uncomment if using obstacles
  for (int i = 0; i < numObst; i++) {
    circle(obstPos[i].x, obstPos[i].y, obstDrawRadius*2);
  }

  for (int i = 0; i < numGoalAgents; i++) {
    circle(agentPos[i].x, agentPos[i].y, goalAgentDrawRad*2);
  }

  // draw the rest of the agents with smaller size
  for (int i = numGoalAgents; i < numAgents; i++){
    circle(agentPos[i].x, agentPos[i].y, agentDrawRad*2);
  }

  strokeWeight(1);
  for (var wall : walls) {
    line(wall[0].x, wall[0].y, wall[1].x, wall[1].y);
  }

  // circle((test_circ_pos.x)%width, (test_circ_pos.y)%height, 10*2);
}

//Pause/unpause the simulation
void keyPressed(){
  if (key == ' ') paused = !paused;
  if (key == 'r') reset();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    leftHeld = true;
  } 
  if (mouseButton == RIGHT) {
    rightHeld = true;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    leftHeld = false;
  }
  if (mouseButton == RIGHT) {
    rightHeld = false;
  }
}

// test ray intersect to make sure its working
void testRayIntersect() {
  Vec2 rayO = new Vec2(width, 0);
  Vec2 rayD = new Vec2(-1, 1);
  Vec2 p1 = new Vec2(0,0);
  Vec2 p2 = new Vec2(width,height);
  print(rayLineIntersectDistance(rayO, rayD, p1, p2));
}

// intersect distance from a circle with velocity to a line
float rayLineIntersectDistance(Vec2 rayO, Vec2 rayD, Vec2 p1, Vec2 p2) {
  rayD = rayD.normalized();
  Vec2 a = rayO.minus(p1);
  Vec2 b = p2.minus(p1);
  Vec2 c = new Vec2(-rayD.y, rayD.x);

  float dot = dot(b, c);
  if (abs(dot) < epsilon) {
    return Float.NaN;
  }

  float t1 = ((b.x*a.y)-(b.y*a.x))/dot;
  float t2 = dot(a, c)/dot;

  if (!Float.isNaN(t1) && t1 >= 0.0 && (t2 >= 0.0 && t2 <= 1.0)) {
    return t1;
  }

  return Float.NaN;
}

///////////////////////
// pos1 = (0,0), r = 200, l_start = (850, 0), l_dir = (2, 0)
float rayCircleIntersectTime(Vec2 center, float r, Vec2 l_start, Vec2 l_dir){
 
  //Compute displacement vector pointing from the start of the line segment to the center of the circle
  Vec2 toCircle = center.minus(l_start);
 
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.length()*l_dir.length();
  float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
  float c = toCircle.lengthSqr() - (r*r); //different of squared distances
 
  float d = b*b - 4*a*c; //discriminant
 
  if (d >=0 ){
    //If d is positive we know the line is colliding
    float t = (-b - sqrt(d))/(2*a); //Optimization: we typically only need the first collision!
    if (t >= 0) return t;
    return -1;
  }
 
  return -1; //We are not colliding, so there is no good t to return
}

//////////////////////
//Vector Library
//CSCI 5611 Vector 2 Library [Example]
//////////////////////

public class Vec2 {
  public float x, y, epsilon;
 
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
    this.epsilon = 0.001;
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
    if (magnitude < epsilon) return;
    x /= magnitude;
    y /= magnitude;
  }
 
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude < epsilon) return new Vec2(x, y);
    return new Vec2(x/magnitude, y/magnitude);
  }
 
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx*dx + dy*dy);
  }

  public void rotate(float rad) {
    x = cos(rad)*x - sin(rad)*y;
    y = sin(rad)*x + cos(rad)*y;
  }

  public Vec2 rotated(float rad) {
    float newx = cos(rad)*x - sin(rad)*y;
    float newy = sin(rad)*x + cos(rad)*y;

    return new Vec2(newx, newy);
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
