/* autogenerated by Processing revision 1286 on 2022-09-09 */
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

public class ray_casting extends PApplet {

// ray caster
int num_squares = 10;
int rec_width, rec_height;

float[][] map = new float[num_squares][num_squares];
Rectangle[][] recs = new Rectangle[num_squares][num_squares];
int num_rays = 45; // always odd
Vec2[] rays = new Vec2[num_rays];
float fov = radians(90);
int[] curr_square;

 public void setup() {
    rec_width = width/num_squares;
    rec_height = height/num_squares;
    /* size commented out by preprocessor */;
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
 public void draw() {
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
    circle(curr_square[2], curr_square[3], 10.0f);
    for (int i = 0; i < rays.length; i++) {
        Vec2 curr_ray = rays[i];
        line(curr_square[2], curr_square[3], curr_square[2]+curr_ray.x*100, curr_square[1]+curr_ray.y*100);
    }
}

 public void keyPressed() {
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

public class Rectangle {
    public Vec2 tLeft, tRight, bLeft, bRight, center;
    public float rwidth, rheight;

    public Rectangle(float tlx, float tly, float rwidth_, float rheight_) {
        tLeft = new Vec2(tlx, tly);
        tRight = new Vec2(tlx+rwidth, tly);
        bLeft = new Vec2(tlx, tly + rheight);
        bRight = new Vec2(tlx + rwidth, tly+rheight);
        center = new Vec2(tlx+(floor(rwidth/2)), tly+(floor(rheight/2)));
        rwidth = rwidth_; rheight = rheight_;
    }
}
//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public float length(){
    return sqrt(x*x+y*y);
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void clampToLength(float maxL){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(float newL){
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public void normalize(){
    float magnitude = sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx*dx + dy*dy);
  }
}

 public Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
  // a + ((b-a)*t)
}

 public float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

 public float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

 public Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}


  public void settings() { size(1200, 1200); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ray_casting" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
