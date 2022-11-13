import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {DragControls} from './DragControls.js';
import {OrbitControls} from './OrbitControls.js';
import WebGL from './webGLCheck.js';
import {GLTFLoader} from './GLTFLoader.js';

// sources
// -> lightning: https://opengameart.org/content/lightning-sprite-texture
// -> bg: https://www.spriters-resource.com/fullview/146176/

// important things
var scene, camera, renderer, stats;
var raycaster; 
var orbitControls, dragControls;
var orbitControlsWereEnabled = false;
var gui, simObj;
var gui_width = 300;
var prevTime;

// kiwi values
var kiwi, gltfLoader, mixer
var modelReady = false;
var moving = false;
var moveForward = false;
var moveBackward = false;
var moveLeft = false;
var moveRight = false;

// var rot_inertia = (boxSize*boxSize + boxSize*boxSize)/12;
// var momentum = THREE.Vector3(0,0,0);
// var angular_momentum = 0.0;
// var total_force = THREE.Vector3(0,0);
// var total_torque = 0.0; // turn all these into arrays
// get started on kinematics first though!!!!

// control booleans

var field_of_view = 45;
var cam_init_height = window.innerWidth/3.25;
var floorBaseVertHeight = 6;
var floorBaseVertWidth = 9;
var vertScale = 3;
var floorNumVertHeight = floorBaseVertHeight*vertScale;
var floorNumVertWidth = floorBaseVertWidth*vertScale
var floorWidth = ((window.innerWidth/1.75)/9) * 7;
var floorHeight = ((window.innerHeight/1.5)/6) * 4;

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
    orbitControls.enabled = false;

    setup_room_walls();
    gen_boxes();
    set_gui();
    load_kiwi();

    dragControls = new DragControls(controlArr, camera, renderer.domElement);
    dragControls.addEventListener('dragstart', (e) => {
        if (orbitControls.enabled) {
            orbitControlsWereEnabled = true;
            orbitControls.enabled = false;
            orbitControls.enableDamping = false;
        }
    });
    dragControls.addEventListener('drag', (e) => {
        e.object.position.set(intersects.x, intersects.y, intersects.z);
    });
    dragControls.addEventListener('dragend', (e) => {
        if (orbitControlsWereEnabled) {
            orbitControls.enabled = true;
            orbitControls.enableDamping = true;
            orbitControlsWereEnabled = false;
        } 
    });

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

// useful constants
var ninety_rad = radians(90);
var thirty_rad = radians(30);
var sixty_rad = radians(60);
var fifteen_rad = radians(15);
var pointHeight = 10;
var maxArmLen = 10;
var armWidth = 8;
var armScale = new THREE.Vector3(1,0.0,1);
var accel = 0.01;

// initializes and creates the lines for the inverse kinematics stuff
var numSegments = 10;
var segments, endpoint, arms, endpoint3;

function initiate_single_arm_kinematic_stuff() {
    segments = []
    arms = []
    endpoint = new THREE.Vector2();
    endpoint3 = new THREE.Vector3()
    for (let i = 0; i < numSegments; i++) {
        segments.push({
            len: 0,
            ang: 0,
            acc: accel,
            max_a: (i != numSegments-1) ? fifteen_rad : ninety_rad,
            min_a: (i != numSegments-1) ? -fifteen_rad : ninety_rad,
            start: new THREE.Vector2(kiwi.position.x,kiwi.position.z+5)
        });
    }

    var armText = new THREE.TextureLoader().load("../images/lazer_sprite_2.png");

    const material = new THREE.MeshStandardMaterial({
        map: armText,
        transparent: true
    });

    for (let i = 0; i < numSegments; i++) {
        var arm = new THREE.Mesh(
            new THREE.PlaneGeometry(armWidth, maxArmLen, 10, 10),
            material
        );
        
        arm.geometry.translate(0, -maxArmLen/2, 0 );
        arm.rotation.x = -Math.PI/2;
        arm.position.y = pointHeight;

        scene.add(arm);

        arms.push(arm);
    }
}

var num_split1 = 5, num_split2 = 5, num_main = 5;
var split1_segs, split2_segs, main_arm_segs;
var split1, split2, main_arm;
var endEffector1, endEffector2;
var goal1, goal2;

