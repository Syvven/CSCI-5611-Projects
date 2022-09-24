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
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node
Vec2[] obstCenters;
float[] obstRadii;
int numObst;

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
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
int closestNode(Vec2 point, Vec2[] nodePos, int numNodes){
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

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
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

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes, boolean debug){
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
ArrayList<Integer> runBFS(Vec2[] nodePos, int numNodes, int startID, int goalID){
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

float heuristic1(Vec2 currNode, Vec2 nextNode, Vec2 goalNode) {
  return currNode.distanceTo(nextNode) + nextNode.distanceTo(goalNode);
}

ArrayList<Integer> runAStar(Vec2[] nodePos, int numNodes, int startID, int goalID) {
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
      Node neighbor = new Node(
        neighborNodeID, 
        heuristic1(nodePos[currentNode.id], nodePos[neighborNodeID], nodePos[goalID])
      )

      if (!visited[neighbor.id]){
        visited[neighbor.id] = true;
        parent[neighbor.id] = currentNode.id;
        fringe.offer(neighbor);
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

