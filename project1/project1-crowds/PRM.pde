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
PriorityQueue<Float>[] closed = new PriorityQueue[numNodes];
PriorityQueue<Node>[] open = new PriorityQueue[numNodes];

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
int closestNode(Vec2 start, Vec2 goal, Vec2[] nodePos, int numNodes){
  int closestID = -1;
  float minDist = 999999;
  for (int i = 0; i < numNodes; i++){
    float distToGoal = nodePos[i].distanceTo(goal);
    float dist = nodePos[i].distanceTo(start);
    float totalDist = dist + distToGoal;
    Vec2 dir = start.minus(nodePos[i]).normalized();
    hitInfo hit = rayCircleListIntersect(obstCenters, obstRadii, numObst, nodePos[i], dir, dist);
    if (totalDist < minDist && !hit.hit && neighbors[i].size() > 0){
      closestID = i;
      minDist = totalDist;
    }
  }
  return closestID;
}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  int startID = closestNode(startPos, goalPos, nodePos, numNodes);
  int goalID = closestNode(goalPos, startID != -1 ? nodePos[startID] : goalPos, nodePos, numNodes);
  
  path = runAStar(nodePos, numNodes, startID, goalID);
  
  return path;
}

ArrayList<Integer> planPath(Vec2 startPos, Vec2 goalPos, Vec2[] centers, float[] radii, int numObstacles, Vec2[] nodePos, int numNodes, int debug){
  ArrayList<Integer> path = new ArrayList();
  
  int startID = closestNode(startPos, goalPos, nodePos, numNodes);
  int goalID = closestNode(goalPos, startID != -1 ? nodePos[startID] : goalPos, nodePos, numNodes);
  
  if (debug == 2) {
    // A*
    path = runAStar(nodePos, numNodes, startID, goalID);
  } else if (debug == 1) {
    // BFS
    path = runBFS(nodePos, numNodes, startID, goalID);
  } else if (debug == 3) {
    path = runAStarNew(nodePos, numNodes, startID, goalID);
  } else {
    println("Please input a valid algorithm number.");
    path.add(0,-1);
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
}

float heuristic1(int currNode, int goalNode, Vec2[] nodePos) {
  return nodePos[currNode].distanceTo(nodePos[goalNode]);
}

ArrayList<Integer> runAStar(Vec2[] nodePos, int numNodes, int startID, int goalID) {
  PriorityQueue<Node> closed = new PriorityQueue<Node>(numNodes);
  PriorityQueue<Node> fringe = new PriorityQueue<Node>(numNodes);
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
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
}

// temporary duplicate so as to not lose code
ArrayList<Integer> runAStarNew(Vec2[] nodePos, int numNodes, int startID, int goalID) {
  PriorityQueue<Node> fringe = new PriorityQueue<Node>();
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
    parent[i] = -1; //No parent yet
    closed[i] = new PriorityQueue<Float>();
    open[i] = new PriorityQueue<Node>();
  }

  //println("\nBeginning Search");
  
  fringe.offer(new Node(startID, 0, heuristic1(startID, goalID, nodePos)));
  while (fringe.size() > 0){
    Node currentNode = fringe.poll();
    open[currentNode.id].poll();
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

      if (open[neighbor.id].size() > 0) {
        // if (open[neighbor.id].peek() <= neighbor.g) continue;
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
      } else if (closed[neighbor.id].size() > 0) {
        if (closed[neighbor.id].peek() <= neighbor.g) continue;
        else {
          Node n = new Node(
            neighbor.id,
            closed[neighbor.id].poll(),
            heuristic1(neighbor.id, goalID, nodePos)
          );
          fringe.offer(n);
          open[neighbor.id].offer(n);
        }
      } else {
        fringe.offer(neighbor);
      }
      parent[neighbor.id] = currentNode.id;
    } 
    closed[currentNode.id].offer(currentNode.g);
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
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
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

