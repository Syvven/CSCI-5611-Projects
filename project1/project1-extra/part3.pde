// //CSCI 5611 - Pathing and Crowd Sim
// //Anticipatory Collision Avoidance (TTC-Forces) [Exercise]
// // Stephen J. Guy <sjguy@umn.edu>

// //NOTE: The simulation starts paused! Press the spacebar to run it.

// /*
// TODO:
//   1. Currently, there are no forces acting on the agents. Add a goal force that penalizes
//      the difference between an agent's current velocity and it's goal velocity.
//      i.e., goal_force = goal_vel-current_vel; acc += goal_force
//   1a. Scale the goal force by the value k_goal. Find a value of k_goal that lets the agents
//      smoothly reach their goal without overshooting it first.
//      i.e., goal_force = k_goal*(goal_vel-current_vel); acc += goal_force
//   2. Finish the function computeTTC() so that it computes the time-to-collision (TTC) between
//      two agents given their positions, velocities and radii. Your implementation should likely
//      call rayCircleIntersectTime to compute the time a ray intersects a circle as part of
//      determining the time to collision. (i.e., at what time would a ray moving at your
//      current relative velocity intersect the Minkowski sum of the obstacle and your reflection?)
//      If there is no collision, return a TTC of -1.
//      ie., TTC(A,B) = Ray-Disk(A's position, relative velocity, B's position, combined radius)
//   2a. Test computeTTC() with some scenarios where you know the (approximate) true value.
//   3. Compute an avoidance force as follows:
//        - Find the ttc between agent "id" and it's neighbor "j" (make sure id != j)
//        - If the ttc is negative (or there is no collision) then there is no avoidance force w.r.t agent j
//        - Predict where both agent's well be at the moment of collision (time = TTC)
//          ie., A_future = A_current + A_vel*ttc; B_future + B_current + B_vel*ttc
//        - Find the relative vector between the agents at the moment of collision, normalize it
//          i.e, relative_future_direction = (A_future - B_future).normalized()
//        - Compute the per-agent avoidance force by scaling this direction by k_avoid and
//          dividing by ttc (smaller ttc -> more urgent collisions)
//          acc += k_avoid * (1/ttc) * relative_future_direction
//       The final force should be the avoidance force for each neighbor plus the overall goal force.
//       Try to find a balance between k_avoid and k_goal that gives good behavior. Note: you may need a
//       very large value of k_goal to avoid collisions between agents.
//    4. Make the following simulation improvements:
//      - Draw agents with a slightly smaller radius than the one used for collisions
//      - When an agent reaches its goal, stop it from reacting to other agents
//    5. Finally, place 2 more agents in the scene and try to make an interesting scenario where the
//       agents interact with each other.

// CHALLENGE:
//   1. Give agents a maximum force and maximum velocity and don't let them violate these constraints.
//   2. Start two agents slightly colliding. Update the approach to better handle collisions.
//   3. Add a static obstacle for the agent to avoid (hint: treat it as an agent with 0 velocity).
// */

// static int maxNumAgents = 14;
// int numAgents = 14;

// static int maxParticles = 20;

// float k_goal = 10;  //TODO: Tune this parameter to agent stop naturally on their goals
// float k_avoid = 400;
// float agentRad = 20;
// float goalSpeed = 100;
// float sepForce_maxD = 1000;
// float seperationScale = 300;

// //The agent states
// Vec2[] agentPos = new Vec2[maxNumAgents];
// Vec2[] agentVel = new Vec2[maxNumAgents];
// Vec2[] agentAcc = new Vec2[maxNumAgents];

// float r = 5;
// float genRate = 20;

// float COR = 0.7;
// Vec2 gravity = new Vec2(0,200);

// Vec2 pos[] = new Vec2[maxParticles];

// Vec2 vel[] = new Vec2[maxParticles];


// int numParticles = 0;

// //The agent goals
// Vec2[] goalPos = new Vec2[maxNumAgents];

// //A list of circle obstacles
// static int numObstacles = 7;
// Vec2 circlePos[] = new Vec2[numObstacles]; //Circle positions
// Vec2 circleVel[] = new Vec2[numObstacles];
// float circleRad[] = new float[numObstacles];  //Circle radii


// void placeRandomObstacles(){
//   //Initial obstacle position
//   for (int i = 0; i < numObstacles; i++){
//     circlePos[i] = new Vec2(random(200,650),random(200,450));
//     circleVel[i] = new Vec2(0,0);
//     circleRad[i] = 25;
    
//     // if the distance is less than 100, then regenerate
    
        
//    }
//   }
 




// void setup(){
//   size(850,650);
//   //size(850,650,P3D); //Smoother
  
