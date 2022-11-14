ArrayList<Segment> ccd_segments = new ArrayList<Segment>();
ArrayList<Segment> fabrik_segments = new ArrayList<Segment>();
Vec2 ccd_endPoint;
Vec2 fabrik_endPoint;
Vec2 fabrik_origin;
float armW = 20;
float len = 50;

void setup(){
    size(1000,1000);
    surface.setTitle("Inverse Kinematics [CSCI 5611 Example]");

    for (int i = 0; i < 3; i++) {
        ccd_segments.add(new Segment(len, 30, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, 1, new Vec2(0,0)));
        fabrik_segments.add(new Segment(len, 30, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, 1, new Vec2(0,0)));
    }
    ccd_segments.add(new Segment(len, 30, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, 0.1, new Vec2(135, 150)));
    fabrik_segments.add(new Segment(len, 30, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, 0.1, new Vec2(width-135, 150)));
    fabrik_origin = new Vec2(width-135, 150);
}

class Segment {
    public float l, a, acc, min_a, max_a;
    public Vec2 start;
    Segment(float l, float a, float max_a, float min_a, float acc, Vec2 start) {
        this.l = l;
        this.a = a;
        this.acc = acc;
        this.max_a = max_a;
        this.min_a = min_a;
        this.start = start;
    }
}

void ccd_solve(){
    Vec2 goal = new Vec2(mouseX, mouseY);
    
    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;
  
    for (int i = 0; i != ccd_segments.size(); i++) {
        Segment s = ccd_segments.get(i);
        startToGoal = goal.minus(s.start);
        startToEndEffector = ccd_endPoint.minus(s.start);
        dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
        dotProd = clamp(dotProd,-1,1);
        angleDiff = acos(dotProd) * s.acc;
        if (cross(startToGoal,startToEndEffector) < 0)
            s.a += angleDiff;
        else
            s.a -= angleDiff;
        /*TODO: Wrist joint limits here*/
        if (s.max_a != Float.POSITIVE_INFINITY) {
            if (s.a > radians(s.max_a)) s.a = radians(s.max_a);
        }
        if (s.min_a != Float.POSITIVE_INFINITY) {
            if (s.a < radians(s.min_a)) s.a = radians(s.min_a);
        }
        ccd_fk(); //Update link positions with fk (e.g. end effector changed)
    }
}

void ccd_fk(){
    float total_angle = 0;
    for (int i = ccd_segments.size()-2; i >= 0; i--) {
        total_angle = 0;
        Segment prev = ccd_segments.get(i+1);
        for (int j = ccd_segments.size()-1; j > i; j--) {
            total_angle += ccd_segments.get(j).a;
        }
        ccd_segments.get(i).start = new Vec2(cos(total_angle)*prev.l, sin(total_angle)*prev.l).plus(prev.start);
    }
    total_angle = 0;
    for (int i = 0; i < ccd_segments.size(); i++) {
        total_angle += ccd_segments.get(i).a;
    }
    ccd_endPoint = new Vec2(cos(total_angle)*ccd_segments.get(0).l,sin(total_angle)*ccd_segments.get(0).l).plus(ccd_segments.get(0).start);
}

// void fabrik_solve() {
//     // first thing to do is check that you can actually reach

//     // do backwards first
//     // set end effector to goal, solve backwards

//     // p0 is off start
//     // do forwards
//     // set p0 to start and do process forwards

//     Vec2 goal = new Vec2(mouseX, mouseY);
    
//     Vec2 startToGoal, startToEndEffector;
//     float dotProd, angleDiff;
  
//     for (int i = 0; i != fabrik_segments.size(); i++) {
//         Segment s = fabrik_segments.get(i);
//         startToGoal = goal.minus(s.start);
//         startToEndEffector = fabrik_endPoint.minus(s.start);
//         dotProd = dot(startToGoal.normalized(),startToEndEffector.normalized());
//         dotProd = clamp(dotProd,-1,1);
//         angleDiff = acos(dotProd) * s.acc;
//         if (cross(startToGoal,startToEndEffector) < 0)
//             s.a += angleDiff;
//         else
//             s.a -= angleDiff;
//         /*TODO: Wrist joint limits here*/
//         if (s.max_a != Float.POSITIVE_INFINITY) {
//             if (s.a > radians(s.max_a)) s.a = radians(s.max_a);
//         }
//         if (s.min_a != Float.POSITIVE_INFINITY) {
//             if (s.a < radians(s.min_a)) s.a = radians(s.min_a);
//         }
//         fabrik_fk(); //Update link positions with fk (e.g. end effector changed)
//     }
// }