function initiate_double_arm_kinematic_stuff() {
    // reset things for when recalling this
    split1 = [], split2 = [], main_arm = [];
    split1_segs = [], split2_segs = [], main_arm_segs = [];
    endEffector1 = new THREE.Vector2(), endEffector2 = new THREE.Vector2(); 
    goal1 = new THREE.Vector2(), goal2 = new THREE.Vector2();

    // could put the creation of the geometry up here too but it
    // might need to not be the same for each in the future so I didn't
    var armText = new THREE.TextureLoader().load("../images/lazer_sprite_2.png");
    const material = new THREE.MeshStandardMaterial({
        map: armText,
        transparent: true
    });

    // create the main arm segments
    for (let i = 0; i < num_main; i++) {
        main_arm_segs.push({
            len: 0,
            ang: 0,
            acc: accel,
            max_a: (i != num_main-1) ? thirty_rad : ninety_rad,
            min_a: (i != num_main-1) ? -thirty_rad : ninety_rad,
            // max_a: null,
            // min_a: null,
            start: new THREE.Vector2(kiwi.position.x,kiwi.position.z+5)
        });
        // lets try having two chains where both pull the middle one?

            var arm = new THREE.Mesh(
                new THREE.PlaneGeometry(armWidth, maxArmLen, 10, 10),
                material
            );
            
            arm.geometry.translate(0, -maxArmLen/2, 0 );
            arm.rotation.x = -Math.PI/2;
            arm.position.y = pointHeight;
    
            scene.add(arm);
    
            main_arm.push(arm);
    }

    // create the list of split1 and main segments
    for (let i = 0; i < num_split1; i++) {
        split1_segs.push({
            len: 0,
            ang: 0,
            acc: accel,
            max_a: (i != num_split1+num_main-1) ? thirty_rad : ninety_rad,
            min_a: (i != num_split1+num_main-1) ? -thirty_rad : ninety_rad,
            // max_a: null,
            // min_a: null,
            start: new THREE.Vector2(kiwi.position.x,kiwi.position.z+5)
        });

            var arm = new THREE.Mesh(
                new THREE.PlaneGeometry(armWidth, maxArmLen, 10, 10),
                material
            );
            
            arm.geometry.translate(0, -maxArmLen/2, 0 );
            arm.rotation.x = -Math.PI/2;
            arm.position.y = pointHeight;
    
            scene.add(arm);
    
            split1.push(arm);
    }
    for (let i = 0; i < num_main; i++) {
        split1_segs.push(main_arm_segs[i]);
        split1.push(main_arm[i]);
    }

    // create the list of split2 and main segments
    for (let i = 0; i < num_split2; i++) {
        split2_segs.push({
            len: 0,
            ang: 0,
            acc: accel,
            max_a: ((i != num_split2+num_main-1) ? thirty_rad : ninety_rad),
            min_a: ((i != num_split2+num_main-1) ? -thirty_rad : ninety_rad),
            // max_a: null,
            // min_a: null,
            start: new THREE.Vector2(kiwi.position.x,kiwi.position.z+5)
        });

        
            var arm = new THREE.Mesh(
                new THREE.PlaneGeometry(armWidth, maxArmLen, 10, 10),
                material
            );
            
            arm.geometry.translate(0, -maxArmLen/2, 0 );
            arm.rotation.x = -Math.PI/2;
            arm.position.y = pointHeight;
    
            scene.add(arm);
    
            split2.push(arm);
    }
    for (let i = 0; i < num_main; i++) {
        split2_segs.push(main_arm_segs[i]);
        split2.push(main_arm[i])
    }
}

var kiwiHeight = 7.5;
var kiwiDir = new THREE.Vector3();
var kiwiVel = new THREE.Vector3();
var startDir = new THREE.Vector2(0, 1);
var kiwiDir2 = new THREE.Vector2();
function load_kiwi() {
    gltfLoader = new GLTFLoader();
    mixer = 
    gltfLoader.load('../models/kiwi.glb', function(gltf) {
        kiwi = gltf.scene;
        kiwi.scale.set(5,5,5);
        kiwi.position.y = kiwiHeight;
        kiwi.position.x = 10;
        kiwi.traverse((o) => {
            if (o.isMesh) {
                o.castShadow = true;
                o.receiveShadow = true;
            }
        });

        mixer = new THREE.AnimationMixer(kiwi);
        mixer.clipAction(gltf.animations[0]).play();

        scene.add(kiwi);

        modelReady = true;
        if (simObj.single_arm)
            initiate_single_arm_kinematic_stuff();
        if (simObj.double_arm)
            initiate_double_arm_kinematic_stuff();
        // after this point, animate() is run
    }, undefined, function(error) {
        console.error(error);
    });
}

