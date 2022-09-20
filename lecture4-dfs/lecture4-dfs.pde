//CSCI 5611 - Graph Search & Planning
//Breadth-First Search (BFS) [Exercise]
// Stephen J. Guy <sjguy@umn.edu>

/*
 TODO: 
    1. Try to understand how this Breadth-first Search (BFS) implementation works.
       As a start, compare to the pseudocode at: https://en.wikipedia.org/wiki/Breadth-first_search
       How do I represent nodes? How do I represent edges?
       What is the purpose of the visited list? What about the parent list?
       What is getting added to the fringe? In what order?
       How do I find the path once I've found the goal?
    2. Convert this Breadth-first Search to a Depth-First Search.
       Which version BFS or DFS has a smaller maximum fring size?
    3. Currently, the code sets up a graph which follows this tree-like structure: https://snipboard.io/6BhxRd.jpg
       Change it to plan a path from node 0 to node 7 over this graph instead: https://snipboard.io/VIx6Er.jpg
       How do we know the graph is no longer a tree?
       Does Breadth-first Search still find the optimal path?
       
 CHALLENGE:
    1. Make a new graph where there is a cycle. DFS should fail. Does it? Why?
    2. Add a maximum depth limit to DFS. Now can it handle cycles?
    3. Call the new depth-limited DFS in a loop, growing the depth limit with each
       iteration. Is this new iterative deepening DFS optimal? Can it handle loops
       in the graph? How does the memory usage/fringe size compare to BFS?
*/


//Initialize our graph 
int numNodes = 8;

//Represents our graph structure as 3 lists
ArrayList<Integer>[] neighbors = new ArrayList[numNodes];  //A list of neighbors can can be reached from a given node
Boolean[] visited = new Boolean[numNodes]; //A list which store if a given node has been visited
int[] parent = new int[numNodes]; //A list which stores the best previous node on the optimal path to reach this node

void setup() {
  // Initialize the lists which represent our graph 
  for (int i = 0; i < numNodes; i++) { 
      neighbors[i] = new ArrayList<Integer>(); 
      visited[i] = false;
      parent[i] = -1; //No parent yet
  }

  //Set which nodes are connected to which neighbors
  neighbors[0].add(1); neighbors[0].add(2); //0 -> 1 & 2
  neighbors[1].add(3); neighbors[1].add(4); //1 -> 3 & 4 
  neighbors[2].add(5); neighbors[2].add(6); //2 -> 5 & 6
  neighbors[4].add(7);                      //4 -> 7

  println("List of Neighbors:");
  println(neighbors);

  //Set start and goal
  int start = 0;
  int goal = 7;

  ArrayList<Integer> fringe = new ArrayList(); 

  println("\nBeginning Search");

  visited[start] = true;
  fringe.add(start);
  println("Adding node", start, "(start) to the fringe.");
  println(" Current Fring: ", fringe);

  while (fringe.size() > 0){
    int fringeTop = 0;
    int currentNode = fringe.get(fringeTop);
    fringe.remove(fringeTop);
    if (currentNode == goal){
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
  int prevNode = parent[goal];
  print(goal, " ");
  while (prevNode >= 0){
    print(prevNode," ");
    prevNode = parent[prevNode];
  }
  print("\n");
}

void draw() {

}
