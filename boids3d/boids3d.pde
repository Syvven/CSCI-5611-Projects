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
float kiwiLength = 2.5; // units // Scale(10) --> 22.5 units
float kiwiHeight = 1.75; // units // Scale(10) --> 17.5 units
int kiwiScale = 30;

PShape fence;
float fenceWidth = 1; // units
float fenceLength = 2.4; // units // Scale(10) --> 24 units 
float fenceHeight = 2; // units // Scale(10) --> 20 units
float fenceScale = 156.25;

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
float tbase = 0.90;
float t;

// variables for the outer fencing
int numFencesX = int(ceil(sceneX/(fenceLength*fenceScale)));
int numFencesZ = int(ceil(sceneZ/(fenceLength*fenceScale)));

// useful things
float ninety, oneeighty, twoseventy;
float epsilon = 1e-6;
boolean debug = false;

////////////// FORCES //////////////////////////

// Infection
int maxInfected = int(numAgents/2);
int numInfected = 0;
ArrayList<Integer> infectedAgents = new ArrayList<Integer>();
float[] infectedTimer = new float[numAgents];
boolean[] isInfected = new boolean[numAgents];
float maxInfectedTime = 60;
int numFlies = 10;
float mutateChance = 99.95;
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

void setup() {
    size(1200, 1200, P3D);
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
    planes[0][0] = new Vec3(sceneX*0.5,-sceneY*0.5,0);
    planes[0][1] = new Vec3(1,0,0);

    planes[1][0] = new Vec3(-sceneX*0.5,-sceneY*0.5,0);
    planes[1][1] = new Vec3(-1,0,0);

    planes[2][0] = new Vec3(0,-sceneY*0.5,sceneZ*0.5);
    planes[2][1] = new Vec3(0,0,1);

    planes[3][0] = new Vec3(0,-sceneY*0.5,-sceneZ*0.5);
    planes[3][1] = new Vec3(0,0,-1);
}

// mainly here for resetting
void start() {
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
    for (; i <= floor(numMoai/2.1); i++) {
        moaiPos[i] = new Vec3(
            (i==0)?(-sceneX*0.5+moaiPadding):(sceneX*0.5-moaiPadding),
            -0.71*kiwiScale,
            (i==0)?(-sceneZ*0.5+moaiPadding):(sceneZ*0.5-moaiPadding)
        );
        
        moaiRot[i] = rotateTo(moaiDir, center.minus(moaiPos[i]));
        float xsign = moaiPos[i].x/abs(moaiPos[i].x);
        float zsign = moaiPos[i].z/abs(moaiPos[i].z);
        moaiNosePos[i] = new Vec3(moaiPos[i].x+-1*xsign*30, -140, moaiPos[i].z+-1*zsign*30);
    }

    for (; i < numMoai; i++) {
        moaiPos[i] = new Vec3(
            (i==2)?(-sceneX*0.5+moaiPadding):(sceneX*0.5-moaiPadding),
            -0.71*kiwiScale,
            (i==2)?(sceneZ*0.5-moaiPadding):(-sceneZ*0.5+moaiPadding)
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
            random(-sceneX*0.5+wallPadding*5+70, sceneX*0.5-5*wallPadding-70),
            -0.71*kiwiScale,
            random(-sceneZ*0.5+wallPadding*5+70, sceneZ*0.5-5*wallPadding-70)
        );
        agentVel[id] = new Vec3(random(-100,100), 0, random(-100,100));
        if (agentVel[id].length() > maxVel) {
            agentVel[id] = agentVel[id].normalized().times(maxVel);
        }
   
        agentAcc[id] = new Vec3(0,0,0);
        agentTime[id] = random(5);
        agentFrame[id] = int(random(kiwiFrames));
        agentDir[id] = atan2(agentVel[id].x, agentVel[id].z);
        isInfected[id] = false;
        infectedTimer[id] = 0;
        
    }
    infectedAgents = new ArrayList<Integer>();
    numInfected = 0;

    t = tbase;
}

//////////////// UPDATING FUNCTIONS ///////////////////////////////

void mutate(int id) {
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

void cure(int id) {
    numInfected--;
    isInfected[id] = false;
    infectedAgents.remove((Integer)id);
    infectedTimer[id] = 0;
}

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
Vec3 computeTTW(Vec3 aPos, Vec3 aVel, int infectScale) {
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
            if (dist <= sepMaxDist*2) {
                Vec3 sepForce = agentPos[id].minus(agentPos[jd]);
                float sepScaleInf = isInfected[jd] ? sepScale*15 : sepScale;
                dist = isInfected[id] ? dist*0.5 : dist;
                sepForce.mul(sepScaleInf/dist);
                sepForce.y = 0;
                // sepForce.clampToLength(maxAcc);
                acc.add(sepForce);
            }

            if (isInfected[jd] && !isInfected[id] && numInfected < maxInfected && dist < agentHBRad*1.5) {
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
            sepForce.mul(infectedRepelScale/(dist*0.5));
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

void update(float dt) {
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
        agentVel[id] = interpolate(agentVel[id], newV, 0.1);

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
        t = tbase-agentVel[id].length()*0.00001;
        if (t > 0.99) t = 0.99;
        if (t < 0.91) t = 0.93;
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
                agentPos[id].distanceTo(closestMoai[id]) < moaiAffectRad*moaiScale*1.5) {
                cure(id);
            } 
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
////////////// DRAW FUNCTIONS /////////////////////////////////////////////////////////

// debug / measuring drawing
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

// drawing borders of the scene
void drawFencesAndFloor() {
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

// draws infection for debugging and deciding
void drawInfection() {
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
void drawMoai() {
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

void keyReleased()
{
  camera.HandleKeyReleased();
}