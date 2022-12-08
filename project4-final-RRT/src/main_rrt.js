import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {DragControls} from './DragControls.js';
import {OrbitControls} from './OrbitControls.js';
import WebGL from './webGLCheck.js';
import {GLTFLoader} from './GLTFLoader.js';

// important things
var scene, camera, renderer, stats;
var raycaster; 
var orbitControls, dragControls;
var orbitControlsWereEnabled = false;
var gui, simObj;
var gui_width = 300;
var prevTime;

// control booleans
// var controlArr;

// floor things
var field_of_view = 45;
var cam_init_height = window.innerWidth/3.25;
var floorBaseVertHeight = 6;
var floorBaseVertWidth = 9;
var vertScale = 3;
var floorNumVertHeight = floorBaseVertHeight*vertScale;
var floorNumVertWidth = floorBaseVertWidth*vertScale
var floorWidth = ((window.innerWidth/1.75)/9) * 7;
var floorHeight = ((window.innerHeight/1.5)/6) * 4;

var program;
function setup() {
    // intialize scene, renderer, cameras, and controls for use later on
    // initializes scene and axis helpers
    scene = new THREE.Scene();
    scene.add(new THREE.AxesHelper(1000));

    // creates renderer and sets its size
    renderer = new THREE.WebGLRenderer({depth:true});
    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.setClearColor(0x555555);
    document.body.appendChild( renderer.domElement );

    raycaster = new THREE.Raycaster();

    // creates new camera / sets position / sets looking angle
    camera = new THREE.PerspectiveCamera(field_of_view, window.innerWidth / window.innerHeight, 0.1, 3000 );
    camera.position.set( 0, cam_init_height, 0 );
    camera.lookAt( 0, 0, 0 );

    // orbit controls
    // for testing purposes
    // get rid of once done ?
    orbitControls = new OrbitControls(camera, renderer.domElement);
    orbitControls.enableDamping = true;
    orbitControls.zoomSpeed = 2;

    setup_room_walls();
    generate_obstacles();
    set_gui();

    // controlArr = []

    // dragControls = new DragControls(controlArr, camera, renderer.domElement);
    // dragControls.addEventListener('dragstart', (e) => {
        
    // });
    // dragControls.addEventListener('drag', (e) => {
    //     e.object.position.set(intersects.x, intersects.y, intersects.z);
    // });
    // dragControls.addEventListener('dragend', (e) => {
        
    // });

    // sets up the fps counter in the top left of the window
    stats = new Stats();
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    // hemisphere light for equal lighting
    var hemiLight = new THREE.PointLight( 0xffffff, 2, 100000 );
    hemiLight.position.set( 0, 700, 0 );
    scene.add( hemiLight );

    // initialize aspects of the scene such as walls, IK things, and objects to be thrown around
    // adds texture for the ground

    // hard coding goal for now
    program = new RRT(
        new THREE.Vector3(
            floorWidth*0.5+agent_rad*2,
            agent.position.y
            -floorHeight*0.5+agent_rad*2
        ), // goal
        agent,
        obstacles,
        100 // n_iters
    ); // rrt program to do things
}

function set_gui() {
    gui = new GUI();
    // base is 246
    gui.width = gui_width;
}

var obstacles = [];
var num_obstacles = 5, obstacle_rad = 10, speed = 50;
var agent, agent_rad = 10;
function generate_obstacles() {
    for (let i = 0; i < num_obstacles; i++) {
        var sphere = new THREE.Mesh(
            new THREE.SphereBufferGeometry(obstacle_rad, 16,16),
            new THREE.MeshBasicMaterial({color:0xff9488})
        )
        sphere.position.set(-floorWidth*0.5 + (i+1)*(floorWidth / (num_obstacles+1)), obstacle_rad, floorHeight*0.5-3*obstacle_rad);
        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, speed*getRandomArbitrary(-10, 10))
        });
    }

    agent = new THREE.Mesh(
        new THREE.SphereBufferGeometry(agent_rad, 16,16),
        new THREE.MeshBasicMaterial({color:0x0000ff})
    )
    scene.add(agent);
    agent.position.x = -floorWidth*0.5+agent_rad*2;
    agent.position.y = agent_rad;
    agent.position.z = -floorHeight*0.5+agent_rad*2;
}

function setup_room_walls() {
    var groundTexture = new THREE.TextureLoader().load("../images/floor_full.png");
    groundTexture.encoding = THREE.sRGBEncoding;
    var groundMaterial = new THREE.MeshStandardMaterial(
        {
            map:groundTexture, 
            side: THREE.DoubleSide
        }
    );
    var groundGeometry = new THREE.PlaneGeometry(
        window.innerWidth/1.75, 
        window.innerHeight/1.5, 
        floorNumVertWidth, 
        floorNumVertHeight
    );
    var mesh = new THREE.Mesh(groundGeometry,groundMaterial);
    mesh.position.y = -0.1;
    mesh.rotation.x = -Math.PI/2;
    mesh.material.wireframe = false;
    scene.add(mesh);

    var end = floorNumVertHeight+1;
    const posAttrib = mesh.geometry.getAttribute('position');
    for (let j = 0; j < floorNumVertHeight+1; j++) {
        for (let i = 0; i < vertScale; i++) {
            var off = j*(floorNumVertWidth+1);
            var end = (j+1)*(floorNumVertWidth+1)-1;
            posAttrib.setXYZ(off + i, posAttrib.getX(off+vertScale), posAttrib.getY(off+vertScale), 100 - i*100/vertScale);
            posAttrib.setXYZ(end - i, posAttrib.getX(end-vertScale), posAttrib.getY(end-vertScale), 100 - i*100/vertScale);
        }
    }

    var off = vertScale*(floorNumVertWidth+1);
    var end = (floorNumVertWidth+1) * (floorNumVertHeight+1)-1;
    for (let i = 0; i < vertScale; i++) {
        for (let j = 0; j < floorNumVertWidth+1; j++) {
            var ind = end - i*(floorNumVertWidth+1)-j;
            var get = (floorNumVertHeight-vertScale+1) * (floorNumVertWidth+1)-1;
            posAttrib.setXYZ(i*(floorNumVertWidth+1) + j, posAttrib.getX(off + j), posAttrib.getY(off + j), 100 - i*100/vertScale);
            posAttrib.setXYZ(ind, posAttrib.getX(get - j), posAttrib.getY(get - j), 100 - i*100/vertScale);
        }
    }
}

