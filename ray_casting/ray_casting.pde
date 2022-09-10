// ray caster
int num_squares = 10;
int rec_width, rec_height;

// 
float[][] map = new float[num_squares][num_squares];
Rectangle[][] recs = new Rectangle[num_squares][num_squares];
int num_rays = 3; // always odd
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
    rays[0] = new Vec2(1, 0); // initializes start direction
}

void update_rays() {
    for (int i = 1; i < floor(num_rays/2)+1; i++) {
        float angle = i*fov/(num_rays-1);
        rays[i*2-1] = rays[0].rotate(angle).normalized();
        rays[i*2] = rays[0].rotate(-angle).normalized();
    }
}

void ray_collisions() {
    
}

Rectangle curr;
void draw() {
    rectMode(CORNER);
    background(255);
    stroke(0,0,0);
    fill(100);

    // drawing for reference // delete when done
    for (int i = 0; i < map.length; i++) {
        for (int j = 0; j < map[0].length; j++) {
            curr = recs[i][j];
            if (curr != null) {
                rect(curr.tLeft.x, curr.tLeft.y, curr.rwidth, curr.rheight);
            }
        }
    }
    circle(curr_square[2], curr_square[3], 10.0);

    update_rays();
    ray_collisions();

    // drawing for reference // delete when done
    for (int i = 0; i < rays.length; i++) {
        Vec2 curr_ray = rays[i];
        line(curr_square[2], curr_square[3], curr_square[2]+curr_ray.x*width, curr_square[3]+curr_ray.y*height);
    }
}

void keyPressed() {
    if (keyCode == LEFT) {
        if (recs[curr_square[0]-1][curr_square[1]] == null) {
            curr_square[0]--;
            curr_square[2] -= rec_width;
        } 
    } else if (keyCode == RIGHT) {
        if (recs[curr_square[0]+1][curr_square[1]] == null) {
            curr_square[0]++;
            curr_square[2] += rec_width;
        } 
    } else if (keyCode == DOWN) {
        if (recs[curr_square[0]][curr_square[1]+1] == null) {
            curr_square[1]++;
            curr_square[3] += rec_height;
        } 
    } else if (keyCode == UP) {
        if (recs[curr_square[0]][curr_square[1]-1] == null) {
            curr_square[1]--;
            curr_square[3] -= rec_height;
        } 
    } else if (key == 'a') {
        rays[0].rotated(-radians(3));
        rays[0].normalize();
    } else if (key == 'd') {
        rays[0].rotated(radians(3));
        rays[0].normalize();
    } 
}

