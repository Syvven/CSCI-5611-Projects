/* autogenerated by Processing revision 1286 on 2022-09-21 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class boids3d extends PApplet {

/******************************************************************************************

3D Kiwi Prison Expiriment
Noah Hendrickson 5520241
CSCI 5611 Homework #1

*******************************************************************************************
Credits:

Moai Model: 
   https://sketchfab.com/3d-models/low-poly-moai-a6613687895d4eb0a778242083ebb824

Kiwi Model: 
   Lauren Oliver (Design Major @ UMN and also the brainchild behind some aspects)

Fence Model: 
   https://www.turbosquid.com/3d-models/3d-metal-fence-1393026

Conkcrete Texture: 
   https://img.freepik.com/free-photo/blank-concrete-white-wall-texture-background_1017-15560.jpg?w=2000

******************************************************************************************/


// Testing for 3d and eventually making a 3d boid simulation
int kiwiFrames = 4;
Vec3 backF = new Vec3(0,0,0); // grayish

PImage conkcrete;

PShape kiwi;
float kiwiWidth = 1; // units // Scale(10) --> 10 units
float kiwiLength = 2.5f; // units // Scale(10) --> 22.5 units
float kiwiHeight = 1.75f; // units // Scale(10) --> 17.5 units
int kiwiScale = 30;

PShape fence;
float fenceWidth = 1; // units
float fenceLength = 2.4f; // units // Scale(10) --> 24 units 
float fenceHeight = 2; // units // Scale(10) --> 20 units
float fenceScale = 156.25f;

// Moai
// 4 --> 1 for each corner
PShape moai;
Vec3 moaiDir = new Vec3(0,0,1);
int moaiScale = 3;
float moaiPadding = 70;
float moaiAffectRad = 50;
int maxMoai = 4;
int numMoai = 4;
// true == healing, false = sickness
boolean[] healingMoai = new boolean[numMoai];
Vec3[] moaiPos = new Vec3[numMoai];
float[] moaiRot = new float[numMoai];
Vec3[] moaiNosePos = new Vec3[numMoai];


PShape[] shapes = new PShape[kiwiFrames];
int[] times = new int[kiwiFrames];

float sceneX = 1500;
float sceneY = 1500;
float sceneZ = 1500;

// speed of gamers
float speed = 70;

// vertices for drawing floor
Vec3[][] floor = new Vec3[][]{
    {new Vec3(sceneX/2+20,0,sceneZ/2+20),new Vec3(0,0,0)},
    {new Vec3(sceneX/2+20,0,-sceneZ/2-20),new Vec3(0,1,0)},
    {new Vec3(-sceneX/2-20,0,-sceneZ/2-20),new Vec3(1,0,0)},
    {new Vec3(-sceneX/2-20,0,sceneZ/2+20),new Vec3(1,1,0)}
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
Vec3[] closestMoai = new Vec3[numAgents];
float tbase = 0.90f;
float t;

// variables for the outer fencing
int numFencesX = PApplet.parseInt(ceil(sceneX/(fenceLength*fenceScale)));
int numFencesZ = PApplet.parseInt(ceil(sceneZ/(fenceLength*fenceScale)));

// useful things
float ninety, oneeighty, twoseventy;
float epsilon = 1e-6f;
boolean debug = false;

////////////// FORCES //////////////////////////

// Infection
int maxInfected = PApplet.parseInt(numAgents/2);
int numInfected = 0;
ArrayList<Integer> infectedAgents = new ArrayList<Integer>();
float[] infectedTimer = new float[numAgents];
boolean[] isInfected = new boolean[numAgents];
float maxInfectedTime = 60;
int numFlies = 10;
float mutateChance = 99.95f;
float flyYOffset = 15;
float infectedRepelScale = 100;
// only forces that should apply to infected kiwis are 
// attraction to the moai forces and TTC forces
float moaiSpeed = 100;
float moaiGoalScale = 1000;

// max vel and acc changes
float maxVel = 200;
float maxAcc = 500;

// TTC
float k_avoid = 500;
float maxTTCTime = 3;

// wall forces
int numPlanes = 4;
Vec3[][] planes = new Vec3[numPlanes][2];
float wallPadding = 30;
float maxTimeToPlane = 10;
float maxWallDist = 100;
float wallAvoid = 10000;

// Separation Force
float sepMaxDist = agentHBRad*2;
float sepScale = 70;

// Cohesion Force
float cohMaxDist = agentHBRad*2+30;
float cohScale = 20;

// Align Force
float alignMaxDist = agentHBRad*2+15;
float alignScale = 2;

// Cam Force
float camMaxDist = 1000;
float camScale = 100;

// float angle;
// float concentration;
// float viewOff;

// PVector half = new PVector();
// PVector mouse = new PVector();

// Kiwi Frame Info
// -> Frames 1 and 3 around for 5 frames
// -> 2 and 4 are 2 frames
float kiwi_framerate = 56;

 public void setup() {
    /* size commented out by preprocessor */;
    hint(ENABLE_DEPTH_SORT);
    blendMode(BLEND);
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
        shapes[i-1] = loadShape(file);
    }
    times[0] = 5; times[2] = 5;
    times[1] = 2; times[3] = 2;

    fence = loadShape("data/MetalFence.obj");

    PImage texture = loadImage("data/FenceAlbedo.png");

    PImage mask = loadImage("data/FenceOpacity.png");

    conkcrete = loadImage("data/conkcrete.jpg");

    moai = loadShape("data/moai_low_poly.obj");

    texture.mask(mask);
    fence.setTexture(texture);

    // setup planes here --> [0] --> center [1] --> normal

    // this sets up the 4 main walls
    planes[0][0] = new Vec3(sceneX*0.5f,-sceneY*0.5f,0);
    planes[0][1] = new Vec3(1,0,0);

    planes[1][0] = new Vec3(-sceneX*0.5f,-sceneY*0.5f,0);
    planes[1][1] = new Vec3(-1,0,0);

    planes[2][0] = new Vec3(0,-sceneY*0.5f,sceneZ*0.5f);
    planes[2][1] = new Vec3(0,0,1);

    planes[3][0] = new Vec3(0,-sceneY*0.5f,-sceneZ*0.5f);
    planes[3][1] = new Vec3(0,0,-1);
}

