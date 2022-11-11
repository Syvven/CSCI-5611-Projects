import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {DragControls} from './DragControls.js';
import {OrbitControls} from './OrbitControls.js';
import WebGL from './webGLCheck.js';
import {GLTFLoader} from './GLTFLoader.js';

// important things
var scene, camera, renderer, stats;
var orbitControls, dragControls;
var orbitControlsWereEnabled = false;
var gui, simObj;
var gui_width = 300;
var prevTime;

// object values
var numBoxes = 10;
var boxSize = 10;
var boxes = [];
var controlArr = [];

// kiwi values
var kiwi, gltfLoader, mixer
var modelReady = false;
var speed = 0;
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

function getRandomArbitrary(min, max) {
    return Math.random() * (max - min) + min;
}

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

    dragControls = new DragControls(controlArr, camera, renderer.domElement);
    dragControls.addEventListener('dragstart', (e) => {
        if (orbitControls.enabled) {
            orbitControlsWereEnabled = true;
            orbitControls.enabled = false;
            orbitControls.enableDamping = false;
        }
    });
    dragControls.addEventListener('drag', (e) => {
        e.object.position.y = 0;
    })
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
    setup_room_walls();
    gen_boxes();
    set_gui();
    load_kiwi();
}

function load_kiwi() {
    gltfLoader = new GLTFLoader();
    mixer = 
    gltfLoader.load('../models/kiwi.glb', function(gltf) {
        kiwi = gltf.scene;
        kiwi.scale.set(5,5,5);
        kiwi.position.y = 7.5;
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
        freeCam: false
    }

    const simFolder = gui.addFolder('Sim Controls');
    simFolder.add(simObj, 'freeCam').name('Lock Camera').onChange(() => {
        orbitControls.enabled = !orbitControls.enabled;
    });
}

function gen_boxes() {
    for (let i = 0; i < numBoxes; i++) {
        // adds a rotating cube, just for testing purposes
       var geometry = new THREE.BoxGeometry( boxSize, boxSize, boxSize);
       var material = new THREE.MeshBasicMaterial( { color: 0x957433 } );
       var cube = new THREE.Mesh( geometry, material );
       cube.geometry.translate(
           getRandomArbitrary(-floorWidth/2, floorWidth/2),
           boxSize/2,
           getRandomArbitrary(-floorHeight/2, floorHeight/2)
       );

       boxes.push(cube);
       controlArr.push(cube);

       scene.add( cube );
   }
}

function setup_room_walls() {
    var groundTexture = new THREE.TextureLoader().load("../images/floor_full.png");
    // groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
    // groundTexture.repeat.set(10,10);
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

    // // little bit of code for debugging floor vertices
    // let wireframe = new THREE.WireframeGeometry( groundGeometry );
    // let line = new THREE.LineSegments( wireframe );
    // line.position.y = 1;
    // line.rotation.x = -Math.PI/2;
    // line.material.color.setHex(0x000000);
        
    // scene.add(line);

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

    if (moving) mixer.update(dt);
    if (orbitControls.enabled) orbitControls.update(1*dt);
    
	renderer.render( scene, camera );
    stats.update();
}

// event listeners
window.addEventListener( 'resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.render(scene, camera);
}, false);

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
    }
});

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
