int numLayers = 35; //increase to improve quality (toggle speed and frameRate too)
Layer[] layers = new Layer[numLayers];

float size = 50;
float speed = 1; //50 layers = .03 speed = 30 frameRate,  30/.05/20,  20/.12/15,  10/.2/5
float bx, by;
float x2, y2, r2, dy2, dx2, tailr2, l2;
float pi = 3.145;
float a, b, eye;

void setup() {
  //size(displayWidth, displayHeight);
  fullScreen();
  frameRate(144);

  // creates layers of whale from back first
  for (int i = layers.length-1; i >= 0; i--) {
    layers[i] = new Layer(i);
    mouseX = width/2;
    mouseY = height/2;
  }
}

void draw() {
  background(200, 230, 250);
  strokeWeight(0); 

  eye = 0;

  x2 = mouseX;
  y2 = mouseY;
  for (int i = layers.length-1; i >= 0; i = i-1) {
    layers[i].updateLayer();
  }
  for (int i = 0; i < layers.length; i++) {
    layers[i].drawLayer();
  }
}

class Layer {
  float X, Y, R, dY, L, gray, X2, Y2, R2, dY2, first, tailR, dX, BX, BY, dX2, tailR2, L2;
  Layer(float i) {
    // L --> 1 minus current Layer divided by total # layers
    L = 1-i/numLayers;
    R = (30*pow(L, 3)-58.5*sq(L)+28*L+.92) * size/2; //body radius equation
    dY = (10*pow(L, 3)-10*sq(L)) * size; ////body placement equation
    gray = 220-100*L; //body color
    if (i == numLayers-1) {
      first = 1; //last layer = nose
    }

    if (L > .775) { //tail length
      dX = (22*sq(L)-30*L+10) * size; //change in tail 
      if (i==0) {
        tailR = 0;
        R = 0;
      } else {
        tailR = (-86.7*sq(L)+153.2*L-66) * size/2; //tail radius
      }
    }

    R2 = r2; //smoothing factors (lowercase = global, uppercase = layer)
    dY2 = dy2; 
    dX2 = dx2; 
    tailR2 = tailr2; 
    L2 = l2;
    r2 = R; 
    dy2 = dY; 
    dx2 = dX; 
    tailr2 = tailR; 
    l2 = L;
  }

  void updateLayer() {
    BX = bx;
    BY = by; 
    bx = X; 
    by = Y; 
    if (first == 1) {
      X = (speed/numLayers*x2+X)/(speed/numLayers+1);
      Y = (speed/numLayers*y2+Y)/(speed/numLayers+1);
    } else {
      X = BX;
      Y = BY;
    }

    X2 = x2; 
    Y2 = y2;  
    x2 = X; 
    y2 = Y;
  }

  void drawLayer() {
    fill(gray); 
    stroke(gray); 
    strokeWeight(0);

    if (L <= .775) {
      ellipse(X, Y-dY, R*2, R*2); //body

      if (L > .3 & L <= .4) { 
        rotate(pi/4);
        a = X-R;
        b = Y+R*.6;
        ellipse(sqrt(sq(a)+sq(b))*sin(pi/4+atan(a/b)), sqrt(sq(a)+sq(b))*cos(pi/4+atan(a/b)), size*(L-.3)*15, size*(L-.3)*40); //left fin
        a = X+R;
        ellipse(sqrt(sq(a)+sq(b))*sin(pi/4+atan(a/b)), sqrt(sq(a)+sq(b))*cos(pi/4+atan(a/b)), size*(L-.3)*40, size*(L-.3)*15); //right fin
        rotate(-pi/4);
      }

      fill(gray+25); 
      strokeWeight(2);
      stroke(gray+25);
      beginShape(); //belly
      if (first != 1) {
        vertex(X2+cos(pi/6)*R2, Y2-dY2+sin(pi/6)*R2);
      }
      for (float i = pi/6; i <= 5*pi/6; i=i+pi/15) {
        vertex(X+cos(i)*R, Y-dY+sin(i)*R);
      }
      vertex(X+cos(5*pi/6)*R, Y-dY+sin(5*pi/6)*R);
      if (first != 1) {
        vertex(X2+cos(5*pi/6)*R2, Y2-dY2+sin(5*pi/6)*R2);
      }
      vertex(X, Y-dY+R/3);
      endShape(CLOSE);

      if (L >.4 & L<.5) {
        fill(gray-50); 
        stroke(gray-50);
        beginShape(); 
        vertex(X2+cos((17+abs(L2-.45)/.05)*pi/12)*R2, Y2-dY2+sin((17+abs(L2-.45)/.05)*pi/12)*R2);
        for (float i = (17+abs(L-.45)/.05)*pi/12; i <= (19-abs(L-.45)/.05)*pi/12; i=i+pi/50) {  // blowhole
          vertex(X+cos(i)*R, Y-dY+sin(i)*R);
        }
        vertex(X2+cos((19-abs(L2-.45)/.05)*pi/12)*R2, Y2-dY2+sin((19-abs(L2-.45)/.05)*pi/12)*R2);
        endShape(CLOSE);
      } else if (L < .2) {
        stroke(150); 
        strokeWeight(3);
        for (int i=1; i>=-1; i=i-2) {
          if (first != 1) {
            line(X2+i*cos(pi/6)*R2, Y2-dY2+sin(pi/6)*R2, X+i*cos(pi/6)*R, Y-dY+sin(pi/6)*R); // mouth
          } else { 
            line(X+i*cos(5*pi/6)*R, Y-dY+sin(5*pi/6)*R, X, Y-dY+R/3);
          }
        }
        strokeWeight(0);
        if (eye == 0) {
          for (int i=1; i>=-1; i=i-2) {
            fill(0); 
            stroke(0); 
            ellipse(X+i*R*.9, Y-R*.15, size/3, size/3); // eye
            fill(250); 
            stroke(250);
            ellipse(X+i*R*.93, Y-R*.18, size/10, size/10);
          }
          eye = 1;
        }
      }
    } else {
      for (int i=1; i>=-1; i=i-2) {
        beginShape();
        vertex(X+i*dX, Y-dY+R); 
        vertex(X2+i*dX2, Y2-dY2+R2);
        vertex(X2+i*dX2, Y2-dY2-R2);
        vertex(X+i*dX, Y-dY-R);
        endShape(CLOSE);
        beginShape();
        vertex(X+i*dX, Y-dY+R); 
        vertex(X+i*dX-tailR, Y-dY); 
        vertex(X+i*dX, Y-dY-R);
        vertex(X+i*dX+tailR, Y-dY); 
        endShape(CLOSE);
        beginShape();
        vertex(X+i*dX-tailR, Y-dY);
        vertex(X2+i*dX2-tailR2, Y2-dY2); 
        vertex(X2+i*dX2+tailR2, Y2-dY2);
        vertex(X+i*dX+tailR, Y-dY);
        endShape(CLOSE);
      }
    }
  }
}