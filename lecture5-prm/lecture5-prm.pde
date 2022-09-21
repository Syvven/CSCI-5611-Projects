//CSCI 5611 - Graph Search & Planning
//PRM Sample Code [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

/*
TODO:
  1. Add a function so that when you press the 'r' key, the obstacles move to
     new random locations with new random radii. Also, be sure to make a new
     PRM and plan a path over these new obstacles.
     [Hint: Look at setup() to see how I place obstacles, build the PRM, and run the BFS]
  2. Currently edge connections of any length are allowed. Update the connectNeighbors()
     function to only allow edges if their length is less than 200 pixels. What use is there
     for this? Why do you think people sometimes put a maximum length on PRM edges?
  3. The function, closestNode() is supposed to return the ID of the PRM node 
     that is closest to the passed-in point. However, it currently returns a 
     random node. Once you fix the function, you should see that clicking with 
     the mouse lets you select the red goal node.
  4. You can see we define a box obstacle with a top left corner, and a width and height.
     I have already written code to draw this box with the rect() command. Uncomment
     the code, to see the box drawn.
  5. For the PRM to be collision free wrt the box we need to make sure no nodes are
     inside and box, and that none of the between-none edges between nodes intersect the box:
       A. Complete in the pointInBox() routine in the CollisionLibrary
       B. Use pointInBox() inside generateRandomNodes() to ensure all PRM nodes
          generated are outside of the box
       C. Use the already existing rayBoxIntersect() to test the edges between 
          PRM nodes with the box
    Test each sub-step individually. If all three work, the planned path should
    be collision free with all of the circles and the box.
  6. Pressing the arrow keys will move the pink box. Update the code to make
    sure the PRM and the planned path get updated as the box moves.
    
Challenge:
  1. Add support for a list of rectangle obstacles.
  2. Let the user use the mouse to click and drag the obstacles.
*/


//A list of circle obstacles
static int numObstacles = 50;
Vec2 circlePos[] = new Vec2[numObstacles]; //Circle positions
float circleRad[] = new float[numObstacles];  //Circle radii

//A box obstacle
Vec2 boxTopLeft = new Vec2(100,100);
float boxW = 100;
float boxH = 250;

Vec2 startPos = new Vec2(100,500);
Vec2 goalPos = new Vec2(500,200);


void placeRandomObstacles(){
  //Initial obstacle position
  for (int i = 0; i < numObstacles; i++){
    circlePos[i] = new Vec2(random(50,950),random(50,700));
    circleRad[i] = (10+40*pow(random(1),3));
  }
}

int strokeWidth = 2;
void setup(){
  size(1024,768);
  placeRandomObstacles();
  buildPRM(circlePos, circleRad, boxTopLeft, boxW, boxH);
  runBFS(closestNode(startPos),closestNode(goalPos));
}

void draw(){
  //println("FrameRate:",frameRate);
  strokeWeight(1);
  background(200); //Grey background
  stroke(0,0,0);
  fill(255,255,255);
  
  
  //Draw the circle obstacles
  for (int i = 0; i < numObstacles; i++){
    Vec2 c = circlePos[i];
    float r = circleRad[i];
    circle(c.x,c.y,r*2);
  }
  
  //Draw the box obstacles
  //TODO: Uncomment this to draw the box
  //fill(250,200,200);
  //rect(boxTopLeft.x, boxTopLeft.y, boxW, boxH);
  
  //Draw PRM Nodes
  fill(0);
  for (int i = 0; i < numNodes; i++){
    circle(nodePos[i].x,nodePos[i].y,5);
  }
  
  //Draw graph
  stroke(100,100,100);
  strokeWeight(1);
  for (int i = 0; i < numNodes; i++){
    for (int j : neighbors[i]){
      line(nodePos[i].x,nodePos[i].y,nodePos[j].x,nodePos[j].y);
    }
  }
  
  //Draw Start and Goal
  fill(20,60,250);
  circle(nodePos[startNode].x,nodePos[startNode].y,20);
  //circle(startPos.x,startPos.y,20);
  fill(250,30,50);
  circle(nodePos[goalNode].x,nodePos[goalNode].y,20);
  //circle(goalPos.x,goalPos.y,20);
  
  //Draw Planned Path
  stroke(20,255,40);
  strokeWeight(5);
  for (int i = 0; i < path.size()-1; i++){
    int curNode = path.get(i);
    int nextNode = path.get(i+1);
    line(nodePos[curNode].x,nodePos[curNode].y,nodePos[nextNode].x,nodePos[nextNode].y);
  }
  
}