function set_gui() {
    gui = new GUI();
    // base is 246
    gui.width = gui_width;

    simObj = {
        freeCam: true,
        single_arm: true,
        double_arm: false
    };

    const simFolder = gui.addFolder('Sim Controls');
    simFolder.add(simObj, 'freeCam').name('Lock Camera').onChange(() => {
        orbitControls.enabled = !orbitControls.enabled;
    });
    simFolder.add(simObj, 'single_arm').name('Single Lazer').onChange(() => {
        for (let i = 0; i < num_split1; i++) {
            scene.remove(split1[i]);
        }
        for (let i = 0; i < num_split2; i++) {
            scene.remove(split2[i]);
        }
        for (let i = 0; i < num_main; i++) {
            scene.remove(main_arm[i]);
        }
        initiate_single_arm_kinematic_stuff();
        simObj.double_arm = false;
        simObj.single_arm = true;
    });
    simFolder.add(simObj, 'double_arm').name('Split Lazer').onChange(() => {
        for (let i = 0; i < arms.length; i++) {
            scene.remove(arms[i]);
        }
        initiate_double_arm_kinematic_stuff();
        simObj.single_arm = false;
        simObj.double_arm = true;
    });
}

// object values
var numBoxes = 10;
var boxSize = 20;
var boxes = [];
var controlArr = [];

// collision variables
var joint_hb_rad = 0;
var box_hb_rad = Math.sqrt(2*(boxSize*boxSize))/2;

