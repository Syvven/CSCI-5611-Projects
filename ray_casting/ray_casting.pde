// ray caster
int num_squares = 10;
int rec_width, rec_height;

// 
float[][] map = new float[num_squares][num_squares];
Rectangle[][] recs = new Rectangle[num_squares][num_squares];
int num_rays = 45; // always odd
Vec2[] rays = new Vec2[num_rays];
float fov = radians(90);
int[] curr_square;

void setup() {
    rec_width = width/num_squares;
    rec_height = height/num_squares;
    size(1200, 1200);
    surface.setTitle("Ray Caster");
    strokeWeight(2);
    for (int i = 0; i < map.length; i++) {
        for (int j = 0; j < map[0].length; j++) {
            if (i == 0 || i == map.length-1 || j == 0 || j == map[0].length-1) {
                map[i][j] = 1;
                recs[i][j] = new Rectangle(i*rec_width, j*rec_height, rec_width, rec_height);
            } else {
                map[i][j] = 0;
                recs[i][j] = null;
            }
        }
    }

    curr_square = new int[]{1, 1, rec_width+(rec_width/2), rec_height+(rec_height/2)};

    rays[0] = new Vec2(0, 1);
    for (int i = 1; i < floor(num_rays/2)+1; i++) {
        float angle = i*fov/num_rays;
        float newx = cos(angle*rays[0].x)-sin(angle*rays[0].y);
        float newy = sin(angle*rays[0].x)+cos(angle*rays[0].y);
        rays[i*2-1] = new Vec2(newx, newy);
        rays[i*2] = new Vec2(-newx, -newy);
    }
}

Rectangle curr;
void draw() {
    rectMode(CORNER);
    background(255);
    stroke(0,0,0);
    fill(100);

    for (int i = 0; i < map.length; i++) {
        for (int j = 0; j < map[0].length; j++) {
            curr = recs[i][j];
            if (curr != null) {
                rect(curr.tLeft.x, curr.tLeft.y, curr.rwidth, curr.rheight);
            }
        }
    }
    circle(curr_square[2], curr_square[3], 10.0);
    for (int i = 0; i < rays.length; i++) {
        Vec2 curr_ray = rays[i];
        line(curr_square[2], curr_square[3], curr_square[2]+curr_ray.x*100, curr_square[1]+curr_ray.y*100);
    }
}

void keyPressed() {
    if (key == 'a' || keyCode == LEFT) {
        if (recs[curr_square[0]-1][curr_square[1]] == null) {
            curr_square[0]--;
            curr_square[2] -= rec_width;
        } 
    } else if (key == 'd' || keyCode == RIGHT) {
        if (recs[curr_square[0]+1][curr_square[1]] == null) {
            curr_square[0]++;
            curr_square[2] += rec_width;
        } 
    } else if (key == 's' || keyCode == DOWN) {
        if (recs[curr_square[0]][curr_square[1]+1] == null) {
            curr_square[1]++;
            curr_square[3] += rec_height;
        } 
    } else if (key == 'w' || keyCode == UP) {
        if (recs[curr_square[0]][curr_square[1]-1] == null) {
            curr_square[1]--;
            curr_square[3] -= rec_height;
        } 
    }
}

