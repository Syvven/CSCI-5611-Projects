import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import {GLTFLoader} from './GLTFLoader.js';
import {FlyControls} from './FlyControls.js';
import {OrbitControls} from './OrbitControls.js';
import {DragControls} from './DragControls.js';
import WebGL from './webGLCheck.js';

// scene globals
var scene, renderer, loader;
var flyControls, orbitControls, camera;

// other render globals
var prevTime;

// rope globals
var floorY, radius, stringTop, mass, k, kv, kfric;
var restLen;
var dampFricU, gravity;
var nodePos, nodeVel, nodeAcc, vertNodes, horizNodes;
var objArr;
var totalDT;

var stats;

setup();

function setup() {
    ///////////////////////// RENDERING INFO ////////////////////////////////////////////////////////
    totalDT = 0;

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
    camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 0.1, 5000 );
    camera.position.set( 0, 50, 200 );
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
    groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
    groundTexture.repeat.set(10,10);
    groundTexture.encoding = THREE.sRGBEncoding;
    var groundMaterial = new THREE.MeshStandardMaterial({map:groundTexture, side: THREE.DoubleSide});
    var mesh = new THREE.Mesh(new THREE.PlaneBufferGeometry(400,400, 10, 10),groundMaterial);
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

    // const light = new THREE.PointLight(0xffffff);
    // light.position.set(0, 50, 50);
    // scene.add(light);

    // date for dt purposes
    prevTime = new Date();

    //////////////////////// ROPE INFO ///////////////////////////////////////

    floorY = 0.0; radius = 5.0;
    mass = 0.1; k = 10000; kv = 1000; kfric = 4000;
    vertNodes = 15; horizNodes = 15;
    gravity = new THREE.Vector3(0.0, -10, 0.0);
    stringTop = new THREE.Vector3(0.0, 50.0, 0.0);
    restLen = 3;
    objArr = [];

    nodePos = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeAcc = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    objArr = Array(vertNodes-1).fill(null).map(() => Array(horizNodes-1));

    // build the verts of the cloth

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodePos[i][j] = new THREE.Vector3(
                j*restLen,
                stringTop.y,
                restLen*i
            );
            nodeVel[i][j] = new THREE.Vector3(0.0,0.0,0.0);
            nodeAcc[i][j] = new THREE.Vector3(0.0,0.0,0.0);
        }
    }
    const controlArr = Array(horizNodes*vertNodes);

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var geo = new THREE.BufferGeometry();
            var positions = new Float32Array(18);
            var colors = new Float32Array(18);

            var pos = nodePos[i][j];
            // tleft vert
            positions[0] = pos.x;
            positions[1] = pos.y;
            positions[2] = pos.z;
            colors[0] = ((pos.y*10)%256)/256;
            colors[1] = ((pos.y*20)%256)/256;
            colors[2] = ((pos.y*30)%256)/256;

             // bRight vert
            positions[15] = pos.x;
            positions[16] = pos.y;
            positions[17] = pos.z;
            colors[15] = ((pos.y*10)%256)/256;
            colors[16] = ((pos.y*20)%256)/256;
            colors[17] = ((pos.y*30)%256)/256;

            pos = nodePos[i][j+1];
            // tRight vert
            positions[3] = pos.x;
            positions[4] = pos.y;
            positions[5] = pos.z;
            colors[3] = ((pos.y*10)%256)/256;
            colors[4] = ((pos.y*20)%256)/256;
            colors[5] = ((pos.y*30)%256)/256;

            pos = nodePos[i+1][j+1];
            positions[6] = pos.x;
            positions[7] = pos.y;
            positions[8] = pos.z;
            colors[6] = ((pos.y*10)%256)/256;
            colors[7] = ((pos.y*20)%256)/256;
            colors[8] = ((pos.y*30)%256)/256;

            // bLeft vert
            positions[9] = pos.x;
            positions[10] = pos.y;
            positions[11] = pos.z;
            colors[9] = ((pos.y*10)%256)/256;
            colors[10] = ((pos.y*20)%256)/256;
            colors[11] = ((pos.y*30)%256)/256;
            
            pos = nodePos[i+1][j];
            positions[12] = pos.x;
            positions[13] = pos.y;
            positions[14] = pos.z;
            colors[12] = ((pos.y*10)%256)/256;
            colors[13] = ((pos.y*20)%256)/256;
            colors[14] = ((pos.y*30)%256)/256;

            geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geo.setAttribute('color', new THREE.BufferAttribute(colors, 3));
            geo.setDrawRange(0,6);

            geo.computeBoundingBox();

            var material = new THREE.MeshPhongMaterial({
                vertexColors: true,
                flatShading: true
            });

            material.side = THREE.DoubleSide;


            objArr[i][j] = new THREE.Mesh(geo, material);
            objArr[i][j].material.transparent = false;
            scene.add(objArr[i][j]);
        }
    }

    dampFricU = new THREE.Vector3(0,0,0);

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
    // var newVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodeAcc[i][j].x = 0; nodeAcc[i].y = 0; nodeAcc[i].z = 0;
            nodeAcc[i][j].add(gravity);
        }
    }

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes; j++) {
            
            var diff = nodePos[i][j].clone();
            diff.sub(nodePos[i+1][j])
            var stringF = -k*(restLen-diff.length());
            
            diff.normalize();
            var projVbot = diff.dot(nodeVel[i][j]);
            var projVtop = diff.dot(nodeVel[i+1][j]);
            var dampF = -kv*(projVtop - projVbot);
            
            dampFricU.x = -kfric*((i===0?0:nodeVel[i-1][j].x)-nodeVel[i][j].x);
            dampFricU.y = 0;
            dampFricU.z = -kfric*((i===0?0:nodeVel[i-1][j].z)-nodeVel[i][j].z);
            
            diff.multiplyScalar((stringF+dampF)*(1/mass));

            nodeAcc[i][j].sub(diff);
            nodeAcc[i][j].sub(dampFricU);
            nodeAcc[i+1][j].add(diff);
        }
    }  

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var diff = nodePos[i][j].clone();
            diff.sub(nodePos[i][j+1])
            var stringF = -k*(restLen-diff.length());
            
            diff.normalize();
            var projVbot = diff.dot(nodeVel[i][j]);
            var projVtop = diff.dot(nodeVel[i][j+1]);
            var dampF = -kv*(projVtop - projVbot);

            diff.multiplyScalar((stringF+dampF)*(1/mass));

            nodeAcc[i][j].sub(diff);
            nodeAcc[i][j+1].add(diff);
        }
    }

    var halfv = vertNodes/2;
    var halfh = horizNodes/2;
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            if (!(i == 0 && j == 0) && !(i == 0 && j == horizNodes-1) &&
                !(i == vertNodes-1 && j == 0) && !(i == vertNodes-1 && j == horizNodes-1)) {
                // RK4 (Runge-Kutta) Integration
                var v1 = nodeVel[i][j].clone();
                v1.multiplyScalar(dt);

                var v2 = nodeVel[i][j].clone();
                var atemp = nodeAcc[i][j].clone();
                atemp.multiplyScalar(0.5*dt)
                v2.add(atemp);
                v2.multiplyScalar(dt);

                var v3 = nodeVel[i][j].clone();
                v3.add(atemp);
                v3.multiplyScalar(dt);

                var v4 = nodeVel[i][j].clone();
                atemp = nodeAcc[i][j].clone().multiplyScalar(dt);
                v2.add(atemp);
                v2.multiplyScalar(dt);
                
                v2.multiplyScalar(2);
                v3.multiplyScalar(2);

                v1.add(v2); v1.add(v3); v1.add(v4);
                v1.multiplyScalar(dt/6);
                
                nodeVel[i][j] = v1.clone();
                nodePos[i][j].add(nodeVel[i][j]);

                // // eulerian integration
                // nodeAcc[i][j].multiplyScalar(dt)
                // nodeVel[i][j].add(nodeAcc[i][j]);
                // var temp = nodeVel[i][j].clone();
                // temp.multiplyScalar(dt)
                // nodePos[i][j].add(temp);
            }
        }
    }
}

