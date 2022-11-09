import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {DragControls} from './DragControls.js';
import {OrbitControls} from './OrbitControls.js';
import WebGL from './webGLCheck.js';

// important things
var scene, camera, renderer, stats, orbitControls;
var prevTime;

// object values
var boxes = [];

// control booleans

// controls whether or not view is fixed
// from top down at the center of the scene
var freeCam = false;

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
    camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.00001, 1000 );
    console.log(window.innerWidth, window.innerHeight);
    camera.position.set( 0, window.innerWidth/3, 0 );
    camera.lookAt( 0, 0, 0 );

    // orbit controls
    // for testing purposes
    // get rid of once done ?
    if (freeCam) {
        orbitControls = new OrbitControls(camera, renderer.domElement);
        orbitControls.enableDamping = true;
        orbitControls.zoomSpeed = 2;
    }

    // sets up the fps counter in the top left of the window
    stats = new Stats();
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    // hemisphere light for equal lighting
    var hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444 );
    hemiLight.position.set( 0, 300, 0 );
    scene.add( hemiLight );

    // initialize aspects of the scene such as walls, IK things, and objects to be thrown around
    // adds texture for the ground
    var groundTexture = new THREE.TextureLoader().load("../images/floor.png");
    // groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
    // groundTexture.repeat.set(10,10);
    groundTexture.encoding = THREE.sRGBEncoding;
    var groundMaterial = new THREE.MeshStandardMaterial({map:groundTexture, side: THREE.DoubleSide});
    var mesh = new THREE.Mesh(new THREE.PlaneGeometry(window.innerWidth/2, window.innerHeight/2, 10),groundMaterial);
    mesh.position.y = -0.1;
    mesh.rotation.x = -Math.PI/2;
    scene.add(mesh);

}

function animate() {
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    if (freeCam) {
        orbitControls.update(1*dt);
    }
    
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