// mainly here for resetting
 public void start() {
    // set up moai particles
    sphereDetail(10);
    for (int i = 0; i < numMoai; i++) {
        pos[i] = new ArrayList<Vec3>();
        vel[i] = new ArrayList<Vec3>();
        life[i] = new ArrayList<Float>();
        numParticles[i] = 0;
    }
    Vec3 center = new Vec3(0,0,0);
    int i = 0;
    for (; i <= floor(numMoai/2.1f); i++) {
        moaiPos[i] = new Vec3(
            (i==0)?(-sceneX*0.5f+moaiPadding):(sceneX*0.5f-moaiPadding),
            -0.71f*kiwiScale,
            (i==0)?(-sceneZ*0.5f+moaiPadding):(sceneZ*0.5f-moaiPadding)
        );
        
        moaiRot[i] = rotateTo(moaiDir, center.minus(moaiPos[i]));
        float xsign = moaiPos[i].x/abs(moaiPos[i].x);
        float zsign = moaiPos[i].z/abs(moaiPos[i].z);
        moaiNosePos[i] = new Vec3(moaiPos[i].x+-1*xsign*30, -140, moaiPos[i].z+-1*zsign*30);
    }

    for (; i < numMoai; i++) {
        moaiPos[i] = new Vec3(
            (i==2)?(-sceneX*0.5f+moaiPadding):(sceneX*0.5f-moaiPadding),
            -0.71f*kiwiScale,
            (i==2)?(sceneZ*0.5f-moaiPadding):(-sceneZ*0.5f+moaiPadding)
        );
        moaiRot[i] = rotateTo(moaiDir, center.minus(moaiPos[i]));
        float xsign = moaiPos[i].x/abs(moaiPos[i].x);
        float zsign = moaiPos[i].z/abs(moaiPos[i].z);
        moaiNosePos[i] = new Vec3(moaiPos[i].x+-1*xsign*30, -140, moaiPos[i].z+-1*zsign*30);
    }

    // set up agent things
    for (int id = 0; id < numAgents; id++) {
        // each agent at a random position within the walls
        agentPos[id] = new Vec3(
            random(-sceneX*0.5f+wallPadding*5+70, sceneX*0.5f-5*wallPadding-70),
            -0.71f*kiwiScale,
            random(-sceneZ*0.5f+wallPadding*5+70, sceneZ*0.5f-5*wallPadding-70)
        );
        agentVel[id] = new Vec3(random(-100,100), 0, random(-100,100));
        if (agentVel[id].length() > maxVel) {
            agentVel[id] = agentVel[id].normalized().times(maxVel);
        }
   
        agentAcc[id] = new Vec3(0,0,0);
        agentTime[id] = random(5);
        agentFrame[id] = PApplet.parseInt(random(kiwiFrames));
        agentDir[id] = atan2(agentVel[id].x, agentVel[id].z);
        isInfected[id] = false;
        infectedTimer[id] = 0;
        
    }
    infectedAgents = new ArrayList<Integer>();
    numInfected = 0;

    t = tbase;
}

