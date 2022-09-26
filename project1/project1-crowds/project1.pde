// Project 1 Part 2
/////////////////////////////

// scene dimensions
float sceneX = 1500;
float sceneY = 1500;
float sceneZ = 1500;

// model info
int kiwiFrames = 4;
PShape[] shapes = new PShape[kiwiFrames];
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
float kiwiYOffset = -0.71*kiwiScale; // model starts below floor, offset height a bit to have it normal

// agent info
Vec2 agentVel = new Vec2(1,1);
Vec3 agentPos = new Vec3(-sceneX/2+25,kiwiYOffset,-sceneZ/2+25);
Vec2 startPos = new Vec2(-sceneX/2+25,-sceneZ/2+25);
Vec2 goalPos = new Vec2(sceneX/2-25, sceneZ/2-25);
float agentColRad = 2.5*0.5*kiwiScale;

float kiwiDir = 0;
float goalSpeed = 100;

// node stuff

// obstacles
ArrayList<Vec3> circleVel = new ArrayList<Vec3>();
ArrayList<Vec3> circlePos = new ArrayList<Vec3>();
ArrayList<Float> circleDrawRad = new ArrayList<Float>();
ArrayList<Float> circleColRad = new ArrayList<Float>();
ArrayList<Vec3> circleColor = new ArrayList<Vec3>();
float obstacleWallPadding = 75;

Camera camera;

// useful things
float ninety, oneeighty, twoseventy, threesixty;
float epsilon = 1e-6;
float tbase = 0.90;
float t;

// drawing info
int strokeWidth = 2;
PImage conkcrete;

// key state variables
boolean moveObjects = false;
boolean mouseCast = false;
boolean paused = true;
Vec3 mouseRay, mouseOrig;

// pathing
int indexCounter;
int startNode;
int currNode;
Vec2 currPos;
int nextNode;
Vec2 nextPos;
int goalNode;

void setup() {
    size(1200, 1200, P3D);
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

    placeRandomObstacles();

    String base = "data/kiwi";
    for (int i = 1; i <= kiwiFrames; i++) {
        String file = base + i + ".obj";
        shapes[i-1] = loadShape(file);
    }
    times[0] = 5; times[2] = 5;
    times[1] = 2; times[3] = 2;
    
    sphereDetail(10);

    t = tbase;
    for (int i = 0; i < maxNumObstacles; i++) {
        validCircles[i] = false;
    } 

    initiatePathfinding();
}

void placeRandomObstacles(){
  //Initial obstacle position
  circleDrawRad.clear();
  circlePos.clear();
  circleColor.clear();
  circleDrawRad.add(30.0); //Make the first obstacle big
  circleColRad.add(30.0+agentColRad);
  circlePos.add(new Vec3(
      random(-sceneX*0.5+obstacleWallPadding,sceneX*0.5-obstacleWallPadding),
      -circleDrawRad.get(0),
      random(-sceneZ*0.5,sceneZ*0.5)
  ));
  circleColor.add(new Vec3(
      random(255),
      random(255),
      random(255)
  ));

  for (int i = 1; i < numObstacles; i++){
    float rad = (10+40*pow(random(1),3));
    circleDrawRad.add(rad);
    circleColRad.add(rad+agentColRad);
    circlePos.add(new Vec3(
        random(-sceneX*0.5+obstacleWallPadding,sceneX*0.5-obstacleWallPadding),
        -circleDrawRad.get(i),
        random(-sceneZ*0.5+obstacleWallPadding,sceneZ*0.5-obstacleWallPadding)
    ));
    circleColor.add(new Vec3(
        random(255),
        random(255),
        random(255)
    ));
  }
}

void reset() {
    placeRandomObstacles();
    kiwiTime = 0;
    kiwiSwitchFrame = 0;
    currFrame = 0;
    initiatePathfinding();
}

void initiatePathfinding() {
    for (int i = 0; i < circlePos.size(); i++) {
        Vec3 pos = circlePos.get(i);
        float rad = circleColRad.get(i);
        if (pos.y > -agentColRad*2-circleDrawRad.get(i)) {
            validCircles[i] = true;
        } 
        circlePosArr[i] = new Vec2(pos.x, pos.z);
        circleRadArr[i] = rad;
    }
    testPRM();
    println(curPath);
    indexCounter = 1;
    startNode = curPath.get(0);
    currNode = startNode; 
    nextNode = curPath.get(1);
    goalNode = curPath.get(curPath.size()-1);
    currPos = nodePos[currNode];
    nextPos = nodePos[nextNode];
    agentVel = nextPos.minus(currPos).normalized().times(goalSpeed);
}