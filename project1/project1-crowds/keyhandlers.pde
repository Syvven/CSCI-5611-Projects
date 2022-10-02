void checkPressed() {
    if (shipMoveNeg.length() > 0) shipMoveNeg.normalize();
    if (shipMovePos.length() > 0) shipMovePos.normalize();
    shipMove.x = shipMoveNeg.x + shipMovePos.x;
    shipMove.y = shipMoveNeg.y + shipMovePos.y;
    // goalPos.x += shipMove.x*5;
    // goalPos.y += shipMove.y*5;

    cameraForward.x = forwardDir.x; cameraForward.y = forwardDir.z;
    cameraForward.normalize();

    cameraBackward.x = cameraForward.x*-1;
    cameraBackward.y = cameraForward.y*-1;

    cameraRight.x = rightDir.x; cameraRight.y = rightDir.z;
    cameraRight.normalize();

    cameraLeft.x = cameraRight.x*-1;
    cameraLeft.y = cameraRight.y*-1;

    cameraLeft.mul(shipMoveNeg.y);
    cameraRight.mul(shipMovePos.y);
    cameraForward.mul(shipMovePos.x);
    cameraBackward.mul(shipMoveNeg.x);

    Vec2 direction = cameraForward.plus(cameraBackward.plus(cameraRight.plus(cameraLeft)));

    direction.mul(5);
    goalPos.add(direction);

    if (direction.x != 0 || direction.y != 0) {
        if (!atGoal) {
            startPos.x = agentPos.x; startPos.y = agentPos.z;

            if (!startOrGoalInCircleList(circlePosArr, circleRadArr, numObstacles, goalPos, epsilon)) {
                curPath = planPath(startPos, goalPos, circlePosArr, circleRadArr, numObstacles, nodePos, numNodes);
                noGoal = false;
                indexCounter = 1;
                nextNode = curPath.get(1);
                goalNode = curPath.get(curPath.size()-1);
                nextPos = newNodePos[nextNode];
                agentVel = nextPos.minus(startPos).normalized().times(goalSpeed);
                return;
            }
            noGoal = true;
            return;
        }
        agentPos.x = goalPos.x;
        agentPos.z = goalPos.y;
    }
}

void mouseWheel(MouseEvent event) {
    
}

void mouseReleased() {
  // mouseCast = true;
  // mouseRay = cameraRay(mouseX, mouseY);
  // mouseOrig = new Vec3(camera.position.x, camera.position.y, camera.position.z);
}

void keyPressed()
{
    camera.HandleKeyPressed();
    if ( key == 'i' || key == 'I' ) {
        shipMovePos.x = 1;
    }
    if ( key == 'j' || key == 'J' ) {
        shipMoveNeg.y = 1;
    }
    if ( key == 'l' || key == 'L' ) {
        shipMovePos.y = 1;
    }
    if ( key == 'k' || key == 'K' ) {
        shipMoveNeg.x = 1;
    }
}

void keyReleased()
{
    camera.HandleKeyReleased();
    if (key == 'r') reset();
    if (key == 'p') paused = !paused;
    if (key == 'c') is3d = !is3d;
    if ( key == 'i' || key == 'I' ) {
        shipMovePos.x = 0;
    }
    if ( key == 'j' || key == 'J' ) {
        shipMoveNeg.y = 0;
    }
    if ( key == 'l' || key == 'L' ) {
        shipMovePos.y = 0;
    }
    if ( key == 'k' || key == 'K' ) {
        shipMoveNeg.x = 0;
    }
}

// Vec3 cameraRay(float x, float y) {
//   float imageAspectRatio = camera.aspectRatio;  //assuming width > height 
//   float px = (2 * ((x + 0.5) / displayWidth) - 1) * tan(camera.fovy / 2 * PI / 180) * imageAspectRatio; 
//   float py = (1 - 2 * ((y + 0.5) / displayHeight) * tan(camera.fovy / 2 * PI / 180)); 
//   Vec3 rayOrigin = new Vec3(camera.position.x, camera.position.y, camera.position.z); 
//   Vec3 rayDirection = new Vec3(px, py, -1);  //note that this just equal to Vec3f(Px, Py, -1); 
//   rayDirection = rayDirection.normalized();  //it's a direction so don't forget to normalize
//   return rayDirection;
// }
