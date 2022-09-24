/* autogenerated by Processing revision 1286 on 2022-09-24 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.Comparator;
import java.util.PriorityQueue;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Proj1_Test extends PApplet {

//CSCI 5611 - Graph Search & Planning
//PRM Sample Code [Proj 1]
//Instructor: Stephen J. Guy <sjguy@umn.edu>

//This is a test harness designed to help you test & debug your PRM.

//USAGE:
// On start-up your PRM will be tested on a random scene and the results printed
// Left clicking will set a red goal, right clicking the blue start
// The arrow keys will move the circular obstacle with the heavy outline
// Pressing 'r' will randomize the obstacles and re-run the tests

//Change the below parameters to change the scenario/roadmap size
int numObstacles = 100;
int numNodes  = 100;
  
  
//A list of circle obstacles
static int maxNumObstacles = 1000;
Vec2 circlePos[] = new Vec2[maxNumObstacles]; //Circle positions
float circleRad[] = new float[maxNumObstacles];  //Circle radii

Vec2 startPos = new Vec2(100,500);
Vec2 goalPos = new Vec2(500,200);

static int maxNumNodes = 1000;
Vec2[] nodePos = new Vec2[maxNumNodes];

//Generate non-colliding PRM nodes
 public void generateRandomNodes(int numNodes, Vec2[] circleCenters, float[] circleRadii){
  for (int i = 0; i < numNodes; i++){
    Vec2 randPos = new Vec2(random(width),random(height));
    boolean insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,2);
    //boolean insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    while (insideAnyCircle){
      randPos = new Vec2(random(width),random(height));
      insideAnyCircle = pointInCircleList(circleCenters,circleRadii,numObstacles,randPos,2);
      //insideBox = pointInBox(boxTopLeft, boxW, boxH, randPos);
    }
    nodePos[i] = randPos;
  }
}

 public void placeRandomObstacles(int numObstacles){
  //Initial obstacle position
  for (int i = 0; i < numObstacles; i++){
    circlePos[i] = new Vec2(random(50,950),random(50,700));
    circleRad[i] = (10+40*pow(random(1),3));
  }
  circleRad[0] = 30; //Make the first obstacle big
}

ArrayList<Integer> curPath;

int strokeWidth = 2;
 public void setup(){
  /* size commented out by preprocessor */;
  testPRM();
}

int numCollisions;
float pathLength;
boolean reachedGoal;
 public void pathQuality(){
  Vec2 dir;
  hitInfo hit;
  float segmentLength;
  numCollisions = 9999; pathLength = 9999;
  if (curPath.size() == 1 && curPath.get(0) == -1) return; //No path found  
  
  pathLength = 0; numCollisions = 0;
  
  if (curPath.size() == 0 ){ //Path found with no nodes (direct start-to-goal path)
    segmentLength = startPos.distanceTo(goalPos);
    pathLength += segmentLength;
    dir = goalPos.minus(startPos).normalized();
    hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, startPos, dir, segmentLength);
    if (hit.hit) numCollisions += 1;
    return;
  }
  
  segmentLength = startPos.distanceTo(nodePos[curPath.get(0)]);
  pathLength += segmentLength;
  dir = nodePos[curPath.get(0)].minus(startPos).normalized();
  hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, startPos, dir, segmentLength);
  if (hit.hit) numCollisions += 1;
  
  
  for (int i = 0; i < curPath.size()-1; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    segmentLength = nodePos[curNode].distanceTo(nodePos[nextNode]);
    pathLength += segmentLength;
    
    dir = nodePos[nextNode].minus(nodePos[curNode]).normalized();
    hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, nodePos[curNode], dir, segmentLength);
    if (hit.hit) numCollisions += 1;
  }
  
  int lastNode = curPath.get(curPath.size()-1);
  segmentLength = nodePos[lastNode].distanceTo(goalPos);
  pathLength += segmentLength;
  dir = goalPos.minus(nodePos[lastNode]).normalized();
  hit = rayCircleListIntersect(circlePos, circleRad, numObstacles, nodePos[lastNode], dir, segmentLength);
  if (hit.hit) numCollisions += 1;
}

 public Vec2 sampleFreePos(){
  Vec2 randPos = new Vec2(random(width),random(height));
  boolean insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos,2);
  while (insideAnyCircle){
    randPos = new Vec2(random(width),random(height));
    insideAnyCircle = pointInCircleList(circlePos,circleRad,numObstacles,randPos,2);
  }
  return randPos;
}

 public void testPRM(){
  long startTime, endTime;
  
  placeRandomObstacles(numObstacles);
  
  startPos = sampleFreePos();
  goalPos = sampleFreePos();

  generateRandomNodes(numNodes, circlePos, circleRad);
  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes);
  
  startTime = System.nanoTime();
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes, false);
  endTime = System.nanoTime();
  pathQuality();
  
  println("BFS Path:");
  println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", PApplet.parseInt((endTime-startTime)/1000),
          " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions, '\n');

  startTime = System.nanoTime();
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes, true);
  endTime = System.nanoTime();
  pathQuality();

  println("A* Path:");
  println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", PApplet.parseInt((endTime-startTime)/1000),
          " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions, '\n');
}

 public void draw(){
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
  //Draw the first circle a little special b/c the user controls it
  fill(240);
  strokeWeight(2);
  circle(circlePos[0].x,circlePos[0].y,circleRad[0]*2);
  strokeWeight(1);
  
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
  //circle(nodePos[startNode].x,nodePos[startNode].y,20);
  circle(startPos.x,startPos.y,20);
  fill(250,30,50);
  //circle(nodePos[goalNode].x,nodePos[goalNode].y,20);
  circle(goalPos.x,goalPos.y,20);
  
  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
  
  //Draw Planned Path
  stroke(20,255,40);
  strokeWeight(5);
  if (curPath.size() == 0){
    line(startPos.x,startPos.y,goalPos.x,goalPos.y);
    return;
  }
  line(startPos.x,startPos.y,nodePos[curPath.get(0)].x,nodePos[curPath.get(0)].y);
  for (int i = 0; i < curPath.size()-1; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    line(nodePos[curNode].x,nodePos[curNode].y,nodePos[nextNode].x,nodePos[nextNode].y);
  }
  line(goalPos.x,goalPos.y,nodePos[curPath.get(curPath.size()-1)].x,nodePos[curPath.get(curPath.size()-1)].y);
  
}