void keyPressed(){
  if (key == 'r'){
    //TODO: Randomize obstacle positions and radii
    //      Also, replan for these new obstacles.
  }
  
  if (keyCode == RIGHT){
    boxTopLeft.x += 10;
  }
  if (keyCode == LEFT){
    boxTopLeft.x -= 10;
  }
  if (keyCode == UP){
    boxTopLeft.y -= 10;
  }
  if (keyCode == DOWN){
    boxTopLeft.y += 10;
  }
}

int closestNode(Vec2 point){
  //TODO: Return the closest node the passed in point
  return int(random(numNodes));
}

void mousePressed(){
  goalPos = new Vec2(mouseX, mouseY);
  println("New Goal is",goalPos.x, goalPos.y);
  runBFS(closestNode(startPos),closestNode(goalPos));
}



/////////
// Point Intersection Tests
/////////

//Returns true if the point is inside a box
boolean pointInBox(Vec2 boxTopLeft, float boxW, float boxH, Vec2 pointPos){
  //TODO: Return true if the point is actually inside the box
  return false;
}

//Returns true if the point is inside a circle
boolean pointInCircle(Vec2 center, float r, Vec2 pointPos){
  float dist = pointPos.distanceTo(center);
  if (dist < r+2){ //small safety factor
    return true;
  }
  return false;
}

//Returns true if the point is inside a list of circle
boolean pointInCircleList(Vec2[] centers, float[] radii, Vec2 pointPos){
  for (int i = 0; i < numObstacles; i++){
    Vec2 center =  centers[i];
    float r = radii[i];
    if (pointInCircle(center,r,pointPos)){
      return true;
    }
  }
  return false;
}




/////////
// Ray Intersection Tests
/////////

class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

hitInfo rayBoxIntersect(Vec2 boxTopLeft, float boxW, float boxH, Vec2 ray_start, Vec2 ray_dir, float max_t){
  hitInfo hit = new hitInfo();
  hit.hit = true;
  
  float t_left_x, t_right_x, t_top_y, t_bot_y;
  t_left_x = (boxTopLeft.x - ray_start.x)/ray_dir.x;
  t_right_x = (boxTopLeft.x + boxW - ray_start.x)/ray_dir.x;
  t_top_y = (boxTopLeft.y - ray_start.y)/ray_dir.y;
  t_bot_y = (boxTopLeft.y + boxH - ray_start.y)/ray_dir.y;
  
  float t_max_x = max(t_left_x,t_right_x);
  float t_max_y = max(t_top_y,t_bot_y);
  float t_max = min(t_max_x,t_max_y); //When the ray exists the box
  
  float t_min_x = min(t_left_x,t_right_x);
  float t_min_y = min(t_top_y,t_bot_y);
  float t_min = max(t_min_x,t_min_y); //When the ray enters the box
  
  
  //The the box is behind the ray (negative t)
  if (t_max < 0){
    hit.hit = false;
    hit.t = t_max;
    return hit;
  }
  
  //The ray never hits the box
  if (t_min > t_max){
    hit.hit = false;
  }
  
  //The ray hits, but further out than max_t
  if (t_min > max_t){
    hit.hit = false;
  }
  
  hit.t = t_min;
  return hit;
}

