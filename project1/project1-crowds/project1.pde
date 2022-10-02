// Project 1 Part 2 -- hend0800, cheon051
/////////////////////////////
// SOURCES
// Camera Code: Professor Guy -- Modified by hend0800
// Cylinder: https://vormplus.be/full-articles/drawing-a-cylinder-with-processing 
// Kiwi: Lauren Oliver
// Planet Textures: http://planetpixelemporium.com/planets.html
// Spaceship: https://www.cgtrader.com/free-3d-models/space/spaceship/free-flying-saucer

// scene dimensions
float sceneX = 3000;
float sceneY = 3000;
float sceneZ = 3000;

// model info
int kiwiFrames = 4;
PShape[] shapes = new PShape[kiwiFrames];
PImage[] textures = new PImage[10];
PShape[] planets = new PShape[10];
int[] times = new int[kiwiFrames];
PShape kiwi;
int kiwiScale = 10;
float kiwiWidth = 1*kiwiScale; // units // Scale(10) --> 10 units
float kiwiLength = 2.5*kiwiScale; // units // Scale(10) --> 22.5 units
float kiwiHeight = 1.75*kiwiScale; // units // Scale(10) --> 17.5 units
float kiwiTime = 0;
int kiwiSwitchFrame = 0;
int currFrame = 0;
float kiwi_framerate = 24;
// float kiwiYOffset = -0.71*kiwiScale; // model starts below floor, offset height a bit to have it normal
float kiwiYOffset = 0; // this one because no need for floor
PImage[] skybox = new PImage[6];
float kiwiInShipHeight = -305;

// agent info
Vec2 lastVel = new Vec2(0,0);
Vec3 lastPos = new Vec3(0,0,0);
Vec2 agentVel = new Vec2(1,1);
Vec2 agentFinalVel = agentVel;
Vec3 agentPos = new Vec3(-sceneX/2+25,kiwiInShipHeight,-sceneZ/2+25);
Vec2 agentPos2 = new Vec2(agentPos.x, agentPos.z);
Vec2 startPos = new Vec2(-sceneX/2+25,-sceneZ/2+25);
Vec2 absStartPos = startPos;
Vec2 goalPos = new Vec2(sceneX/2-25, sceneZ/2-25);
float agentColRad = 2.5*0.5*kiwiScale;
float agentDir = 0;

Vec2 backDir = agentVel.times(-1);
Vec2 forwardDir2 = agentVel;
Vec2 backVel = agentVel.times(-1);

float kiwiDir = 0;
float goalSpeed = 100;

// obstacles
ArrayList<Vec3> circleVel = new ArrayList<Vec3>();
ArrayList<Vec3> circlePos = new ArrayList<Vec3>();
ArrayList<Float> circleDrawRad = new ArrayList<Float>();
ArrayList<Float> circleColRad = new ArrayList<Float>();
ArrayList<Vec3> circleColor = new ArrayList<Vec3>();
ArrayList<PShape> circleShape = new ArrayList<PShape>();
ArrayList<Float> circleRot = new ArrayList<Float>();
ArrayList<Float> circleRotRate = new ArrayList<Float>();
ArrayList<Float[]> circleTilt = new ArrayList<Float[]>();
float obstacleWallPadding = 75;

// kiwi particles
ArrayList<Vec3> particlePos = new ArrayList<Vec3>();
ArrayList<Vec3> particleVel = new ArrayList<Vec3>();
ArrayList<Vec3> particleCol = new ArrayList<Vec3>();
Vec3 startColor = new Vec3(254, 240, 1);
Vec3 endColor = new Vec3(240, 5, 5);
Vec3 smoke = new Vec3(50, 50, 50);
FloatList particleLife = new FloatList();
int maxParticles = 200;
int numParticles = 0;
float genRate = 200;
float coneRad = radians(10);
float maxLife = 0.5;

Camera camera;

// useful things
float ninety, oneeighty, twoseventy, threesixty;
float epsilon = 2;
float t = 0.91;

