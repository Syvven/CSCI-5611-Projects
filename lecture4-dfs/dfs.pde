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
    
    Each NODE is represented as an integer (0-7).
    An EDGE connecting one node to another is represented as an ArrayList
        at the starting node's index in an array. The array list contains
        the nodes that that index is connected to. 
        i.e. at index 0 (node 0) there is an ArrayList containing 1 and 2 
            because node 0 has child nodes 1 and 2
    The VISITED LIST is there in order not to revisit nodes that you have already
        visited. This list prevents loops(?).
    The PARENT LIST stores the best previous node on the optimal path to reach 
        the current node. Once the goal is reached, it contains the optimal path.
    The nodes being added to the FRINGE are the children nodes of the current node.
        They are being added in order of low node # to high in this specific case
        but more generally they are being added in the order that they were added
        to the current nodes' neighbor ArrayList.
    You find the PATH once you've reached the goal by tracing your way back up the 
        parent list.

    2. Convert this Breadth-first Search to a Depth-First Search.
       Which version BFS or DFS has a smaller maximum fringe size?
    DFS has the smaller maximum fringe size.

    3. Currently, the code sets up a graph which follows this tree-like structure: https://snipboard.io/6BhxRd.jpg
       Change it to plan a path from node 0 to node 7 over this graph instead: https://snipboard.io/VIx6Er.jpg
       How do we know the graph is no longer a tree?
       Does Breadth-first Search still find the optimal path?
    We know the graph is no longer a tree because there are nodes that have more
        than one parent.
    Breadth first still finds the optimal path because it can handle loops and infinite paths.
       
 CHALLENGE:
    1. Make a new graph where there is a cycle. DFS should fail. Does it? Why?
    Depth first does not fail in this case. This is because of the visited array.
    It negates the possibility of loops by not allowing the path to double back on itself.
    Without the visited array, yes, dfs fails.

    2. Add a maximum depth limit to DFS. Now can it handle cycles?
    It handles cycles...kind of. If the depth limit is just right, it finds the optimal solution.
    If the depth limit is too much, it might go through a cycle and get a non-optimal solution
    
    3. Call the new depth-limited DFS in a loop, growing the depth limit with each
       iteration. Is this new iterative deepening DFS optimal? Can it handle loops
       in the graph? How does the memory usage/fringe size compare to BFS?
    IDDFS can handle loops, is optimal, and the solution I implemented does not actually have
    a fringe so uh. I'm not sure. But I do know that IDDFS is much more memory efficient than BFS
    because it is a depth first search algorithm. 
*/


//Initialize our graph 
int numNodes = 8;

//Represents our graph structure as 3 lists
Boolean[] visited = new Boolean[numNodes]; //A list which store if a given node has been visited
int maxDepth = 3;
int currDepth = 0;
boolean goalFound = false;
ArrayList<Integer> path = new ArrayList<Integer>();

// iteratively deepens the dls
boolean[] iddfs(ArrayList<Integer>[] graph, int start, int goal) {
    boolean[] res = new boolean[]{false, false};
    for (int i = 0; i < 2147483647; i++) {
        println("Starting Search With Depth " + i);
        // calls dls with new depth
        res = dls(graph, i, start, goal);
        // returns if it finds goal or cant keep going
        if (res[0] || !res[1]) return res;
    }
    // extra return to keep the error checker happy :)
    // also for if your graph/tree is depeer than the maximum int
    return new boolean[]{false, false};
}

// depth limited search
boolean[] dls(ArrayList<Integer>[] graph, int depth, int start, int goal) {
    // base case for if max depth reached or goal found
    print("Current Path: \n[");
    for (int i = 0; i < path.size()-1; i++) {
        print(path.get(i)); print(", ");
    }
    if (path.size() > 0) {
        print(path.get(path.size()-1));
    }
    print("]\n\n");
    if (depth == 0 || start == goal) {
        // if goal found, add to the path and return
        if (start == goal) {
            path.add(start);
            return new boolean[]{true, true};
        // can still keep going maybe so return a different case
        } else {
            // not found but maybe children
            return new boolean[]{false, true};
        }
    }

    // iterate through the children 
    boolean remaining = false;
    for (var child : graph[start]) {
        // add current node to the path
        path.add(start);
        // recursively call dls with one less depth
        boolean[] keep_going = dls(graph, depth-1, child, goal);
        // if you found the goal, cascade back up
        if (keep_going[0]) {
            return new boolean[]{true, true};
        }
        // remove current node from path because it did not lead to goal
        path.remove(path.size()-1);
        // if any of the nodes might have children, have the search keep
        // going (only for iterative deepening)
        if (keep_going[1]) remaining = true;
    }

    // return the state of the search
    return new boolean[]{false, remaining};
}

