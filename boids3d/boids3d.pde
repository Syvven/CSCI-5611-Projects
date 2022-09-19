// Testing for 3d and eventually making a 3d boid simulation
int kiwiFrames = 4;
Vec3 backF = new Vec3(0,0,0); // grayish

PShape kiwi;
float kiwiWidth = 1; // units // Scale(10) --> 10 units
float kiwiLength = 2.5; // units // Scale(10) --> 22.5 units
float kiwiHeight = 1.75; // units // Scale(10) --> 17.5 units
int kiwiScale = 30;

PShape fence;
float fenceWidth = 1; // units
float fenceLength = 2.4; // units // Scale(10) --> 24 units 
float fenceHeight = 2; // units // Scale(10) --> 20 units
int fenceScale = 125;

PShape[] shapes = new PShape[kiwiFrames];
int[] times = new int[kiwiFrames];

float sceneX = 1500;
float sceneY = 1500;
float sceneZ = 1500;

float speed = 10;

Vec3[] floor = new Vec3[]{
    new Vec3(sceneX/2+20,0,sceneZ/2+20),
    new Vec3(sceneX/2+20,0,-sceneZ/2-20),
    new Vec3(-sceneX/2-20,0,-sceneZ/2-20),
    new Vec3(-sceneX/2-20,0,sceneZ/2+20)
};

// camera, centering, and key handling things
Camera camera;
int centerAgentID = 0;
boolean centerAgent = false;
boolean simPaused = true;
boolean leftHeld, rightHeld;

// agent variables
float agentHBRad = kiwiScale;
int numAgents = 50;
Vec3 agentPos[] = new Vec3[numAgents];
Vec3 agentVel[] = new Vec3[numAgents];
Vec3 agentAcc[] = new Vec3[numAgents];
float agentRot[] = new float[numAgents];
float agentTime[] = new float[numAgents];
int agentSwitchFrame[] = new int[numAgents];
int agentFrame[] = new int[numAgents];
float agentDir[] = new float[numAgents];
float t = 0.98;

// variables for the outer fencing
int numFencesX = int(ceil(sceneX/(fenceLength*fenceScale)));
int numFencesZ = int(ceil(sceneZ/(fenceLength*fenceScale)));

// useful things
float ninety, oneeighty, twoseventy;
float epsilon = 1e-6;
boolean debug = false;

////////////// FORCES //////////////////////////

// max vel and acc changes
float maxVel = 80;
float maxAcc = 200;

// TTC
float k_avoid = 50;
float maxTTCTime = 3;

// wall forces
int numPlanes = 4;
Vec3[][] planes = new Vec3[numPlanes][2];
float wallPadding = 30;
float maxTimeToPlane = 3;
float wallAvoid = 50;

// Separation Force
float sepMaxDist = agentHBRad*2;
float sepScale = 30;

// Cohesion Force
float cohMaxDist = agentHBRad*2+30;
float cohScale = 10;

// Align Force
float alignMaxDist = agentHBRad*2+15;
float alignScale = 2;

// Cam Force
float camMaxDist = 1000;
float camScale = 10;

// float angle;
// float concentration;
// float viewOff;

// PVector half = new PVector();
// PVector mouse = new PVector();