//   //Set initial agent positions and goals
//   agentPos[0] = new Vec2(40,40);
//   agentPos[1] = new Vec2(810,40);
//   agentPos[2] = new Vec2(810,215);                  
//   agentPos[3] = new Vec2(810,425);                                          
//   agentPos[4] = new Vec2(810,610);
//   agentPos[5] = new Vec2(425,610);
//   agentPos[6] = new Vec2(40,610);
//   agentPos[7] = new Vec2(40,450);
//   agentPos[8] = new Vec2(40,215);
//   agentPos[9] = new Vec2(425,40);
//   agentPos[10] = new Vec2(425,100);
//   agentPos[11] = new Vec2(525,100);
//   agentPos[12] = new Vec2(650,300);
//   agentPos[13] = new Vec2(40,300);
  
 
  
//   goalPos[0] = new Vec2(750,550);
//   goalPos[1] = new Vec2(425,550);
//   goalPos[2] = new Vec2(100,550);
//   goalPos[3] = new Vec2(110,425);
//   goalPos[4] = new Vec2(110,240);
//   goalPos[5] = new Vec2(110,110);
//   goalPos[6] = new Vec2(425,120);
//   goalPos[7] = new Vec2(750,120);
//   goalPos[8] = new Vec2(750,400);
  
//   //goalPos[9] = new Vec2(625,550);
//   goalPos[9] = new Vec2(750,225);
//   goalPos[10] = new Vec2(750,300);
//   goalPos[11] = new Vec2(200,500);
//   goalPos[12] = new Vec2(430,340);
//   goalPos[13] = new Vec2(220,100);

  
  
  
  
//   placeRandomObstacles();
//   //Set initial velocities to cary agents towards their goals
//   for (int i = 0; i < numAgents; i++){
//     agentVel[i] = goalPos[i].minus(agentPos[i]);
//     if (agentVel[i].length() > 0)
//       agentVel[i].setToLength(goalSpeed);
//   }
  
// }

// //Return at what time agents 1 and 2 collide if they keep their current velocities
// // or -1 if there is no collision.
// float computeTTC(Vec2 pos1, Vec2 vel1, float radius1, Vec2 pos2, Vec2 vel2, float radius2){
//   float t = rayCircleIntersectTime( pos1, radius1+radius2, pos2, vel2.minus(vel1));
//   return t;
// }

// Vec2 sepration(Vec2 pos1, Vec2 pos2){
//   float dist = pos1.distanceTo(pos2);
//   if (dist< 0.01 || dist > sepForce_maxD) return new Vec2(0,0);
//   Vec2 seperationForce = pos1.minus(pos2);
//   seperationForce.setToLength(seperationScale/pow(dist,2));
  
//   return seperationForce;
// }

// // Compute attractive forces to draw agents to their goals,
// // and avoidance forces to anticipatory avoid collisions
// Vec2 computeAgentForces(int id){
//   //TODO: Make this better
  
//   Vec2 targetVel = goalPos[id].minus(agentPos[id]);
//   targetVel.setToLength(goalSpeed);
//   Vec2 goalSpeedForce = targetVel.minus(agentVel[id]);
//   goalSpeedForce.mul(2*k_goal); 
//   Vec2 acc = goalSpeedForce;
  
//   for (int j = 0; j < numAgents; j++){
//     if (j !=id){
//       float ttc = computeTTC(agentPos[id], agentVel[id], agentRad, agentPos[j], agentVel[j], agentRad);
//       Vec2 sep = sepration(agentPos[id], agentPos[j]);
//       if (ttc >0 && agentPos[id] != goalPos[id]){
//         Vec2 futurePos1 = agentPos[id].plus(agentVel[id].times(ttc));
//         Vec2 futurePos2 = agentPos[j].plus(agentVel[j].times(ttc));
//         Vec2 dir = futurePos1.minus(futurePos2).normalized();
//         acc.add(dir.times(k_avoid*(1/ttc)));
        
//       }
//       acc.add(sep);
//       //for (j = 0; j < numAgents; j++){
//       //  float dist = pos[id].distanceTo(pos[j]);
//       //  if (dist< 0.01 || dist > sepForce_maxD) continue;
//       //  Vec2 seperationForce = pos[id].minus(pos[j]);
//       //  seperationForce.setToLength(seperationScale/pow(dist,2));
//       //  acc.add(seperationForce);
        
      
      
      
//     }
//   }
//   for (int j = 0; j < numObstacles; j++){
//     float ttc = computeTTC(agentPos[id], agentVel[id], agentRad, circlePos[j], circleVel[j], circleRad[j]);
//     Vec2 sep = sepration(agentPos[id], circlePos[j]);
//     if (ttc >0 && agentPos[id] != goalPos[id]){
      
//       Vec2 futurePos1 = agentPos[id].plus(agentVel[id].times(ttc));
//       Vec2 futurePos2 = circlePos[j];
//       Vec2 dir = futurePos1.minus(futurePos2).normalized();
//       acc.add(dir.times(700*(1/ttc)));
      
