static int maxParticles = 500; // per moai
float genRate = maxParticles; // per moai
float maxLife = maxParticles/genRate;
Vec3 gravity = new Vec3(0,60,0);
ArrayList<Vec3>[] pos = new ArrayList[numMoai];
ArrayList<Vec3>[] vel = new ArrayList[numMoai];
ArrayList<Float>[] life = new ArrayList[numMoai];
int[] numParticles = new int[numMoai];
float COR = 0;
float partRad = 1;

void updateParticles(float dt) {
    float toGen_float = genRate*dt;
    int toGen = int(toGen_float);
    float fractPart = toGen_float-toGen;
    if (random(1) < fractPart) toGen++;
    for (int m = 0; m < numMoai; m++) {
        if (numParticles[m] < maxParticles) {
            for (int p = 0; p < toGen; p+=2) {
                pos[m].add(new Vec3(
                    moaiNosePos[m].x,
                    moaiNosePos[m].y,
                    moaiNosePos[m].z
                ));
                pos[m].add(new Vec3(
                    moaiNosePos[m].x,
                    moaiNosePos[m].y,
                    moaiNosePos[m].z
                ));
                vel[m].add(new Vec3(
                    -112 + random(-48, 48),
                    112,
                    -32 + random(-48, 48)
                ));
                vel[m].add(new Vec3(
                    -32 + random(-48, 48),
                    112,
                    -112 + random(-48, 48)
                ));
                life[m].add(0.0);
                life[m].add(0.0);
                numParticles[m]+=2;
            }
        }   
    }

    for (int m = 0; m < numMoai; m++) {
        for (int i = 0; i < numParticles[m]; i++) {
            life[m].set(i, life[m].get(i)+dt);
            if (life[m].get(i) < maxLife) {
                // do stuff
                Vec3 curr_pos = pos[m].get(i);
                Vec3 curr_vel = vel[m].get(i);

                curr_pos.add(curr_vel.times(dt));

                if (curr_pos.y > 0-partRad) {
                    curr_pos.y = 0-partRad;
                    curr_vel.y *= -COR;
                }

                curr_vel.add(gravity.times(dt));

                pos[m].set(i, curr_pos);
                vel[m].set(i, curr_vel);
            } else {
                pos[m].remove(i);
                vel[m].remove(i);
                life[m].remove(i);
                numParticles[m]--;
            }
        }
    }
}