void setup() {
    size(1200, 1200, P3D);
    surface.setTitle("3d Stuff");
    surface.setResizable(true);
    surface.setLocation(600,50);
    strokeWeight(5);

    camera = new Camera();

    // thigns that will be needed...
    oneeighty = radians(180);
    ninety = radians(90);
    twoseventy = radians(270);

    // angle = QUARTER_PI;
    // viewOff = height * .86602;

    // half.set(width * .5, height * .5);

    // intializing the kiwi frames for the animation
    String base = "data/kiwi";
    for (int i = 1; i <= kiwiFrames; i++) {
        String file = base + i + ".obj";
        println(file);
        shapes[i-1] = loadShape(file);
    }
    times[0] = 5; times[2] = 5;
    times[1] = 2; times[3] = 2;

    fence = loadShape("data/MetalFence.obj");

    PImage texture = loadImage("data/FenceAlbedo.png");

    PImage mask = loadImage("data/FenceOpacity.png");

    texture.mask(mask);
    fence.setTexture(texture);

    // setup planes here --> [0] --> center [1] --> normal

    // this sets up the 4 main walls
    planes[0][0] = new Vec3(sceneX*0.5-wallPadding,-sceneY*0.5,0);
    planes[0][1] = new Vec3(1,0,0);

    planes[1][0] = new Vec3(-sceneX*0.5+wallPadding,-sceneY*0.5,0);
    planes[1][1] = new Vec3(-1,0,0);

    planes[2][0] = new Vec3(0,-sceneY*0.5,sceneZ*0.5-wallPadding);
    planes[2][1] = new Vec3(0,0,1);

    planes[3][0] = new Vec3(0,-sceneY*0.5,-sceneZ*0.5+wallPadding);
    planes[3][1] = new Vec3(0,0,-1);
}

void start() {
    // set up agent things
    for (int id = 0; id < numAgents; id++) {
        // each agent at a random position within the walls
        agentPos[id] = new Vec3(
            (-sceneX*0.5)+(wallPadding+agentHBRad)+70+random(2*((sceneX*0.5)-(2*wallPadding)-agentHBRad-70)),
            -0.71*kiwiScale,
            (-sceneZ*0.5)+(wallPadding+agentHBRad)+70+random(2*((sceneZ*0.5)-(2*wallPadding)-agentHBRad-70))
        );
        agentVel[id] = new Vec3(-200+random(400), 0, -200+random(400));
        agentVel[id].setToLength(speed);
        agentAcc[id] = new Vec3(0,0,0);
        agentTime[id] = random(5);
        agentFrame[id] = int(random(kiwiFrames));
        agentDir[id] = atan2(agentVel[id].x, agentVel[id].z);
    }
}

void reset() {  
    start();
}

//////////////// UPDATING FUNCTIONS ///////////////////////////////

void updateKiwiFrame(int id) {
    /*  
        updates each kiwi's frame at different time to 
        make it look a bit better 
    */
    agentTime[id] += agentVel[id].length()*0.005;
    if (agentTime[id] > 1/kiwi_framerate) {
        agentTime[id] = 0;
        agentSwitchFrame[id]++;
        if (agentSwitchFrame[id] == times[agentFrame[id]]) {
            agentSwitchFrame[id] = 0;
            agentFrame[id] = (agentFrame[id]+1)%4;
        }
    }
}

// Time To Wall
Vec3 computeTTW(Vec3 aPos, Vec3 aVel, int numRays) {
    Vec3 acc = new Vec3(0,0,0);
    for (var plane : planes) {
        float ttc = rayIntersectPlaneTime(
            plane[1], plane[0], 
            aPos, aVel
        );
        
        // apply a repel force? I don't know if this is a good approach
        // TODO: Ask Prof Guy or TA for other options / advice
        if (!Float.isNaN(ttc) && ttc <= maxTimeToPlane && ttc > 0) {
            Vec3 intPoint = aPos.plus(aVel.times(ttc));
            Vec3 repel = aPos.minus(intPoint);
            repel.mul(wallAvoid);
            repel.clampToLength(maxAcc);
            acc.add(repel);
        }
    }

    return acc;
}

// Time to Collision (between kiwis)
Vec3 computeTTC(Vec3 pos1, Vec3 vel1, float rad1, Vec3 pos2, Vec3 vel2, float rad2) {
    float ttc = rayIntersectSphereTime(pos1, rad1+rad2, pos2, vel2.minus(vel1));
    if (!Float.isNaN(ttc) && ttc <= maxTTCTime) {
        Vec3 future1 = pos1.plus(vel1.times(ttc));
        Vec3 future2 = pos2.plus(vel2.times(ttc));
        Vec3 rfd = (future1.minus(future2)).normalized();
        
        return rfd.times(k_avoid*(1/ttc));
    }
    return new Vec3(0,0,0);
}