// drawing info
int strokeWidth = 2;
PImage conkcrete;
PShape back;
PShape ship;

// key state variables
boolean moveObjects = false;
boolean mouseCast = false;
boolean paused = true;
boolean is3d = true;
boolean cameraFollowAgent = false;
boolean firstPerson = false;
float agentBackY = -75;
boolean agentBackYUp, agentBackYDown;
boolean atGoal = false;
boolean stopParticles = false;
boolean kiwiOnGround = false;
boolean noGoal = false;
Vec3 mouseRay, mouseOrig;
Vec2 shipMove = new Vec2(0,0);
Vec2 shipMoveNeg = new Vec2(0,0);
Vec2 shipMovePos = new Vec2(0,0);

Vec2 cameraForward = new Vec2(0,0);
Vec2 cameraBackward = new Vec2(0,0);
Vec2 cameraLeft = new Vec2(0,0);
Vec2 cameraRight = new Vec2(0,0);

// pathing
int indexCounter;
int startNode;
int currNode;
Vec2 currPos;
int nextNode;
Vec2 nextPos;
int goalNode;

void setup() {
    size(1300, 1300, P3D);
    surface.setTitle("CSCI 5611 Project 1 Part 2");
    surface.setResizable(true);
    surface.setLocation(500,500);
    strokeWeight(2);

    camera = new Camera();

    // useful things
    oneeighty = radians(180);
    ninety = radians(90);
    twoseventy = radians(270);
    threesixty = radians(360);

    // image/model loading
    conkcrete = loadImage("data/conkcrete.jpg");

    ship = loadShape("data/Low_poly_UFO.obj");

    textures[0] = loadImage("data/sun.jpg");
    textures[1] = loadImage("data/mercury.jpg");
    textures[2] = loadImage("data/venus.jpg");
    textures[3] = loadImage("data/earth.jpg");
    textures[4] = loadImage("data/mars.jpg");
    textures[5] = loadImage("data/saturn.jpg");
    textures[6] = loadImage("data/neptune.jpg");
    textures[7] = loadImage("data/jupiter.jpg");
    textures[8] = loadImage("data/pluto.jpg");
    textures[9] = loadImage("data/uranus.jpg");

    // skybox[0] = loadImage("data/spacebox1.jpg");
    // skybox[1] = loadImage("data/spacebox2.jpg");
    // skybox[2] = loadImage("data/spacebox3.jpg");
    // skybox[3] = loadImage("data/spacebox4.jpg");
    // skybox[4] = loadImage("data/spacebox5.jpg");
    // skybox[5] = loadImage("data/spacebox6.jpg");

    // back = loadImage("data/back.jpg");
    
    noStroke();
    sphereDetail(200);
    back = createShape(SPHERE, 4000);
    PImage text = loadImage("data/blackhole.jpg");
    back.setTexture(text);

    placeRandomObstacles();

    String base = "data/kiwi";
    for (int i = 1; i <= kiwiFrames; i++) {
        String file = base + i + ".obj";
        shapes[i-1] = loadShape(file);
    }
    times[0] = 5; times[2] = 5;
    times[1] = 2; times[3] = 2;

    initiatePathfinding();
}

void randomizeStart() {
    startPos = new Vec2(random(-sceneX*0.5, sceneX*0.5), random(-sceneZ*0.5, sceneZ*0.5));
    while (startOrGoalInCircleList(circlePosArr, circleRadArr, numObstacles, startPos, epsilon)) {
        startPos = new Vec2(random(-sceneX*0.5, sceneX*0.5), random(-sceneZ*0.5, sceneZ*0.5));
    }
    agentPos.x = startPos.x; agentPos.z = startPos.y;
    agentPos2 = startPos;
}

void randomizeGoal() {
    goalPos = new Vec2(random(-sceneX*0.5, sceneX*0.5), random(-sceneZ*0.5, sceneZ*0.5));
    while (startOrGoalInCircleList(circlePosArr, circleRadArr, numObstacles, startPos, epsilon)) {
        goalPos = new Vec2(random(-sceneX*0.5, sceneX*0.5), random(-sceneZ*0.5, sceneZ*0.5));
    }
}

