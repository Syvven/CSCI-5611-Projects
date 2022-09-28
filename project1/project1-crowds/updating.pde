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
    } else if (nextNode != goalNode) {
        Vec2 nextNextPos = newNodePos[curPath.get(indexCounter+1)];
        dist = agentPos.distanceTo(nextNextPos);
        Vec2 dir = nextNextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized();
        hitInfo hit = rayCircleListIntersect(circlePosArr, circleRadArr, numObstacles, new Vec2(agentPos.x, agentPos.z), dir, dist);
        if (!hit.hit) {
            indexCounter++;
            nextNode = curPath.get(indexCounter);
            nextPos = newNodePos[nextNode];
            agentVel = nextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized().times(goalSpeed);
        }
    }
    agentPos.add(agentVel.times(dt));
}

void updateKiwiFrame() {
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