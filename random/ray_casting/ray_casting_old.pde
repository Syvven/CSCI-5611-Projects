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

