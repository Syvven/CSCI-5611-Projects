//CSCI 5611 - Pathing and Crowd Sim
//Anticipatory Collision Avoidance (TTC-Forces) [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused! Press the spacebar to run it.

/*
TODO:
  1. Currently, there are no forces acting on the agents. Add a goal force that penalizes
     the difference between an agent's current velocity and it's goal velocity.
     i.e., goal_force = goal_vel-current_vel; acc += goal_force
  1a. Scale the goal force by the value k_goal. Find a value of k_goal that lets the agents
     smoothly reach their goal without overshooting it first.
     i.e., goal_force = k_goal*(goal_vel-current_vel); acc += goal_force
  2. Finish the function computeTTC() so that it computes the time-to-collision (TTC) between
     two agents given their positions, velocities and radii. Your implementation should likely
     call rayCircleIntersectTime to compute the time a ray intersects a circle as part of
     determining the time to collision. (i.e., at what time would a ray moving at your
     current relative velocity intersect the Minkowski sum of the obstacle and your reflection?)
     If there is no collision, return a TTC of -1.
     ie., TTC(A,B) = Ray-Disk(A's position, relative velocity, B's position, combined radius)
  2a. Test computeTTC() with some scenarios where you know the (approximate) true value.
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
   4. Make the following simulation improvements:
     - Draw agents with a slightly smaller radius than the one used for collisions
     - When an agent reaches its goal, stop it from reacting to other agents
   5. Finally, place 2 more agents in the scene and try to make an interesting scenario where the
      agents interact with each other.

CHALLENGE:
  1. Give agents a maximum force and maximum velocity and don't let them violate these constraints.
  2. Start two agents slightly colliding. Update the approach to better handle collisions.
  3. Add a static obstacle for the agent to avoid (hint: treat it as an agent with 0 velocity).
*/

static int maxNumAgents = 3;
int numAgents = 3;

float k_goal = 1;  //TODO: Tune this parameter to agent stop naturally on their goals
float k_avoid = 1;
float agentRad = 40;
float goalSpeed = 100;

//The agent states
Vec2[] agentPos = new Vec2[maxNumAgents];
Vec2[] agentVel = new Vec2[maxNumAgents];
Vec2[] agentAcc = new Vec2[maxNumAgents];

//The agent goals
Vec2[] goalPos = new Vec2[maxNumAgents];

void setup(){
  size(850,650);
  //size(850,650,P3D); //Smoother
 
  //Set initial agent positions and goals
  agentPos[0] = new Vec2(220,610);
  agentPos[1] = new Vec2(320,650);
  agentPos[2] = new Vec2(320,420);
  goalPos[0] = new Vec2(200,420);
  goalPos[1] = new Vec2(120,120);
  goalPos[2] = new Vec2(220,220);
 
  //Set initial velocities to cary agents towards their goals
  for (int i = 0; i < numAgents; i++){
    agentVel[i] = goalPos[i].minus(agentPos[i]);
    if (agentVel[i].length() > 0)
      agentVel[i].setToLength(goalSpeed);
  }
}

//Return at what time agents 1 and 2 collide if they keep their current velocities
// or -1 if there is no collision.
float computeTTC(Vec2 pos1, Vec2 vel1, float radius1, Vec2 pos2, Vec2 vel2, float radius2){
  return -1;
}

// Compute attractive forces to draw agents to their goals,
// and avoidance forces to anticipatory avoid collisions
Vec2 computeAgentForces(int id){
  //TODO: Make this better
  Vec2 acc = new Vec2(0,0);
 
  return acc;
}


//Update agent positions & velocities based acceleration
void moveAgent(float dt){
  //Compute accelerations for every agents
  for (int i = 0; i < numAgents; i++){
    agentAcc[i] = computeAgentForces(i);
  }
  //Update position and velocity using (Eulerian) numerical integration
  for (int i = 0; i < numAgents; i++){
    agentVel[i].add(agentAcc[i].times(dt));
    agentPos[i].add(agentVel[i].times(dt));
  }
}

boolean paused = true;
void draw(){
  background(255,255,255); //White background
 
  //Update agent if not paused
  if (!paused){
    moveAgent(1.0/frameRate);
  }
 
  //Draw orange goal rectangle
  fill(255,150,50);
  for (int i = 0; i < numAgents; i++){
    rect(goalPos[i].x-10, goalPos[i].y-10, 20, 20);
  }
 
  //Draw the green agents
  fill(20,200,150);
  for (int i = 0; i < numAgents; i++){
    circle(agentPos[i].x, agentPos[i].y, agentRad*2);
  }
}

//Pause/unpause the simulation
void keyPressed(){
  if (key == ' ') paused = !paused;
}


///////////////////////

float rayCircleIntersectTime(Vec2 center, float r, Vec2 l_start, Vec2 l_dir){
 
  //Compute displacement vector pointing from the start of the line segment to the center of the circle
  Vec2 toCircle = center.minus(l_start);
 
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.length();
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

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}