function updatePosAndColor() {
    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var positions = objArr[i][j].geometry.attributes.position.array;
            var colors = objArr[i][j].geometry.attributes.color.array;

            var pos = nodePos[i][j];
            var a = ((pos.y*10)%256)/256;
            var b = ((pos.y*20)%256)/256;
            var c = ((pos.z*30)%256)/256;
            // tleft vert
            positions[0] = pos.x;
            positions[1] = pos.y;
            positions[2] = pos.z;
            colors[0] = a;
            colors[1] = b;
            colors[2] = c;

             // bRight vert
            positions[15] = pos.x;
            positions[16] = pos.y;
            positions[17] = pos.z;
            colors[15] = a;
            colors[16] = b;
            colors[17] = c;

            pos = nodePos[i][j+1];
            // tRight vert
            positions[3] = pos.x;
            positions[4] = pos.y;
            positions[5] = pos.z;
            colors[3] = ((pos.y*10)%256)/256;
            colors[4] = ((pos.y*20)%256)/256;
            colors[5] = ((pos.z*30)%256)/256;

            pos = nodePos[i+1][j+1];
            a = ((pos.y*10)%256)/256;
            b = ((pos.y*20)%256)/256;
            c = ((pos.z*30)%256)/256;
            positions[6] = pos.x;
            positions[7] = pos.y;
            positions[8] = pos.z;
            colors[6] = a;
            colors[7] = b;
            colors[8] = c;

            // bLeft vert
            positions[9] = pos.x;
            positions[10] = pos.y;
            positions[11] = pos.z;
            colors[9] = a;
            colors[10] = b;
            colors[11] = c;
            
            pos = nodePos[i+1][j];
            positions[12] = pos.x;
            positions[13] = pos.y;
            positions[14] = pos.z;
            colors[12] = ((pos.y*10)%256)/256;
            colors[13] = ((pos.y*20)%256)/256;
            colors[14] = ((pos.z*30)%256)/256;
        }
    }
}