function gen_boxes() {
    var text = new THREE.TextureLoader().load("../images/box.jpg");
    for (let i = 0; i < numBoxes; i++) {
        // adds a rotating cube, just for testing purposes
        var geometry = new THREE.BoxGeometry( boxSize, boxSize, boxSize);
        var material = new THREE.MeshBasicMaterial( { map: text, color: 0x957433 } );
        var cube = new THREE.Mesh( geometry, material );
        cube.position.set(
            getRandomArbitrary(-floorWidth/2+boxSize, floorWidth/2-boxSize),
            pointHeight,
            getRandomArbitrary(-floorHeight/2+boxSize, floorHeight/2-boxSize)
        );
        
        boxes.push(cube);
        controlArr.push(cube);

        scene.add( cube );
   }
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

var goal = new THREE.Vector2();
function solve_single() {
    var dotProd, angleDiff;

    for (let i = 0; i < segments.length; i++) {
        var startToGoal = goal.clone();
        startToGoal.sub(segments[i].start);

        var startToEndEffector = endpoint.clone();
        startToEndEffector.sub(segments[i].start);

        startToGoal.normalize(); 
        startToEndEffector.normalize();

        dotProd = startToGoal.dot(startToEndEffector);
        dotProd = clamp(dotProd, -1, 1);

        angleDiff = Math.acos(dotProd) * segments[i].acc;

        if (cross(startToGoal, startToEndEffector) < 0) segments[i].ang += angleDiff;
        else segments[i].ang -= angleDiff;
        
        // add angle limits here
        if (segments[i].max_a != null && segments[i].ang > segments[i].max_a) {
            segments[i].ang = segments[i].max_a;
        }
        if (segments[i].min_a != null && segments[i].ang < segments[i].min_a) {
            segments[i].ang = segments[i].min_a;
        }

        fk_single();
    }
}

function solve_double() {
    var dotProd, angleDiff;
    for (let i = 0; i < split1_segs.length; i++) {
        var seg = split1_segs[i];
        var startToGoal = goal1.clone();
        startToGoal.sub(seg.start);

        var startToEndEffector = endEffector1.clone();
        startToEndEffector.sub(seg.start);

        startToGoal.normalize(); 
        startToEndEffector.normalize();

        dotProd = startToGoal.dot(startToEndEffector);
        dotProd = clamp(dotProd, -1, 1);

        angleDiff = Math.acos(dotProd) * seg.acc;

        if (cross(startToGoal, startToEndEffector) < 0) seg.ang += angleDiff;
        else seg.ang -= angleDiff;
        
        // add angle limits here
        if (seg.max_a != null && seg.ang > seg.max_a) {
            seg.ang = seg.max_a;
        }
        if (seg.min_a != null && seg.ang < seg.min_a) {
            seg.ang = seg.min_a;
        }

        fk_double();
    }
    for (let i = 0; i < split2_segs.length; i++) {
        var seg = split2_segs[i];
        var startToGoal = goal2.clone();
        startToGoal.sub(seg.start);

        var startToEndEffector = endEffector2.clone();
        startToEndEffector.sub(seg.start);

        startToGoal.normalize(); 
        startToEndEffector.normalize();

        dotProd = startToGoal.dot(startToEndEffector);
        dotProd = clamp(dotProd, -1, 1);

        angleDiff = Math.acos(dotProd) * seg.acc;

        if (cross(startToGoal, startToEndEffector) < 0) seg.ang += angleDiff;
        else seg.ang -= angleDiff;
        
        // add angle limits here
        if (seg.max_a != null && seg.ang > seg.max_a) {
            seg.ang = seg.max_a;
        }
        if (seg.min_a != null && seg.ang < seg.min_a) {
            seg.ang = seg.min_a;
        }

        fk_double();
    }
}

function fk_single() {
    var tot = 0;
    for (let i = segments.length-2; i >= 0; i--) {
        tot = 0;
        var prev = segments[i+1];
        for (let j = segments.length-1; j > i; j--) {
            tot += segments[j].ang;
        }
        segments[i].start.x = Math.cos(tot)*prev.len;
        segments[i].start.y = Math.sin(tot)*prev.len;

        segments[i].start.add(prev.start);
        handle_collisions(segments[i]);
    }

    tot = 0;
    for (let i = 0; i < segments.length; i++) {
        tot += segments[i].ang;
    }

    endpoint.x = Math.cos(tot)*segments[0].len;
    endpoint.y = Math.sin(tot)*segments[0].len;
    endpoint.add(segments[0].start);

    check_holding(1);
}

function fk_double() {
    // first update the split1 segment
    var tot = 0;
    for (let i = split1_segs.length-2; i >= 0; i--) {
        tot = 0;
        var prev = split1_segs[i+1];
        for (let j = split1_segs.length-1; j > i; j--) {
            tot += split1_segs[j].ang;
        }
        split1_segs[i].start.x = Math.cos(tot)*prev.len;
        split1_segs[i].start.y = Math.sin(tot)*prev.len;

        split1_segs[i].start.add(prev.start);
        handle_collisions(split1_segs[i]);
    }
    tot = 0;
    for (let i = 0; i < split1_segs.length; i++) {
        tot += split1_segs[i].ang;
    }
    endEffector1.x = Math.cos(tot)*split1_segs[0].len;
    endEffector1.y = Math.sin(tot)*split1_segs[0].len;
    endEffector1.add(split1_segs[0].start);

    check_holding(1)

    tot = 0;
    for (let i = split2_segs.length-2; i >= 0; i--) {
        tot = 0;
        var prev = split2_segs[i+1];
        for (let j = split2_segs.length-1; j > i; j--) {
            tot += split2_segs[j].ang;
        }
        split2_segs[i].start.x = Math.cos(tot)*prev.len;
        split2_segs[i].start.y = Math.sin(tot)*prev.len;

        split2_segs[i].start.add(prev.start);
        handle_collisions(split2_segs[i]);
    }
    tot = 0;
    for (let i = 0; i < split2_segs.length; i++) {
        tot += split2_segs[i].ang;
    }
    endEffector2.x = Math.cos(tot)*split2_segs[0].len;
    endEffector2.y = Math.sin(tot)*split2_segs[0].len;
    endEffector2.add(split2_segs[0].start);

    check_holding(2);
}

var single_holding = false;
var double_holding_1 = false;
var double_holding_2 = false;
function check_holding(num) {
    if (extending) {
        if (simObj.double_arm) {
            if (num == 1) {
                if (endEffector1.distanceTo(goal1) < box_hb_rad) {
                    double_holding_1 = true;
                }
            } else {
                if (endEffector2.distanceTo(goal2) < box_hb_rad) {
                    double_holding_2 = true;
                }
            }
        } else {
            if (endpoint.distanceTo(goal) < box_hb_rad) {
                single_holding = true;
            }
        }
    }   
}

function handle_collisions(seg) {
    for (let i = 0; i < boxes.length; i++) {
        if ((single_holding || double_holding_1) && i === closest1.index) continue;
        if ((double_holding_2 && i === closest2.index)) continue;
        var boxCent = new THREE.Vector2(boxes[i].position.x, boxes[i].position.z)
        var dist = seg.start.distanceTo(boxCent);
        if (dist < joint_hb_rad+box_hb_rad) {
            var norm = seg.start.clone();
            norm.sub(boxCent);
            norm.normalize();
            norm.multiplyScalar((box_hb_rad+joint_hb_rad)*1.001);
            norm.add(boxCent);
            seg.start = norm;
        }
    }

    if (seg.start.x > (floorWidth/2)) {
        seg.start.x = floorWidth/2;
    }
    if (seg.start.x < (-floorWidth/2)) {
        seg.start.x = -floorWidth/2;
    }
    if (seg.start.y > (floorHeight/2)) {
        seg.start.y = floorHeight/2;
    }
    if (seg.start.y < (-floorHeight/2)) {
        seg.start.y = -floorHeight/2;
    }
}

function update_single_line_points() {
    var total = 0;
    for (let i = numSegments-1; i >= 0; i--) {
        total += segments[i].ang;
        arms[i].position.set(
            segments[i].start.x,
            pointHeight,
            segments[i].start.y 
        );
        arms[i].rotation.z = -total + ninety_rad;
        arms[i].scale.x = armScale.x;
        arms[i].scale.y = armScale.y;
    }
}

function update_double_line_points() {
    var total = 0;
    for (let i = split1_segs.length-1; i >= 0; i--) {
        total += split1_segs[i].ang;
        split1[i].position.set(
            split1_segs[i].start.x,
            pointHeight,
            split1_segs[i].start.y
        )
        split1[i].rotation.z = -total + ninety_rad;
        split1[i].scale.x = armScale.x;
        split1[i].scale.y = armScale.y;
    }

    total = 0;
    for (let i = split2_segs.length-1; i >= 0; i--) {
        total += split2_segs[i].ang;
        split2[i].position.set(
            split2_segs[i].start.x,
            pointHeight,
            split2_segs[i].start.y
        )
        split2[i].rotation.z = -total + ninety_rad;
        split2[i].scale.x = armScale.x;
        split2[i].scale.y = armScale.y;
    }
}

function update_len(dt) {
    if (extending) {
        armScale.y += dt;
        armScale.x += dt;
        if (armScale.y > 1) {
            armScale.y = 1;
            armScale.x = 1;
        }
    } else {
        armScale.y -= dt;
        armScale.x -= dt;
        if (armScale.y < 0) {
            armScale.y = 0.001;
            armScale.x = 0.001;
        }
    }
    var dot = kiwiDir2.dot(startDir);
    var cross = kiwiDir2.cross(startDir);
    var rot = Math.atan2(cross, dot);
    if (simObj.single_arm) {
        segments[numSegments-1].start.x = kiwi.position.x;
        segments[numSegments-1].start.y = kiwi.position.z;
        segments[numSegments-1].min_a = -rot+ninety_rad;
        segments[numSegments-1].max_a = -rot+ninety_rad;
        for (let i = 0; i < numSegments; i++) {
            segments[i].len = maxArmLen * armScale.y;
        }
    }
    if (simObj.double_arm) {
        main_arm_segs[num_main-1].start.x = kiwi.position.x;
        main_arm_segs[num_main-1].start.y = kiwi.position.z;
        main_arm_segs[num_main-1].min_a = -rot+ninety_rad;
        main_arm_segs[num_main-1].max_a = -rot+ninety_rad;
        for (let i = 0; i < split1_segs.length; i++) {
            split1_segs[i].len = maxArmLen * armScale.y;
        }
        for (let i = 0; i < split2_segs.length; i++) {
            split2_segs[i].len = maxArmLen * armScale.y;
        }
    }
    joint_hb_rad = maxArmLen*armScale.y*0.5;
}

var kiwiPos = new THREE.Vector2();
var boxCent = new THREE.Vector2();
function update_kiwi_pos(dt) {
    kiwiDir.x = intersects.x;
    kiwiDir.y = kiwiHeight;
    kiwiDir.z = intersects.z;
    kiwi.lookAt(kiwiDir);
    kiwiDir.sub(kiwi.position);
    kiwiDir2.x = kiwiDir.x;
    kiwiDir2.y = kiwiDir.z;
    kiwiDir2.normalize();
    if (!moving) {   
        kiwiVel.x = 0;
        kiwiVel.z = 0;
        return 
    }
    mixer.update(dt);

    if (moveForward) kiwiVel.z += -1;
    if (moveLeft) kiwiVel.x += -1;
    if (moveRight) kiwiVel.x += 1;
    if (moveBackward) kiwiVel.z += 1; 

    kiwiVel.normalize();
    kiwiVel.y = 0;
    kiwi.position.add(kiwiVel);

    for (let i = 0; i < boxes.length; i++) {
        if ((single_holding || double_holding_1) && i === closest1.index) continue;
        if ((double_holding_2 && i === closest2.index)) continue;
        boxCent.x = boxes[i].position.x;
        boxCent.y = boxes[i].position.z;
        kiwiPos.x = kiwi.position.x;
        kiwiPos.y = kiwi.position.z;
        var dist = kiwiPos.distanceTo(boxCent);
        if (dist < 1.5*box_hb_rad) {
            var norm = kiwiPos;
            norm.sub(boxCent);
            norm.normalize();
            norm.multiplyScalar((box_hb_rad*1.5)*1.001);
            norm.add(boxCent);
            kiwi.position.x = norm.x;
            kiwi.position.z = norm.y;
        }
    }

    if (kiwi.position.x > (floorWidth/2)-boxSize/1.7) {
        kiwi.position.x = floorWidth/2-boxSize/1.7;
    }
    if (kiwi.position.x < (-floorWidth/2)+boxSize/1.7) {
        kiwi.position.x = -floorWidth/2+boxSize/1.7;
    }
    if (kiwi.position.z > (floorHeight/2)-boxSize/1.7) {
        kiwi.position.z = floorHeight/2-boxSize/1.7;
    }
    if (kiwi.position.z < (-floorHeight/2)+boxSize/1.7) {
        kiwi.position.z = -floorHeight/2+boxSize/1.7;
    }
}

function update_boxes() {
    if (extending) {
        if (simObj.single_arm) {
            if (single_holding) {
                closest1.obj.position.x = endpoint.x
                closest1.obj.position.z = endpoint.y

                closest1.obj.position.x = clamp(
                    closest1.obj.position.x,
                    -floorWidth/2+boxSize/2,
                    (floorWidth/2)-boxSize/2
                )
                closest1.obj.position.z = clamp(
                    closest1.obj.position.z,
                    -floorHeight/2+boxSize/2,
                    (floorHeight/2)-boxSize/2
                )
    
                goal.x = intersects.x;
                goal.y = intersects.z;
            }
        } else {
            if (double_holding_1) {
                closest1.obj.position.x = endEffector1.x
                closest1.obj.position.z = endEffector1.y
    
                goal1.x = intersects.x;
                goal1.y = intersects.z;

                closest1.obj.position.x = clamp(
                    closest1.obj.position.x,
                    -floorWidth/2+boxSize/2,
                    (floorWidth/2)-boxSize/2
                )
                closest1.obj.position.z = clamp(
                    closest1.obj.position.z,
                    -floorHeight/2+boxSize/2,
                    (floorHeight/2)-boxSize/2
                )
            }
            if (double_holding_2) {
                closest2.obj.position.x = endEffector2.x
                closest2.obj.position.z = endEffector2.y

                closest2.obj.position.x = clamp(
                    closest2.obj.position.x,
                    -floorWidth/2+boxSize/2,
                    (floorWidth/2)-boxSize/2
                )
                closest2.obj.position.z = clamp(
                    closest2.obj.position.z,
                    -floorHeight/2+boxSize/2,
                    (floorHeight/2)-boxSize/2
                )
    
                goal2.x = -intersects.x;
                goal2.y = intersects.z;
            }
        }
    } 
}

function update_closest() {
    if (!single_holding && !double_holding_1) {
        closest1 = {obj: null, dist:9e9, index: 0};
        for (let i = 0; i < boxes.length; i++) {
            if (simObj.single_arm) {
                endpoint3.x = endpoint.x;
                endpoint3.z = endpoint.y;
            } else {
                endpoint3.x = endEffector1.x;
                endpoint3.z = endEffector1.y;
            }
            endpoint3.y = pointHeight;
            
            var dist = boxes[i].position.distanceTo(endpoint3);
            if (dist < closest1.dist) {
                closest1.obj = boxes[i];
                closest1.dist = dist;
                closest1.index = i;
            }
        }
        
        if (simObj.single_arm) {
            goal.x = closest1.obj.position.x;
            goal.y = closest1.obj.position.z;
        } else {
            goal1.x = closest1.obj.position.x;
            goal1.y = closest1.obj.position.z;
        }
    }

    if (simObj.double_arm && !double_holding_2) {
        closest2 = {obj: null, dist:9e9, index: 0};
        for (let i = 0; i < boxes.length; i++) {
            if (i !== closest1.index) {
                endpoint3.x = endEffector2.x;
                endpoint3.z = endEffector2.y;
                var dist = boxes[i].position.distanceTo(endpoint3);
                if (dist < closest2.dist) {
                    closest2.obj = boxes[i];
                    closest2.dist = dist;
                    closest2.index = i;
                }
            }
        }

        goal2.x = closest2.obj.position.x;
        goal2.y = closest2.obj.position.z;
    } 
}

var extending = false;
function animate() {
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    if (!paused && modelReady) {
        update_closest();
        update_kiwi_pos(dt);
        if (simObj.single_arm) {
            update_len(dt);
            fk_single();
            solve_single();
            update_single_line_points();
        }
        if(simObj.double_arm) {
            update_len(dt);
            fk_double();
            solve_double();
            update_double_line_points();
        }
        update_boxes();
    }  

    

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
        case 'ArrowUp':
        case 'KeyW':
            moveForward = true;
            moving = true;
            break;

        case 'ArrowLeft':
        case 'KeyA':
            moveLeft = true;
            moving = true;
            break;

        case 'ArrowDown':
        case 'KeyS':
            moveBackward = true;
            moving = true;
            break;

        case 'ArrowRight':
        case 'KeyD':
            moveRight = true;
            moving = true;
            break;
        case 'Space':
            paused = !paused;
    }
    if (moveForward && moveBackward) {
        if (!(moveLeft && moveRight)) {
            if (moveLeft || moveRight) {
                moving = false;
            }
        }
    }
});