function animate() {
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    program.step(dt);

    // var guy1 = new Agent(dt);
    // var guy2 = new Agent(dt);

    if (orbitControls.enabled) orbitControls.update(1*dt);
    
	renderer.render( scene, camera );
    stats.update();
}

// event listeners
window.addEventListener( 'resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    // cam_init_height = window.innerWidth/3.25;
    // camera.position.set( 0, cam_init_height, 0 );

    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.render(scene, camera);
}, false);

var paused = false;
document.addEventListener( 'keydown', (e) => {
    switch (e.code) {
        case 'Space':
            paused = !paused;
    }
});

document.addEventListener( 'keyup', (e) => {
    
});

var mouse = new THREE.Vector2();
var plane = new THREE.Plane(new THREE.Vector3(0,1,0), 0);
var intersects = new THREE.Vector3();
window.addEventListener('mousemove', (e) => {
    mouse.x = ( e.clientX / window.innerWidth ) * 2 - 1;
	mouse.y = - ( e.clientY / window.innerHeight ) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    raycaster.ray.intersectPlane(plane, intersects);
}, false);

class Node {
    constructor(pos) {
        this.pos = pos;
        this.links = []
    }

    add_link(node) {
        this.links.push(node);
    }
}

class RRT {
    constructor(startGoal, agent, obstacles, n_iters) {
        this.goal = startGoal;
        
        this.agent = agent;
        this.obstacles = obstacles;

        this.root = new Node(new THREE.Vector3(
            this.agent.position.x + 1,
            this.agent.position.y,
            this.agent.position.z + 1
        ));
    
        this.changeGoal = false;
        this.newGoal = new THREE.Vector3(
            0,
            this.agent.position.y,
            0
        );

        this.iterations = n_iters;
        this.epsilon = 3; // for distance calculations

        this.planned_path = []

        this.Qr = Queue();
        this.Qs = Queue();
    }

    step(dt) {
        // step serves as alogirthm 1 from the paper

        // update goal, obstacles
        if (this.changeGoal) {
            this.goal = this.newGoal;
        }
        this.update_obstacles(dt);

        // do expanding and rewiring for # of iterations
        for (let i = 0; i < this.n_iters; i++) {
            this.algorithm2();
        }

        // plan path using algorithm 6
        this.algorithm6();
        
        if (this.agent.position.distanceTo(this.root.pos) < this.epsilon) {
            // update this.root to the next node in the path
        }

        var dir = this.root.pos.clone();
        dir.sub(this.agent.position);
        dir.normalize();
        console.log(dir);
        this.agent.position.x += dir.x*dt;
        this.agent.position.z += dir.z*dt;
    }

    algorithm2() {
        // input is Tree, random queue, and queue for rewiring from root
        // T, Qr, Qs
    }

    algorithm6() {

    }

    update_obstacles(dt) {
        // replace this with other updating code in future? 
        obstacles.forEach((obs) => {
            obs.obj.position.z += obs.vel.y*dt;
            if (obs.obj.position.z <= (-floorHeight*0.5+obs.rad)) {
                obs.vel.y *= -1;
                obs.obj.position.z = -floorHeight*0.5+obs.rad
            }
            if (obs.obj.position.z >= (floorHeight*0.5-obs.rad)) {
                obs.vel.y *= -1;
                obs.obj.position.z = floorHeight*0.5-obs.rad
            }
        });
    }
}

class Queue {
    constructor() {
      this.items = [];
    }
  
    // Implementing various methods of javascript queue:
  
    // 1. adding element to the queue
    enqueue(item) {
      this.items.push(item);
    }
  
    // 2. removing element from the queue
    dequeue() {
      // checking if the queue is empty or not before removing it!
      if (this.isEmpty()) {
        return "Queue is empty: underflow!";
      }
      return this.items.shift();
    }
  
    // 3. returning the Front element of
    front() {
      // checking if the queue is empty or not!
      if (this.isEmpty()) {
        return "Queue is empty!";
      }
      return this.items[0];
    }
  
    // 4. returning true if the queue is empty.
    isEmpty() {
      return this.items.length == 0;
    }
  
    // 5. printing the queue.
    printQueue() {
      var queue = "";
      for (var i = 0; i < this.items.length; i++) {
        queue += this.items[i] + " ";
      }
      return queue;
    }
  
    // 6. getting the size of the queue.
    size() {
      return this.items.length;
    }
  }

// helper functions

function clamp(f, min, max) {
    if (f < min) return min;
    if (f > max) return max;
    return f;
}

function radians(degrees) {
    return degrees * (Math.PI / 180);
}

function cross(v1, v2) {
    return v1.x*v2.y - v1.y*v2.x;
}

function getRandomArbitrary(min, max) {
    return Math.random() * (max - min) + min;
}

// at very end so that everything is initialized

setup();
if ( WebGL.isWebGLAvailable() ) {
    // Initiate function or other initializations here
    // date for dt purposes
    prevTime = new Date();
    animate();
} else {
    const warning = WebGL.getWebGLErrorMessage();
    document.getElementById( 'container' ).appendChild( warning );
}