boolean shiftDown = false;
 public void keyPressed(){
  if (key == 'r'){
    testPRM();
    return;
  }
  
  if (keyCode == SHIFT){
    shiftDown = true;
  }
  
  float speed = 10;
  if (shiftDown) speed = 30;
  if (keyCode == RIGHT){
    circlePos[0].x += speed;
  }
  if (keyCode == LEFT){
    circlePos[0].x -= speed;
  }
  if (keyCode == UP){
    circlePos[0].y -= speed;
  }
  if (keyCode == DOWN){
    circlePos[0].y += speed;
  }
  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, numNodes);
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes);
}

 public void keyReleased(){
  if (keyCode == SHIFT){
    shiftDown = false;
  }
}

 public void mousePressed(){
  if (mouseButton == RIGHT){
    startPos = new Vec2(mouseX, mouseY);
    //println("New Start is",startPos.x, startPos.y);
  }
  else{
    goalPos = new Vec2(mouseX, mouseY);
    //println("New Goal is",goalPos.x, goalPos.y);
  }

  long startTime = System.nanoTime();
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes, false);
  long endTime = System.nanoTime();
  pathQuality();
  
  println("BFS Path:");
  println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", PApplet.parseInt((endTime-startTime)/1000),
          " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions, '\n');

  startTime = System.nanoTime();
  curPath = planPath(startPos, goalPos, circlePos, circleRad, numObstacles, nodePos, numNodes, true);
  endTime = System.nanoTime();
  pathQuality();
  
  println("A* Path:");
  println("Nodes:", numNodes," Obstacles:", numObstacles," Time (us):", PApplet.parseInt((endTime-startTime)/1000),
          " Path Len:", pathLength, " Path Segment:", curPath.size()+1,  " Num Collisions:", numCollisions, '\n');
}
// //Compute collision tests. Code from the in-class exercises may be helpful ehre.

// //Returns true if the point is inside a circle
// //You must consider a point as colliding if it's distance is <= eps
// boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps){
//   return false;
// }

// //Returns true if the point is inside a list of circle
// //You must consider a point as colliding if it's distance is <= eps
// boolean pointInCircleList(Vec2[] centers, float[] radii, int numObstacles, Vec2 pointPos, float eps){
//   return false;
// }


// class hitInfo{
//   public boolean hit = false;
//   public float t = 9999999;
// }

// hitInfo rayCircleIntersect(Vec2 center, float r, Vec2 l_start, Vec2 l_dir, float max_t){
//   hitInfo hit = new hitInfo();
//   return hit;
// }

// hitInfo rayCircleListIntersect(Vec2[] centers, float[] radii,  int numObstacles, Vec2 l_start, Vec2 l_dir, float max_t){
//   hitInfo hit = new hitInfo();
//   return hit;
// }
//You will only be turning in this file
//Your solution will be graded based on it's runtime (smaller is better), 
//the optimality of the path you return (shorter is better), and the
//number of collisions along the path (it should be 0 in all cases).

