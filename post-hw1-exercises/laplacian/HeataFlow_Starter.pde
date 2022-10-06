//1D Heat Equation : du/dt = k*(d2/dx2)u
//CSCI 5611 PDE Integration [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation begins paused, press space to un-pause it
  
//TODO:
// 1. Currently pressing r, prints "Resetting Simulation", but does not actually reset anything.
//    Update the code so that r actually resets the heat to its inital condition.
//  Done

// 2. Recall the heat equation says the amount of heat will change at a rate proportional 
//    to the negative of the laplacian, confirm that it is implemented correctly here.
//  Done

// 3. The laplacian of a function is defined by how fast the slope changes. Prove that
//    the variables "laplacian" and "laplacian_alt" compute the same value.
//  Done

// 4. The function colorByTemp() takes in a temperature (expected to be between 0 and 1)
//     and calls fill with a color based on that temperature. Currently colorByTemp() is
//     grayscale, change it to follow a blackbody color ramp. This is:
//        -From 0 - 0.333, interpolate from black to red
//        -From 0.333 - 0.666, interpolate from red to yellow
//        -From 0.666 - 1.0, interpolate from yellow to white
//        -You can choose any color you like for outside to 0 to 1 range (or simply
//         clamp the input to be from 0 to 1).
//  I think done?

// 5. Currently, the temperature is not fixed on either end (free boundary conditions)
//     Set one end of the bar to always be a fixed temperature of 1.0.
//  Done

// 6. The Stefan–Boltzmann law of evaporative cooling states that heat in a vacuum will
//     dissipate by a rate proportional to heat^4. Add a Stefan–Boltzmann evaporative 
//     cooling term to the simulated used in the PDE.
//  Done

// 7. How does the final state of the system compare with a cooling rate k=0 vs k=1 vs k = 100

// Challenge:
//  -Allow the user to set hot spots using their mouse or keyboard.
//  -Why is the weight factor, alpha, multiplied by n?
//   (Hint: How might you simulate a longer bar with n slices?)
//  -Try midpoint integration, is it any more stable?

static int n = 20;
float dx = 400/n;
float dy = 40;
float heat[] = new float[n];
float dheat_dt[] = new float[n];
float alpha = 1000*n; 

float k = 1;

//Set up screen and initial conditions
String windowTitle = "Heatflow Simulation";
void setup(){
  size(600, 300);
  //Initial tepmapture distribution (linear heat ramp from left to right)
  for (int i = 0; i < n; i++){ //TODO: Try different initial conditions
    heat[i] = i/(float)n;
  }
}

//TODO: Change me to a blackbody color ramp
void colorByTemp(float u){
  if (u <= 0) {
    u = 0.001;
  } else if (u >= 1) {
    u = 0.999;
  }

  float r = 0;
  float g = 0;
  float b = 0;

  if (0 < u && u <= 0.333) {
     r = 255*u*(1/0.333);
     g = 0;
     b = 0;
  } else if (0.333 < u && u <= 0.666) {
    r = 255;
    g = 255*u*(1/0.666);
    b = 0;
  } else if (0.666 < u && u <= 0.999) {
    r = 255;
    g = 255;
    b = u*255;
  }
  // float r = u/1;
  // float g = u/1;
  // float b = u/1;
  fill(r,g,b);
}

//Red for positive values, blue for negative ones.
void redBlue(float u){
  if (u < 0)
    fill(0,0,-255*u);
  else
    fill(255*u,0,0);
}

void update(float dt){
  //Compute Gradiant of heat (du/dt = alpha*laplacian)
  for (int i = 1; i < n-1; i++){
    float leftGradient = (heat[i-1] - heat[i])/dx;
    float rightGradient = (heat[i] - heat[i+1])/dx;
    float laplacian = (leftGradient - rightGradient)/dx; 
    float lapalcianAlt = (heat[i-1] - 2*heat[i] + heat[i+1])/(dx*dx);
    dheat_dt[i] = alpha * laplacian;
    //TODO: Add evaporative cooling here
  }
  
  //Impose (free) Bounardy Conditions
  heat[0] = heat[1];
  heat[n-1] = 1;
  dheat_dt[0] = dheat_dt[1];
  dheat_dt[n-1] = dheat_dt[n-2];
  
  //Integrate with Eulerian integration
  for (int i = 1; i < n-1; i++){
    heat[i] += dheat_dt[i]*dt - k*pow(heat[i], 4)*dt;
  }
}

boolean paused = true;
void draw() {
  background(200,200,200);
  
  float dt = 0.0002;
  for (int i = 0; i < 20; i++){
    if (!paused) update(dt);
  }
    
  //Draw Heat
  fill(0);
  text("Heat:", 50, 105);
  noStroke();
  for (int i = 0; i < n; i++){
    colorByTemp(heat[i]);
    pushMatrix();
    translate(100+dx*i,100+0);
    beginShape();
    vertex(-dx/2, -dy/2);
    vertex(dx/2, -dy/2);
    vertex(dx/2, dy/2);
    vertex(-dx/2, dy/2);
    endShape();
    popMatrix();
  }
  noFill();
  stroke(1);
  rect(100-dx/2,100-dy/2,n*dx,dy);
  
  //Draw derivative (dHeat/dt)
  fill(0);
  text("Derivative:", 22, 205);
  noStroke();
  for (int i = 0; i < n; i++){
    redBlue(4*dheat_dt[i]);
    pushMatrix();
    translate(100+dx*i,200+0);
    beginShape();
    vertex(-dx/2, -dy/2);
    vertex(dx/2, -dy/2);
    vertex(dx/2, dy/2);
    vertex(-dx/2, dy/2);
    endShape();
    popMatrix();
  }
  noFill();
  stroke(1);
  rect(100-dx/2,200-dy/2,n*dx,dy);
  
  if (paused)
    surface.setTitle(windowTitle + " [PAUSED]");
  else
    surface.setTitle(windowTitle + " "+ nf(frameRate,0,2) + "FPS");
}

void keyPressed(){
  if (key == 'r'){
    println("Resetting Simulation");
    setup();
    //TODO: Actually result the simulation
  }
  else {
    paused = !paused;
  }
}


float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}