//     } 
//     sep.setToLength(225);
//     acc.add(sep);
//   }
//   return acc;
// }


// //Update agent positions & velocities based acceleration
// void moveAgent(float dt){

//   //Compute accelerations for every agents
  
//   for (int i = 0; i < numAgents; i++){
    
//     agentAcc[i] = computeAgentForces(i);
    

//   }
//   //Update position and velocity using (Eulerian) numerical integration
//   for (int i = 0; i < numAgents; i++){
   
    
//     if (agentPos[i].distanceTo(goalPos[i])< 0.4){
//       agentPos[i] = goalPos[i];
//       agentVel[i] = new Vec2 (0,0);}
      
//     else{ agentVel[i].add(agentAcc[i].times(dt));
//     agentPos[i].add(agentVel[i].times(dt)); }
  
//   }  

// }


// void update(float dt){
//   float toGen_float = genRate * dt;
//   int toGen = int(toGen_float);
//   float fractPart = toGen_float - toGen;
//   if (random(1) < fractPart) toGen += 1;
//   for (int i = 0; i < toGen; i++){
//     if (numParticles >= maxParticles) break;
//     pos[numParticles] = new Vec2(110,110);
//     vel[numParticles] = new Vec2(60+random(30),-200+random(10));

//     numParticles += 1;
//   }
 
//   for (int i = 0; i <  numParticles; i++){
    
//     Vec2 acc = gravity; //Gravity
//     vel[i].add(acc.times(dt)); 
//     pos[i].add((vel[i].times(dt))); //Update position based on velocity
    
//     if (pos[i].y > height - r){ //??
//       pos[i].y = height - r;
//       vel[i].y *= -COR;
//     }
//     if (pos[i].y < r){
//       pos[i].y = r;
//       vel[i].y *= -COR;
//     }
//     if (pos[i].x > width - r){
//       pos[i].x = width - r;
//       vel[i].x *= -COR;
//     }
//     if (pos[i].x < r){
//       pos[i].x = r;
//       vel[i].x *= -COR;
//     }
//   }
// }
// boolean paused = true;

// void draw(){
//   background(255,255,255); //White background
 
//   //Update agent if not paused
//   if (!paused){
//     moveAgent(1.0/frameRate);
//   }
//   // if some agents reach to their goal, then the particles come out of the first destination position
//   if ( agentPos[0] == goalPos[0] && agentPos[1] == goalPos[1] && agentPos[2] == goalPos[2] && agentPos[3] == goalPos[3] && agentPos[4] == goalPos[4]){
//     update(1.0/frameRate);
//   }
  
//   //Draw the circle obstacles
//   fill(0);
//   for (int i = 0; i < numObstacles; i++){
//     Vec2 c = circlePos[i];
//     float r = circleRad[i];
//     circle(c.x,c.y,r*2);
//   }
 
//   //Draw orange goal rectangle
//   fill(255,150,50);
//   for (int i = 0; i < numAgents; i++){
//     rect(goalPos[i].x-10, goalPos[i].y-10, 20, 20);
//   }

//   //Draw the green agents
  
//   fill(255,255,255);
//   for (int i = 0; i < numAgents; i++){
//     circle(agentPos[i].x, agentPos[i].y, agentRad*2);
//   }
  
//   fill(20,200,150);
//   for (int i = 0; i < numAgents; i++){
//     circle(agentPos[i].x, agentPos[i].y, agentRad);
//   }
//   stroke(0,0,0);
//   fill(20,120,20);
//   for (int i = 0; i < numParticles; i++){
//     circle(pos[i].x, pos[i].y, r*2); //(x, y, diameter)   
//   }
  
// }

// //Pause/unpause the simulation
// void keyPressed(){
//   if (key == ' ') paused = !paused;
//   if (key == 'r') setup();
// }


// ///////////////////////

// float rayCircleIntersectTime(Vec2 center, float r, Vec2 l_start, Vec2 l_dir){
 
//   //Compute displacement vector pointing from the start of the line segment to the center of the circle
//   Vec2 toCircle = center.minus(l_start);
 
//   //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
//   float a = l_dir.length()*l_dir.length();
//   float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
//   float c = toCircle.lengthSqr() - (r*r); //different of squared distances
 
//   float d = b*b - 4*a*c; //discriminant
 
//   if (d >=0 ){
//     //If d is positive we know the line is colliding
//     float t = (-b - sqrt(d))/(2*a); //Optimization: we typically only need the first collision!
//     if (t >= 0) return t;
//     return -1;
//   }
 
//   return -1; //We are not colliding, so there is no good t to return
// }

// //////////////////////
// //Vector Library
// //CSCI 5611 Vector 2 Library [Example]
// //////////////////////




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
