void update(float dt) {
    float dist = agentPos.distanceTo(nextPos);
    if (dist < goalSpeed*dt) {
        if (nextNode == goalNode) {
            agentPos.x = goalPos.x;
            agentPos.y = kiwiYOffset;
            agentPos.z = goalPos.y;
            // agentVel.x = 0; agentVel.y = 0;
            // agentFinalVel.x = 0; agentFinalVel.y = 0;
            atGoal = true;
            cameraFollowAgent = false;
            firstPerson = false;
        } else {
            agentPos = new Vec3(nextPos.x, agentPos.y, nextPos.y);
            indexCounter++;
            nextNode = curPath.get(indexCounter);
            nextPos = newNodePos[nextNode];
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
        }
    }   
    if (!atGoal) {
        agentFinalVel = nextPos.minus(new Vec2(agentPos.x, agentPos.z)).normalized().times(goalSpeed);
        agentVel = interpolate(agentVel, agentFinalVel, 0.05*goalSpeed/100);
        backVel = agentVel.times(-1);
        backDir = interpolate(backDir, backVel, 0.01*goalSpeed/100);
        forwardDir = interpolate(forwardDir, agentVel.normalized(), 0.13);

        if (agentVel.length() != goalSpeed) {
            agentVel = agentVel.normalized().times(goalSpeed);
        }
        agentPos.add(agentVel.times(dt));
    }

    
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

void updateKiwiParticles(float dt) {
    float toGen_float = genRate*dt;
    int toGen = int(toGen_float);
    float fractPart = toGen_float-toGen;
    if (random(1) < fractPart) toGen++;
    if (numParticles < maxParticles) {
        for (int p = 0; p < toGen; p++) {
            particlePos.add(
                agentPos.plus(backDir.normalized().times(agentColRad-0.5*kiwiScale))
            );
            particleVel.add(new Vec3(
                backDir.x + random(-30, 30),
                agentPos.y + random(-30, 30),
                backDir.y + random(-30, 30)
            ).normalized().times(goalSpeed));
            particleCol.add(startColor);
            particleLife.append(0.0);
            numParticles++;
        }
    }

    for (int i = 0; i < numParticles; i++) {
        float life = particleLife.get(i);
        particleLife.set(i, life+dt);
        if (life < maxLife) {
            Vec3 col = particleCol.get(i);
            Vec3 currPos = particlePos.get(i);

            currPos.add(particleVel.get(i).times(dt));
            if (life < maxLife * 0.8) {
                particleCol.set(i, interpolate(col, endColor, 0.3));
            } else {
                particleCol.set(i, interpolate(col, smoke, 0.2));
            }
            

            particlePos.set(i, currPos);
        } else {
            particlePos.remove(i);
            particleVel.remove(i);
            particleLife.remove(i);
            particleCol.remove(i);
            numParticles--;
        }
    }
}

