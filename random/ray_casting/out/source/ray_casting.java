/* autogenerated by Processing revision 1286 on 2023-01-12 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.Map;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class ray_casting extends PApplet {



/* useful values */
float RAD_15 = radians(15);
float RAD_30 = radians(30);
float RAD_45 = radians(45);
float RAD_60 = radians(60);
float RAD_90 = radians(90);
float RAD_180 = radians(180);

/* dimensions of the map and screen */
float scr_width = 600;
float scr_height = 600;
int map_dim = 20;
float rec_width = scr_width / map_dim;
float rec_height = scr_height / map_dim;

/* 
 * map_vals holds the status of each square
 * -> 0 means empty
 * -> 1 means obstacle
 * map_recs holds the rectangle objects representing each square
 */
float[][] map_vals = new float[map_dim][map_dim];
Rectangle[][] map_recs = new Rectangle[map_dim][map_dim];

/* values for calculations */
int num_rays = 201;
Vec2[] rays = new Vec2[num_rays];
float ray_len = (scr_width > scr_height) ? (scr_width*2) : (scr_height*2);
float fov = RAD_45;
/* starting square for user */
Vec2 agent_square = new Vec2(2, 2);
Vec2 agent_center = new Vec2();

/* ray collision info stuff */
Float[] intersect_distances = new Float[num_rays];
ArrayList<Vec2> dots = new ArrayList<Vec2>();
float epsilon = 0.001f;

/* control booleans */
boolean a_pressed = false;
boolean d_pressed = false;
boolean debug = false;
float rotation_degrees = 1;

public void settings() 
{
    size(PApplet.parseInt(scr_width), PApplet.parseInt(scr_height));
}

 public void setup() 
{
    surface.setTitle("Ray Caster");
    strokeWeight(2);

    /* fill out the vals and recs arrays */
    for (int i = 0; i < map_dim; i++) 
    {
        for (int j = 0; j < map_dim; j++) 
        {
            if (i != 0 && i != map_dim-1 && j != 0 && j != map_dim-1) 
            {
                map_vals[i][j] = 0; 
                map_recs[i][j] = null;
            } 
            else 
            {
                map_vals[i][j] = 1;
                map_recs[i][j] = new Rectangle(
                    i*rec_width, /* top left x value */
                    j*rec_height, /* top left y value */
                    rec_width, 
                    rec_height
                );
            }
        }
    }

    /* intialize the start direction of the rays */
    rays[0] = new Vec2(1,0);

    /* set agent center */
    agent_center.x = agent_square.x*rec_width + rec_width*0.5f;
    agent_center.y = agent_square.y*rec_height + rec_height*0.5f;

    /* only need to set rectMode() once */
    rectMode(CORNER);
}

 public void update_rays() 
{
    /* 
     * rotates the initial ray a portion of the fov
     * each iteration it is rotated both up and down
     * creating a fan
     * rays[0] is the initial ray pointing straight 
     */

    if (a_pressed) 
    {
        rays[0].rotated(radians(-rotation_degrees));
        rays[0].normalize();
    }

    if (d_pressed)
    {
        rays[0].rotated(radians(rotation_degrees));
        rays[0].normalize();
    }

    for (int i = 1; i < floor(num_rays/2) + 1; i++) 
    {
        float angle = (i*fov) / (num_rays-1);
        rays[i*2-1] = rays[0].rotate(angle).normalized();
        rays[i*2] = rays[0].rotate(-angle).normalized();
    }
}

