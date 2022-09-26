void update(float dt) {
    println(agentPos.distanceTo(nextPos));
    if (agentPos.distanceTo(nextPos) < 50) {
        if (nextNode == goalNode) {
            agentPos = new Vec3(goalPos.x, kiwiYOffset, goalPos.y);
            agentVel = new Vec2(0,0);
        } else {
            indexCounter++;
            currNode = nextNode;
            currPos = nextPos;
            nextNode = curPath.get(indexCounter);
            nextPos = nodePos[nextNode];
            agentVel = nextPos.minus(currPos);
            agentVel = agentVel.normalized().times(goalSpeed);
        }
    }
    agentPos.add(agentVel.times(dt));
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