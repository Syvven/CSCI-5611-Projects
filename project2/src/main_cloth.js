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
var prevTime;

// rope globals
var floorY, radius, stringTop, mass, k, kv, kfric;
var restLen;
var dampFricU, forceU, gravity;
var nodePos, nodeVel, nodeAcc, maxNodes, vertNodes, horizNodes;
var objArr;
var totalDT;

// key handler booleans
var paused = true;

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
    vertNodes = 20; horizNodes = 20;
    gravity = new THREE.Vector3(0.0, -10, 0.0);
    stringTop = new THREE.Vector3(0.0, 50.0, 0.0);
    restLen = 2;
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

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var geo = new THREE.BufferGeometry();

            var positions = new Float32Array(18);
            var colors = new Float32Array(18);
            // tleft vert
            positions[0] = nodePos[i][j].x;
            positions[1] = nodePos[i][j].y;
            positions[2] = nodePos[i][j].z;
            colors[0] = Math.random();
            colors[1] = Math.random();
            colors[2] = Math.random();

            // tRight vert
            positions[3] = nodePos[i][j+1].x;
            positions[4] = nodePos[i][j+1].y;
            positions[5] = nodePos[i][j+1].z;
            colors[3] = Math.random();
            colors[4] = Math.random();
            colors[5] = Math.random();

            positions[6] = nodePos[i+1][j+1].x;
            positions[7] = nodePos[i+1][j+1].y;
            positions[8] = nodePos[i+1][j+1].z;
            colors[6] = Math.random();
            colors[7] = Math.random();
            colors[8] = Math.random();

            // bLeft vert
            positions[9] = nodePos[i+1][j+1].x;
            positions[10] = nodePos[i+1][j+1].y;
            positions[11] = nodePos[i+1][j+1].z;
            colors[9] = Math.random();
            colors[10] = Math.random();
            colors[11] = Math.random();
            
            positions[12] = nodePos[i+1][j].x;
            positions[13] = nodePos[i+1][j].y;
            positions[14] = nodePos[i+1][j].z;
            colors[12] = Math.random();
            colors[13] = Math.random();
            colors[14] = Math.random();

            // bRight vert
            positions[15] = nodePos[i][j].x;
            positions[16] = nodePos[i][j].y;
            positions[17] = nodePos[i][j].z;
            colors[15] = Math.random();
            colors[16] = Math.random();
            colors[17] = Math.random();

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

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            if (!(i == 0 && j == 0) && !(i == 0 && j == horizNodes-1) /*&&
                !(i == vertNodes-1 && j == 0) && !(i == vertNodes-1 && j == horizNodes-1)*/) {
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
            var pos = objArr[i][j].geometry.attributes.position.array;
            var colors = objArr[i][j].geometry.attributes.color.array;
            pos[0] = nodePos[i][j].x;
            pos[1] = nodePos[i][j].y;
            pos[2] = nodePos[i][j].z;
            colors[0] = Math.random();
            colors[1] = Math.random();
            colors[2] = Math.random();

            // tRight vert
            pos[3] = nodePos[i][j+1].x;
            pos[4] = nodePos[i][j+1].y;
            pos[5] = nodePos[i][j+1].z;
            colors[3] = Math.random();
            colors[4] = Math.random();
            colors[5] = Math.random();

            pos[6] = nodePos[i+1][j+1].x;
            pos[7] = nodePos[i+1][j+1].y;
            pos[8] = nodePos[i+1][j+1].z;
            colors[6] = Math.random();
            colors[7] = Math.random();
            colors[8] = Math.random();

            // bLeft vert
            pos[9] = nodePos[i+1][j+1].x;
            pos[10] = nodePos[i+1][j+1].y;
            pos[11] = nodePos[i+1][j+1].z;
            colors[9] = Math.random();
            colors[10] = Math.random();
            colors[11] = Math.random();
            
            pos[12] = nodePos[i+1][j].x;
            pos[13] = nodePos[i+1][j].y;
            pos[14] = nodePos[i+1][j].z;
            colors[12] = Math.random();
            colors[13] = Math.random();
            colors[14] = Math.random();

            // bRight vert
            pos[15] = nodePos[i][j].x;
            pos[16] = nodePos[i][j].y;
            pos[17] = nodePos[i][j].z;
            colors[15] = Math.random();
            colors[16] = Math.random();
            colors[17] = Math.random();
        }
    }
}

function animate() {
    stats.begin()
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;
    
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

window.addEventListener( 'resize', onWindowResize, false );
window.addEventListener('keyup', onKeyUp, false);

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