Vec2 ray_end = new Vec2();
Vec2[] temp_dots = new Vec2[4];
 public void check_ray_collisions() 
{
    dots.clear();
    /* iterate through the squares on the map */
    /* for each ray, check for collisions with square wall */
    for (int k = 0; k < num_rays; k++) 
    {
        for (int i = 0; i < map_dim; i++) 
        {
            for (int j = 0; j < map_dim; j++) 
            {
                Rectangle curr_rect = map_recs[i][j];
                /* first check that there is actually a wall here */
                if (curr_rect != null) 
                {
                    /* check that rectangle is within FOV (with a little room) */
                    Vec2 pointvec = curr_rect.center.minus(agent_center).normalized();
                    float angle = acos(dot(pointvec, rays[0]));
                    if (Math.abs(angle) > fov || Float.isNaN(angle)) 
                    {
                        continue;
                    }

                    /* dots.add(curr_rect.center); */
                    
                    int ind = 0;
                    boolean ray_hit = false;
                    ray_end.x = agent_center.x + rays[k].x*ray_len;
                    ray_end.y = agent_center.y + rays[k].y*ray_len;

                    /* 
                     * for each of the walls of square, check that its open
                     * a squares wall is open if the adjacent square is null
                     * using intersect formula from:
                     *    https://en.wikipedia.org/wiki/Line–line_intersection
                     * x3 and x4 will always be the points on the square
                     * x3 will be the first mentioned in the comment and x4 the second
                     * x1 will be agent_center, x2 will be ray_end
                     * line segment 1 is ray, 2 is square, so find u
                     */

                    /* left open -- use top left and bottom left */
                    if (i != 0 && map_recs[i-1][j] == null) 
                    {
                        /* first, determine intersection */
                        float n1 = (agent_center.x - curr_rect.tLeft.x);
                        float n2 = (agent_center.y - ray_end.y);
                        float n3 = (agent_center.y - curr_rect.tLeft.y);
                        float n4 = (agent_center.x - ray_end.x);

                        float d1 = (agent_center.x - ray_end.x);
                        float d2 = (curr_rect.tLeft.y - curr_rect.bLeft.y);
                        float d3 = (agent_center.y - ray_end.y);
                        float d4 = (curr_rect.tLeft.x - curr_rect.bLeft.x);

                        float nu = n1*n2 - n3*n4;
                        float du = d1*d2 - d3*d4;

                        float nt = n1*d2 - n3*d4;
                        float dt = du;

                        float u = nu / du;
                        float t = nt / dt;

                        /* then check if there's actual intersection */
                        if (t >= 0 && t <= 1 && u >= 0 && u <= 1) 
                        {
                            Vec2 dot = new Vec2(
                                curr_rect.tLeft.x + u*(curr_rect.bLeft.x-curr_rect.tLeft.x),
                                curr_rect.tLeft.y + u*(curr_rect.bLeft.y-curr_rect.tLeft.y)
                            );
                            temp_dots[ind++] = dot;
                        }
                    }

                    /* right open -- use top right and bottom right */
                    if (i != map_dim-1 && map_recs[i+1][j] == null) 
                    {
                        /* first, determine intersection */
                        float n1 = (agent_center.x - curr_rect.tRight.x);
                        float n2 = (agent_center.y - ray_end.y);
                        float n3 = (agent_center.y - curr_rect.tRight.y);
                        float n4 = (agent_center.x - ray_end.x);

                        float d1 = (agent_center.x - ray_end.x);
                        float d2 = (curr_rect.tRight.y - curr_rect.bRight.y);
                        float d3 = (agent_center.y - ray_end.y);
                        float d4 = (curr_rect.tRight.x - curr_rect.bRight.x);

                        float nu = n1*n2 - n3*n4;
                        float du = d1*d2 - d3*d4;

                        float nt = n1*d2 - n3*d4;
                        float dt = du;

                        float u = nu / du;
                        float t = nt / dt;

                        if (t >= 0 && t <= 1 && u >= 0 && u <= 1) 
                        {
                            Vec2 dot = new Vec2(
                                curr_rect.tRight.x + u*(curr_rect.bRight.x-curr_rect.tRight.x),
                                curr_rect.tRight.y + u*(curr_rect.bRight.y-curr_rect.tRight.y)
                            );
                            temp_dots[ind++] = dot;
                        }
                    }

                    /* top open -- use top left and top right */
                    if (j != 0 && map_recs[i][j-1] == null) 
                    {
                        /* first, determine intersection */
                        float n1 = (agent_center.x - curr_rect.tLeft.x);
                        float n2 = (agent_center.y - ray_end.y);
                        float n3 = (agent_center.y - curr_rect.tLeft.y);
                        float n4 = (agent_center.x - ray_end.x);

                        float d1 = (agent_center.x - ray_end.x);
                        float d2 = (curr_rect.tLeft.y - curr_rect.tRight.y);
                        float d3 = (agent_center.y - ray_end.y);
                        float d4 = (curr_rect.tLeft.x - curr_rect.tRight.x);

                        float nu = n1*n2 - n3*n4;
                        float du = d1*d2 - d3*d4;

                        float nt = n1*d2 - n3*d4;
                        float dt = du;

                        float u = nu / du;
                        float t = nt / dt;

                        if (t >= 0 && t <= 1 && u >= 0 && u <= 1) 
                        {
                            Vec2 dot = new Vec2(
                                curr_rect.tLeft.x + u*(curr_rect.tRight.x-curr_rect.tLeft.x),
                                curr_rect.tLeft.y + u*(curr_rect.tRight.y-curr_rect.tLeft.y)
                            );
                            temp_dots[ind++] = dot;
                        }
                    }

                    /* bottom open -- use bottom left and bottom right */
                    if (j != map_dim-1 && map_recs[i][j+1] == null)
                    {
                        /* first, determine intersection */
                        float n1 = (agent_center.x - curr_rect.bLeft.x);
                        float n2 = (agent_center.y - ray_end.y);
                        float n3 = (agent_center.y - curr_rect.bLeft.y);
                        float n4 = (agent_center.x - ray_end.x);

                        float d1 = (agent_center.x - ray_end.x);
                        float d2 = (curr_rect.bLeft.y - curr_rect.bRight.y);
                        float d3 = (agent_center.y - ray_end.y);
                        float d4 = (curr_rect.bLeft.x - curr_rect.bRight.x);

                        float nu = n1*n2 - n3*n4;
                        float du = d1*d2 - d3*d4;

                        float nt = n1*d2 - n3*d4;
                        float dt = du;

                        float u = nu / du;
                        float t = nt / dt;

                        if (t >= 0 && t <= 1 && u >= 0 && u <= 1) 
                        {
                            Vec2 dot = new Vec2(
                                curr_rect.bLeft.x + u*(curr_rect.bRight.x-curr_rect.bLeft.x),
                                curr_rect.bLeft.y + u*(curr_rect.bRight.y-curr_rect.bLeft.y)
                            );
                            temp_dots[ind++] = dot;
                        }
                    }

                    Vec2 min_dot = null;
                    float min_dist = Float.POSITIVE_INFINITY;
                    for (int num = 0; num < ind; num++) 
                    {
                        float dist = agent_center.distanceTo(temp_dots[num]);
                        if (dist < min_dist) 
                        {
                            min_dot = temp_dots[num];
                            min_dist = dist;
                        }
                    }

                    if (min_dot != null) 
                    {
                        intersect_distances[k] = min_dist;
                        dots.add(min_dot);
                    } 
                }
            }
        }
    }
}

 public void draw() 
{
    /* float array??!??! */
    for (int i = 0; i < num_rays; i++) 
    {
        intersect_distances[i] = 0.0f;
    }
    
    background(255);
    stroke(0,0,0);
    fill(100);

    if (debug) 
    {
        /* draw the map */
        for (int i = 0; i < map_dim; i++) 
        {
            for (int j = 0; j < map_dim; j++) 
            {
                Rectangle curr_rect = map_recs[i][j];
                if (curr_rect != null)
                {   
                    /* drwaing from top left corner */
                    rect(
                        curr_rect.tLeft.x,
                        curr_rect.tLeft.y,
                        curr_rect.rwidth,
                        curr_rect.rheight
                    );
                }
            }
        }

        circle(agent_center.x, agent_center.y, 10.0f);
    }
    

    

    update_rays();
    check_ray_collisions();

    if (debug) {
        /* draw the rays from the agent */
        for (int i = 0; i < num_rays; i++) 
        {
            line(
                agent_center.x,
                agent_center.y,
                agent_center.x + rays[i].x*scr_width*2,
                agent_center.y + rays[i].y*scr_height*2
            );
        }

        /* draw out collisions circles */
        fill(255, 0, 0);
        for (int i = 0; i < dots.size(); i++) 
        {
            Vec2 dot = dots.get(i);
            circle(dot.x, dot.y, 20); 
        }
    }
    
    if (!debug) 
    {
        /* draw the lines corresponding to intersection distances */
        float step = scr_width / num_rays;

        float x = scr_width * 0.5f;
        float y = scr_height * 0.5f;
        float len = intersect_distances[0];
        if (intersect_distances[0] != -1.0f) 
        {
            /* draw line in exact middle of screen for first ray */
            line(
                x, y-len*0.5f,
                x, y+len*0.5f
            );
        }
        for (int i = 1; i < floor(num_rays/2) + 1; i++) 
        {
            /* left ray */
            len = intersect_distances[2*i];
            line(
                x-i*step, y-len*0.5f,
                x-i*step, y+len*0.5f
            );

            /* right ray */
            len = intersect_distances[2*i-1];
            line(
                x+i*step, y-len*0.5f,
                x+i*step, y+len*0.5f
            );
        }
    }
}