//You must provide a function with the following prototype:
// ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes);
// Where: 
//    -startPos and goalPos are 2D start and goal positions
//    -centers and radii are arrays specifying the center and radius of obstacles
//    -numObstacles specifies the number of obstacles
//    -nodePos is an array specifying the 2D position of roadmap nodes
//    -numNodes specifies the number of nodes in the PRM
// The function should return an ArrayList of node IDs (indexes into the nodePos array).
// This should provide a collision-free chain of direct paths from the start position
// to the position of each node, and finally to the goal position.
// If there is no collision-free path between the start and goal, return an ArrayList with
// the 0'th element of "-1".

// Your code can safely make the following assumptions:
//   - The function connectNeighbors() will always be called before planPath()
//   - The variable maxNumNodes has been defined as a large static int, and it will
//     always be bigger than the numNodes variable passed into planPath()
//   - None of the positions in the nodePos array will ever be inside an obstacle
//   - The start and the goal position will never be inside an obstacle

// There are many useful functions in CollisionLibrary.pde and Vec2.pde
// which you can draw on in your implementation. Please add any additional 
// functionality you need to this file (PRM.pde) for compatabilty reasons.

// Here we provide a simple PRM implementation to get you started.
// Be warned, this version has several important limitations.
// For example, it uses BFS which will not provide the shortest path.
// Also, it (wrongly) assumes the nodes closest to the start and goal
// are the best nodes to start/end on your path on. Be sure to fix 
// these and other issues as you work on this assignment. This file is
// intended to illustrate the basic set-up for the assignmtent, don't assume 
// this example funcationality is correct and end up copying it's mistakes!).




//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node
Vec2[] obstCenters;
float[] obstRadii;
int numObst;

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
 public void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  obstCenters = centers;
  obstRadii = radii;
  numObst = numObstacles;
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = nodePos[j].minus(nodePos[i]).normalized();
      float distBetween = nodePos[i].distanceTo(nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      }
    }
  }
}

//This is probably a bad idea and you shouldn't use it...
 public int closestNode(Vec2 point, Vec2[] nodePos, int numNodes){
  int closestID = -1;
  float minDist = 999999;
  for (int i = 0; i < numNodes; i++){
    float dist = nodePos[i].distanceTo(point);
    Vec2 dir = point.minus(nodePos[i]).normalized();
    hitInfo hit = rayCircleListIntersect(obstCenters, obstRadii, numObst, nodePos[i], dir, dist);
    if (dist < minDist && !hit.hit){
      closestID = i;
      minDist = dist;
    }
  }
  return closestID;
}

 public ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  int startID = closestNode(startPos, nodePos, numNodes);
  int goalID = closestNode(goalPos, nodePos, numNodes);
  
  // BFS
  // path = runBFS(nodePos, numNodes, startID, goalID);

  // // DFS --> Fails sometimes dont use this
  // path = runIDDFS(neighbors, startID, goalID);

  // A*
  path = runAStar(nodePos, numNodes, startID, goalID);
  
  return path;
}

 public ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes, boolean debug){
  ArrayList<Integer> path = new ArrayList();
  
  int startID = closestNode(startPos, nodePos, numNodes);
  int goalID = closestNode(goalPos, nodePos, numNodes);
  
  if (debug) {
    // A*
    path = runAStar(nodePos, numNodes, startID, goalID);
  } else {
    // BFS
    path = runBFS(nodePos, numNodes, startID, goalID);
  }
  
  return path;
}

//BFS (Breadth First Search)
 public ArrayList<Integer> runBFS(Vec2[] nodePos, int numNodes, int startID, int goalID){
  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
  ArrayList<Integer> path = new ArrayList();

  if (startID == -1 || goalID == -1) {
    path.add(0, -1);
    return path;
  }

  if (startID == goalID) {
    path.add(0, startID);
    return path;
  }

  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");
  
  visited[startID] = true;
  fringe.add(startID);
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  
  while (fringe.size() > 0){
    int currentNode = fringe.get(0);
    fringe.remove(0);
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      if (!visited[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        fringe.add(neighborNode);
        //println("Added node", neighborNode, "to the fringe.");
        //println(" Current Fringe: ", fringe);
      }
    } 
  }
  
  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
}

class Node {
  public Float cost;
  public int id;

