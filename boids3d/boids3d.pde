// Testing for 3d and eventually making a 3d boid simulation

Vec3 camEye = new Vec3(600,600,600);
float dist = camEye.length();
Vec3 camCenter = new Vec3(0,0,0);
Vec3 camRay;
Vec3 camUp = new Vec3(0,-1,0);
PShape kiwi;

// booleans for holding
boolean upPressed, downPressed, leftPressed, rightPressed;
boolean aPressed, dPressed, wPressed, sPressed;

void setup() {
    size(1200, 1200, P3D);
    surface.setTitle("3d Stuff");
    surface.setResizable(true);
    surface.setLocation(500,500);
    strokeWeight(5);
    kiwi = loadShape("data/tinker.obj");
}

void reset() {
    camEye = new Vec3(600,600,0);
    camCenter = new Vec3(0,0,0);
    camUp = new Vec3(0,-1,0);
}

void drawBounds() {
    // x axis --> red
    stroke(255,0,0);
    line(0,0,0,3000,0,0);
    line(0,0,0,-3000,0,0);
    

    // y axis --> green
    stroke(0,255,0);
    line(0,0,0,0,3000,0);
    line(0,0,0,0,-3000,0);

    // z axis --> blue
    stroke(0,0,255);
    line(0,0,0,0,0,3000);
    line(0,0,0,0,0,-3000);
}

void checkPressed() {
    if (upPressed) {
        camEye.y += 10; camCenter.y += 10;
    }
    if (downPressed) {
        camEye.y -= 10; camCenter.y -= 10;
    }
    if (leftPressed) {

    }
    if (rightPressed) {

    }
    if (aPressed) {
        camEye.rotateAroundY(-0.1);
    }
    if (dPressed) {
        camEye.rotateAroundY(0.1);
    }
    if (wPressed) {
        camCenter.y += 10;
    }
    if (sPressed) {
        camCenter.y -= 10;
    }
}

void update() {
    camRay = camEye.minus(camCenter);
}

void draw() {
    background(0);
    // Sets the default ambient 
    // and directional light
    lights();

    // used for understanding where the bounds of the scene are
    drawBounds();
    checkPressed();

    update();

    // eyeX, eyeY, eyeZ
    // centerX, centerY, centerZ
    // upX (0,1,-1), upY (0,1,-1), upZ(0,1,-1)
    fill(255);
    camera(
        camEye.x, camEye.y, camEye.z,
        camCenter.x, camCenter.y, camCenter.z,
        camUp.x, camUp.y, camUp.z
    );

    pushMatrix();
    scale(10);
    rotateX(radians(-90));
    shape(kiwi, 0, 0);
    popMatrix();
}

void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    camEye.add(camRay.times(e*0.01));
}

void keyPressed() {
    if (keyCode == UP) {
        upPressed = true;
    }
    if (keyCode == DOWN) {
        downPressed = true;
    }
    if (keyCode == RIGHT) {
        rightPressed = true;
    }
    if (keyCode == LEFT) {
        leftPressed = true;
    }
    if (key == 'a') {
        aPressed = true;
    }
    if (key == 'd') {
        dPressed = true;
    }
    if (key == 'w') {
        wPressed = true;
    }
    if (key == 's') {
        sPressed = true;
    }
}

void keyReleased() {
    if (keyCode == UP) {
        upPressed = false;
    }
    if (keyCode == DOWN) {
        downPressed = false;
    }
    if (keyCode == RIGHT) {
        rightPressed = false;
    }
    if (keyCode == LEFT) {
        leftPressed = false;
    }
    if (key == 'a') {
        aPressed = false;
    }
    if (key == 'd') {
        dPressed = false;
    }
    if (key == 'w') {
        wPressed = false;
    }
    if (key == 's') {
        sPressed = false;
    }
    if (key == 'r') {
        reset();
    }
}

// CSCI 5611 Vector 3 Library
// Noah J Hendrickson <hend0800@umn.edu>

public class Vec3 {
    public float x, y, z;

    public Vec3(float x, float y, float z){
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public String toString(){
        return "(" + x + "," + y + "," + z + ")";
    }

    public float length(){
        return sqrt(x*x+y*y+z*z);
    }

    public Vec3 plus(Vec3 rhs){
        return new Vec3(x+rhs.x, y+rhs.y, z+rhs.z);
    }

    public void add(Vec3 rhs){
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
    }

    public Vec3 minus(Vec3 rhs){
        return new Vec3(x-rhs.x, y-rhs.y, z-rhs.z);
    }

    public void subtract(Vec3 rhs){
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
    }

    public Vec3 times(float rhs){
        return new Vec3(x*rhs, y*rhs, z*rhs);
    }

    public void mul(float rhs){
        x *= rhs;
        y *= rhs;
        z *= rhs;
    }

    public void clampToLength(float maxL){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > maxL){
            x *= maxL/magnitude;
            y *= maxL/magnitude;
            z *= maxL/magnitude;
        }
    }

    public void setToLength(float newL){
        float magnitude = sqrt(x*x + y*y);
        x *= newL/magnitude;
        y *= newL/magnitude;
        z *= newL/magnitude;
    }

    public void normalize(){
        float magnitude = sqrt(x*x + y*y + z*z);
        x /= magnitude;
        y /= magnitude;
        z /= magnitude;
    }

    public Vec3 normalized(){
        float magnitude = sqrt(x*x + y*y + z*z);
        return new Vec3(x/magnitude, y/magnitude, z/magnitude);
    }

    public float distanceTo(Vec3 rhs){
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        float dz = rhs.z - z;
        return sqrt(dx*dx + dy*dy + dz*dz);
    }

    public void rotateAroundZ(float rad) {
        x = cos(rad)*x-sin(rad)*y;
        y = sin(rad)*x+cos(rad)*y;
        z = z;
    }

    public void rotateAroundY(float rad) {
        x = cos(rad)*x+sin(rad)*z;
        y = y;
        z = -sin(rad)*x+cos(rad)*z;
    }

    public void rotateAroundX(float rad) {
        x = x;
        y = cos(rad)*y-sin(rad)*z;
        z = sin(rad)*y+cos(rad)*z;
    }

    public Vec3 rotatedAroundZ(float rad) {
        float newx = cos(rad)*x-sin(rad)*y;
        float newy = sin(rad)*x+cos(rad)*y;
        float newz = z;
        return new Vec3(newx, newy, newz);
    }

    public Vec3 rotatedAroundY(float rad) {
        float newx = cos(rad)*x+sin(rad)*z;
        float newy = y;
        float newz = -sin(rad)*x+cos(rad)*z;
        return new Vec3(newx, newy, newz);
    }

    public Vec3 rotatedAroundX(float rad) {
        float newx = x;
        float newy = cos(rad)*y-sin(rad)*z;
        float newz = sin(rad)*y+cos(rad)*z;
        return new Vec3(newx, newy, newz);
    }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return a.plus((b.minus(a)).times(t));
  // a + ((b-a)*t)
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}

Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(a.x*b.x + a.y*b.y + a.z*b.z);
}
