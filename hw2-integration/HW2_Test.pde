//CSCI 5611 HW 2 PDE Library
//Look at GroundTruth.pde and Integrator.pde for more instructions.

void RunComparisons() {
  println("==========\nComparison Against the Ground Truth\n==========");
  println();
  
  //Integrate from t_start to t_end
  float t_start = 0;
  float x_start = actual_x_of_t(t_start);
  float dt = 1;
  int n_steps = 10;
  float t_end = t_start + n_steps * dt;
  
  float x_end;
  ArrayList<Float> x_all;
  ArrayList<Float> x_actual = actualList(t_start,n_steps,dt);
  float actual_end = actual_x_of_t(t_end);

  
  //Integrate using Eulerian integration
  println("Eulerian: ");
  x_end = eulerian(t_start,x_start,n_steps,dt);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);

  println("Printing Each Step--");
  x_all = eulerianList(t_start,x_start,n_steps,dt);
  println("Approx:",x_all);
  println("Actual:",x_actual);
  

  //Integrate using Midpoint integration
  println("\nMidpoint: ");
  x_end= midpoint(t_start,x_start,n_steps,dt);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);
  
  println("Printing Each Step--");
  x_all = midpointList(t_start,x_start,n_steps,dt);
  println("Aprox:",x_all);
  println("Actual:",x_actual);
  
  
  //Integrate using RK4 (4th order Runge–Kutta)
  println("\nRK4: ");
  x_end= rk4(t_start,x_start,n_steps,dt);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);
  
  println("Printing Each Step--");
  x_all = rk4List(t_start,x_start,n_steps,dt);
  println("Approx:",x_all);
  println("Actual:",x_actual);
  
 
  //For comparison, this is Heun's method, a different 2nd order method (similar to midpoint)
  println("\nHeun: ");
  x_end= heun(t_start,x_start,n_steps,dt);
  println("f(t) for t =",t_end,"is",x_end," Ground truth:", actual_end," Error is", actual_end-x_end);
}


void setup(){
  // Test code for homework 2.
  
   // Compare the numerical integration results with actual antiderivatives 
  RunComparisons();
}