  public Node(int id, float cost) {
    this.id = id;
    this.cost = cost;
  }
}

 public float heuristic1(Vec2 currNode, Vec2 nextNode, Vec2 goalNode) {
  return currNode.distanceTo(nextNode) + nextNode.distanceTo(goalNode);
}

 public ArrayList<Integer> runAStar(Vec2[] nodePos, int numNodes, int startID, int goalID) {
  Comparator<Node> compare = new Comparator<Node>() {
    @Override
    public int compare(Node n1, Node n2) {
      return n1.cost.compareTo(n2.cost);
    }
  };
  
  PriorityQueue<Node> fringe = new PriorityQueue<Node>(numNodes, compare);
  ArrayList<Integer> path = new ArrayList();

  if (startID == -1 || goalID == -1) {
    path.add(0, -1);
    return path;
  }

  if (startID == goalID) {
    path.add(0, startID);
    return path;
  }

  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");
  
  visited[startID] = true;
  fringe.offer(new Node(startID, nodePos[startID].distanceTo(nodePos[goalID])));
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  while (fringe.size() > 0){
    Node currentNode = fringe.poll();
    if (currentNode.id == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode.id].size(); i++){
      int neighborNodeID = neighbors[currentNode.id].get(i);
      if (!visited[neighborNodeID]){
        visited[neighborNodeID] = true;
        parent[neighborNodeID] = currentNode.id;
        fringe.offer(new Node(
          neighborNodeID, 
          heuristic1(nodePos[currentNode.id], nodePos[neighborNodeID], nodePos[goalID])
        ));
        //println("Added node", neighborNode, "to the fringe.");
        //println(" Current Fringe: ", fringe);
      }
    } 
  }

  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
}

// // iteratively deepens the dls
// ArrayList<Integer> runIDDFS(ArrayList<Integer>[] graph, int start, int goal) {
//     boolean[] res = new boolean[]{false, false};
//     ArrayList<Integer> path = new ArrayList<Integer>();
//     for (int i = 0; i < numNodes; i++) {
//         // println("Starting Search With Depth " + i);
//         // calls dls with new depth
//         res = dls(path, graph, i, start, goal);
//         // returns if it finds goal or cant keep going
//         if (res[0]) return path;
//         if (!res[0] && !res[1]) break;
//     }
    
//     // no path
//     path.add(0, -1);
//     return path;
// }

// // depth limited search
// boolean[] dls(ArrayList<Integer> path, ArrayList<Integer>[] graph, int depth, int start, int goal) {
//     // base case for if max depth reached or goal found
//     // print("Current Path: \n[");
//     // for (int i = 0; i < path.size()-1; i++) {
//     //     print(path.get(i)); print(", ");
//     // }
//     // if (path.size() > 0) {
//     //     print(path.get(path.size()-1));
//     // }
//     // print("]\n\n");
//     if (depth == 0 || start == goal) {
//         // if goal found, add to the path and return
//         if (start == goal) {
//             path.add(start);
//             return new boolean[]{true, true};
//         // can still keep going maybe so return a different case
//         } else {
//             // not found but maybe children
//             return new boolean[]{false, true};
//         }
//     }

//     // iterate through the children 
//     boolean remaining = false;
//     for (var child : graph[start]) {
//         // add current node to the path
//         path.add(start);
//         // recursively call dls with one less depth
//         boolean[] keep_going = dls(path, graph, depth-1, child, goal);
//         // if you found the goal, cascade back up
//         if (keep_going[0]) {
//             return new boolean[]{true, true};
//         }
//         // remove current node from path because it did not lead to goal
//         path.remove(path.size()-1);
//         // if any of the nodes might have children, have the search keep
//         // going (only for iterative deepening)
//         if (keep_going[1]) remaining = true;
//     }

//     // return the state of the search
//     return new boolean[]{false, remaining};
// }


//Compute collision tests. Code from the in-class exercises may be helpful ehre.

//Returns true if the point is inside a circle
//You must consider a point as colliding if it's distance is <= eps
 public boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps){
  float dist = pointPos.distanceTo(center);
  if (dist < r+eps){ //small safety factor
    return true;
  }
  return false;
}

//Returns true if the point is inside a list of circle
//You must consider a point as colliding if it's distance is <= eps
 public boolean pointInCircleList(Vec2[] centers, float[] radii, int numObstacles, Vec2 pointPos, float eps){
  for (int i = 0; i < numObstacles; i++){
    Vec2 center =  centers[i];
    float r = radii[i];
    if (pointInCircle(center,r,pointPos, eps)){
      return true;
    }
  }
  return false;
}


class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

 public hitInfo rayCircleIntersect(Vec2 center, float r, Vec2 l_start, Vec2 l_dir, float max_t){
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

 public hitInfo rayCircleListIntersect(Vec2[] centers, float[] radii,  int numObstacles, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  hit.t = max_t;
  for (int i = 0; i < numObstacles; i++){
    Vec2 center = centers[i];
    float r = radii[i];
    
    hitInfo circleHit = rayCircleIntersect(center, r, l_start, l_dir, hit.t);
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

 public Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

 public float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

 public float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

 public Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}


  public void settings() { size(1024, 768); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Proj1_Test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
