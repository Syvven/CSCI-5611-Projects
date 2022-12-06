import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import {GLTFLoader} from './GLTFLoader.js';
import {FlyControls} from './FlyControls.js';
import {OrbitControls} from './OrbitControls.js';
import WebGL from './webGLCheck.js';

// scene globals
var scene, renderer, loader;
var flyControls, orbitControls, camera;

// other render globals
var geometry, cube;
var prevTime;

// rope globals
var floorY, radius, stringTop, restLen, mass, k, kv, kfric, gravity;
var dampFricU, forceU;
var nodePos, nodeVel, nodeAcc, maxNodes, numNodes, nodes;
var positions, line;

// key handler booleans
var paused = true;

var stats;

setup();

function setup() {
    ///////////////////////// RENDERING INFO ////////////////////////////////////////////////////////
    stats = new Stats();
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    scene = new THREE.Scene();

    // creates renderer and sets its size
    renderer = new THREE.WebGLRenderer({depth:true});
    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.setClearColor(0x555555);
    document.body.appendChild( renderer.domElement );

    // creates new camera / sets position / sets looking angle
    camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 5000 );
    camera.position.set( 0, 0, 200 );
    camera.lookAt( 0, 0, 0 );

    // flyControls = new FlyControls(camera, renderer.domElement);
    // flyControls.dragToLook = true;
    // flyControls.movementSpeed = 10;
    // flyControls.rollSpeed = 1;

    orbitControls = new OrbitControls(camera, renderer.domElement);
    orbitControls.enableDamping = true;
    orbitControls.zoomSpeed = 2;


    // // other setup items go here

    // // kiwi loading, only do after cloth is done
    // loader = new GLTFLoader();

    // loader.load('../models/kiwi.glb', function(gltf) {
    //     scene.add(gltf.scene);
    // }, undefined, function(error) {
    //     console.error(error);
    // });

    // adds texture for the ground
    var groundTexture = new THREE.TextureLoader().load("../models/floor-min.png");
    groundTexture.weapS = groundTexture.wrapT = THREE.RepeatWrapping;
    groundTexture.encoding = THREE.sRGBEncoding;
    var groundMaterial = new THREE.MeshStandardMaterial({map:groundTexture});
    var mesh = new THREE.Mesh(new THREE.PlaneBufferGeometry(100,100),groundMaterial);
    mesh.position.y = 0.0;
    mesh.rotation.x = -Math.PI/2;
    scene.add(mesh);

    // // adds a rotating cube, just for testing purposes
    // geometry = new THREE.BoxGeometry( 1, 1, 1 );
    // material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
    // cube = new THREE.Mesh( geometry, material );
    // scene.add( cube );

    // hemisphere light for equal lighting
    var hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444 );
    hemiLight.position.set( 0, 300, 0 );
    scene.add( hemiLight );

    // date for dt purposes
    prevTime = new Date();

    //////////////////////// ROPE INFO ///////////////////////////////////////

    floorY = 0.0; radius = 5.0;
    mass = 0.01; k = 1000; kv = 200; kfric = 20.0;
    numNodes = 100; maxNodes = 101;
    gravity = new THREE.Vector3(0.0, -400, 0.0);
    stringTop = new THREE.Vector3(0.0, 150.0, 0.0);
    restLen = (stringTop.y-10)/(numNodes*2); 
    nodePos = []; nodeVel = []; nodeAcc = []; nodes = [];

    // build the lines of the rope
    var geo = new THREE.BufferGeometry();
    positions = new Float32Array(maxNodes*3);

    positions.needsUpdate = true;

    for (let i = 0, index = 0, l = numNodes; i < l; i++, index += 3) {
        nodePos[i] = new THREE.Vector3(stringTop.x-1.0*i,stringTop.y-1.0*i,stringTop.z-1.0*i);
        nodeVel[i] = new THREE.Vector3(0.0,0.0,0.0);
        nodeAcc[i] = new THREE.Vector3(0.0,0.0,0.0);

        positions[index] = nodePos[i].x;
        positions[index+1] = nodePos[i].y;
        positions[index+2] = nodePos[i].z;
    }

    geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));

    var drawCount = numNodes;
    geo.setDrawRange(0, drawCount);
    var material = new THREE.LineBasicMaterial({color:0x000000});
    line = new THREE.Line(geo, material);
    scene.add(line);

    dampFricU = new THREE.Vector3(0,0,0);
    forceU = new THREE.Vector3(0,0,0);

    // after this point, animate() is run
    if ( WebGL.isWebGLAvailable() ) {
        // Initiate function or other initializations here
        animate();
    } else {
        const warning = WebGL.getWebGLErrorMessage();
        document.getElementById( 'container' ).appendChild( warning );
    }
}

function update(dt) {
    // other code goes here
    for (let i = 0; i < numNodes; i++) {
        nodeAcc[i].x = 0; nodeAcc[i].y = 0; nodeAcc[i].z = 0;
        nodeAcc[i].add(gravity);
    }

    for (let i = 0; i < numNodes-1; i++) {
        var diff = nodePos[i+1].clone();
        diff.sub(nodePos[i])
        var stringF = -k*(diff.length()-restLen);
        
        diff.normalize();
        var projVbot = nodeVel[i].dot(diff);
        var projVtop = nodeVel[i+1].dot(diff);
        var dampF = -kv*(projVtop - projVbot);

        dampFricU.x = -kfric*(nodeVel[i].x-(i==0?0:nodeVel[i-1].x));
        // dampFricU.y = -kfric*(nodeVel[i].y-(i==0?0:nodeVel[i-1].y));
        dampFricU.y = 0;
        dampFricU.z = -kfric*(nodeVel[i].z-(i==0?0:nodeVel[i-1].z));

        forceU.x = diff.x * (stringF+dampF);
        forceU.y = diff.y * (stringF+dampF);
        forceU.z = diff.z * (stringF+dampF);
        
        // nodeAcc[i].add(dampFricU);
        forceU.multiplyScalar(1.0/mass)
        nodeAcc[i+1].add(forceU);
        forceU.multiplyScalar(-1);
        nodeAcc[i].add(forceU);
        nodeAcc[i].add(dampFricU);
    }

    positions = line.geometry.attributes.position.array;
    for (let i = 1, index = 3; i < numNodes; i++, index+=3) {
        nodeAcc[i].multiplyScalar(dt)
        nodeVel[i].add(nodeAcc[i]);
        var temp = nodeVel[i].clone();
        temp.multiplyScalar(dt)
        nodePos[i].add(temp);

        positions[index] = nodePos[i].x;
        positions[index+1] = nodePos[i].y;
        positions[index+2] = nodePos[i].z;
    }   
}

function animate() {
    stats.begin()
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;
    
    if (!paused) {
        for (let i = 0; i < 1000; i++) {
            update(1/(60*1000));
        }
        
    }
    orbitControls.update(1*dt);

    line.geometry.attributes.position.needsUpdate = true;

    // adds line and renders scene
	renderer.render( scene, camera );
    stats.end()
}

window.addEventListener( 'resize', onWindowResize, false );
window.addEventListener('keyup', onKeyUp, false);

function onWindowResize(){
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );
}

function onKeyUp(event) {
    if (event.code == 'Space') {
        paused = !paused;
    }

    if (event.code == 'KeyR') {
        location.reload();
    }
}