hitInfo rayCircleIntesect(Vec2 center, float r, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  
  //Step 2: Compute W - a displacement vector pointing from the start of the line segment to the center of the circle
    Vec2 toCircle = center.minus(l_start);
    
    //Step 3: Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
    float a = 1;  //Length of l_dir (we normalized it)
    float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
    float c = toCircle.lengthSqr() - (r+strokeWidth)*(r+strokeWidth); //different of squared distances
    
    float d = b*b - 4*a*c; //discriminant 
    
    if (d >=0 ){ 
      //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
      //  ... this means t will be between 0 and the length of the line segment
      float t1 = (-b - sqrt(d))/(2*a); //Optimization: we only need the first collision
      float t2 = (-b + sqrt(d))/(2*a); //Optimization: we only need the first collision
      //println(hit.t,t1,t2);
      if (t1 > 0 && t1 < max_t){
        hit.hit = true;
        hit.t = t1;
      }
      else if (t1 < 0 && t2 > 0){
        hit.hit = true;
        hit.t = -1;
      }
      
    }
    
  return hit;
}

hitInfo rayCircleListIntesect(Vec2[] centers, float[] radii, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  hit.t = max_t;
  for (int i = 0; i < numObstacles; i++){
    Vec2 center = centers[i];
    float r = radii[i];
    
    hitInfo circleHit = rayCircleIntesect(center, r, l_start, l_dir, hit.t);
    if (circleHit.t > 0 && circleHit.t < hit.t){
      hit.hit = true;
      hit.t = circleHit.t;
    }
    else if (circleHit.hit && circleHit.t < 0){
      hit.hit = true;
      hit.t = -1;
    }
  }
  return hit;
}




/////////////////////////////////
// A Probabilistic Roadmap (PRM)
////////////////////////////////

static int numNodes = 100;

//The optimal path found along the PRM
ArrayList<Integer> path = new ArrayList();
int startNode, goalNode; //The actual node the PRM tries to connect do

//Represent our graph structure as 3 lists
ArrayList<Integer>[] neighbors = new ArrayList[numNodes];  //A list of neighbors can can be reached from a given node
Boolean[] visited = new Boolean[numNodes]; //A list which store if a given node has been visited
int[] parent = new int[numNodes]; //A list which stores the best previous node on the optimal path to reach this node

//The PRM uses the above graph, along with a list of node positions
Vec2[] nodePos = new Vec2[numNodes];

//Generate non-colliding PRM nodes
void generateRandomNodes(Vec2[] circleCenters, float[] circleRadii, Vec2 boxTopLeft, float boxW, float boxH){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(width),random(height));
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,randPos);
    while (insideAnyCircle){
      randPos = new Vec2(random(width),random(height));
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,randPos);
    }
    nodePos[i] = randPos;
  }
}


//Set which nodes are connected to which neighbors based on PRM rules
void connectNeighbors(){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntesect(circlePos, circleRad, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
}

//Build the PRM
// 1. Generate collision-free nodes
// 2. Connect mutually visible nodes as graph neighbors
void buildPRM(Vec2[] circleCenters, float[] circleRadii, Vec2 boxTopLeft, float boxW, float boxH){
  generateRandomNodes(circleCenters, circleRadii, boxTopLeft, boxW, boxH);
  connectNeighbors();
}

//BFS
void runBFS(int startID, int goalID){
  startNode = startID;
  goalNode = goalID;
  ArrayList<Integer> fringe = new ArrayList();  //Make a new, empty fringe
  path = new ArrayList(); //Reset path
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  println("\nBeginning Search");
  
  visited[startID] = true;
  fringe.add(startID);
  println("Adding node", startID, "(start) to the fringe.");
  println(" Current Fring: ", fringe);
  
  while (fringe.size() > 0){
    int currentNode = fringe.get(0);
    fringe.remove(0);
    if (currentNode == goalID){
      println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      if (!visited[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        fringe.add(neighborNode);
        println("Added node", neighborNode, "to the fringe.");
        println(" Current Fringe: ", fringe);
      }
    } 
  }
  
  print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  print(goalID, " ");
  while (prevNode >= 0){
    print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  print("\n");
}




/////////////////////////////////
// Vec2 Library
////////////////////////////////

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
  
  public float lengthSqr(){
    return x*x+y*y;
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

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}
