///////////////////////////////////////
// CONTRIBUTERS: hend0800 and cheon051
///////////////////////////////////////


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

import java.util.Comparator;
import java.util.PriorityQueue;

//Here, we represent our graph structure as a neighbor list
//You can use any graph representation you like
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes+2];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes+2]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes+2]; //A list which stores the best previous node on the optimal path to reach this node
Vec2[] obstCenters;
float[] obstRadii;
int numObst;
Vec2[] newNodePos = new Vec2[numNodes+2];
PriorityQueue<Float>[] closedd = new PriorityQueue[numNodes+2];
PriorityQueue<Node>[] open = new PriorityQueue[numNodes+2];

PriorityQueue<Node> closed = new PriorityQueue<Node>(numNodes);
PriorityQueue<Node> fringe = new PriorityQueue<Node>(numNodes);

ArrayList<Integer> path = new ArrayList();

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  obstCenters = centers;
  obstRadii = radii;
  numObst = numObstacles;

  for (int i = 0; i < numNodes; i++) {
    newNodePos[i+1] = nodePos[i];
  }

  for (int i = 1; i < numNodes+1; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    for (int j = 1; j < numNodes+1; j++){
      if (i == j) continue; //don't connect to myself 
      Vec2 dir = newNodePos[j].minus(newNodePos[i]).normalized();
      float distBetween = newNodePos[i].distanceTo(newNodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, newNodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
      } 
    }
  }
}

//This is probably a bad idea and you shouldn't use it...
void connectStartAndGoal(int numNodes, Vec2[] centers, float[] radii, int numObstacles) {
  neighbors[0] = new ArrayList<Integer>();
  neighbors[numNodes-1] = new ArrayList<Integer>();

  for (int i = 0; i < numNodes; i++) {
    if (i != 0) {
      Vec2 dir = newNodePos[i].minus(newNodePos[0]).normalized();
      float distBetween = newNodePos[0].distanceTo(newNodePos[i]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, newNodePos[0], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[0].add(i);
      }
    }
    if (i != numNodes-1) {
      Vec2 dir = newNodePos[i].minus(newNodePos[numNodes-1]).normalized();
      float distBetween = newNodePos[numNodes-1].distanceTo(newNodePos[i]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, newNodePos[numNodes-1], dir, distBetween);
      neighbors[i].remove(Integer.valueOf(numNodes-1));
      if (!circleListCheck.hit){
        neighbors[i].add(numNodes-1);
      }
    }
  }
}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  path.clear();

  newNodePos[0] = startPos;
  newNodePos[numNodes+1] = goalPos;
  
  connectStartAndGoal(numNodes+2, centers, radii, numObstacles);
  
  path = runAStar(newNodePos, numNodes+2, 0, numNodes+1);
  
  if (path.size() > 1) {
    path.remove(path.size()-1);
    path.remove(0);
  }

  return path;
}

class Node implements Comparable<Node> {
  public Float g;
  public Float h;
  public Float cost;
  public int id;

  public Node(int id, float g, float h) {
    this.id = id;
    this.g = g;
    this.h = h;
    
    this.cost = this.g+this.h;
  }

  public boolean equals(Object o) {
    if (o instanceof Node) {
      Node toCompare = (Node) o;
      return (this.id==toCompare.id);
    }
    return false;
  }

  @Override
  public int compareTo(Node n2) {
    return this.cost.compareTo(n2.cost);
  }

  public String toString() {
    return this.id + "";
  }
}

float heuristic1(int currNode, int goalNode, Vec2[] nodePos) {
  return nodePos[currNode].distanceTo(nodePos[goalNode]);
}

ArrayList<Integer> runAStar(Vec2[] nodePos, int nNodes, int startID, int goalID) {
  closed.clear();
  fringe.clear();
  ArrayList<Integer> path = new ArrayList();

  for (int i = 0; i < nNodes; i++) { //Clear visit tags and parent pointers
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");
  
  fringe.offer(new Node(startID, 0, heuristic1(startID, goalID, nodePos)));
  while (fringe.size() > 0){
    Node currentNode = fringe.poll();
    if (currentNode.id == goalID){
      break;
    }
    
    for (int i = 0; i < neighbors[currentNode.id].size(); i++){
      int neighborNodeID = neighbors[currentNode.id].get(i);
      Node neighbor = new Node(
        neighborNodeID, 
        currentNode.g + nodePos[currentNode.id].distanceTo(nodePos[neighborNodeID]),
        heuristic1(neighborNodeID, goalID, nodePos)
      );

      if (fringe.contains(neighbor)) {
        boolean cont = false;
        for (Node n : fringe) {
          if (n.g <= neighbor.g && n.equals(neighbor)) {
            cont = true;
            break;
          }
        }
        if (cont) {
          continue;
        }
      } else if (closed.contains(neighbor)) {
        boolean cont = false;
        for (Node n : closed) {
          if (n.g <= neighbor.g && n.equals(neighbor)) {
            cont = true;
            break;
          }
          else if (n.equals(neighbor)) {
            closed.remove(n);
            fringe.offer(n);
          }
        }
        if (cont) {
          continue;
        }
      } else {
        fringe.offer(neighbor);
      }
      parent[neighbor.id] = currentNode.id;
    } 
    closed.offer(currentNode);
  }

  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  // print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode-1);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
}


////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

// Collision library
// DONT NEED THIS?
// I GUESS IF WE DO NEED THIS, UNCOMMENT

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

//Compute collision tests. Code from the in-class exercises may be helpful ehre.

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

hitInfo rayCircleIntersect(Vec2 center, float r, Vec2 l_start, Vec2 l_dir, float max_t){
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

hitInfo rayCircleListIntersect(Vec2[] centers, float[] radii,  int numObstacles, Vec2 l_start, Vec2 l_dir, float max_t){
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