Vec3 computeAgentForces(int id) {
    Vec3 acc = new Vec3(0,0,0);
    
    Vec3 avgPos = new Vec3(0,0,0);
    Vec3 avgVel = new Vec3(0,0,0);
    int numAlign = 0; int numCohesion = 0;
    for (int jd = 0; jd < numAgents; jd++) {
        if (id != jd) {
            // TTC force
            acc.add(computeTTC(
                agentPos[id], agentVel[id], agentHBRad,
                agentPos[jd], agentVel[jd], agentHBRad
            ));

            float dist = agentPos[id].distanceTo(agentPos[jd]);

            // Separation Force
            if (dist <= sepMaxDist) {
                Vec3 sepForce = agentPos[id].minus(agentPos[jd]);
                sepForce.mul(sepScale/dist);
                sepForce.y = 0;
                sepForce.clampToLength(maxAcc);
                acc.add(sepForce);
            }

            if (dist <= cohMaxDist) {
            avgPos.add(agentPos[jd]);
            numCohesion++;
            }

            if (dist <= alignMaxDist) {
            avgVel.add(agentVel[jd]);
            numAlign++;
            }
        }
    }

    // Cohesion Force
    if (numCohesion > 0) {
        avgPos.x /= numCohesion; avgPos.z /= numCohesion;
        Vec3 cohForce = avgPos.minus(agentPos[id]);
        cohForce.normalize();
        cohForce.y = 0;
        cohForce.mul(cohScale);
        cohForce.clampToLength(maxAcc);
        acc.add(cohForce);
    }

    // Alignment Force
    if (numAlign > 0) {
        avgVel.x /= numAlign; avgVel.z /= numAlign;
        Vec3 alignForce = avgVel.minus(agentVel[id]);
        alignForce.normalize();
        alignForce.y = 0;
        alignForce.times(alignScale);
        acc.add(alignForce);
    }

    // Mouse Force
    Vec3 camPos = new Vec3(camera.position.x, camera.position.y, camera.position.z);
    camPos.y = agentPos[id].y;
    float camDist = agentPos[id].distanceTo(camPos);

    if (leftHeld && camDist <= camMaxDist) {
        Vec3 camForce = camPos.minus(agentPos[id]);
        camForce.normalize();
        camForce.mul(camScale);
        camForce.y = 0;
        camForce.clampToLength(maxAcc);
        acc.add(camForce);
    }

    if (rightHeld && camDist <= camMaxDist) {
        Vec3 camForce = agentPos[id].minus(camPos);
        camForce.mul(camScale/camDist);
        camForce.y = 0;
        camForce.clampToLength(maxAcc);
        acc.add(camForce);
    }

    // Wall forces
    acc.add(computeTTW(agentPos[id], agentVel[id], 50));

    return acc;
}

void update(float dt) {
    checkPressed();

    for (int id = 0; id < numAgents; id++) {
        agentAcc[id] = computeAgentForces(id);
    }

    for (int id = 0; id < numAgents; id++) {
        agentPos[id].add(agentVel[id].times(dt));
        agentVel[id].add(agentAcc[id].times(dt));

        if (agentVel[id].length() > maxVel) {
            agentVel[id] = agentVel[id].normalized().times(maxVel);
        }
        // agentVel[id] = interpolate(agentVel[id], target, 0.09);
        

        // float randomWalk = random(100);
        // if (randomWalk > 98) {
        //     Vec3 targetVel = new Vec3(
        //         -10+random(20),
        //         0,
        //         -10+random(20)
        //     );

        //     // agentVel[id] = interpolate(agentVel[id], targetVel, 0.09);
        // }

        // introduce orientation
        // vector or angle
        // start -> way model is laoding -- 0 deg
        // timestep -> new vel from boid --> dorient= t*dorient+(1-t)*atan2(vel.y,vel.x)
        // --> smaller t = more floaty? tune it

        // more? t --> function of velocity

        // old way --> bad, has jittering
        // agentRot[id] = rotateTo(new Vec3(0,0,1), agentVel[id]);

        // new way --> doesnt work yet
        agentDir[id] = agentDir[id]*t+(1-t)*atan2(agentVel[id].x, agentVel[id].z);
        // println(agentDir[id]);
    }
}

