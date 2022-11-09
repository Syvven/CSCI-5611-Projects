/* Sources: 
    -> https://www.spriters-resource.com/pc_computer/bindingofisaacrebirth/sheet/146176/ -- floor sprite
    -> 

*/

PImage[] floor;

void setup() {
    size(1200,1200);
    surface.setTitle("Project 3: Inverse Kinematics");
    // surface.setResizable(true);

    floor = new PImage[4];

    for (int i = 0; i < 4; i++) {
        floor[i] = loadImage("images/floor.png");
    }
    
}

float rad90 = radians(90);
float floor_x, floor_y, floor_w, floor_h;
void drawFloor() {
    imageMode(CENTER);
    boolean flip = false;
    boolean first = true;
    int rot = 0;
    for (int i = 1; i < 4; i+=2) {
        for (int j = 1; j < 4; j+=2) {
            if (width > height) {
                floor_x = (height*0.25*j) + width*0.25;
                floor_y = (height*0.25*i);
                floor_w = height*0.5; floor_h = width*0.5;
            }
            if (height > width) {
                floor_x = (width*0.25*j);
                floor_y = (width*0.25*i) + height*0.25;
                floor_w = width*0.5; floor_h = width*0.5;
            }
            if (height == width) {
                floor_x = (height*0.25*j); floor_w = height*0.5;
                floor_y = (height*0.25*i); floor_h = height*0.5;
            }
            pushMatrix();
            translate(floor_x, floor_y);
            if (flip) {
                scale(-1, 1);
            }
            rotate(rad90+(rad90*rot)+(first ? -rad90 : 0));
            image(floor[i], 0,0, floor_w, floor_h);
            popMatrix();
            flip = !flip;
        }
        rot++;
        flip = true;
        first = false;
    }
}

void draw() {
    background(0,0,0);

    drawFloor();
}