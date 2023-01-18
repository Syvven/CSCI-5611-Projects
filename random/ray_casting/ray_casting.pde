import java.util.Map;

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
float epsilon = 0.001;

/* control booleans */
boolean a_pressed = false;
boolean d_pressed = false;
boolean debug = false;
float rotation_degrees = 1;

public void settings() 
{
    size(int(scr_width), int(scr_height));
}

void setup() 
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
    agent_center.x = agent_square.x*rec_width + rec_width*0.5;
    agent_center.y = agent_square.y*rec_height + rec_height*0.5;

    /* only need to set rectMode() once */
    rectMode(CORNER);
}

void update_rays() 
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
void check_ray_collisions() 
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

void draw() 
{
    /* float array??!??! */
    for (int i = 0; i < num_rays; i++) 
    {
        intersect_distances[i] = 0.0;
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

        circle(agent_center.x, agent_center.y, 10.0);
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

        float x = scr_width * 0.5;
        float y = scr_height * 0.5;
        float len = intersect_distances[0];
        if (intersect_distances[0] != -1.0) 
        {
            /* draw line in exact middle of screen for first ray */
            line(
                x, y-len*0.5,
                x, y+len*0.5
            );
        }
        for (int i = 1; i < floor(num_rays/2) + 1; i++) 
        {
            /* left ray */
            len = intersect_distances[2*i];
            line(
                x-i*step, y-len*0.5,
                x-i*step, y+len*0.5
            );

            /* right ray */
            len = intersect_distances[2*i-1];
            line(
                x+i*step, y-len*0.5,
                x+i*step, y+len*0.5
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
void keyPressed() 
{
    if (keyCode == LEFT) 
    {
        if (map_recs[int(agent_square.x-1)][int(agent_square.y)] == null) 
        {
            agent_square.x--;
        }
    } 
    else if (keyCode == RIGHT) 
    {
        if (map_recs[int(agent_square.x+1)][int(agent_square.y)] == null) 
        {
            agent_square.x++;
        } 
    } 
    else if (keyCode == DOWN) 
    {
        if (map_recs[int(agent_square.x)][int(agent_square.y+1)] == null) 
        {
            agent_square.y++;
        } 
    } 
    else if (keyCode == UP) 
    {
        if (map_recs[int(agent_square.x)][int(agent_square.y-1)] == null) 
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
    agent_center.x = agent_square.x*rec_width + rec_width*0.5;
    agent_center.y = agent_square.y*rec_height + rec_height*0.5;
}

void keyReleased() {
    if (key == 'a')
    {
        a_pressed = false;
    }
    if (key == 'd') 
    {
        d_pressed = false;
    }
}

