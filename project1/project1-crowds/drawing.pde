// main draw loop
void draw() {
    // updates things
    camera.Update(1.0/frameRate);
    updateKiwiFrame();
    checkPressed();
    update();

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
    pushMatrix();
        noFill();
        strokeWeight(strokeWidth);
        stroke(255);
        translate(agentPos.x, agentPos.y, agentPos.z);
        sphere(agentColRad);
    popMatrix();
}