/*
 * Key Handling
 * -> 'a' rotates negative (looks positive)
 * -> 'd' rotates positive (looks negative)
 * -> Arrow keys move current square
 */
 public void keyPressed() 
{
    if (keyCode == LEFT) 
    {
        if (map_recs[PApplet.parseInt(agent_square.x-1)][PApplet.parseInt(agent_square.y)] == null) 
        {
            agent_square.x--;
        }
    } 
    else if (keyCode == RIGHT) 
    {
        if (map_recs[PApplet.parseInt(agent_square.x+1)][PApplet.parseInt(agent_square.y)] == null) 
        {
            agent_square.x++;
        } 
    } 
    else if (keyCode == DOWN) 
    {
        if (map_recs[PApplet.parseInt(agent_square.x)][PApplet.parseInt(agent_square.y+1)] == null) 
        {
            agent_square.y++;
        } 
    } 
    else if (keyCode == UP) 
    {
        if (map_recs[PApplet.parseInt(agent_square.x)][PApplet.parseInt(agent_square.y-1)] == null) 
        {
            agent_square.y--;
        } 
    } 
    if (key == 'a') 
    {
        a_pressed = true;
    }
    if (key == 'd') 
    {   
        d_pressed = true;
    } 
    if (key == 'c') 
    {
        debug = !debug;
    }
    agent_center.x = agent_square.x*rec_width + rec_width*0.5f;
    agent_center.y = agent_square.y*rec_height + rec_height*0.5f;
}

 public void keyReleased() {
    if (key == 'a')
    {
        a_pressed = false;
    }
    if (key == 'd') 
    {
        d_pressed = false;
    }
}

