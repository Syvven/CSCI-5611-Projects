float noiseScale = 0.005;

void setup() {
    size(500,500);
    surface.setResizable(true);
}

// void draw() {
//   background(0);
//   for (int x=0; x < width; x++) {
//     float noiseVal = noise((mouseX+x)*noiseScale, mouseY*noiseScale);
//     stroke(noiseVal*255);
//     line(x, mouseY+noiseVal*80, x, height);
//   }
// }

float xoff = 0.0;

void draw() {
  for (int i = 0; i < width; i+=10) {
    for (int j = 0; j < height; j+=10) {
        float tNoise = noise(i*noiseScale, j*noiseScale);
        stroke(tNoise*255);
        for (int k = 0; k < 10; k++) {
            for (int l = 0; l < 10; l++) {
                point(i+k, j+l);
            }
        }
    }
  }
}