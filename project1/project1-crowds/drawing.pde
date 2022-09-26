// main draw loop
void draw() {
    // updates things
    camera.Update(1.0/frameRate);
    if (!paused) updateKiwiFrame();
    checkPressed();
    if (!paused) update(1.0/frameRate);

    background(0);
    lightFalloff(1, 0, 0);
    lightSpecular(0, 0, 0);
    ambientLight(75, 75, 75);
    directionalLight(128, 128, 128, 0, 0, -1);

    // concentration = map(cos(frameCount * .01), -1, 1, 12, 100);
    // mouse.set(mouseX - half.x, mouseY - half.y, viewOff);
    // mouse.normalize();

    // // Flash light.
    // spotLight(
    //     191, 170, 133,
    //     0, 0, viewOff,
    //     mouse.x, mouse.y, -1,
    //     angle, concentration
    // );

    // used for understanding where the bounds of the scene are
    drawBounds();
    drawObstacles();
    // if (mouseCast) {
    //   drawMouseRay();
    // }

    colorMode(HSB, 360, 100, 100);
    lightFalloff(0.1, 0, 0);
    spotLight(
        360,100, 100,
        agentPos.x, agentPos.y-80*kiwiScale, agentPos.z,
        0,1,0,
        ninety*0.25,
        500
    );
    
    colorMode(RGB, 255, 255, 255);
    drawKiwi();
    drawFloor();

    stroke(0,0,0);
  fill(255,255,255);
  
  
//   //Draw the circle obstacles
//   for (int i = 0; i < numObstacles; i++){
//     Vec2 c = circlePosArr[i];
//     float r = circleRadArr[i];
//     circle(c.x,c.y,r*2);
//   }
  //Draw the first circle a little special b/c the user controls it
//   fill(240);
//   strokeWeight(2);
//   circle(circlePosArr[0].x,circlePosArr[0].y,circleRadArr[0]*2);
//   strokeWeight(1);
  
  //Draw PRM Nodes
//   fill(0);
//   for (int i = 0; i < numNodes; i++){
//     circle(nodePos[i].x,nodePos[i].y,5);
//   }
  
  //Draw graph
  stroke(100,100,100);
  strokeWeight(1);
  for (int i = 0; i < numNodes; i++){
    for (int j : neighbors[i]){
      line(nodePos[i].x, 0, nodePos[i].y,nodePos[j].x,0,nodePos[j].y);
    }
  }
  
//   //Draw Start and Goal
//   fill(20,60,250);
//   //circle(nodePos[startNode].x,nodePos[startNode].y,20);
//   circle(startPos.x,startPos.y,20);
//   fill(250,30,50);
//   //circle(nodePos[goalNode].x,nodePos[goalNode].y,20);
//   circle(goalPos.x,goalPos.y,20);
  
  if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
  
  //Draw Planned Path
  stroke(20,255,40);
  strokeWeight(5);
  if (curPath.size() == 0){
    line(startPos.x,0,startPos.y,goalPos.x,0,goalPos.y);
    return;
  }
  line(startPos.x,0,startPos.y,nodePos[curPath.get(0)].x,0,nodePos[curPath.get(0)].y);
  for (int i = 0; i < curPath.size()-1; i++){
    int curNode = curPath.get(i);
    int nextNode = curPath.get(i+1);
    line(nodePos[curNode].x,0,nodePos[curNode].y,nodePos[nextNode].x,0,nodePos[nextNode].y);
  }
  line(goalPos.x,0,goalPos.y,nodePos[curPath.get(curPath.size()-1)].x,0,nodePos[curPath.get(curPath.size()-1)].y);
  
}

// void draw(){
//   //println("FrameRate:",frameRate);
//   strokeWeight(1);
//   background(200); //Grey background
// //   stroke(0,0,0);
//   fill(255,255,255);
  
  
// //   //Draw the circle obstacles
// //   for (int i = 0; i < numObstacles; i++){
// //     Vec2 c = circlePosArr[i];
// //     float r = circleRadArr[i];
// //     circle(c.x,c.y,r*2);
// //   }
//   //Draw the first circle a little special b/c the user controls it
// //   fill(240);
// //   strokeWeight(2);
// //   circle(circlePosArr[0].x,circlePosArr[0].y,circleRadArr[0]*2);
// //   strokeWeight(1);
  