int[] dfs_cyclefail(ArrayList<Integer>[] graph, int start, int goal) {
    ArrayList<Integer> fringe = new ArrayList(); 
    int[] parent = new int[numNodes]; //A list which stores the best previous node on the optimal path to reach this node
    for (int i = 0; i < graph.length; i++) {
        parent[i] = -1; 
    }

    println("\nBeginning Search");

    println("Adding node", start, "(start) to the fringe.");
    visited[start] = true;
    fringe.add(start);
    println(" Current Fringe: ", fringe);

    while (fringe.size() > 0){
        int fringeTop = fringe.size()-1;

        int currentNode = fringe.get(fringeTop);
        fringe.remove(fringeTop);
        if (currentNode == goal){
            println("Goal found!");
            break;
        }

        for (int i = 0; i < graph[currentNode].size(); i++){
            int neighborNode = graph[currentNode].get(i);
            // if you commented out this if statement DFS would fail
            // if (!visited[neighborNode]) {
                // visited[neighborNode] = true;
                parent[neighborNode] = currentNode;
                fringe.add(neighborNode);
                println("Added node", neighborNode, "to the fringe.");
            // }
        } 
        println("Depth " + currDepth + " Current Fringe: ", fringe);
    }

    return parent;
}

// Depth First Search --> LIFO
int[] dfs(ArrayList<Integer>[] graph, int start, int goal) {
    ArrayList<Integer> fringe = new ArrayList(); 
    int[] parent = new int[numNodes]; //A list which stores the best previous node on the optimal path to reach this node
    for (int i = 0; i < graph.length; i++) {
        parent[i] = -1; 
    }

    println("\nBeginning Search");

    println("Adding node", start, "(start) to the fringe.");
    visited[start] = true;
    fringe.add(start);
    println(" Current Fringe: ", fringe);

    while (fringe.size() > 0){
        int fringeTop = fringe.size()-1;

        int currentNode = fringe.get(fringeTop);
        fringe.remove(fringeTop);
        if (currentNode == goal){
            println("Goal found!");
            break;
        }

        for (int i = 0; i < graph[currentNode].size(); i++){
            int neighborNode = graph[currentNode].get(i);
            // if you commented out this if statement DFS would fail
            if (!visited[neighborNode]) {
                visited[neighborNode] = true;
                parent[neighborNode] = currentNode;
                fringe.add(neighborNode);
                println("Added node", neighborNode, "to the fringe.");
            }
        } 
        println("Depth " + currDepth + " Current Fringe: ", fringe);
    }

    return parent;
}

// Breadth First Search --> FIFO
int[] bfs(ArrayList<Integer>[] graph, int start, int goal) {
    ArrayList<Integer> fringe = new ArrayList(); 
    int[] parent = new int[numNodes]; //A list which stores the best previous node on the optimal path to reach this node
    for (int i = 0; i < graph.length; i++) {
        parent[i] = -1; 
    }

    println("\nBeginning Search");

    println("Adding node", start, "(start) to the fringe.");
    visited[start] = true;
    fringe.add(start);
    println(" Current Fringe: ", fringe);

    while (fringe.size() > 0){
        int fringeTop = 0;

        int currentNode = fringe.get(fringeTop);
        fringe.remove(fringeTop);
        if (currentNode == goal){
            println("Goal found!");
            break;
        }

        for (int i = 0; i < graph[currentNode].size(); i++){
            int neighborNode = graph[currentNode].get(i);
            // if you commented out this if statement DFS would fail
            if (!visited[neighborNode]) {
                visited[neighborNode] = true;
                parent[neighborNode] = currentNode;
                fringe.add(neighborNode);
                println("Added node", neighborNode, "to the fringe.");
            }
        } 
        println("Depth " + currDepth + " Current Fringe: ", fringe);
    }

    return parent;
} 

