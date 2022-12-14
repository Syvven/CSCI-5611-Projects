/* autogenerated by Processing revision 1286 on 2022-09-16 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class whale_test extends PApplet {

int numLayers = 35; //increase to improve quality (toggle speed and frameRate too)
Layer[] layers = new Layer[numLayers];

float size = 50;
float speed = 1; //50 layers = .03 speed = 30 frameRate,  30/.05/20,  20/.12/15,  10/.2/5
float bx, by;
float x2, y2, r2, dy2, dx2, tailr2, l2;
float pi = 3.145f;
float a, b, eye;

 public void setup() {
  //size(displayWidth, displayHeight);
  /* size commented out by preprocessor */;
  frameRate(144);
  for (int i = layers.length-1; i >= 0; i--) {
    layers[i] = new Layer(i);
    mouseX = width/2;
    mouseY = height/2;
  }
}

 public void draw() {
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
    L = 1-i/numLayers;
    R = (30*pow(L, 3)-58.5f*sq(L)+28*L+.92f) * size/2; //body radius equation
    dY = (10*pow(L, 3)-10*sq(L)) * size; ////body placement equation
    gray = 220-100*L; //body color
    if (i == numLayers-1) {
      first = 1; //last layer = nose
    }

    if (L > .775f) { //tail length
      dX = (22*sq(L)-30*L+10) * size; //change in tail 
      if (i==0) {
        tailR = 0;
        R = 0;
      } else {
        tailR = (-86.7f*sq(L)+153.2f*L-66) * size/2; //tail radius
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

   public void updateLayer() {
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

   public void drawLayer() {
    fill(gray); 
    stroke(gray); 
    strokeWeight(0);

    if (L <= .775f) {
      ellipse(X, Y-dY, R*2, R*2); //body

      if (L > .3f & L <= .4f) { 
        rotate(pi/4);
        a = X-R;
        b = Y+R*.6f;
        ellipse(sqrt(sq(a)+sq(b))*sin(pi/4+atan(a/b)), sqrt(sq(a)+sq(b))*cos(pi/4+atan(a/b)), size*(L-.3f)*15, size*(L-.3f)*40); //left fin
        a = X+R;
        ellipse(sqrt(sq(a)+sq(b))*sin(pi/4+atan(a/b)), sqrt(sq(a)+sq(b))*cos(pi/4+atan(a/b)), size*(L-.3f)*40, size*(L-.3f)*15); //right fin
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

      if (L >.4f & L<.5f) {
        fill(gray-50); 
        stroke(gray-50);
        beginShape(); 
        vertex(X2+cos((17+abs(L2-.45f)/.05f)*pi/12)*R2, Y2-dY2+sin((17+abs(L2-.45f)/.05f)*pi/12)*R2);
        for (float i = (17+abs(L-.45f)/.05f)*pi/12; i <= (19-abs(L-.45f)/.05f)*pi/12; i=i+pi/50) {  // blowhole
          vertex(X+cos(i)*R, Y-dY+sin(i)*R);
        }
        vertex(X2+cos((19-abs(L2-.45f)/.05f)*pi/12)*R2, Y2-dY2+sin((19-abs(L2-.45f)/.05f)*pi/12)*R2);
        endShape(CLOSE);
      } else if (L < .2f) {
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
            ellipse(X+i*R*.9f, Y-R*.15f, size/3, size/3); // eye
            fill(250); 
            stroke(250);
            ellipse(X+i*R*.93f, Y-R*.18f, size/10, size/10);
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


  public void settings() { fullScreen(); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "whale_test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
