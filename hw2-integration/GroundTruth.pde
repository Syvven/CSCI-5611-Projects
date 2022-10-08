//Different functions to test with PDEs
//You need to specify both the derivative you want to numerically integrate (dxdt)
// and its antiderivative (which is used to evaluate accuracy).

//TODO:
//  -Try: dx/dx = 2*t*cos(t*t)
//        dx/dt = 2
//        dx/dt = 2*t
//        dx/dt = t*t*t
//        dx/dt = x
//        dx/dt = sin(t) + t*cos(t)
float dxdt(float t, float x){ //The function actual_x_of_t() should be an antiderivative of this function
  return cos(t);
}

//In practice the derivative will typically be complex enough that we don't know the actual answer
//   but for this assignment, let's practice with simple functions we know the antiderivative of.
//   We use this known antiderivative to compute the error of the numerical approximations.
//Note: There is a family of antiderivative functions up-to a shift (the test-harness code auto-detects the shift)
float actual_x_of_t(float t){
  return sin(t) + 2.718; //The derivative of this function should be placed in dxdt!
}

//Returns a list of the actual values from t_start to t_end (also ignores shifts as the "actual" function)
ArrayList<Float> actualList(float t_start, int n_steps, float dt){
  ArrayList<Float> xVals = new ArrayList<Float>();
  float t = t_start;
  xVals.add(actual_x_of_t(t));
  for (int i = 0; i < n_steps; i++){
    t += dt;
    xVals.add(actual_x_of_t(t));
  }
  return xVals;
}