void setup() {
     //A list of neighbors can can be reached from a given node
    ArrayList<Integer>[] graph4 = new ArrayList[numNodes];
    ArrayList<Integer>[] graph3 = new ArrayList[numNodes];
    ArrayList<Integer>[] graph2 = new ArrayList[numNodes];
    ArrayList<Integer>[] graph1 = new ArrayList[numNodes];

    // Initialize the lists which represent our graph 
    for (int i = 0; i < numNodes; i++) { 
        graph1[i] = new ArrayList<Integer>(); 
        graph2[i] = new ArrayList<Integer>(); 
        graph3[i] = new ArrayList<Integer>();  
        graph4[i] = new ArrayList<Integer>();
        visited[i] = false;
    }

    // Tree 
    //Set which nodes are connected to which neighbors
    graph1[0].add(1); graph1[0].add(2); //0 -> 1 & 2
    graph1[1].add(3); graph1[1].add(4); //1 -> 3 & 4 
    graph1[2].add(5); graph1[2].add(6); //2 -> 5 & 6
    graph1[4].add(7);                   //4 -> 7

    // Graph
    graph2[0].add(1); graph2[0].add(3); //0 -> 1 and 3
    graph2[1].add(2); graph2[1].add(4); //1 -> 2 and 4
    graph2[2].add(7);                   //2 -> 7
    graph2[3].add(4); graph2[3].add(6); //3 -> 4 and 6
    graph2[4].add(5);                   //4 -> 5
    graph2[5].add(7);                   //5 -> 7
    graph2[6].add(5);                   //6 -> 5

    // Cycle Graph
    graph3[0].add(1);
    graph3[1].add(2); 
    graph3[2].add(0); graph3[2].add(3); 
    graph3[3].add(0); graph3[3].add(4); 
    graph3[4].add(0); graph3[4].add(5); 
    graph3[5].add(0); graph3[5].add(6); 
    graph3[6].add(0); graph3[6].add(7); 

    // Cycle Graph
    graph4[0].add(1);
    graph4[1].add(2); 
    graph4[2].add(3); graph4[2].add(0); 
    graph4[3].add(4); graph4[3].add(0); 
    graph4[4].add(5); graph4[4].add(0); 
    graph4[5].add(6); graph4[5].add(0); 
    graph4[6].add(7); graph4[6].add(0); 



    // println("List of Neighbors:");
    // println(neighbors);

    //Set start and goal
    int start = 0;
    int goal = 7;

    // while (!goalFound) {
        

    //     if (currDepth >= maxDepth) {
    //         continue;
    //     }

    //     maxDepth++;
    //     // println(maxDepth);
    //     currDepth = 0;
    //     fringe = new ArrayList();
    //     fringe.add(start);
    //     parent = new int[numNodes];
    // }

    // tree
    // int[] parent = bfs(graph1, start, goal);
    /* Result
        Beginning Search
        Adding node 0 (start) to the fringe.
        Current Fringe:  [0]
        Added node 1 to the fringe.
        Added node 2 to the fringe.
        Depth 0 Current Fringe:  [1, 2]
        Added node 3 to the fringe.
        Added node 4 to the fringe.
        Depth 0 Current Fringe:  [2, 3, 4]
        Added node 5 to the fringe.
        Added node 6 to the fringe.
        Depth 0 Current Fringe:  [3, 4, 5, 6]
        Depth 0 Current Fringe:  [4, 5, 6]
        Added node 7 to the fringe.
        Depth 0 Current Fringe:  [5, 6, 7]
        Depth 0 Current Fringe:  [6, 7]
        Depth 0 Current Fringe:  [7]
        Goal found!

        Reverse path: 7  4  1  0 
        Finished
        -> Optimal Path, larger max fringe
    */

    // tree
    // int[] parent = dfs(graph1, start, goal);
    /* Result
        Beginning Search
        Adding node 0 (start) to the fringe.
        Current Fringe:  [0]
        Added node 1 to the fringe.
        Added node 2 to the fringe.
        Depth 0 Current Fringe:  [1, 2]
        Added node 5 to the fringe.
        Added node 6 to the fringe.
        Depth 0 Current Fringe:  [1, 5, 6]
        Depth 0 Current Fringe:  [1, 5]
        Depth 0 Current Fringe:  [1]
        Added node 3 to the fringe.
        Added node 4 to the fringe.
        Depth 0 Current Fringe:  [3, 4]
        Added node 7 to the fringe.
        Depth 0 Current Fringe:  [3, 7]
        Goal found!

        Reverse path: 7  4  1  0 
        Finished
        -> Optimal Path, smaller max fringe
    */

    // graph
    // int[] parent = bfs(graph2, start, goal);
    /* Result
        Beginning Search
        Adding node 0 (start) to the fringe.
        Current Fringe:  [0]
        Added node 1 to the fringe.
        Added node 3 to the fringe.
        Depth 0 Current Fringe:  [1, 3]
        Added node 2 to the fringe.
        Added node 4 to the fringe.
        Depth 0 Current Fringe:  [3, 2, 4]
        Added node 6 to the fringe.
        Depth 0 Current Fringe:  [2, 4, 6]
        Added node 7 to the fringe.
        Depth 0 Current Fringe:  [4, 6, 7]
        Added node 5 to the fringe.
        Depth 0 Current Fringe:  [6, 7, 5]
        Depth 0 Current Fringe:  [7, 5]
        Goal found!

        Reverse path: 7  2  1  0 
        Finished.
        -> Optimal Path, same fringe
    */

    // graph
    // int[] parent = dfs(graph2, start, goal);
    /* Result
        Beginning Search
        Adding node 0 (start) to the fringe.
        Current Fringe:  [0]
        Added node 1 to the fringe.
        Added node 3 to the fringe.
        Depth 0 Current Fringe:  [1, 3]
        Added node 4 to the fringe.
        Added node 6 to the fringe.
        Depth 0 Current Fringe:  [1, 4, 6]
        Added node 5 to the fringe.
        Depth 0 Current Fringe:  [1, 4, 5]
        Added node 7 to the fringe.
        Depth 0 Current Fringe:  [1, 4, 7]
        Goal found!

        Reverse path: 7  5  6  3  0 
        Finished.
        -> Non-Optimal Path, same fringe
    */

    // cycle graph
    // int[] parent = bfs(graph3, start, goal);
    /* Result 
        Beginning Search
        Adding node 0 (start) to the fringe.
        Current Fringe:  [0]
        Added node 1 to the fringe.
        Depth 0 Current Fringe:  [1]
        Added node 2 to the fringe.
        Depth 0 Current Fringe:  [2]
        Added node 3 to the fringe.
        Depth 0 Current Fringe:  [3]
        Added node 4 to the fringe.
        Depth 0 Current Fringe:  [4]
        Added node 5 to the fringe.
        Depth 0 Current Fringe:  [5]
        Added node 6 to the fringe.
        Depth 0 Current Fringe:  [6]
        Added node 7 to the fringe.
        Depth 0 Current Fringe:  [7]
        Goal found!

        Reverse path: 7  6  5  4  3  2  1  0
        Finished
        -> Works on a graph with cycles
    */

    // int[] parent = dfs(graph3, start, goal);
    /* Result
        Beginning Search
        Adding node 0 (start) to the fringe.
        Current Fringe:  [0]
        Added node 1 to the fringe.
        Depth 0 Current Fringe:  [1]
        Added node 2 to the fringe.
        Depth 0 Current Fringe:  [2]
        Added node 3 to the fringe.
        Depth 0 Current Fringe:  [3]
        Added node 4 to the fringe.
        Depth 0 Current Fringe:  [4]
        Added node 5 to the fringe.
        Depth 0 Current Fringe:  [5]
        Added node 6 to the fringe.
        Depth 0 Current Fringe:  [6]
        Added node 7 to the fringe.
        Depth 0 Current Fringe:  [7]
        Goal found!

        Reverse path: 7  6  5  4  3  2  1  0
        Finished
        -> Did not fail -> kept track of visited nodes
    */

    // THIS WILL FAIL //
    // int[] parent = dfs_cyclefail(graph3, start, goal);
    // Fails because the visited list is taken away
    // Depth Limited / Iterative Deepening both take visited away

    // Depth Limited Search on Cycle Graph
    // int depth = 10;
    // println("Starting Search With Depth " + depth);
    // boolean[] found = dls(graph3, depth, start, goal);
    // if (found[0]) {
    //     println("Goal Found!");
    // } else if (!found[0] && found[1]) {
    //     println("Goal Not Found, but could be if going deeper...");
    // } else {
    //     println("Goal Not Found");
    // }
    // for (int i = 0; i < path.size(); i++) {
    //     print(path.get(i)); print(' ');
    // }
    // print('\n');

    /* Result
        Goal Found!
        0 1 2 0 1 2 3 4 5 6 7 
        Finished.
        -> This approach can handle loops, but does not always find a solution.
            -> In this case, if depth <= 7, the search does not find the goal
            -> Additionally, if depth => 10, the search finds a non-optimal solution
    */
    
    boolean[] found = iddfs(graph4, start, goal);
    if (found[0]) {
        println("Goal Found!");
    } else if (!found[0] && found[1]) {
        println("Goal Not Found, but could be if going deeper...");
    } else {
        println("This is a really big graph");
    }
    for (int i = 0; i < path.size(); i++) {
        print(path.get(i)); print(' ');
    }
    print('\n');

    /* Result
        Goal Found!
        0 1 2 3 4 5 6 7
        Finished.
        -> This approach will find the goal eventually and will find the optimal path.
            -> UNLESS your goal is deeper than the maximum int, in which case you may want
                to upgrade to longs.
    */

    // print("\nReverse path: ");
    // int prevNode = parent[goal];
    // print(goal, " ");
    // while (prevNode >= 0){
    //     print(prevNode," ");
    //     prevNode = parent[prevNode];
    // }
    // print("\n");
}