//////////////// UPDATING FUNCTIONS ///////////////////////////////

 public void mutate(int id) {
    numInfected++;
    infectedAgents.add(id);
    isInfected[id] = true;
    float min = Float.POSITIVE_INFINITY;
    int minM = -1;
    for (int m = 0; m < numMoai; m++) {
        float dist2 = agentPos[id].distanceTo(moaiPos[m]);
        if (min > dist2) {
            min = dist2;
            minM = m;
        }
    }
    closestMoai[id] = moaiPos[minM];
}

 public void cure(int id) {
    numInfected--;
    isInfected[id] = false;
    infectedAgents.remove((Integer)id);
    infectedTimer[id] = 0;
}

 public void updateKiwiFrame(int id) {
    /*  
        updates each kiwi's frame at different time to 
        make it look a bit better 
    */
    agentTime[id] += agentVel[id].length()*0.005f;
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
 public Vec3 computeTTW(Vec3 aPos, Vec3 aVel, int infectScale) {
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
            float dist = aPos.distanceTo(intPoint);
            repel.mul(wallAvoid/infectScale);
            // repel.clampToLength(maxAcc);
            acc.add(repel);
        }

        Vec3 planeClose = new Vec3(
            (abs(plane[0].x)<epsilon)?aPos.x:plane[0].x, 
            aPos.y, 
            (abs(plane[0].z)<epsilon)?aPos.z:plane[0].z
        );
        float dist = aPos.distanceTo(planeClose);
        if (dist <= maxWallDist) {
            Vec3 repel = aPos.minus(planeClose);
            repel.mul(wallAvoid/infectScale);
            // repel.clampToLength(maxAcc);
            acc.add(repel);
        }
    }

    return acc;
}