///////////////////////////////////////////////////////////////////////////////////////
////////////// DRAW FUNCTIONS /////////////////////////////////////////////////////////

void drawBounds() {
    // x axis --> red
    stroke(255,0,0);
    line(0,0,0,10000,0,0);
    stroke(0,0,0);
    line(0,0,0,-10000,0,0);
    

    // y axis --> green
    stroke(0,255,0);
    line(0,0,0,0,10000,0);
    stroke(0,0,0);
    line(0,0,0,0,-10000,0);

    // z axis --> blue
    stroke(0,0,255);
    line(0,0,0,0,0,10000);
    stroke(0,0,0);
    line(0,0,0,0,0,-10000);

    stroke(255, 0, 255);
    for (int i = 0; i < numAgents; i++) {
        line(
            agentPos[i].x, agentPos[i].y, agentPos[i].z,
            agentPos[i].x+agentVel[i].x*2, agentPos[i].y+agentVel[i].y*2, agentPos[i].z+agentVel[i].z*2 
        );
    }

    for (var plane : planes) {
        line(
            plane[0].x, plane[0].y, plane[0].z,
            plane[0].x+200*plane[1].x, plane[0].y+200*plane[1].y, plane[0].z+200*plane[1].z
        );
    }
}

void drawFencesAndFloor() {
    fill(11, 43, 20);
    beginShape();
        for (var vertex : floor) {
            vertex(vertex.x, vertex.y, vertex.z);
        }
    endShape(CLOSE);

    for (int i = 0; i < numFencesX; i++) {
        pushMatrix();
            translate(-sceneX/2,0,-sceneZ*0.5+fenceLength*fenceScale*0.5+i*fenceLength*fenceScale);
            rotateZ(oneeighty);
            rotateY(twoseventy);
            scale(fenceScale);
            shape(fence);
        popMatrix();

        pushMatrix();
            translate(sceneX/2,0,-sceneZ*0.5+fenceLength*fenceScale*0.5+i*fenceLength*fenceScale);
            rotateZ(oneeighty);
            rotateY(ninety);
            scale(fenceScale);
            shape(fence);
        popMatrix();
    } 
    for (int i = 0; i < numFencesZ; i++) {
        pushMatrix();
            translate(-sceneX*0.5+fenceLength*fenceScale*0.5+i*fenceLength*fenceScale,0,-sceneX/2);
            rotateZ(oneeighty);
            scale(fenceScale);
            shape(fence);
        popMatrix();

        pushMatrix();
            translate(-sceneX*0.5+fenceLength*fenceScale*0.5+i*fenceLength*fenceScale,0,sceneX/2);
            rotateZ(oneeighty);
            rotateY(oneeighty);
            scale(fenceScale);
            shape(fence);
        popMatrix();
    }
}

// Kiwi Frame Info
// -> Frames 1 and 3 around for 5 frams
// -> 2 and 4 are 2 frames

float total_time = 0;
int switchframe = 0;
int frame = 0;
float kiwi_framerate = 28;
float rot = 0;
void draw() {
    background(backF.x, backF.y, backF.z);

    // Sets the default ambient 
    // and directional light
    colorMode(HSB, 360, 100, 100);
    lightFalloff(1,0,0);
    lightSpecular(0,0,10);
    ambientLight(0,0,70);
    directionalLight(128,128,128, 0,0,0);
    colorMode(RGB, 255, 255, 255);

    // concentration = map(cos(frameCount * .01), -1, 1, 12, 100);
    // mouse.set(mouseX - half.x, mouseY - half.y, viewOff);
    // mouse.normalize();

    // // Flash light.
    // spotLight(
    //     191, 170, 133,
    //     0, 0, viewOff,
    //     mouse.x, mouse.y, -1,
    //     angle, concentration
    // );

    camera.Update(1.0/frameRate);
    
    if (!simPaused) update(1/frameRate);

    // draws things needed for understanding coordinate system
    // safe to comment out once everything is ready
    if (debug) drawBounds();

    // draw each agent
    for (int id = 0; id < numAgents; id++) {
        if (!simPaused) updateKiwiFrame(id);
        pushMatrix();
            translate(agentPos[id].x, agentPos[id].y, agentPos[id].z);
            // for new way
            rotateY(agentDir[id]);
            // for old way
            // rotateY(agentRot[id]);
            scale(kiwiScale);
            shape(shapes[agentFrame[id]]);
        popMatrix();
    }
    // draw fences after because of some weird masking quirks
    drawFencesAndFloor();
}