function checkKeyPressed() {
    if (mouseDown && mouseMove) {

    } else if (!mouseDown && mouseMove) {
        mouseMove = false;
    }
}

function animate() {
    stats.begin()
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    checkKeyPressed();
    
    if (!paused) {
        for (let i = 0; i < 100; i++) {
            totalDT += 1;
            update(1/100);
        }
        updatePosAndColor();
    }
    orbitControls.update(1*dt);

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            objArr[i][j].geometry.attributes.position.needsUpdate = true;
            objArr[i][j].geometry.attributes.color.needsUpdate = true;
            objArr[i][j].geometry.computeBoundingBox();
            objArr[i][j].geometry.computeBoundingSphere();
        }
    }

    // adds line and renders scene
	renderer.render( scene, camera );
    stats.end()
}

// key handler booleans
var paused = true;
var mouseDown = false;
var mouseMove = false;
window.addEventListener( 'resize', onWindowResize, false );
window.addEventListener('keyup', onKeyUp, false);
window.addEventListener('mousedown', (e) => {
    mouseDown = true;
});
window.addEventListener('mousemove', (e) =>{
    mouseMove = true;
});
window.addEventListener('mousesup', (e) => {
    mouseDown = true;
});

function onWindowResize(){
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );
}

function reset() {
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodePos[i][j] = new THREE.Vector3(
                j*restLen,
                stringTop.y,
                restLen*i
            );
            nodeVel[i][j] = new THREE.Vector3(0.0,0.0,0.0);
            nodeAcc[i][j] = new THREE.Vector3(0.0,0.0,0.0);
        }
    }
}

function onKeyUp(event) {
    if (event.code == 'Space') {
        paused = !paused;
    }

    if (event.code == 'KeyR') {
        reset();
    }
}

