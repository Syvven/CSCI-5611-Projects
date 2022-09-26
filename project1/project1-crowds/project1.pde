// Project 1 Part 2
/////////////////////////////

// scene dimensions
float sceneX = 1500;
float sceneY = 1500;
float sceneZ = 1500;

// node stuff
static int numNodes = 100;
static int maxNumNodes = 1000;

// obstacles
ArrayList<Vec3> circleVel = new ArrayList<Vec3>();
ArrayList<Vec3> circlePos = new ArrayList<Vec3>();
ArrayList<Float> circleRad = new ArrayList<Float>();
ArrayList<Vec3> circleColor = new ArrayList<Vec3>();
static int initObstacles = 200;
int numObstacles = initObstacles;

Camera camera;

// useful things
float ninety, oneeighty, twoseventy, threesixty;
float epsilon = 1e-6;

// drawing info
int strokeWidth = 2;
PImage conkcrete;

// key state variables
boolean moveObjects = false;
boolean mouseCast = false;
Vec3 mouseRay, mouseOrig;

// vertices for drawing floor
Vec3[][] floor = new Vec3[][]{
    {new Vec3(sceneX/2+20,0,sceneZ/2+20),new Vec3(0,0,0)},
    {new Vec3(sceneX/2+20,0,-sceneZ/2-20),new Vec3(0,1,0)},
    {new Vec3(-sceneX/2-20,0,-sceneZ/2-20),new Vec3(1,0,0)},
    {new Vec3(-sceneX/2-20,0,sceneZ/2+20),new Vec3(1,1,0)}
};

void setup() {
    size(1200, 1200, P3D);
    surface.setTitle("CSCI 5611 Project 1 Part 2");
    surface.setResizable(true);
    surface.setLocation(500,500);
    strokeWeight(2);

    camera = new Camera();

    // useful things
    oneeighty = radians(180);
    ninety = radians(90);
    twoseventy = radians(270);
    threesixty = radians(360);

    // image/model loading
    conkcrete = loadImage("data/conkcrete.jpg");

    placeRandomObstacles();
}

void placeRandomObstacles(){
  //Initial obstacle position
  circleRad.add(30.0); //Make the first obstacle big
  circlePos.add(new Vec3(
      random(-sceneX*0.5,sceneX*0.5),
      -circleRad.get(0),
      random(-sceneZ*0.5,sceneZ*0.5)
  ));
  circleColor.add(new Vec3(
      random(255),
      random(255),
      random(255)
  ));

  for (int i = 1; i < numObstacles; i++){
    circleRad.add((10+40*pow(random(1),3)));
    circlePos.add(new Vec3(
        random(-sceneX*0.5,sceneX*0.5),
        -circleRad.get(i),
        random(-sceneZ*0.5,sceneZ*0.5)
    ));
    circleColor.add(new Vec3(
        random(255),
        random(255),
        random(255)
    ));
  }
  circleRad.set(0, 30.0); //Make the first obstacle big
}

void reset() {
    
}

void update() {
    
}

// draws coordinate system of scene for debugging
void drawBounds() {
    // x axis --> red
    stroke(255,0,0);
    line(0,0,0,3000,0,0);
    line(0,0,0,-3000,0,0);
    

    // y axis --> green
    stroke(0,255,0);
    line(0,0,0,0,3000,0);
    line(0,0,0,0,-3000,0);

    // z axis --> blue
    stroke(0,0,255);
    line(0,0,0,0,0,3000);
    line(0,0,0,0,0,-3000);
}

// drawing borders of the scene
void drawFloor() {
    fill(11, 43, 20);
    textureMode(NORMAL);
    beginShape();
        texture(conkcrete);
        for (var vertex : floor) {
            vertex(vertex[0].x, vertex[0].y, vertex[0].z, vertex[1].x, vertex[1].y);
        }
    endShape(CLOSE);
}

// draw obstacles :)
void drawObstacles() {
    noStroke();
    for (int i = 0; i < numObstacles; i++) {
        Vec3 currPos = circlePos.get(i);
        Vec3 currCol = circleColor.get(i);
        float currRad = circleRad.get(i);
        fill(currCol.x, currCol.y, currCol.z);
        pushMatrix();
            translate(currPos.x, currPos.y, currPos.z);
            sphere(currRad);
        popMatrix();
    }   
    strokeWeight(strokeWidth);
}

// void drawMouseRay() {
//   strokeWeight(3);
//   stroke(0);
//   line(
//     mouseOrig.x, 
//     mouseOrig.y, 
//     mouseOrig.z,
//     mouseOrig.x + mouseRay.x*10000, 
//     mouseOrig.y + mouseRay.y*10000, 
//     mouseOrig.z + mouseRay.z*10000
//   );
//   strokeWeight(strokeWidth);
// }

// main draw loop
void draw() {
    background(50);

    // Sets the default ambient 
    // and directional light
    colorMode(HSB, 360, 100, 100);
    lightFalloff(1,0,0);
    lightSpecular(0,0,10);
    ambientLight(0,0,100);
    directionalLight(128,128,128, 0,0,0);
    colorMode(RGB, 255, 255, 255);

    // concentration = map(cos(frameCount * .01), -1, 1, 12, 100);
    // mouse.set(mouseX - half.x, mouseY - half.y, viewOff);
    // mouse.normalize();

    // // Flash light.
    // spotLight(
    //     191, 170, 133,
    //     0, 0, viewOff,
    //     mouse.x, mouse.y, -1,
    //     angle, concentration
    // );

    camera.Update(1.0/frameRate);

    // used for understanding where the bounds of the scene are
    drawFloor();
    drawBounds();
    drawObstacles();
    // if (mouseCast) {
    //   drawMouseRay();
    // }
    checkPressed();
    update();
}

void checkPressed() {

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
  if (key == 'v') {
    moveObjects = !moveObjects;
  }
}

void keyReleased()
{
  camera.HandleKeyReleased();
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
