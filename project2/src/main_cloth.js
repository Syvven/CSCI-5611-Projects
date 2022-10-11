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
    mass = 10; k = 1000; kv = 200; kfric = 2;
    vertNodes = 5; horizNodes = 5;
    gravity = new THREE.Vector3(0.0, -4000, 0.0);
    stringTop = new THREE.Vector3(0.0, 100.0, 0.0);
    restLen = 5;
    objArr = [];

    nodePos = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeAcc = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    objArr = Array(vertNodes-1).fill(null).map(() => Array(horizNodes-1));

    // build the verts of the cloth

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodePos[i][j] = new THREE.Vector3(
                5*j,
                stringTop.y-5*i,
                -2*i
            );
            nodeVel[i][j] = new THREE.Vector3(0.0,0.0,0.0);
            nodeAcc[i][j] = new THREE.Vector3(0.0,0.0,0.0);
        }
    }

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var geo = new THREE.BufferGeometry();
            var positions = new Float32Array(15);
            // tleft vert
            positions[0] = nodePos[i][j].x;
            positions[1] = nodePos[i][j].y;
            positions[2] = nodePos[i][j].z;
            // tRight vert
            positions[3] = nodePos[i][j+1].x;
            positions[4] = nodePos[i][j+1].y;
            positions[5] = nodePos[i][j+1].z;

            positions[6] = nodePos[i+1][j+1].x;
            positions[7] = nodePos[i+1][j+1].y;
            positions[8] = nodePos[i+1][j+1].z;
            // bLeft vert
            positions[9] = nodePos[i+1][j].x;
            positions[10] = nodePos[i+1][j].y;
            positions[11] = nodePos[i+1][j].z;
            // bRight vert
            positions[12] = nodePos[i][j].x;
            positions[13] = nodePos[i][j].y;
            positions[14] = nodePos[i][j].z;

            geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geo.setDrawRange(0,5);
            var material = new THREE.LineBasicMaterial({color:0xff0000});
            objArr[i][j] = new THREE.Line(geo, material);
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
            // newVel[i][j] = nodeVel[i][j].clone();
        }
    }

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes; j++) {
            var diff = nodePos[i+1][j].clone();
            diff.sub(nodePos[i][j])
            var stringF = -k*(restLen-diff.length());
            
            diff.normalize();
            var projVbot = diff.dot(nodeVel[i][j]);
            var projVtop = diff.dot(nodeVel[i+1][j]);
            var dampF = -kv*(projVtop - projVbot);

            // dampFricU.x = -kfric*(nodeVel[i][j].x-(i==0?0:nodeVel[i-1][j].x));
            // // dampFricU.y = -kfric*(nodeVel[i].y-(i==0?0:nodeVel[i-1].y));
            // dampFricU.y = 0;
            // dampFricU.z = -kfric*(nodeVel[i][j].z-(i==0?0:nodeVel[i-1][j].z));

            diff.multiplyScalar((stringF+dampF)*(1/mass));
            // dampFricU.multiplyScalar(dt);

            nodeAcc[i][j].add(diff);
            // newVel[i][j].add(dampFricU);
            nodeAcc[i+1][j].sub(diff);
        }
    }  

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var diff = nodePos[i][j+1].clone();
            diff.sub(nodePos[i][j])
            var stringF = -k*(restLen-diff.length());
            
            diff.normalize();
            var projVbot = diff.dot(nodeVel[i][j]);
            var projVtop = diff.dot(nodeVel[i][j+1]);
            var dampF = -kv*(projVtop - projVbot);

            // dampFricU.x = -kfric*(nodeVel[i][j].x-(j==0?0:nodeVel[i][j-1].x));
            // // dampFricU.y = -kfric*(nodeVel[i].y-(i==0?0:nodeVel[i-1].y));
            // dampFricU.y = 0;
            // dampFricU.z = -kfric*(nodeVel[i][j].z-(j==0?0:nodeVel[i][j-1].z));

            diff.multiplyScalar((stringF+dampF)*(1/mass));
            // dampFricU.multiplyScalar(dt);

            nodeAcc[i][j].add(diff);
            // newVel[i][j].add(dampFricU);
            nodeAcc[i][j+1].sub(diff);
        }
    }

    // for (let i = 0; i < vertNodes; i++) {
    //     for (let j = 0; j < horizNodes; j++) {
    //         if (i == 0) {
    //             newVel[i][j].x = 0; newVel[i][j].y = 0; newVel[i][j].z = 0;
    //             nodeVel[i][j] = newVel[i][j].clone();
    //             continue;
    //         }
    //         newVel[i][j].add(gravitydt);
    //         nodeVel[i][j] = newVel[i][j].clone();
    //     }
    // } 

    var temp;
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            if (i != 0) {
                // part 1 of runge kutta
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

                nodePos[i][j].add(v1);
            }
        }
    }

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var pos = objArr[i][j].geometry.attributes.position.array;
            pos[0] = nodePos[i][j].x;
            pos[1] = nodePos[i][j].y;
            pos[2] = nodePos[i][j].z;
            //  vert
            pos[3] = nodePos[i][j+1].x;
            pos[4] = nodePos[i][j+1].y;
            pos[5] = nodePos[i][j+1].z;
            // vert

            pos[6] = nodePos[i+1][j+1].x;
            pos[7] = nodePos[i+1][j+1].y;
            pos[8] = nodePos[i+1][j+1].z;

            pos[9] = nodePos[i+1][j].x;
            pos[10] = nodePos[i+1][j].y;
            pos[11] = nodePos[i+1][j].z;
            //  vert
            pos[12] = nodePos[i][j].x;
            pos[13] = nodePos[i][j].y;
            pos[14] = nodePos[i][j].z;
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
        for (let i = 0; i < 3000; i++) {
            update(dt/3000);
        }
        
    }
    orbitControls.update(1*dt);

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            objArr[i][j].geometry.attributes.position.needsUpdate = true;
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

function onKeyUp(event) {
    if (event.code == 'Space') {
        paused = !paused;
    }

    if (event.code == 'KeyR') {
        location.reload();
    }
}