void placeRandomObstacles(){
    //Initial obstacle position
    sphereDetail(15);
    fill(255);
    noStroke();
    // clear things in case of reset
    circleDrawRad.clear();
    circlePos.clear();
    circleColor.clear();
    circleRot.clear();
    circleRotRate.clear();
    circleColRad.clear();
    circleShape.clear();
    circleTilt.clear();

    circleDrawRad.add(30.0); //Make the first obstacle big
    circleColRad.add(30.0+agentColRad);
    circlePos.add(new Vec3(
        random(-sceneX*0.5+obstacleWallPadding,sceneX*0.5-obstacleWallPadding),
        random(-100,100),
        random(-sceneZ*0.5,sceneZ*0.5)
    ));
    PShape globe = createShape(SPHERE, 30);
    globe.setTexture(textures[int(random(10))]);
    circleShape.add(globe);
    validCircles[0] = false;
    circleRot.add(random(0, radians(359)));
    circleRotRate.add(random(0.001, 0.05));
    circleTilt.add(new Float[]{random(-radians(45), radians(45)), random(-radians(45), radians(45))});

    for (int i = 1; i < numObstacles; i++){
        float rad = (10+40*pow(random(1),3));
        circleDrawRad.add(rad);
        circleColRad.add(rad+agentColRad);
        circlePos.add(new Vec3(
            random(-sceneX*0.5+obstacleWallPadding,sceneX*0.5-obstacleWallPadding),
            random(-100, 100),
            random(-sceneZ*0.5+obstacleWallPadding,sceneZ*0.5-obstacleWallPadding)
        ));
        globe = createShape(SPHERE, rad);
        globe.setTexture(textures[int(random(10))]);
        circleShape.add(globe);
        validCircles[i] = false;
        circleRot.add(random(0, radians(359)));
        circleRotRate.add(random(0.001, 0.05));
        circleTilt.add(new Float[]{random(-radians(45), radians(45)), random(-radians(45), radians(45))});
    }
    strokeWeight(strokeWidth);
}

void reset() {
    placeRandomObstacles();
    initiatePathfinding();
    kiwiTime = 0;
    kiwiSwitchFrame = 0;
    currFrame = 0;
    agentPos = new Vec3(startPos.x, kiwiInShipHeight, startPos.y);
    Vec2 agentFinalVel = agentVel;
    Vec2 backDir = agentVel.times(-1);
    Vec2 backVel = agentVel.times(-1);
    atGoal = false;
    stopParticles = false;
    kiwiOnGround = false;
    particlePos = new ArrayList<Vec3>();
    particleVel = new ArrayList<Vec3>();
    particleCol = new ArrayList<Vec3>();
    particleLife = new FloatList();
    numParticles = 0;
}

void initiatePathfinding() {
    for (int i = 0; i < circlePos.size(); i++) {
        Vec3 pos = circlePos.get(i);
        float rad = circleColRad.get(i);
        if ((abs(pos.y)-circleColRad.get(i)) < agentColRad) {
            validCircles[i] = true;
        } 
        circlePosArr[i] = new Vec2(pos.x, pos.z);
        circleRadArr[i] = rad;
    }

    // if random start and goal, uncomment this
    randomizeStart();
    randomizeGoal();

    absStartPos.x = startPos.x; absStartPos.y = startPos.y;

    testPRM();
    int iters = 0;
    while (curPath.size() == 1 && iters != 3) {
        testPRM();
        iters++;
    }
    if (iters == 3) {
        reset();
        return;
    }
    noGoal = false;
    indexCounter = 1;
    nextNode = curPath.get(1);
    goalNode = curPath.get(curPath.size()-1);
    nextPos = newNodePos[nextNode];
    agentVel = nextPos.minus(startPos).normalized().times(goalSpeed);
}