//   //Draw PRM Nodes
// //   fill(0);
// //   for (int i = 0; i < numNodes; i++){
// //     circle(nodePos[i].x,nodePos[i].y,5);
// //   }
  
//   //Draw graph
//   stroke(100,100,100);
//   strokeWeight(1);
//   for (int i = 0; i < numNodes; i++){
//     for (int j : neighbors[i]){
//       line(nodePos[i].x, 0, nodePos[i].y,nodePos[j].x,0,nodePos[j].y);
//     }
//   }
  
// //   //Draw Start and Goal
// //   fill(20,60,250);
// //   //circle(nodePos[startNode].x,nodePos[startNode].y,20);
// //   circle(startPos.x,startPos.y,20);
// //   fill(250,30,50);
// //   //circle(nodePos[goalNode].x,nodePos[goalNode].y,20);
// //   circle(goalPos.x,goalPos.y,20);
  
//   if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
  
//   //Draw Planned Path
//   stroke(20,255,40);
//   strokeWeight(5);
//   if (curPath.size() == 0){
//     line(startPos.x,0,startPos.y,goalPos.x,0,goalPos.y);
//     return;
//   }
//   line(startPos.x,0,startPos.y,nodePos[curPath.get(0)].x,0,nodePos[curPath.get(0)].y);
//   for (int i = 0; i < curPath.size()-1; i++){
//     int curNode = curPath.get(i);
//     int nextNode = curPath.get(i+1);
//     line(nodePos[curNode].x,0,nodePos[curNode].y,nodePos[nextNode].x,0,nodePos[nextNode].y);
//   }
//   line(goalPos.x,0,goalPos.y,nodePos[curPath.get(curPath.size()-1)].x,0,nodePos[curPath.get(curPath.size()-1)].y);
  
// }

// draws coordinate system of scene for debugging
void drawBounds() {
    // x axis --> red
    stroke(255,0,0);
    line(0,0,0,3000,0,0);
    line(0,0,0,-3000,0,0);
    

    // y axis --> green
    stroke(0,255,0);
    line(0,0,0,0,3000,0);
    line(0,0,0,0,-3000,0);

    // z axis --> blue
    stroke(0,0,255);
    line(0,0,0,0,0,3000);
    line(0,0,0,0,0,-3000);
}

// drawing borders of the scene
void drawFloor() {
    noStroke();
    fill(11, 43, 20);
    float x = sceneX/100;
    float z = sceneZ/100;
    for (int i = 0; i < 100; i++) {
        for (int j = 0; j < 100; j++) {
            pushMatrix();
                translate((-sceneX*0.5) + i*x, 5, (-sceneZ*0.5) + j*z);
                box(x, 10, z);
            popMatrix();
        }
    }
    strokeWeight(strokeWidth);
}

// draw obstacles :)
void drawObstacles() {
    noStroke();
    for (int i = 0; i < numObstacles; i++) {
        Vec3 currPos = circlePos.get(i);
        Vec3 currCol = circleColor.get(i);
        float currRad = circleDrawRad.get(i);
        fill(currCol.x, currCol.y, currCol.z);
        pushMatrix();
            translate(currPos.x, currPos.y, currPos.z);
            sphere(currRad);
        popMatrix();
    }   
    strokeWeight(strokeWidth);
}

// void drawMouseRay() {
//   strokeWeight(3);
//   stroke(0);
//   line(
//     mouseOrig.x, 
//     mouseOrig.y, 
//     mouseOrig.z,
//     mouseOrig.x + mouseRay.x*10000, 
//     mouseOrig.y + mouseRay.y*10000, 
//     mouseOrig.z + mouseRay.z*10000
//   );
//   strokeWeight(strokeWidth);
// }

void drawKiwi() {
    pushMatrix();  
        translate(agentPos.x, agentPos.y, agentPos.z);
        scale(kiwiScale);
        shape(shapes[currFrame]);
    popMatrix();
    // pushMatrix();
    //     noFill();
    //     strokeWeight(strokeWidth);
    //     stroke(255);
    //     translate(agentPos.x, agentPos.y, agentPos.z);
    //     sphere(agentColRad);
    // popMatrix();
}