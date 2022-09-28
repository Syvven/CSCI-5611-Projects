void update(float dt) {
    float dist = agentPos.distanceTo(nextPos);
    if (dist < goalSpeed*dt) {
        if (nextNode == goalNode) {
            agentPos.x = goalPos.x;
            agentPos.y = kiwiYOffset;
            agentPos.z = goalPos.y;
            agentVel.x = 0; agentVel.y = 0;
        } else {
            agentPos = new Vec3(nextPos.x, agentPos.y, nextPos.y);
            indexCounter++;
            nextNode = curPath.get(indexCounter);
            nextPos = newNodePos[nextNode];
            agentVel = nextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized().times(goalSpeed);
        }
    } else {
        Vec2 dir = nextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized();
        println("line");
        stroke(255,0,0);
        strokeWeight(2);
        line(agentPos.x, agentPos.z, agentPos.x+dir.x*100, agentPos.z+dir.y*100);
        hitInfo hit = rayCircleListIntersect(circlePosArr, circleRadArr, numObstacles, new Vec2(agentPos.x, agentPos.z), dir, dist);
        
        if (hit.hit && (indexCounter < curPath.size()-1)) {
            indexCounter++;
            nextNode = curPath.get(indexCounter);
            nextPos = newNodePos[nextNode];
            agentVel = nextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized().times(goalSpeed);
        }
    }
    agentPos.add(agentVel.times(dt));
}

void updateKiwiFrame() {
    t = tbase-agentVel.length()*0.00001;
    if (t > 0.99) t = 0.99;
    if (t < 0.91) t = 0.93;
    agentDir = agentDir*t+(1-t)*atan2(agentVel.x, agentVel.y);

    kiwiTime += agentVel.length()*0.005;
    if (kiwiTime > 1/kiwi_framerate) {
        kiwiTime = 0;
        kiwiSwitchFrame++;
        if (kiwiSwitchFrame == times[currFrame]) {
            kiwiSwitchFrame = 0;
            currFrame = (currFrame+1)%kiwiFrames;
        }
    }
}