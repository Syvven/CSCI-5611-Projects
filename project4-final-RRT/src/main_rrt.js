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
    orbitControls.enabled = false;

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
}
var rrtCreated = false;

function set_gui() {
    gui = new GUI();
    // base is 246
    gui.width = gui_width;

    simObj = {
        grid: false,
        lines: false
    };

    const simFolder = gui.addFolder('Sim Controls');
    simFolder.add(simObj, 'grid').name('Show Grid').onChange(() => {
        renderGrid = !renderGrid;
    });
    simFolder.add(simObj, 'lines').name('Render Tree').onChange(() => {
        for (let i = 0; i < program.nodes.length; i++) {
            if (program.nodes[i].line !== null) {
                program.nodes[i].line.material.opacity = Math.abs(
                    program.nodes[i].line.material.opacity-1
                )
            }
        }
        
        renderTree = !renderTree;
    });
}

var obstacles = [];
var num_obstacles = 5, obstacle_rad = 10, speed = 1;
var agent, agent_rad = obstacle_rad;
function generate_obstacles() {
    // for (let i = 0; i < num_obstacles; i++) {
    //     var sphere = new THREE.Mesh(
    //         new THREE.SphereBufferGeometry(obstacle_rad, 16,16),
    //         new THREE.MeshBasicMaterial({color:0xff9488})
    //     )
    //     sphere.position.set(
    //         -floorWidth*0.5 + (i+1)*(floorWidth / (num_obstacles+1)), 
    //         obstacle_rad, 
    //         floorHeight*0.5-3*obstacle_rad
    //     );
    //     scene.add(sphere);
    //     obstacles.push({
    //         obj: sphere,
    //         rad: obstacle_rad,
    //         vel: new THREE.Vector2(0, speed*getRandomArbitrary(-10, 10))
    //     });
    // }

    var text = new THREE.TextureLoader().load("../images/box.jpg");
    var geometry = new THREE.BoxGeometry( obstacle_rad*2, obstacle_rad*2, obstacle_rad*2 );
    var material = new THREE.MeshBasicMaterial( { map: text, color: 0x957433 } );

    for (let i = 0; i < 10; i++) {
        var sphere = new THREE.Mesh(
            geometry, material
        );
        
        sphere.position.set(
            -floorWidth*0.5+obstacle_rad+obstacle_rad*2*i, 
            obstacle_rad, 
            -floorHeight*0.25
        );

        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, 0)
        });
    }

    for (let i = 0; i < 10; i++) {
        var sphere = new THREE.Mesh(
            geometry, material
        );
        
        sphere.position.set(
            -floorWidth*0.5+obstacle_rad+obstacle_rad*20, 
            obstacle_rad, 
            -floorHeight*0.25+obstacle_rad*2*i
        );

        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, 0)
        });
    }

    for (let i = 0; i < 10; i++) {
        var sphere = new THREE.Mesh(
            geometry, material
        );
        
        sphere.position.set(
            floorWidth*0.5-obstacle_rad-obstacle_rad*20, 
            obstacle_rad, 
            -floorHeight*0.5+obstacle_rad+obstacle_rad*2*i
        );

        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, 0)
        });
    }

    for (let i = 0; i < 10; i++) {
        var sphere = new THREE.Mesh(
            geometry, material
        );
        
        sphere.position.set(
            floorWidth*0.5-obstacle_rad-obstacle_rad*10, 
            obstacle_rad, 
            floorHeight*0.5-obstacle_rad-obstacle_rad*2*i
        );

        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, 0)
        });
    }

    for (let i = 0; i < 10; i++) {
        var sphere = new THREE.Mesh(
            geometry, material
        );
        
        sphere.position.set(
            0, 
            obstacle_rad, 
            floorHeight*0.5-obstacle_rad-obstacle_rad*2*i
        );

        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, 0)
        });
    }

    for (let i = 0; i < 9; i++) {
        var sphere = new THREE.Mesh(
            geometry, material
        );
        
        sphere.position.set(
            0, 
            obstacle_rad, 
            -floorHeight*0.5+obstacle_rad+obstacle_rad*2*i
        );

        scene.add(sphere);
        obstacles.push({
            obj: sphere,
            rad: obstacle_rad,
            vel: new THREE.Vector2(0, 0)
        });
    }

    var gltfLoader = new GLTFLoader();
    gltfLoader.load('../models/kiwi.glb', function(gltf) {
        agent = gltf.scene;
        agent.scale.set(5,5,5);
        agent.position.x = -floorWidth*0.5+agent_rad*2;
        agent.position.y = agent_rad;
        agent.position.z = -floorHeight*0.5+agent_rad*2;
        agent.traverse((o) => {
            if (o.isMesh) {
                o.castShadow = true;
                o.receiveShadow = true;
            }
        });

        mixer = new THREE.AnimationMixer(agent);
        mixer.clipAction(gltf.animations[0]).play();

        scene.add(agent);
        modelReady = true;
        // after this point, animate() is run
    }, undefined, function(error) {
        console.error(error);
    });

    // agent = new THREE.Mesh(
    //     new THREE.SphereBufferGeometry(agent_rad, 16,16),
    //     new THREE.MeshBasicMaterial({color:0x0000ff})
    // )
    // scene.add(agent);
    // agent.position.x = -floorWidth*0.5+agent_rad*2;
    // agent.position.y = agent_rad;
    // agent.position.z = -floorHeight*0.5+agent_rad*2;
}
var mixer;
var modelReady = false;
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

    if (!rrtCreated && modelReady) {
        // hard coding goal for now
        program = new RRT(
            new THREE.Vector3(
                floorWidth*0.5-agent_rad*2,
                agent.position.y,
                floorHeight*0.5+-agent_rad*2
            ), // goal
            agent,
            obstacles,
            100, // n_iters
            floorWidth, // bounds in x
            floorHeight // bounds in z
        ); // rrt program to do things
        rrtCreated = true;
    }

    if (!paused && modelReady)  {
        mixer.update(dt);
        program.step(dt);
    }

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
var clicked = false;
window.addEventListener('contextmenu', (e) => {e.preventDefault()})
document.addEventListener('mouseup', (e) => {
    e.preventDefault();
    if (e.button === 2) {
        clicked = true;
        program.changeGoal = true;

        program.newGoal = new Node(
            new THREE.Vector3(
                intersects.x,
                agent_rad,
                intersects.z
            ),
            null
        );
    }
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

function GridGeometry(width = 1, height = 1, wSeg = 1, hSeg = 1, lExt = [0, 0]){
	/* https://jsfiddle.net/prisoner849/ces0pL1v/ */
    let seg = new THREE.Vector2(width / wSeg, height / hSeg);
    let hlfSeg = seg.clone().multiplyScalar(0.5);
    
    let pts = [];
    
    for(let y = 0; y <= hSeg; y++){
        pts.push(
            new THREE.Vector3(0, 0, y * seg.y),
            new THREE.Vector3(width + (hlfSeg.x * lExt[0]), 0, y * seg.y)
        )
    }
    
    for(let x = 0; x <= wSeg; x++){
        pts.push(
            new THREE.Vector3(x * seg.x, 0, 0),
            new THREE.Vector3(x * seg.x, 0, height + (hlfSeg.y * lExt[1]))
        )
    }
    
    return new THREE.BufferGeometry().setFromPoints(pts);
    
}

class Cell {
    constructor(row, col, center) {
        this.row = row;
        this.col = col;
        this.nodes = [];
        this.center = center;
    }
}

class Grid {
    constructor(rows, cols) {
        this.rows = rows;
        this.cols = cols;

        this.cell_width = floorWidth / cols;
        this.cell_height = floorHeight / rows;

        this.grid = []
        for (let i = 0; i < this.rows; i++) {
            var t = []
            for (let j = 0; j < this.cols; j++) {
                t.push(new Cell(
                    i, j, // row and column indices
                    new THREE.Vector3(
                        -floorWidth*0.5 + this.cell_width*0.5 * j,
                        obstacle_rad,
                        -floorHeight*0.5 + this.cell_height*0.5 * i, 
                    ) // center of cell
                ));
            }
            this.grid.push(t);
        }

        var gridgeom = GridGeometry(
            floorWidth, floorHeight, cols, rows, [0,0]
        );
        gridgeom.translate(-floorWidth/2,1,-floorHeight/2)
        this.obj = new THREE.LineSegments(
            gridgeom,
            new THREE.LineBasicMaterial({
                color: 0xff57,
                transparent: true
            })
        );
        scene.add(this.obj);
    }

    get(i, j) {
        return this.grid[i][j];
    }

    get_cell_from_node(node) {
        var w = -floorWidth*0.5 - node.pos.x;
        var h = -floorHeight*0.5 - node.pos.z;

        var colIndex = Math.floor(-1 * w / this.cell_width);
        var rowIndex = Math.floor(-1 * h / this.cell_height);

        return this.grid[rowIndex][colIndex];
    }

    add_node_to_cell(node) {
        /* 
         * adds node to proper cell
         * also adds cell to the node
         * also adds index in cell's node list to node
         */
        var w = -floorWidth*0.5 - node.pos.x;
        var h = -floorHeight*0.5 - node.pos.z;

        var colIndex = Math.floor(-1 * w / this.cell_width);
        var rowIndex = Math.floor(-1 * h / this.cell_height);

        this.grid[rowIndex][colIndex].nodes.push(node);

        node.cell_list_index = this.grid[rowIndex][colIndex].nodes.length-1;
        node.cell = this.grid[rowIndex][colIndex];
    }

    get_cell_and_surrounding_cells(cell) {
        var cells_dist = [];
        for (let i = 0; i < this.rows; i++) {
            for (let j = 0; j < this.cols; j++) {
                var c = this.grid[i][j];
                if (c.nodes.length != 0) {
                    var dist = c.center.distanceTo(cell.center);
                    cells_dist.push([c, dist]);
                }
            }
        }

        cells_dist.sort((a, b) => {
            return a[1] - b[1];
        });

        var cells = cells_dist.slice(0, 8);
        
       
        for (let i = 0; i < cells.length; i++) {
            cells[i] = cells[i][0];
        }

        cells.push(cell);
        return cells;
        
    }
}

class Node {
    constructor(pos, parent) {
        this.pos = pos;
        this.parent = parent;
        
        this.cost = 0;

        this.cell = null;
        this.cell_index = null;
        this.blocked = false;
        this.moved = true;
        this.line = null;
    }
}
var renderTree = false;
var renderGrid = false;
class RRT {
    constructor(startGoal, agent, obstacles, n_iters, boundsx, boundsz) {
        this.width = boundsx;
        this.height = boundsz;
        this.area = this.width * this.height;

        this.nodes = [];

        this.goal = new Node(
            startGoal,
            null
        );
        
        this.agent = agent;
        this.agent_node = new Node(
            agent.position,
            null
        );
        this.obstacles = obstacles;

        /* spatial grid for faster neighbor search */
        this.spat_grid = new Grid(
            8, /* placeholder: row cells */
            10, /* palceholder: column cells */
        );

        this.root = new Node(
            new THREE.Vector3(
                this.agent.position.x + 1,
                this.agent.position.y,
                this.agent.position.z + 1
            ), // position
            null // parent
        );
        this.root.cost = 0;

        this.spat_grid.add_node_to_cell(this.root);
        // this.spat_grid.add_node_to_cell(this.goal);
    
        this.changeGoal = false;
        this.newGoal = new THREE.Vector3(
            0,
            this.agent.position.y,
            0
        );

        this.iterations = n_iters;
        this.epsilon = 3; // for distance calculations

        this.planned_path = []

        this.Qr = new Queue();
        this.Qs = new Queue();

        this.goal_path_found = false;
        /* value for controlling sampling of xrand */
        this.alpha = 0.1;
        /* max number of nodes that can be returned from find_nearest */
        this.kmax = 10;
        /* max euclidean distance between nodes in the tree */
        this.rs = 10;
        /* 
         *  used for returning closest nodes to xrand
         *  sqrt(u(X)kmax / PI*ntotal)
         *  u(X) is volume / area of search space
         *  if epsilon becomes smaller than rs, set epsilon to rs
         */
        this.epsilon = 1;
        this.total_nodes = 1;
        /* uncomment when actually running the algorithm */
        this.n_iters = n_iters;

        this.agent_block_node_radius = agent_rad*2 + 20; // cspace plus some wiggle room

        // tree rendering
        this.lines = [];
        this.changed_nodes = [];

        this.at_goal = false;

        this.nodes.push(this.root);
    }
    
    step(dt) {
        // step serves as alogirthm 1 from the paper
        this.Qr.clear();
        this.Qs.clear();

        if (renderGrid) {
            this.spat_grid.obj.material.opacity = 1;
        } else {
            this.spat_grid.obj.material.opacity = 0;
        }

        // update goal, obstacles
        if (this.changeGoal) {
            this.goal = this.newGoal;
            this.at_goal = false;
            this.goal_path_found = false;
            this.changeGoal = false;
        }
        this.update_obstacles(dt);

        // do expanding and rewiring for # of iterations
        for (let i = 0; i < this.n_iters; i++) {
            this.expand_and_rewire();
        }

        // plan path using algorithm 6
        this.k_step_path_plan();
        
        var epsilon = 1;
        var sight = false;
        if (this.planned_path.length > 0) {
            sight = this.line_to(this.agent_node, this.planned_path[0]);
        }
        if ((this.agent.position.distanceTo(this.root.pos) < epsilon || sight) 
                && this.at_goal === false) {
            // update this.root to the next node in the path
            this.changed_nodes.push(this.root);

            var temp = this.root;
            this.root = this.planned_path.shift();

            temp.cost = this.root.pos.distanceTo(temp.pos);
            temp.parent = this.root;
            
            this.root.parent = null;
            this.root.cost = 0;
            
            if (this.planned_path.length == 0) {
                this.at_goal = true;
                this.goal.cell = this.spat_grid.get_cell_from_node(this.goal);
            }

            this.rewire_from_root();
        }
        if (this.at_goal === false) {
            var dir = this.root.pos.clone();
        } else {
            var dir = this.goal.pos.clone();
        }
        
        dir.sub(this.agent.position);
        dir.normalize();
        this.agent.position.x += dir.x*dt*30; // hardcoded 4, change in future
        this.agent.position.z += dir.z*dt*30;
        if (this.agent.position.distanceTo(this.goal.pos) < 5) {
            this.agent.rotation.y += 1;
        } else {
            this.agent.lookAt(this.root.pos);
        }
        if (renderTree) this.render_tree();
    }

    expand_and_rewire() {
        // input is Tree, random queue, and queue for rewiring from root
        // T, Qr, Qs
        var xrand;
        // sample random x
        xrand = this.sample_uniform();
        /*  
         *  XSI is subset of nodes that are contained 
         *  in the cell or adjacent cells to the random node
         */
        var XSI = this.spat_grid.get_cell_from_node(xrand);

        var xclosest = this.get_closest_node(xrand, XSI);

        if (this.line_to(xclosest, xrand)) {
            var Xnear = this.find_nodes_near(xrand, XSI);
            if (Xnear.length < this.kmax || xrand.pos.distanceTo(xclosest.pos) > this.rs) {
                this.add_node_to_tree(xrand, xclosest, Xnear);
                this.Qr.enqueue_front(xrand);
            } else {
                this.Qr.enqueue_front(xclosest);
            }
            // this.rewire_random_node();
        }
        this.rewire_from_root();
    }

    add_node_to_tree(xnew, xclosest, Xnear) {
        var xmin = xclosest; 
        var cmin = this.cost(xclosest) + xclosest.pos.distanceTo(xnew.pos);
        Xnear.forEach((xnear) => {
            var cnew = this.cost(xnear) + xnear.pos.distanceTo(xnew.pos);
            if (cnew < cmin && this.line_to(xnear, xnew)) {
                cmin = cnew;
                xmin = xnear;
            }
        });
        xnew.parent = xmin;

        xnew.cost = cmin;

        this.spat_grid.add_node_to_cell(xnew);

        this.changed_nodes.push(xnew);
        this.nodes.push(xnew);

        this.total_nodes++;
    }

    rewire_random_node() {
        // rewires a random node
        while (!this.Qr.isEmpty()) {
            var xr = this.Qr.dequeue();
            if (xr.parent === null) {
                if (this.Qr.isEmpty()) {
                    return;
                }
                xr = this.Qr.dequeue();
            }
            var XSI = xr.cell;
            var Xnear = this.find_nodes_near(xr, XSI);
            Xnear.forEach((xnear) => {
                var cold = this.cost(xnear);
                var cnew = this.cost(xr) + xr.pos.distanceTo(xnear.pos);
                if (cnew < cold && this.line_to(xr, xnear)) {
                    if (xnear.parent.parent !== xnear) {
                        xnear.parent = xr;
                        this.changed_nodes.push(xnear);
                        xnear.cost = cnew;
                        this.Qr.enqueue(xnear);
                    }
                }
            });
        }
    }

    rewire_from_root() {
        if (this.Qs.isEmpty()) {
            this.Qs.enqueue(this.root);
        }
        var iters = 0; var maxIters = 10;
        while (!this.Qs.isEmpty() && iters < maxIters) {
            var xs = this.Qs.dequeue();
            var XSI = xs.cell;
            var Xnear = this.find_nodes_near(xs, XSI);
            Xnear.forEach((xnear) => {
                var cold = this.cost(xnear);
                var cnew = this.cost(xs) + xs.pos.distanceTo(xnear.pos);
                if (cnew < cold && this.line_to(xnear, xs)) {
                    xnear.parent = xs;
                    xnear.cost = cnew;
                    this.changed_nodes.push(xnear);
                    
                    this.Qs.enqueue(xnear);
                }
            });
            iters++;
        }
    }

    check_goal_found() {
        var goal_cell = this.spat_grid.get_cell_from_node(this.goal);
        var cells = this.spat_grid.get_cell_and_surrounding_cells(goal_cell);
        for (let i = 0; i < cells.length; i++) {
            for (let j = 0; j < cells[i].nodes.length; j++) {
                var node = cells[i].nodes[j];
                if (this.line_to(node, this.goal)) {
                    if (this.planned_path.length > 0) {
                        for (let i = 0; i < this.planned_path.length-1; i++) {
                            if (renderTree) {
                                if (this.planned_path[i].line === null) {
                                    const line = new THREE.Line(
                                        new THREE.BufferGeometry()
                                            .setFromPoints(
                                                [
                                                    this.planned_path[i].parent.pos, 
                                                    this.planned_path[i].pos
                                                ]
                                            ),
                                        new THREE.LineBasicMaterial(
                                            {
                                                color: 0x0000ff,
                                                transparent: true
                                            }
                                        )
                                    );
                                    scene.add(line);
                                    this.planned_path[i].line = line;
                                }
                                this.planned_path[i].line.material.color = new THREE.Color(0x0000ff);
                                this.planned_path[i].line.material.needsUpdate = true;
                            }
                        }
                    }
                    this.planned_path = [];
                    this.goal_path_found = true;
                    return node;
                }
            }
        }

        return null;
    }

    k_step_path_plan() {
        var temp_node = this.check_goal_found();
        if (this.goal_path_found && !this.at_goal) {
            while (temp_node !== null) {
                if (temp_node.parent !== null) {
                    this.planned_path.unshift(temp_node);
                }
                temp_node = temp_node.parent;
            }
            // not breaking out of loop
            return;
        }
    }

    find_nodes_near(node, cell) {
        /*
         * Finds nodes near a node in cell
         * Distance between nodes is at most epsilon
         * If epsilon is smaller than rs, set equal
         * Returns list of those nodes
         * List should not be longer than kmax
         */
        this.epsilon = Math.sqrt(
            (this.area * this.kmax) / (Math.PI * this.total_nodes)
        );

        if (this.epsilon < this.rs) this.epsilon = this.rs;
        
        var cells = this.spat_grid.get_cell_and_surrounding_cells(cell);

        var close_nodes = [];
        
        cells.forEach((c) => {
            if (c !== null) {
                c.nodes.forEach((n) => {
                    var dist = n.pos.distanceTo(node.pos);
                    if (dist < this.epsilon) {
                        close_nodes.push(n);
                    }
                })
            }
        })

        return close_nodes;
    }

    get_closest_node(node, cell) {
        var cells = this.spat_grid.get_cell_and_surrounding_cells(cell);

        var min_dist = 9e9;
        var min_node = null;

        cells.forEach((c) => {
            if (c !== null) {
                c.nodes.forEach((n) => {
                    var dist = n.pos.distanceTo(node.pos);
                    if (dist < min_dist) {
                        min_dist = dist;
                        min_node = n;
                    } 
                });
            }
        });

        return min_node;
    }

    line_to(n1, n2) {
        /* 
         * returns true or false depending on 
         * if there is direct line of sight from n1 to n2
         */ 
        var rad = obstacle_rad*2+5;
        var dir = n2.pos.clone();
        dir.sub(n1.pos);
        dir.normalize();
        var dist = n1.pos.distanceTo(n2.pos);
        for (let i = 0; i < this.obstacles.length; i++) {
            var toCircle = this.obstacles[i].obj.position.clone();
            toCircle.sub(n1.pos);

            var a = 1.0;
            var b = -2 * dir.dot(toCircle);
            var c = toCircle.lengthSq() - rad*rad;
            var d = b*b - 4*a*c;

            if (d >= 0) {
                var t1 = (-b - Math.sqrt(d))/(2*a);

                if (t1 > 0 && t1 < dist) {
                    return false;
                }
            }
        }
        return true;
    }

    sample_uniform() {
        /* 
         * Sample node from anywhere in space
         */
        var rand_w = getRandomArbitrary(
            -this.width/2+agent_rad*2, 
            this.width/2-agent_rad*2
        );
        var rand_h = getRandomArbitrary(
            -this.height/2+agent_rad*2,
            this.height/2-agent_rad*2
        );

        var node = new Node(
            new THREE.Vector3(rand_w, this.agent.position.y, rand_h),
            null
        );

        return node;
    }

    cost(node) {
        return node.cost;
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

    render_tree() {
        this.changed_nodes.forEach((node) => {
            if (node.parent !== null) {
                const line = new THREE.Line(
                    new THREE.BufferGeometry()
                        .setFromPoints(
                            [node.parent.pos, node.pos]
                        ),
                    new THREE.LineBasicMaterial(
                        {
                            color: 0x0000ff,
                            transparent: true
                        }
                    )
                );
    
                if (node.line !== null) scene.remove(node.line);
                scene.add(line);
                node.line = line;
            }
        });
        this.changed_nodes.length = [];
        for (let i = 0; i < this.planned_path.length-1; i++) {
            if (this.planned_path[i].line === null) {
                const line = new THREE.Line(
                    new THREE.BufferGeometry()
                        .setFromPoints(
                            [
                                this.planned_path[i].parent.pos, 
                                this.planned_path[i].pos
                            ]
                        ),
                    new THREE.LineBasicMaterial(
                        {
                            color: 0x0000ff,
                            transparent: true
                        }
                    )
                );
                scene.add(line);
                this.planned_path[i].line = line;
            }
            this.planned_path[i].line.material.color = new THREE.Color("yellow");
            this.planned_path[i].line.material.needsUpdate = true;
        }
    }
}

class Queue {
    constructor() {
      this.items = [];
    }

    clear() {
        this.items = [];
    }
  
    // Implementing various methods of javascript queue:
  
    // 1. adding element to the queue
    enqueue(item) {
      this.items.push(item);
    }
    
    enqueue_front(item) {
        this.items.unshift(item);
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