//////////////////////////////////////////////////////////////////////////
/////////////////// BUTTON HANDLERS //////////////////////////////////////

void checkPressed() {

}

void mouseWheel(MouseEvent event) {
    
}

void mousePressed() {
    if (mouseButton == LEFT) leftHeld = true;
    if (mouseButton == RIGHT) rightHeld = true;
}

void mouseReleased() {
    if (mouseButton == LEFT) leftHeld = false;
    if (mouseButton == RIGHT) rightHeld = false;
}

void keyPressed()
{
  camera.HandleKeyPressed();
  if (key == 'c' || key == 'C') {
    if (!centerAgent) {
        centerAgent = true;
        centerAgentID = 0;
    } else {
        centerAgentID++;
        if (centerAgentID >= numAgents) {
            centerAgent = false;
            centerAgentID = 0;
        }
    }
  }
  if (key == 'p' || key == 'P') simPaused = !simPaused;
  if (key == 'r') reset();
  if (keyCode == BACKSPACE) centerAgent = false;
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

////////////////////////////////////////////////////////////////////////////////

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

    public float lengthSqr() {
        return x*x+y*y+z*z;
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
        if (magnitude <= epsilon) return;
        x *= newL/magnitude;
        y *= newL/magnitude;
        z *= newL/magnitude;
    }

    public void normalize(){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > epsilon) {
            x /= magnitude;
            y /= magnitude;
            z /= magnitude;
        }
    }

    public Vec3 normalized(){
        float magnitude = sqrt(x*x + y*y + z*z);
        if (magnitude > epsilon) return new Vec3(x/magnitude, y/magnitude, z/magnitude);
        return new Vec3(x,y,z);
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

Vec3 cross(Vec3 a, Vec3 b) {
    float newx = a.y*b.z - a.z*b.y;
    float newy = a.z*b.x - a.x*b.z;
    float newz = a.x*b.y - a.y*b.x;

    return new Vec3(newx, newy, newz);
}

Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(a.x*b.x + a.y*b.y + a.z*b.z);
}

float rotateTo(Vec3 a, Vec3 b) {
    Vec3 cross = cross(a, b);
    float first = cross.x+cross.y+cross.z;
    return atan2(first, dot(a,b));
}

// for detecting the edges of the area
float rayIntersectPlaneTime(Vec3 normal, Vec3 normPoint, Vec3 origin, Vec3 ray) {
    float denom = dot(normal, ray);
    if (denom > epsilon) {
        Vec3 pl = normPoint.minus(origin);
        float t = dot(pl, normal) / denom;
        if (t >= 0) return t;
        return Float.NaN;
    }
    return Float.NaN;
}

// for detecting collisions between other keewers
float rayIntersectSphereTime(Vec3 center, float radius, Vec3 origin, Vec3 ray) {
    Vec3 toCircle = center.minus(origin);

    float a = ray.length()*ray.length(); // square the length of the ray
    float b = -2*dot(ray, toCircle); // 2*dot between ray and dir from pos to center of circle
    float c = toCircle.lengthSqr() - (radius*radius); // difference of squares

    float d = b*b - 4*a*c; // discriminant

    if (d >= 0) {
        float t = (-b-sqrt(d))/(2*a); // only need first intersection
        if (t >= 0) return t; // only return if going to collide
        return Float.NaN; 
    }
    return Float.NaN; // no colliding
}