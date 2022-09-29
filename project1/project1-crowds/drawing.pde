// main draw loop
void draw() {
    // updates things
    camera.Update(1.0/frameRate);
    checkPressed();
    if (!paused) {
        update(1.0/frameRate);
        updateKiwiFrame();
    }

    if (is3d) {
        background(0);
        drawSkyBox();
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
        // drawBounds();
        // if (mouseCast) {
        //   drawMouseRay();
        // }

        // colorMode(HSB, 360, 100, 100);
        // lightFalloff(0.1, 0, 0);
        // spotLight(
        //     360,100, 100,
        //     agentPos.x, agentPos.y-80*kiwiScale, agentPos.z,
        //     0,1,0,
        //     ninety*0.25,
        //     500
        // );
        // colorMode(RGB, 255, 255, 255);

        // draws obstacles, agent and floor if you want
        drawObstacles(1/frameRate);
        drawPointLight();
        drawKiwi();
        // drawFloor();
    
        // //Draw graph
        // stroke(50,50,50);
        // strokeWeight(1);
        // for (int i = 0; i < numNodes+2; i++){
        //     for (int j : neighbors[i]){
        //     line(newNodePos[i].x, 0, newNodePos[i].y,newNodePos[j].x,0,newNodePos[j].y);
        //     }
        // }

        
        // if (curPath.size() >0 && curPath.get(0) == -1) return; //No path found
        
        // //Draw Planned Path
        // stroke(20,255,40);
        // strokeWeight(5);
        // if (curPath.size() == 0){
        //     line(startPos.x,0,startPos.y,goalPos.x,0,goalPos.y);
        //     return;
        // }
        // for (int i = 0; i < curPath.size()-1; i++){
        //     int curNode = curPath.get(i);
        //     int nextNode = curPath.get(i+1);
        //     line(newNodePos[curNode].x,0,newNodePos[curNode].y,newNodePos[nextNode].x,0,newNodePos[nextNode].y);
        // }
    } else {
        strokeWeight(1);
        background(200); //Grey background
        stroke(0,0,0);
        fill(255,255,255);
        
        
        //Draw the circle obstacles
        for (int i = 0; i < numObstacles; i++){
            if (validCircles[i]) {
                Vec2 c = circlePosArr[i];
                float r = circleRadArr[i];
                circle(c.x,c.y,r*2);
            }
        }
        //Draw the first circle a little special b/c the user controls it
        fill(240);
        strokeWeight(2);
        circle(circlePosArr[0].x,circlePosArr[0].y,circleRadArr[0]*2);
        strokeWeight(1);
        
        //Draw PRM Nodes
        fill(0);
        for (int i = 0; i < numNodes; i++){
            circle(nodePos[i].x,nodePos[i].y,5);
        }
        
        //Draw graph
        stroke(100,100,100);
        strokeWeight(1);
        for (int i = 0; i < numNodes+2; i++){
            for (int j : neighbors[i]){
            line(newNodePos[i].x,newNodePos[i].y,newNodePos[j].x,newNodePos[j].y);
            }
        }
        
        //Draw Start and Goal
        fill(20,60,250);
        //circle(nodePos[startNode].x,nodePos[startNode].y,20);
        circle(agentPos.x,agentPos.z,20);
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
            line(newNodePos[curNode].x,newNodePos[curNode].y,newNodePos[nextNode].x,newNodePos[nextNode].y);
        }
        line(goalPos.x,goalPos.y,newNodePos[curPath.get(curPath.size()-1)].x,newNodePos[curPath.get(curPath.size()-1)].y);
        
    }
    
}

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

// // drawing borders of the scene
// void drawFloor() {
//     noStroke();
//     fill(1,0,0);
//     float x = sceneX/100;
//     float z = sceneZ/100;
//     for (int i = 0; i < 100; i++) {
//         for (int j = 0; j < 100; j++) {
//             pushMatrix();
//                 translate((-sceneX*0.5) + i*x, 5, (-sceneZ*0.5) + j*z);
//                 box(x, 10, z);
//             popMatrix();
//         }
//     }
//     strokeWeight(strokeWidth);
// }

// draw obstacles :)
void drawObstacles(float dt) {
    noFill();
    for (int i = 0; i < numObstacles; i++) {
        float rot = circleRot.get(i);
        float rotRate = circleRotRate.get(i);
        rot += rotRate;
        circleRot.set(i, rot);
        Float[] tilt = circleTilt.get(i);
        Vec3 currPos = circlePos.get(i);
        Vec3 currCol = circleColor.get(i);
        float currRad = circleDrawRad.get(i);
        // fill(currCol.x, currCol.y, currCol.z);
        pushMatrix();
            translate(currPos.x, currPos.y, currPos.z);
            rotateX(tilt[0]);
            rotateZ(tilt[1]);
            rotateY(rot);
            shape(circleShape.get(i));
        popMatrix();
    }   
}

void drawSkyBox() {
    // pushMatrix();
    // textureMode(NORMAL);
    // float size = 5000;
    // for(int i = 0; i < 6; i++)
    // {
    //   beginShape();
    //   texture(skybox[i]);
    //   vertex(size - (size * 2), size,              (size - 1) - ((size - 1) * 2), 0, 0);
    //   vertex(size,              size,              (size - 1) - ((size - 1) * 2), 1, 0);
    //   vertex(size,              size - (size * 2), (size - 1) - ((size - 1) * 2), 1, 1);
    //   vertex(size - (size * 2), size - (size * 2), (size - 1) - ((size - 1) * 2), 0, 1);
    //   endShape();
    //   if(i < 4)  rotateY(HALF_PI);
    //   if(i == 3) rotateX(HALF_PI);
    //   if(i >= 4) rotateX(PI);
    //   if(i == 5) rotateY(PI);
    // }
    // popMatrix();
    pushMatrix();
    shape(back);
    popMatrix();
}

void drawPointLight() {
    colorMode(HSB, 360, 100, 100);
    lightFalloff(0.1, 0, 0);
    pointLight(
        0,0,100,
        agentPos.x, agentPos.y-50, agentPos.z
    );
    colorMode(RGB, 256, 256, 256);
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
        rotateY(agentDir);
        scale(kiwiScale);
        shape(shapes[currFrame]);
    popMatrix();

    // draws the collision
    // pushMatrix();
    //     noFill();
    //     strokeWeight(strokeWidth);
    //     stroke(255);
    //     translate(agentPos.x, agentPos.y, agentPos.z);
    //     sphere(agentColRad);
    // popMatrix();
}