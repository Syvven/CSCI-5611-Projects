// //FK & IK 
// //CSCI 5611 3-link IK Chain follows mouse [Example]
// // Stephen J. Guy <sjguy@umn.edu>

// void setup(){
//   size(640,480);
//   surface.setTitle("Inverse Kinematics [CSCI 5611 Example]");
//   strokeWeight(2);
// }


// //Root
// Vec2 root = new Vec2(50,50);

// //Link 1
// float l0 = 200;
// float a0 = 0.4;

// //Link 2
// float l1 = 150;
// float a1 = 0.0; 

// //Link 3
// float l2 = 100;
// float a2 = 0.7; 

// Vec2 start_l1, start_l2, endPoint;

// void fk(){
//   start_l1 = new Vec2(cos(a0)*l0,sin(a0)*l0).plus(root);
//   start_l2 = new Vec2(cos(a0+a1)*l1,sin(a0+a1)*l1).plus(start_l1);
//   endPoint = new Vec2(cos(a0+a1+a2)*l2,sin(a0+a1+a2)*l2).plus(start_l2);
// }

// void solve(){
//   Vec2 goal = new Vec2(mouseX, mouseY);
  
//   Vec2 startToGoal, startToEndEffector;
//   float dotProd;
  
//   startToGoal = goal.minus(start_l2);
//   startToEndEffector = endPoint.minus(start_l2);
//   dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
//   dotProd = clamp(dotProd,-1,1);
//   if (cross(startToGoal,startToEndEffector) < 0)
//     a2 += acos(dotProd);
//   else
//     a2 -= acos(dotProd);
//   fk(); //Update link positions with fk (e.g. end effector changed)
  
//   startToGoal = goal.minus(start_l1);
//   startToEndEffector = endPoint.minus(start_l1);
//   dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
//   dotProd = clamp(dotProd,-1,1);
//   if (cross(startToGoal,startToEndEffector) < 0)
//     a1 += acos(dotProd);
//   else
//     a1 -= acos(dotProd);
//   fk(); //Update link positions with fk (e.g. end effector changed)
  
//   //[CODE FOR LAST LINK GOES HERE]
//   startToGoal = goal.minus(root);
//   startToEndEffector = endPoint.minus(root);
//   dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
//   dotProd = clamp(dotProd,-1,1);
//   if (cross(startToGoal,startToEndEffector) < 0)
//     a0 += acos(dotProd);
//   else
//     a0 -= acos(dotProd);
//   fk(); //Update link positions with fk (e.g. end effector changed)
  
//   println("Angle 0:",nf(a0,1,2),"Angle 1:",nf(a1,1,2),"Angle 2:",nf(a2,1,2));
// }

// float armW = 20;
// void draw(){
//   fk();
//   solve();
  
//   background(255,255,255);
  
//   fill(180,20,40); //Root
//   pushMatrix();
//   translate(root.x,root.y);
//   rect(-20,-20,40,40);
//   popMatrix();
  
  
//   fill(10,150,40); //Green IK Chain
//   pushMatrix();
//   translate(root.x,root.y);
//   rotate(a0);
//   quad(0, -armW/2, l0, -.1*armW, l0, .1*armW, 0, armW/2);
//   popMatrix();
  
//   pushMatrix();
//   translate(start_l1.x,start_l1.y);
//   rotate(a0+a1);
//   quad(0, -armW/2, l1, -.1*armW, l1, .1*armW, 0, armW/2);
//   popMatrix();
  
//   pushMatrix();
//   translate(start_l2.x,start_l2.y);
//   rotate(a0+a1+a2);
//   quad(0, -armW/2, l2, -.1*armW, l2, .1*armW, 0, armW/2);
//   popMatrix();
  
//   fill(0,0,0); //Goal/mouse
//   pushMatrix();
//   translate(mouseX,mouseY);
//   circle(0,0,20);
//   popMatrix();
  
//   //saveFrame("frame####.png");
// }




// // Vector Library

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

// float cross(Vec2 a, Vec2 b){
//   return a.x*b.y - a.y*b.x;
// }


// Vec2 projAB(Vec2 a, Vec2 b){
//   return b.times(a.x*b.x + a.y*b.y);
// }

// float clamp(float f, float min, float max){
//   if (f < min) return min;
//   if (f > max) return max;
//   return f;
// }
