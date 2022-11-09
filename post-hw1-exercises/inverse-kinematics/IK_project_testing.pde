int solve_start, solve_end, solve_dir, fk_start, fk_end, fk_dir;
void setup(){
    size(1000,1000);
    surface.setTitle("Inverse Kinematics [CSCI 5611 Example]");
    
    float len = 60;
    for (int i = 10; i >= 0; i--) {
        segments.add(
            new Segment(
                len, 0, 0, Float.POSITIVE_INFINITY,
                Float.POSITIVE_INFINITY, 1-(0.001*i*i), 0.001*i*i,
                new Vec2(i*len,0), new Vec2((i+1)*len,0)
            )
        );
    }
    
    solve_start = 0;
    solve_end = segments.size()-1;
    solve_dir = 1;
    fk_start = segments.size()-2;
    fk_end = 0;
    fk_dir = -1;

    goal = new Vec2(0,0);
}

ArrayList<Segment> segments = new ArrayList<Segment>();

Vec2[] locs = new Vec2[]{
  new Vec2(300,100), new Vec2(300, 700), new Vec2(400, 100), new Vec2(400, 700),
  new Vec2(500,100), new Vec2(500, 700), new Vec2(600, 100), 
  new Vec2(600,700), new Vec2(700, 100), new Vec2(700, 700), 
  new Vec2(800,100), new Vec2(800, 700)
};

class Segment {
    public float l, a, total_a, acc, acc2, min_a, max_a;
    public Vec2 start, end;
    Segment(float l, float a, float total_a, float max_a, float min_a, float acc, float acc2, Vec2 start, Vec2 end) {
        this.l = l;
        this.a = a;
        this.total_a = total_a;
        this.acc = acc;
        this.acc2 = acc;
        this.max_a = max_a;
        this.min_a = min_a;
        this.start = start;
        this.end = end;
    }
    void switchEnds() {
        Vec2 temp = new Vec2(this.start.x, this.start.y);
        this.start = this.end;
        this.end = temp;
    }
    void switchAcc() {
        float temp = this.acc;
        this.acc = this.acc2;
        this.acc2 = temp;
    }
}

Vec2 endPoint;

Vec2 c = new Vec2(300, 100);
int curr = 0;
Vec2 goal;
boolean just_paused = false;
void solve(){
    if (mouse) goal = new Vec2(mouseX, mouseY);
    else goal = locs[curr];
    // goal = new Vec2(mouseX, mouseY);
    
    Vec2 startToGoal, startToEndEffector;
    float dotProd, angleDiff;
  
    for (int i = solve_start; i != solve_end+solve_dir; i += solve_dir) {
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

        // if (i != solve_start) {
        //     segments.get(i-solve_dir).end = segments.get(i).start;
        // }
    }

    if (just_paused) {
        paused = true;
        just_paused = false;
    }

    if (endPoint.distanceTo(locs[curr]) < 2) {
        if (start_to_end) {
            solve_start = segments.size()-1;
            solve_end = 0;
            solve_dir = -1;

            fk_start = 1;
            fk_end = segments.size()-1;
            fk_dir = 1;

            start_to_end = false;
        } else {
            solve_start = 0;
            solve_end = segments.size()-1;
            solve_dir = 1;

            fk_start = segments.size()-2;
            fk_end = 0;
            fk_dir = -1;

            start_to_end = true;
        }
        // paused = true;
        segments.get(solve_end).start = endPoint;
        println(segments.get(solve_end).a);
        segments.get(solve_end).a = radians(180)+segments.get(solve_end).a;

        for (int i = solve_end; i != solve_start-solve_dir; i-=solve_dir) {
            segments.get(i).switchAcc();
            // segments.get(i).a = segments.get(i+solve_dir).a - segments.get(i).a;
        }

        // just_paused = true;

        curr++;
        curr %= 12;
    }
}

float total_angle = 0;
void fk(){
    total_angle = 0;
    for (int i = fk_start; i != fk_end+fk_dir; i += fk_dir) {
        total_angle = 0;
        Segment prev = segments.get(i-fk_dir);
        for (int j = fk_start-fk_dir; j != i; j += fk_dir) {
            total_angle += segments.get(j).a;
        }
        Vec2 res = new Vec2(cos(total_angle)*prev.l, sin(total_angle)*prev.l);
        segments.get(i).start = res.plus(prev.start);
    }

    total_angle = 0;
    for (int i = solve_start; i != solve_end+solve_dir; i+=solve_dir) {
        total_angle += segments.get(i).a;
        // segments.get(i).total_a = total_angle;
    }
    Segment end = segments.get(fk_end);
    endPoint = new Vec2(cos(total_angle)*end.l,sin(total_angle)*end.l).plus(end.start);
}

boolean start_to_end = true;

float armW = 20;
void draw(){
    if (!paused) {
        fk();
        solve();
    }
    
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
    for (int i = solve_end; i != solve_start-solve_dir; i-=solve_dir) {
        Segment curr = segments.get(i);
        
        total_angle += curr.a;
        if (!paused) println(i, degrees(curr.a), degrees(total_angle));
        pushMatrix();
        translate(curr.start.x, curr.start.y);
        rotate(total_angle);
        rect(0, -armW/2, curr.l, armW);
        popMatrix();
    }
}

boolean holding = false;
boolean mouse = false;
Vec2 dir = new Vec2(0,0);
float dist = 0;
void mousePressed() {
//   if (!holding && endPoint.distanceTo(c) < 50) {
//     holding = true;
//     dir = c.minus(endPoint);
//   }
    mouse = true;
}

void mouseReleased() {
//   if (holding) {
//     holding = false;
//   }
    mouse = false;
}

boolean paused = true;
void keyPressed() {
    if (key == ' ') paused = !paused; 
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
