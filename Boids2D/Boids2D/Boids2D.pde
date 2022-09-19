//Boids in 2D
//CSCI 5611 Boids [Example]
// Stephen J. Guy <sjguy@umn.edu>

// NOTE: This is not intended as "starter code" for you to copy for your homework/project,
//       rather the goal is just to illustrate one way you might approach boids.
//       Also, this is somewhat basic, hopefully yours looks cooler! =)

//This simple boids implementation illustrates some of the ideas of flocking.
//There are several ways in which to improve the implementation:
//  -Improve the behavoirs (e.g., less collisions)
//  -Add context to the simulation (e.g. a house or a forest scene)
//  -Get the method workign in 3D
//  -Have more user interaction
//  -Have the boids randomly perch on object for a few seconds then take off
//  -Render the boids as something more interesting than circles
//  -Have the boids avoid obsacles
//  -Have preditor agents which chace down the boids
//  -Give (some of) the boids a specific goal to head towards as they flock

static int numBoids = 50;

//Inital positions and velocities of masses
Vec2 pos[] = new Vec2[numBoids];
Vec2 vel[] = new Vec2[numBoids];
Vec2 acc[] = new Vec2[numBoids];

float maxSpeed = 20;
float targetSpeed = 10;
float maxForce = 10;
float radius = 6;

void setup(){
  size(900,800);
  surface.setTitle("2D Boids [CSCI 5611 Example]");
  
  //Initial boid positions and velocities
  for (int i = 0; i < numBoids; i++){
    pos[i] = new Vec2(200+random(300),200+random(200));
    vel[i] = new Vec2(-1+random(2),-1+random(2));  //TODO: Better random angle
    vel[i].normalize();
    vel[i].mul(maxSpeed);
  }
  
  strokeWeight(2); //Draw thicker lines 
}


void draw(){
  background(255); //Grey background
  stroke(0,0,0);
  //fill(255);
  //for (int i = 0; i < numBoids; i++){
  //  circle(pos[i].x, pos[i].y,40*2); //Question: Why is it radius*2 ?
  //}
  fill(10,120,10);
  for (int i = 0; i < numBoids; i++){
    circle(pos[i].x, pos[i].y,radius*2); 
  }
  
  float dt = .1;
  
  
  //TODO: We loop through our neighbors 3 times, can you do it just once?
  for (int i = 0; i < numBoids; i++){
    acc[i] = new Vec2(0,0); //TODO: Why does acceleration reset to zero here?
      
    //Seperation force (push away from each neighbor if we are too close)
    for  (int j = 0; j < numBoids; j++){ //Go through neighbors
      float dist = pos[i].distanceTo(pos[j]);
      if (dist < .01 || dist > 50) continue; //TODO: Why do we not need to skip i == j?
      Vec2 seperationForce =  pos[i].minus(pos[j]).normalized();
      seperationForce.setToLength(200.0/pow(dist,2));
      acc[i] = acc[i].plus(seperationForce);
      //if (i ==0) println(acc[i].x,acc[i].y,pos[i].minus(pos[1]).length());
    }
            
    //Atttraction force (move towards the average position of our neighbors
    Vec2 avgPos = new Vec2(0,0);
    int count = 0;
    for  (int j = 0; j <  numBoids; j++){ //Go through each neighbor
      float dist = pos[i].distanceTo(pos[j]);
      if (dist < 60 && dist > 0){
        avgPos.add(pos[j]);
        count += 1;
      }
    }
    avgPos.mul(1.0/count);
    if (count >= 1){
      Vec2 attractionForce = avgPos.minus(pos[i]);
      attractionForce.normalize();
      attractionForce.mul(1.0);
      attractionForce.clampToLength(maxForce);
      acc[i] = acc[i].plus(attractionForce);
    }
      
    //Alignment force
    Vec2 avgVel = new Vec2(0,0);
    count = 0;
    for  (int j = 0; j <  numBoids; j++){ //Go through each neighbor
      float dist = pos[i].minus(pos[j]).length();
      if (dist < 40 && dist > 0){
        avgVel.add(vel[j]);
        count += 1;
      }
    }
    avgVel.mul(1.0/count);
    if (count >= 1){
      Vec2 towards = avgVel.minus(vel[i]);
      towards.normalize();
      acc[i] = acc[i].plus(towards.times(2));
    }
    
    //Goal Speed
    Vec2 targetVel = vel[i];
    targetVel.setToLength(targetSpeed);
    Vec2 goalSpeedForce = targetVel.minus(vel[i]);
    goalSpeedForce.mul(1.0);
    goalSpeedForce.clampToLength(maxForce);
    acc[i] = acc[i].plus(goalSpeedForce);    
    
    //Wander force
    Vec2 randVec = new Vec2(1-random(2),1-random(2));
    acc[i] = acc[i].plus(randVec.times(10.0)); 
  }
  
  for (int i = 0; i < numBoids; i++){
      
    //Update Position & Velocity
    pos[i] = pos[i].plus(vel[i].times(dt));
    vel[i] = vel[i].plus(acc[i].times(dt));
    //println(vel[i].x,vel[i].y);
    
    //Max speed
    if (vel[i].length() > maxSpeed){
      vel[i] = vel[i].normalized().times(maxSpeed);
    }
    
    // Loop the world if agents fall off the edge.
    if (pos[i].x < 0) pos[i].x += width;
    if (pos[i].x > width) pos[i].x -= width;
    if (pos[i].y < 0) pos[i].y += height;
    if (pos[i].y > height) pos[i].y -= height;
  }

}

void mousePressed(){
  //pos.add(new Vec2(mouseX,mouseY));  #TODO: Switch to an arraylist and allow users to add boids, 
  //                                          Or, even better, support add without using arraylists!
  pos[0] = new Vec2(mouseX,mouseY);
  vel[0] = new Vec2(-1+random(2),-1+random(2));  //TODO: Better random angle
  vel[0].normalize();
  vel[0].mul(targetSpeed);
}
