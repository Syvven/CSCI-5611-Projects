// //Simulation-Driven Animation
// //CSCI 5611 Example - Bouncing Balls
// // Stephen J. Guy <sjguy@umn.edu>

// static int numParticles = 60;

// float r = 5;
// //Inital positions and velocities of masses
// Vec2 pos[] = new Vec2[numParticles];
// Vec2 vel[] = new Vec2[numParticles];
// Vec2 circles[] = new Vec2[3];

// float sphereRadius = 60;
// float cor = 0.8;
// Vec2 grav = new Vec2(0,9.8);
// float fric = 0.005;
// float accel = 0.01;

// void setup(){
//   size(640,480);
//   surface.setTitle("Falling Balls [CSCI 5611 Example]");
  
//   //Initial boid positions and velocities
//   for (int i = 0; i < numParticles; i++){
//     pos[i] = new Vec2(200+random(300),100+random(200));
//     vel[i] = new Vec2(random(40),100+random(20)); 
//   }

//   circles[0] = new Vec2(100, 400);
//   circles[1] = new Vec2(500, 400);
//   circles[2] = new Vec2(300, 400);
  
//   strokeWeight(2); //Draw thicker lines 
// }

// void update(float dt){
//     Vec2 norm = new Vec2(0,0);
//     for (int i = 0; i <  numParticles; i++){
//         pos[i].add(vel[i].times(dt));
//         if (pos[i].y > height - r){
//             norm.x = 0; norm.y = -1;
//             pos[i].y = height - r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//             vel[i] = interpolate(vel[i], new Vec2(0, vel[i].y), fric);
//         }
//         if (pos[i].y < r){
//             norm.x = 0; norm.y = 1;
//             pos[i].y = r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//         }
//         if (pos[i].x > width - r){
//             norm.x = -1; norm.y = 0;
//             pos[i].x = width - r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//         }
//         if (pos[i].x < r){
//             norm.x = 1; norm.y = 0;
//             pos[i].x = r;
//             vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor));
//         }
//         for (int j = 0; j < 3; j++) {
//             Vec2 spherePos = circles[j];
//             if (pos[i].distanceTo(spherePos) < (sphereRadius+r)){
//                 //TODO: Code to bounce the balls off of a sphere goes here...
//                 //Find sphere normal at point of contact
//                 //Move along the normal be to no longer colliding with the sphere
//                 //Compute the bounce equation
//                 norm = pos[i].minus(spherePos);
//                 norm.normalize();
//                 pos[i] = spherePos.plus(norm.times(sphereRadius + r).times(1.01)); 
//                 vel[i].subtract(norm.times(dot(vel[i], norm)).times(1+cor)); // Vf = Vi - N(VdotN)(1+a)
//             }
//         }
//         vel[i] = vel[i].plus(grav);
//     }
// }


// void draw(){
//   update(1.0/frameRate);
  
//   background(255); //White background
//   stroke(0,0,0);
//   fill(10,120,10);
//   for (int i = 0; i < numParticles; i++){
//     circle(pos[i].x, pos[i].y, r*2); 
//   }
  
//   fill(180,60,40);
//   for (int i = 0; i < 3; i++) {
//     circle(circles[i].x, circles[i].y, sphereRadius*2);
//   }
// }
