//Change the below parameters to change the scenario/roadmap size
static int numNodes  = 200;
  
//A list of circle obstacles
static int maxNumObstacles = 1000;
static int initObstacles = 250;
int numObstacles = initObstacles;
boolean[] validCircles = new boolean[maxNumObstacles];
Vec2 circlePosArr[] = new Vec2[maxNumObstacles]; //Circle positions
float circleRadArr[] = new float[maxNumObstacles];  //Circle radii

static int maxNumNodes = 1000;
Vec2[] nodePos = new Vec2[maxNumNodes];

ArrayList<Integer> curPath = new ArrayList<Integer>();

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, Vec2[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(-sceneX*0.5, sceneX*0.5),random(-sceneZ*0.5, sceneZ*0.5));
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,2);
    //boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideAnyCircle){
      randPos = new Vec2(random(-sceneX*0.5, sceneX*0.5),random(-sceneZ*0.5, sceneZ*0.5));
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,2);
      //insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    nodePos[i] = randPos;
  }
}

int numCollisions;
float pathLength;
boolean reachedGoal;
void pathQuality(){
  Vec2 dir;
  hitInfo hit;
  float segmentLength;
  numCollisions = 9999; pathLength = 9999;
  if (curPath.size() == 1 && curPath.get(0) == -1) return; //No path found  
  
  pathLength = 0; numCollisions = 0;
  
  if (curPath.size() == 2){ //Path found with no nodes (direct start-to-goal path)
    segmentLength = startPos.distanceTo(goalPos);
    pathLength += segmentLength;
    dir = goalPos.minus(startPos).normalized();
    hit = rayCircleListIntersect(circlePosArr, circleRadArr, numObstacles, startPos, dir, segmentLength);
    if (hit.hit) numCollisions += 1;
    return;
  }
  
  segmentLength = startPos.distanceTo(newNodePos[curPath.get(1)]);
  pathLength += segmentLength;
  dir = newNodePos[curPath.get(1)].minus(startPos).normalized();
  hit = rayCircleListIntersect(circlePosArr, circleRadArr, numObstacles, startPos, dir, segmentLength);
  if (hit.hit) numCollisions += 1;
  
  
  for (int i = 1; i < curPath.size()-2; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    segmentLength = newNodePos[curNode].distanceTo(newNodePos[nextNode]);
    pathLength += segmentLength;
    
    dir = newNodePos[nextNode].minus(newNodePos[curNode]).normalized();
    hit = rayCircleListIntersect(circlePosArr, circleRadArr, numObstacles, nodePos[curNode], dir, segmentLength);
    if (hit.hit) numCollisions += 1;
  }
  
  int lastNode = curPath.get(curPath.size()-2);
  segmentLength = newNodePos[lastNode].distanceTo(goalPos);
  pathLength += segmentLength;
  dir = goalPos.minus(newNodePos[lastNode]).normalized();
  hit = rayCircleListIntersect(circlePosArr, circleRadArr, numObstacles, nodePos[lastNode], dir, segmentLength);
  if (hit.hit) numCollisions += 1;
}

Vec2 sampleFreePos(){
  Vec2 randPos = new Vec2(random(width),random(height));
  boolean insideAnyCircle = pointInCircleList(circlePosArr,circleRadArr,numObstacles,randPos,2);
  while (insideAnyCircle){
    randPos = new Vec2(random(width),random(height));
    insideAnyCircle = pointInCircleList(circlePosArr,circleRadArr,numObstacles,randPos,2);
  }
  return randPos;
}

void testPRM(){
    long startTime, endTime;
    curPath.clear();

    generateRandomNodes(numNodes, circlePosArr, circleRadArr);
    connectNeighbors(circlePosArr, circleRadArr, numObstacles, nodePos, numNodes);
  
//   startTime = System.nanoTime();
//   curPath = planPath(startPos, goalPos, circlePosArr, circleRadArr, numObstacles, nodePos, numNodes, 1);
//   endTime = System.nanoTime();
//   pathQuality();
  
//   println("BFS Path:");
//   println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", int((endTime-startTime)/1000),
//           " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions, '\n');

    startTime = System.nanoTime();
    curPath = planPath(startPos, goalPos, circlePosArr, circleRadArr, numObstacles, nodePos, numNodes);
    endTime = System.nanoTime();
    pathQuality();

    println("A* Path:");
    println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", int((endTime-startTime)/1000),
            " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions, '\n');
}

//Returns true if the point is inside a circle
//You must consider a point as colliding if it's distance is <= eps
boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps){
    float dist = pointPos.distanceTo(center);
    if (dist < r+eps){ //small safety factor
        return true;
    }
    return false;
}

//Returns true if the point is inside a list of circle
//You must consider a point as colliding if it's distance is <= eps
boolean pointInCircleList(Vec2[] centers, float[] radii, int numObstacles, Vec2 pointPos, float eps){
    for (int i = 0; i < numObstacles; i++){
        if (validCircles[i]) {
            Vec2 center =  centers[i];
            float r = radii[i];
            if (pointInCircle(center,r,pointPos, eps)){
                return true;
            }
        } 
    }
    return false;
}