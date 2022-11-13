float[] lengths = new float[8];


void setup(){
    size(1000,1000);
    surface.setTitle("Inverse Kinematics [CSCI 5611 Example]");

    for (int i = 0; i < 10; i++) {
        segments.add(new Segment(50, 30, 30, -30, 0.1, new Vec2(0,0)));
    }
    segments.add(new Segment(50, 30, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, 0.1, new Vec2(135, 150)));
    lengths[0] = 144;
}

ArrayList<Segment> segments = new ArrayList<Segment>();

Vec2[] locs = new Vec2[]{
  new Vec2(200,200), new Vec2(400, 200), new Vec2(600, 200), new Vec2(800, 200),
  new Vec2(800,400), new Vec2(800, 600), new Vec2(800, 800), 
  new Vec2(200,800), new Vec2(400, 800), new Vec2(600, 800), 
  new Vec2(200,600), new Vec2(200, 400)
};

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

Vec2 endPoint;

Vec2 c = new Vec2(300, 100);
int curr = 0;

void solve(){
    Vec2 goal = new Vec2(mouseX, mouseY);
    
    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;
  
    for (int i = 0; i != segments.size(); i++) {
        Segment s = segments.get(i);
        startToGoal = goal.minus(s.start);
        startToEndEffector = endPoint.minus(s.start);
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
        fk(); //Update link positions with fk (e.g. end effector changed)
    }
}



void fk(){
    float total_angle = 0;
    for (int i = segments.size()-2; i >= 0; i--) {
        total_angle = 0;
        Segment prev = segments.get(i+1);
        for (int j = segments.size()-1; j > i; j--) {
            total_angle += segments.get(j).a;
        }
        segments.get(i).start = new Vec2(cos(total_angle)*prev.l, sin(total_angle)*prev.l).plus(prev.start);
    }
    total_angle = 0;
    for (int i = 0; i < segments.size(); i++) {
        total_angle += segments.get(i).a;
    }
    endPoint = new Vec2(cos(total_angle)*segments.get(0).l,sin(total_angle)*segments.get(0).l).plus(segments.get(0).start);

    if (endPoint.distanceTo(locs[curr]) < 2) {
        curr++;
        curr %= 12;
    }
}

float armW = 20;
void draw(){
    fk();
    solve();
    
    background(250,250,250);
    
    fill(230, 199, 154);

    pushMatrix();
    translate(100, 100);
    circle(0,0,100);
    popMatrix();

    pushMatrix();
    translate(100, 150);
    rect(-35, 0, 70, 150);
    popMatrix();

    for (int i = 0; i < 12; i++) {
        pushMatrix();
        translate(locs[i].x, locs[i].y);
        circle(0,0,20);
        popMatrix();
    }

    float total_angle = 0;
    for (int i = segments.size()-1; i >= 0; i--) {
        Segment curr = segments.get(i);
        total_angle += curr.a;
        println(total_angle);
        pushMatrix();
        translate(curr.start.x, curr.start.y);
        rotate(total_angle);
        rect(0, -armW/2, curr.l, armW);
        popMatrix();
    }
}

// boolean holding = false;
// Vec2 dir = new Vec2(0,0);
// float dist = 0;
// void mousePressed() {
//   if (!holding && endPoint.distanceTo(c) < 50) {
//     holding = true;
//     dir = c.minus(endPoint);
//   }
// }

// void mouseReleased() {
//   if (holding) {
//     holding = false;
//   }
// }



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