void fabrik_backward() {
    Vec2 goal = new Vec2(mouseX, mouseY);
    fabrik_endPoint = goal;
    for (int i = fabrik_segments.size()-1; i >= 0; i--) {
        Segment s = fabrik_segments.get(i);
        if (i == fabrik_segments.size()-1) {
            Vec2 dir = fabrik_endPoint.minus(s.start);
            float len;
            if (dir.length() == 0) len = 0;
            else len = s.l / dir.length();
            Vec2 pos = fabrik_endPoint.times(1-len).plus(s.start.times(len));
            s.start = pos;
        } else {
            Segment sbefore = fabrik_segments.get(i+1);
            Vec2 dir = sbefore.start.minus(s.start);
            float len;
            if (dir.length() == 0) len = 0;
            else len = s.l / dir.length();
            Vec2 pos = sbefore.start.times(1-len).plus(s.start.times(len));
            s.start = pos;
        }
    }
}

void fabrik_forward() {
    fabrik_segments.get(0).start = fabrik_origin;
    for (int i = 0; i < fabrik_segments.size(); i++) {
        Segment s = fabrik_segments.get(i);
        if (i == fabrik_segments.size()-1) {
            Vec2 dir = fabrik_endPoint.minus(s.start);
            float len;
            if (dir.length() == 0) len = 0;
            else len = s.l / dir.length();
            Vec2 pos = s.start.times(1-len).plus(fabrik_endPoint.times(len));
            fabrik_endPoint = pos;
        } else {
            Segment safter = fabrik_segments.get(i+1);
            Vec2 dir = safter.start.minus(s.start);
            float len;
            if (dir.length() == 0) len = 0;
            else len = s.l / dir.length();
            Vec2 pos = s.start.times(1-len).plus(safter.start.times(len));
            safter.start = pos;
        }
    }
}

// void fabrik_fk() {
//     float total_angle = 0;
//     for (int i = fabrik_segments.size()-2; i >= 0; i--) {
//         total_angle = 0;
//         Segment prev = fabrik_segments.get(i+1);
//         for (int j = fabrik_segments.size()-1; j > i; j--) {
//             total_angle += fabrik_segments.get(j).a;
//         }
//         fabrik_segments.get(i).start = new Vec2(cos(total_angle)*prev.l, sin(total_angle)*prev.l).plus(prev.start);
//     }
//     total_angle = 0;
//     for (int i = 0; i < fabrik_segments.size(); i++) {
//         total_angle += fabrik_segments.get(i).a;
//     }
//     fabrik_endPoint = new Vec2(cos(total_angle)*fabrik_segments.get(0).l,sin(total_angle)*fabrik_segments.get(0).l).plus(fabrik_segments.get(0).start);
// }

void draw(){
    ccd_fk();
    ccd_solve();

    fabrik_backward();
    fabrik_forward();

    // fabrik_fk();
    // fabrik_solve();
    
    background(250,250,250);
    
    fill(230, 199, 154);

    pushMatrix();
    translate(100, 100);
    circle(0,0,100);
    popMatrix();

    pushMatrix();
    translate(width-100, 100);
    circle(0,0,100);
    popMatrix();

    pushMatrix();
    translate(100, 150);
    rect(-35, 0, 70, 150);
    popMatrix();

    pushMatrix();
    translate(width-100, 150);
    rect(-35, 0, 70, 150);
    popMatrix();

    float total_angle = 0;
    for (int i = ccd_segments.size()-1; i >= 0; i--) {
        Segment curr = ccd_segments.get(i);
        total_angle += curr.a;
        pushMatrix();
        translate(curr.start.x, curr.start.y);
        rotate(total_angle);
        rect(0, -armW/2, curr.l, armW);
        popMatrix();
    }

    strokeWeight(10);
    Vec2 s = fabrik_segments.get(fabrik_segments.size()-1).start;
    line(s.x, s.y, fabrik_endPoint.x, fabrik_endPoint.y);
    strokeWeight(1);
    pushMatrix();
    translate(fabrik_endPoint.x, fabrik_endPoint.y);
    circle(0,0,10);
    popMatrix();
    for (int i = fabrik_segments.size()-1; i >= 1; i--) {
        Segment curr = fabrik_segments.get(i);
        Segment next = fabrik_segments.get(i-1);
        strokeWeight(10);
        line(curr.start.x, curr.start.y, next.start.x, next.start.y);
        strokeWeight(1);

        pushMatrix();
        translate(curr.start.x, curr.start.y);
        circle(0,0,10);
        popMatrix();
    }
    Segment curr = fabrik_segments.get(0);
    pushMatrix();
    translate(curr.start.x, curr.start.y);
    circle(0,0,10);
    popMatrix();
}



//-----------------
// Vector Library
//-----------------

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

float cross(Vec2 a, Vec2 b){
  return a.x*b.y - a.y*b.x;
}


Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

float clamp(float f, float min, float max){
  if (f < min) return min;
  if (f > max) return max;
  return f;
}
