void update(float dt) {
    if (agentPos.distanceTo(nextPos) < goalSpeed*dt) {
        if (nextNode == goalNode) {
            agentPos = new Vec3(goalPos.x, kiwiYOffset, goalPos.y);
            agentVel = new Vec2(0,0);
        } else {
            agentPos = new Vec3(nextPos.x, agentPos.y, nextPos.y);
            indexCounter++;
            nextNode = curPath.get(indexCounter);
            nextPos = newNodePos[nextNode];
            agentVel = nextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized().times(goalSpeed);
        }
    } else {
        agentPos.add(agentVel.times(dt));

    }
}

void updateKiwiFrame() {
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