// Time to Collision (between kiwis)
 public Vec3 computeTTC(Vec3 pos1, Vec3 vel1, float rad1, Vec3 pos2, Vec3 vel2, float rad2) {
    float ttc = rayIntersectSphereTime(pos1, rad1+rad2, pos2, vel2.minus(vel1));
    if (!Float.isNaN(ttc) && ttc <= maxTTCTime) {
        Vec3 future1 = pos1.plus(vel1.times(ttc));
        Vec3 future2 = pos2.plus(vel2.times(ttc));
        Vec3 rfd = (future1.minus(future2)).normalized();
        
        return rfd.times(k_avoid*(1/ttc));
    }
    return new Vec3(0,0,0);
}

 public Vec3 computeAgentForces(int id) {
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
            if (dist <= sepMaxDist*2) {
                Vec3 sepForce = agentPos[id].minus(agentPos[jd]);
                float sepScaleInf = isInfected[jd] ? sepScale*15 : sepScale;
                dist = isInfected[id] ? dist*0.5f : dist;
                sepForce.mul(sepScaleInf/dist);
                sepForce.y = 0;
                // sepForce.clampToLength(maxAcc);
                acc.add(sepForce);
            }

            if (isInfected[jd] && !isInfected[id] && numInfected < maxInfected && dist < agentHBRad*1.5f) {
                println("Mutating");
                mutate(id);
            }

            // average for cohesion
            if (dist <= cohMaxDist && !isInfected[jd]) {
                avgPos.add(agentPos[jd]);
                numCohesion++;
            }

            // average for alignment
            if (dist <= alignMaxDist && !isInfected[jd]) {
                avgVel.add(agentVel[jd]);
                numAlign++;
            }
        }
    }

    // Wall forces
    acc.add(computeTTW(agentPos[id], agentVel[id], isInfected[id]?1000:1));

    // infection force
    if (isInfected[id]) {
        Vec3 goal_vel = closestMoai[id].minus(agentPos[id]);
        goal_vel.y = 0;
        goal_vel = goal_vel.normalized().times(moaiSpeed);
        Vec3 goal_force = goal_vel.minus(agentVel[id]);

        acc.add(goal_force.times(moaiGoalScale));
        return acc;
    }

    // moai separation
    // Separation Force
    for (int i = 0; i < numMoai; i++) {
        float dist = agentPos[id].distanceTo(moaiPos[i]);
        if (dist <= moaiAffectRad*moaiScale*3) {
            Vec3 sepForce = agentPos[id].minus(moaiPos[i]);
            sepForce.mul(infectedRepelScale/(dist*0.5f));
            sepForce.y = 0;
            // sepForce.clampToLength(maxAcc);
            acc.add(sepForce);
        }
    }

    // Cohesion Force
    if (numCohesion > 0) {
        avgPos.x /= numCohesion; avgPos.z /= numCohesion;
        Vec3 cohForce = avgPos.minus(agentPos[id]);
        cohForce.normalize();
        cohForce.y = 0;
        cohForce.mul(cohScale);
        // cohForce.clampToLength(maxAcc);
        acc.add(cohForce);
    }

    // Alignment Force
    if (numAlign > 0) {
        avgVel.x /= numAlign; avgVel.z /= numAlign;
        Vec3 alignForce = avgVel.minus(agentVel[id]);
        alignForce.normalize();
        alignForce.y = 0;
        alignForce.times(alignScale);
        // alignForce.clampToLength(maxAcc);
        acc.add(alignForce);
    }

    // Cam (mouse) force
    Vec3 camPos = new Vec3(camera.position.x, camera.position.y, camera.position.z);
    camPos.y = agentPos[id].y;
    float camDist = agentPos[id].distanceTo(camPos);

    // attraction force of camera
    // TODO: Make this where mouse is pointing
    if (leftHeld && camDist <= camMaxDist) {
        Vec3 camForce = camPos.minus(agentPos[id]);
        camForce.normalize();
        camForce.mul(camScale);
        camForce.y = 0;
        // camForce.clampToLength(maxAcc);
        acc.add(camForce);
    }

    // repulsion force of camera
    // TODO: Make this where mouse is pointing
    if (rightHeld && camDist <= camMaxDist) {
        Vec3 camForce = agentPos[id].minus(camPos);
        camForce.mul(camScale/camDist);
        camForce.y = 0;
        // camForce.clampToLength(maxAcc);
        acc.add(camForce);
    }

    return acc;
}

 public void update(float dt) {
    checkPressed();

    // compute forces for each agent
    for (int id = 0; id < numAgents; id++) {
        agentAcc[id] = computeAgentForces(id);
        if (agentAcc[id].length() > maxAcc) {
            agentAcc[id] = agentAcc[id].normalized().times(maxAcc);
        }
    }

    // update position, velocity, rotation
    for (int id = 0; id < numAgents; id++) {
        // increase pos and vel
        Vec3 newV = agentVel[id].plus(agentAcc[id].times(dt));
        agentVel[id] = interpolate(agentVel[id], newV, 0.1f);

        // make velocity comply with the speed limit
        if (agentVel[id].length() > maxVel && !isInfected[id]) {
            agentVel[id] = agentVel[id].normalized().times(maxVel);
        }
        
        if (agentVel[id].length() > maxVel && isInfected[id]) {
            agentVel[id] = agentVel[id].normalized().times(moaiSpeed);
        }
        
        // agentVel[id].add(agentAcc[id].times(dt));
        agentPos[id].add(agentVel[id].times(dt));

        

        // float randomWalk = random(100);
        // if (randomWalk > 98) {
        //     Vec3 targetVel = new Vec3(
        //         -10+random(20),
        //         0,
        //         -10+random(20)
        //     );

        // old way --> bad, has jittering
        // agentRot[id] = rotateTo(new Vec3(0,0,1), agentVel[id]);

        // new way --> t = f(v) --> theta = theta*t+(1-t)*atan2(v.x, v.z)
        // credit to Professor Guy for this hack
        t = tbase-agentVel[id].length()*0.00001f;
        if (t > 0.99f) t = 0.99f;
        if (t < 0.91f) t = 0.93f;
        agentDir[id] = agentDir[id]*t+(1-t)*atan2(agentVel[id].x, agentVel[id].z);

        // determine infection stuff
        if (!isInfected[id] && numInfected < maxInfected) {
            boolean mutate = (random(100) > mutateChance) ? true : false;
            if (mutate) {
                println("Mutating");
                mutate(id);
            }
        } 

        if (isInfected[id]) {
            infectedTimer[id] += dt;
            if (infectedTimer[id] > maxInfectedTime ||
                agentPos[id].distanceTo(closestMoai[id]) < moaiAffectRad*moaiScale*1.5f) {
                cure(id);
            } 
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
////////////// DRAW FUNCTIONS /////////////////////////////////////////////////////////

// debug / measuring drawing
 public void drawBounds() {
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

// drawing borders of the scene
 public void drawFencesAndFloor() {
    fill(11, 43, 20);
    textureMode(NORMAL);
    beginShape();
        texture(conkcrete);
        for (var vertex : floor) {
            vertex(vertex[0].x, vertex[0].y, vertex[0].z, vertex[1].x, vertex[1].y);
        }
    endShape(CLOSE);

    for (int i = 0; i < numFencesX; i++) {
        pushMatrix();
            translate(-sceneX/2,0,-sceneZ*0.5f+fenceLength*fenceScale*0.5f+i*fenceLength*fenceScale);
            rotateZ(oneeighty);
            rotateY(twoseventy);
            scale(fenceScale);
            shape(fence);
        popMatrix();

        pushMatrix();
            translate(sceneX/2,0,-sceneZ*0.5f+fenceLength*fenceScale*0.5f+i*fenceLength*fenceScale);
            rotateZ(oneeighty);
            rotateY(ninety);
            scale(fenceScale);
            shape(fence);
        popMatrix();
    } 
    for (int i = 0; i < numFencesZ; i++) {
        pushMatrix();
            translate(-sceneX*0.5f+fenceLength*fenceScale*0.5f+i*fenceLength*fenceScale,0,-sceneX/2);
            rotateZ(oneeighty);
            scale(fenceScale);
            shape(fence);
        popMatrix();

        pushMatrix();
            translate(-sceneX*0.5f+fenceLength*fenceScale*0.5f+i*fenceLength*fenceScale,0,sceneX/2);
            rotateZ(oneeighty);
            rotateY(oneeighty);
            scale(fenceScale);
            shape(fence);
        popMatrix();
    }
}

// draws infection for debugging and deciding
 public void drawInfection() {
    stroke(0,255,0);
    strokeWeight(1);
    noFill();
    for (var agent : infectedAgents) {
        Vec3 pos = agentPos[agent];
        pushMatrix();
            translate(pos.x, pos.y-flyYOffset, pos.z);
            sphere(agentHBRad);
        popMatrix();
    }
}

// draws the healing and hurting moai
 public void drawMoai() {
    for (int i = 0; i < numMoai; i++) {
        pushMatrix();
            translate(moaiPos[i].x, 0, moaiPos[i].z);
            rotateZ(oneeighty);
            rotateY(-moaiRot[i]);
            scale(moaiScale);
            shape(moai);
            // sphere(moaiAffectRad);
        popMatrix();
        
        noStroke();
        fill(0,40);
        for (int p = 0; p < numParticles[i]; p++) {
            pushMatrix();
                Vec3 curr = pos[i].get(p);
                translate(curr.x, curr.y, curr.z);
                sphere(10);
            popMatrix();
        }
        noFill();
    }
}

// draw func
 public void draw() {
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

    camera.Update(1.0f/frameRate);
    
    if (!simPaused) {
        update(1/frameRate);
        updateParticles(1/frameRate);
    }

    // draws things needed for understanding coordinate system
    // safe to comment out once everything is ready
    if (debug) drawBounds();

    // Draws the infection
    //drawInfection();
    drawMoai();

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

 public void checkPressed() {

}

 public void mouseWheel(MouseEvent event) {
    
}

 public void mousePressed() {
    if (mouseButton == LEFT) leftHeld = true;
    if (mouseButton == RIGHT) rightHeld = true;
}

 public void mouseReleased() {
    if (mouseButton == LEFT) leftHeld = false;
    if (mouseButton == RIGHT) rightHeld = false;
}

 public void keyPressed()
{
  camera.HandleKeyPressed();
  if (key == 'c') {
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
  if (key == 'r') start();
  if (key == 'C') centerAgent = false;
}

 public void keyReleased()
{
  camera.HandleKeyReleased();
}
// Created for CSCI 5611 by Liam Tyler

// WASD keys move the camera relative to its current orientation
// Arrow keys rotate the camera's orientation
// Holding shift boosts the move speed

class Camera
{
  Camera()
  {
    position      = new PVector( 600, -600, 600 ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 60;
    turnSpeed     = 1.7f; // radians/sec
    boostSpeed    = 5;  // extra speed boost for when you press shift
    
    // dont need to change these
    shiftPressed = false;
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    verticalMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1f;
    farPlane         = 10000;
  }
  
   public void Update(float dt)
  {
    theta += turnSpeed * ( negativeTurn.x + positiveTurn.x)*dt;
    
    // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    float maxAngleInRadians = 85 * PI / 180;
    phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    if (negativeMovement.mag() > 0) negativeMovement.normalize();
    if (positiveMovement.mag() > 0) positiveMovement.normalize();
    if (verticalMovement.mag() > 0) verticalMovement.normalize();

    if (shiftPressed){
      positiveMovement.mult(boostSpeed);
      negativeMovement.mult(boostSpeed);
      verticalMovement.mult(boostSpeed);
    }

    PVector velocity   = new PVector( 
      negativeMovement.x + positiveMovement.x + verticalMovement.x, 
      negativeMovement.y + positiveMovement.y + verticalMovement.y, 
      negativeMovement.z + positiveMovement.z 
    );

    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    if (centerAgent) {
      // pushMatrix();
      //   translate(agentPos[centerAgentID].x, agentPos[centerAgentID].y, agentPos[centerAgentID].z);
        camera(
          position.x, position.y, position.z,
          agentPos[centerAgentID].x, agentPos[centerAgentID].y, agentPos[centerAgentID].z,
          upDir.x, upDir.y, upDir.z 
        );
      // popMatrix();
    } else {
      camera( 
        position.x, position.y, position.z,
        position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
        upDir.x, upDir.y, upDir.z 
      );
    }
   
  }
  
  // only need to change if you want difrent keys for the controls
   public void HandleKeyPressed()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 1;
    if ( key == 's' || key == 'S' ) negativeMovement.z = -1;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = -1;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 1;
    if ( key == 'q' || key == 'Q' ) positiveMovement.y = 1;
    if ( key == 'e' || key == 'E' ) negativeMovement.y = -1;
    if ( key == ' ' ) verticalMovement.y = -1;
    if ( key == 'R' ){
      Camera defaults = new Camera();
      position = defaults.position;
      theta = defaults.theta;
      phi = defaults.phi;
    }
    
    if ( keyCode == LEFT )  negativeTurn.x = 1;
    if ( keyCode == RIGHT ) positiveTurn.x = -0.5f;
    if ( keyCode == UP )    positiveTurn.y = 0.5f;
    if ( keyCode == DOWN )  negativeTurn.y = -1;
    if ( keyCode == CONTROL ) verticalMovement.y = 1;
    
    if ( keyCode == SHIFT ) shiftPressed = true; 
  }
  
  // only need to change if you want difrent keys for the controls
   public void HandleKeyReleased()
  {
    if ( key == 'w' || key == 'W' ) positiveMovement.z = 0;
    if ( key == 'q' || key == 'Q' ) positiveMovement.y = 0;
    if ( key == 'd' || key == 'D' ) positiveMovement.x = 0;
    if ( key == 'a' || key == 'A' ) negativeMovement.x = 0;
    if ( key == 's' || key == 'S' ) negativeMovement.z = 0;
    if ( key == 'e' || key == 'E' ) negativeMovement.y = 0;
    if ( key == ' ' ) verticalMovement.y = 0;
    
    if ( keyCode == LEFT  ) negativeTurn.x = 0;
    if ( keyCode == RIGHT ) positiveTurn.x = 0;
    if ( keyCode == UP    ) positiveTurn.y = 0;
    if ( keyCode == DOWN  ) negativeTurn.y = 0;
    if ( keyCode == CONTROL ) verticalMovement.y = 0;
    
    if ( keyCode == SHIFT ){
      shiftPressed = false;
      positiveMovement.mult(1.0f/boostSpeed);
      negativeMovement.mult(1.0f/boostSpeed);
    }
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  float boostSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector verticalMovement;
  PVector negativeTurn;
  PVector positiveTurn;
  boolean shiftPressed;
};




// ----------- Example using Camera class -------------------- //
// Camera camera;

// void setup()
// {
//   size(600, 600, P3D);
//   camera = new Camera();
// }

// void keyPressed()
// {
//   camera.HandleKeyPressed();
// }

// void keyReleased()
// {
//   camera.HandleKeyReleased();
// }

// void draw() {
//   background(255);
//   noLights();

//   camera.Update(1.0/frameRate);
  
//   // draw six cubes surrounding the origin (front, back, left, right, top, bottom)
//   fill( 0, 0, 255 );
//   pushMatrix();
//   translate( 0, 0, -50 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 0, 0, 50 );
//   box( 20 );
//   popMatrix();
  
//   fill( 255, 0, 0 );
//   pushMatrix();
//   translate( -50, 0, 0 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 50, 0, 0 );
//   box( 20 );
//   popMatrix();
  
//   fill( 0, 255, 0 );
//   pushMatrix();
//   translate( 0, 50, 0 );
//   box( 20 );
//   popMatrix();
  
//   pushMatrix();
//   translate( 0, -50, 0 );
//   box( 20 );
//   popMatrix();
// }
static int maxParticles = 180; // per moai
float genRate = 90; // per moai
float maxLife = maxParticles/genRate;
Vec3 gravity = new Vec3(0,60,0);
ArrayList<Vec3>[] pos = new ArrayList[numMoai];
ArrayList<Vec3>[] vel = new ArrayList[numMoai];
ArrayList<Float>[] life = new ArrayList[numMoai];
int[] numParticles = new int[numMoai];
float COR = 0;
float partRad = 1;

 public void updateParticles(float dt) {
    float toGen_float = genRate*dt;
    int toGen = PApplet.parseInt(toGen_float);
    float fractPart = toGen_float-toGen;
    if (random(1) < fractPart) toGen++;
    for (int m = 0; m < numMoai; m++) {
        if (numParticles[m] < maxParticles) {
            for (int p = 0; p < toGen; p+=2) {
                pos[m].add(new Vec3(
                    moaiNosePos[m].x,
                    moaiNosePos[m].y,
                    moaiNosePos[m].z
                ));
                pos[m].add(new Vec3(
                    moaiNosePos[m].x,
                    moaiNosePos[m].y,
                    moaiNosePos[m].z
                ));
                vel[m].add(new Vec3(
                    -48,
                    48,
                    -24
                ));
                vel[m].add(new Vec3(
                    -24,
                    48,
                    -48
                ));
                life[m].add(0.0f);
                life[m].add(0.0f);
                numParticles[m]+=2;
            }
        }   
    }

    for (int m = 0; m < numMoai; m++) {
        for (int i = 0; i < numParticles[m]; i++) {
            life[m].set(i, life[m].get(i)+dt);
            if (life[m].get(i) < maxLife) {
                // do stuff
                Vec3 curr_pos = pos[m].get(i);
                Vec3 curr_vel = vel[m].get(i);

                curr_pos.add(curr_vel.times(dt));

                if (curr_pos.y > 0-partRad) {
                    curr_pos.y = 0-partRad;
                    curr_vel.y *= -COR;
                }

                curr_vel.add(gravity.times(dt));

                pos[m].set(i, curr_pos);
                vel[m].set(i, curr_vel);
            } else {
                pos[m].remove(i);
                vel[m].remove(i);
                life[m].remove(i);
                numParticles[m]--;
            }
        }
    }
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

 public Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return a.plus((b.minus(a)).times(t));
  // a + ((b-a)*t)
}

 public float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

 public float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}

 public Vec3 cross(Vec3 a, Vec3 b) {
    float newx = a.y*b.z - a.z*b.y;
    float newy = a.z*b.x - a.x*b.z;
    float newz = a.x*b.y - a.y*b.x;

    return new Vec3(newx, newy, newz);
}

 public Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(a.x*b.x + a.y*b.y + a.z*b.z);
}

 public float rotateTo(Vec3 a, Vec3 b) {
    Vec3 cross = cross(a, b);
    float first = cross.x+cross.y+cross.z;
    return atan2(first, dot(a,b));
}

// for detecting the edges of the area
 public float rayIntersectPlaneTime(Vec3 normal, Vec3 normPoint, Vec3 origin, Vec3 ray) {
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
 public float rayIntersectSphereTime(Vec3 center, float radius, Vec3 origin, Vec3 ray) {
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


  public void settings() { size(1200, 1200, P3D); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "boids3d" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