document.addEventListener( 'keyup', (e) => {
    switch ( e.code ) {

        case 'ArrowUp':
        case 'KeyW':
            moveForward = false;
            break;

        case 'ArrowLeft':
        case 'KeyA':
            moveLeft = false;
            break;

        case 'ArrowDown':
        case 'KeyS':
            moveBackward = false;
            break;

        case 'ArrowRight':
        case 'KeyD':
            moveRight = false;
            break;

    }
    if (!(moveForward || moveBackward || moveLeft || moveRight)) {
        moving = false;
        mixer.setTime(1.905);
    }
});

window.addEventListener('contextmenu', (e) => {e.preventDefault()})
window.addEventListener( 'mousedown', (e) => { 
    e.preventDefault();
    if (e.button === 0) {
        extending = true; 
    }
    
});
window.addEventListener( 'mouseup', (e) => {
    if (e.button === 0) {
        extending = false; 
        if (single_holding) {
            single_holding = false;
        }
        if (double_holding_1) {
            double_holding_1 = false;
        }
        if (double_holding_2) {
            double_holding_2 = false;
        }
    }
    
});

var mouse = new THREE.Vector2();
var plane = new THREE.Plane(new THREE.Vector3(0,1,0), -pointHeight);
var intersects = new THREE.Vector3();
var closest1 = {obj: null, dist:9e9, index: 0}
var closest2 = {obj: null, dist:9e9, index: 0};
window.addEventListener('mousemove', (e) => {
    mouse.x = ( e.clientX / window.innerWidth ) * 2 - 1;
	mouse.y = - ( e.clientY / window.innerHeight ) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    raycaster.ray.intersectPlane(plane, intersects);
}, false);

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