public class Rectangle {
    public Vec2 tLeft, tRight, bLeft, bRight, center;
    public float rwidth, rheight;

    public Rectangle(float tlx, float tly, float rwidth_, float rheight_) {
        this.rwidth = rwidth_; this.rheight = rheight_;
        this.tLeft = new Vec2(tlx, tly);
        this.tRight = new Vec2(tlx+rwidth, tly);
        this.bLeft = new Vec2(tlx, tly + rheight);
        this.bRight = new Vec2(tlx + rwidth, tly+rheight);
        this.center = new Vec2(tlx+(floor(rwidth/2)), tly+(floor(rheight/2)));
    }
}
//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
    public float x, y;

    public Vec2() {
        this.x = 0;
        this.y = 0;
    }

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
            if (magnitude < 1e-15f) {
                this.x = 0; this.y = 0;
                return;
            }
            x *= maxL/magnitude;
            y *= maxL/magnitude;
        }
    }

    public void setToLength(float newL){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude < 1e-15f) {
            this.x = 0; this.y = 0;
            return;
        }
        x *= newL/magnitude;
        y *= newL/magnitude;
    }

    public void normalize(){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude < 1e-15f) {
            this.x = 0; this.y = 0;
            return;
        }
        x /= magnitude;
        y /= magnitude;
    }

    public Vec2 normalized(){
        float magnitude = sqrt(x*x + y*y);
        if (magnitude < 1e-15f) {
            return new Vec2();
        }
        return new Vec2(x/magnitude, y/magnitude);
    }

    public float distanceTo(Vec2 rhs){
        float dx = rhs.x - x;
        float dy = rhs.y - y;
        return sqrt(dx*dx + dy*dy);
    }

    public void rotated(float rad) {
        x = cos(rad)*x-sin(rad)*y;
        y = sin(rad)*x+cos(rad)*y;
    }

    public Vec2 rotate(float rad) {
        float newx = cos(rad)*x-sin(rad)*y;
        float newy = sin(rad)*x+cos(rad)*y;
        return new Vec2(newx, newy);
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
// // ray caster
// import java.util.Map;

// int num_squares = 20;
// int rec_width, rec_height;

// // 
// float[][] map = new float[num_squares][num_squares];
// Rectangle[][] recs = new Rectangle[num_squares][num_squares];
// int num_rays = 101; // always odd
// Vec2[] rays = new Vec2[num_rays];
// float fov = radians(90);
// Vec2[] curr_square = new Vec2[2];

// void setup() {
//     rec_width = width/num_squares;
//     rec_height = height/num_squares;
//     size(600, 600);
//     surface.setTitle("Ray Caster");
//     strokeWeight(2);

//     for (int i = 0; i < map.length; i++) {
//         for (int j = 0; j < map[0].length; j++) {
//             if (i == 0 || i == map.length-1 || j == 0 || j == map[0].length-1) {
//                 map[i][j] = 1;
//                 recs[i][j] = new Rectangle(i*rec_width, j*rec_height, rec_width, rec_height);
//             } else {
//                 map[i][j] = 0;
//                 recs[i][j] = null;
//             }
//         }
//     }

//     curr_square[0] = new Vec2(2,2);
//     curr_square[1] = new Vec2(
//         (curr_square[0].x+1)*rec_width-(rec_width/2), 
//         (curr_square[0].y+1)*rec_height-(rec_height/2)
//     );
//     rays[0] = new Vec2(1, 0); // initializes start direction
// }

// void update_rays() {
//     for (int i = 1; i < floor(num_rays/2)+1; i++) {
//         float angle = i*fov/(num_rays-1);
//         rays[i*2-1] = rays[0].rotate(angle).normalized();
//         rays[i*2] = rays[0].rotate(-angle).normalized();
//     }
// }

// ArrayList<Vec2> dots = new ArrayList<Vec2>();
// float epsilon = 0.001;
// boolean ray_hit;

// Vec2 min1;
// Vec2 min2;
// float dist;
// HashMap<Float,Vec2> dist_map = new HashMap<Float,Vec2>();

// void ray_collisions() {
//     dots = new ArrayList<Vec2>();
//     for (int i = 0; i < rays.length; i++) {
//         ray_hit = false;
//         Vec2 ray = rays[i];
//         float a = ((curr_square[1].y+ray.y*10)-(curr_square[1].y));
//         float b = ((curr_square[1].x)-(curr_square[1].x+ray.x*10));
//         float c = a*curr_square[1].x+b*curr_square[1].y;

//         for (int j = 0; j < recs.length; j++) {
//             for (int k = 0; k < recs[0].length; k++) {
//                 Rectangle curr = recs[j][k];

//                 if (curr != null) {

//                     dist_map.put(curr_square[1].distanceTo(curr.bLeft), curr.bLeft);
                
//                     dist_map.put(curr_square[1].distanceTo(curr.bRight), curr.bRight);
//                     dist_map.put(curr_square[1].distanceTo(curr.tLeft), curr.tLeft);
//                     dist_map.put(curr_square[1].distanceTo(curr.tRight), curr.tRight);
                    
//                     float min_key = Float.POSITIVE_INFINITY;
//                     for (float key : dist_map.keySet()) {
//                         if (key < min_key) {
//                             min_key = key;
//                         }
//                     }
//                     min1 = dist_map.get(min_key);
//                     dist_map.remove(min_key);

//                     min_key = Float.POSITIVE_INFINITY;
//                     for (float key : dist_map.keySet()) {
//                         if (key < min_key) {
//                             min_key = key;
//                         }
//                     }
//                     min2 = dist_map.get(min_key);

//                     // dots.add(min1); dots.add(min2);

//                     Vec2 pointvec = curr_square[1].minus(curr.center).normalized();
//                     float angle = acos(dot(pointvec, rays[0]));

//                     if (angle - fov < epsilon || Float.isNaN(angle)) {
//                         continue;
//                     }

//                     float a2 = (min2.y-min1.y);
//                     float b2 = (min1.x-min2.x);
//                     float c2 = a2*min1.x + b2*min2.y;

//                     float det = a * b2 - a2 * b;
//                     if (det != 0) {
//                         float x = (b2 * c - b * c2)/det;
//                         float y = (a * c2 - a2 * c)/det;
                        
//                         if (x < 0 || y < 0 || y > height || x > width) {
//                             continue;
//                         }

//                         Vec2 point = new Vec2(x,y);

//                         Vec2 aa = curr.tLeft;
//                         Vec2 bb = curr.bLeft;
                        
//                         if (point.x - aa.x < epsilon && (point.y <= bb.y && point.y >= aa.y)) {
//                             dots.add(new Vec2(x,y));
//                         }
//                     }
//                 }
//             }
//         }
//     }
//     // for (int i = 0; i < recs.length; i++) {
//     //     for (int j = 0; j < recs[0].length; j++) {
//     //         if (recs[i][j] != null) {
//     //             
//     //         }
//     //     }
//     // }
// }

// Rectangle curr;
// void draw() {
//     rectMode(CORNER);
//     background(255);
//     stroke(0,0,0);
//     fill(100);

//     // drawing for reference // delete when done
//     for (int i = 0; i < map.length; i++) {
//         for (int j = 0; j < map[0].length; j++) {
//             curr = recs[i][j];
//             if (curr != null) {
//                 rect(curr.tLeft.x, curr.tLeft.y, curr.rwidth, curr.rheight);
//             }
//         }
//     }
//     circle(curr_square[1].x, curr_square[1].y, 10.0);

//     update_rays();
//     ray_collisions();

//     // drawing for reference // delete when done
//     for (int i = 0; i < rays.length; i++) {
//         Vec2 curr_ray = rays[i];
//         line(curr_square[1].x, curr_square[1].y, curr_square[1].x+curr_ray.x*width, curr_square[1].y+curr_ray.y*height);
//     }

//     fill(255, 0, 0);
//     for (int i = 0; i < dots.size(); i++) {
//         Vec2 dot = dots.get(i);
//         circle(dot.x, dot.y, 20);
//     }
// }

// void keyPressed() {
//     if (keyCode == LEFT) {
//         if (recs[int(curr_square[0].x-1)][int(curr_square[0].y)] == null) {
//             curr_square[0].x--;
//             curr_square[1].x -= rec_width;
//         } 
//     } else if (keyCode == RIGHT) {
//         if (recs[int(curr_square[0].x+1)][int(curr_square[0].y)] == null) {
//             curr_square[0].x++;
//             curr_square[1].x += rec_width;
//         } 
//     } else if (keyCode == DOWN) {
//         if (recs[int(curr_square[0].x)][int(curr_square[0].y+1)] == null) {
//             curr_square[0].y++;
//             curr_square[1].y += rec_height;
//         } 
//     } else if (keyCode == UP) {
//         if (recs[int(curr_square[0].x)][int(curr_square[0].y-1)] == null) {
//             curr_square[0].y--;
//             curr_square[1].y -= rec_height;
//         } 
//     } else if (key == 'a') {
//         rays[0].rotated(-radians(3));
//         rays[0].normalize();
//     } else if (key == 'd') {
//         rays[0].rotated(radians(3));
//         rays[0].normalize();
//     } 
// }


  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ray_casting" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
