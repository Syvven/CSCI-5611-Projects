import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import {GLTFLoader} from './GLTFLoader.js';
import {FlyControls} from './FlyControls.js';
import {OrbitControls} from './OrbitControls.js';
import {DragControls} from './DragControls.js';
import WebGL from './webGLCheck.js';
import { QuadraticBezierCurve } from '../node_modules/three/src/Three.js';

// scene globals
var scene, renderer, loader;
var flyControls, orbitControls, camera;
var raycaster, dragControls;
var kiwi, mixer;
var kiwiBod, kiwiHead, kiwiGroup;
var bodRad = 30;
var headRad = 30;
var modelReady = false;

// other render globals
var prevTime;

// rope globals
var floorY, radius, stringTop, mass, k, kv, kfric;
var restLen;
var dampFricU, gravity;
var nodePos, nodeVel, nodeAcc, vertNodes, horizNodes;
var objArr, controlArr;
var totalDT, stats;

function setup() {
    ///////////////////////// RENDERING INFO ////////////////////////////////////////////////////////
    totalDT = 0;

    stats = new Stats();
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    scene = new THREE.Scene();
    scene.add(new THREE.AxesHelper(1000));

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


    // other setup items go here

    // adds texture for the ground
    var groundTexture = new THREE.TextureLoader().load("../models/floor-min.png");
    groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
    groundTexture.repeat.set(10,10);
    groundTexture.encoding = THREE.sRGBEncoding;
    var groundMaterial = new THREE.MeshStandardMaterial({map:groundTexture, side: THREE.DoubleSide});
    var mesh = new THREE.Mesh(new THREE.PlaneBufferGeometry(400,400, 10, 10),groundMaterial);
    mesh.position.y = -0.1;
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

    raycaster = new THREE.Raycaster();

    // date for dt purposes
    prevTime = new Date();

    //////////////////////// ROPE INFO ///////////////////////////////////////

    floorY = 0.0; radius = 5.0;
    mass = 0.01; k = 10000; kv = 2000; kfric = 40000;
    vertNodes = 15; horizNodes = 15;
    gravity = new THREE.Vector3(0.0, -100, 0.0);
    stringTop = new THREE.Vector3(0.0, 50.0, 0.0);
    restLen = 2;

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
    // controlArr = Array(1);
    // controlArr[0] = scene.children[scene.children.length];

    controlArr = [];
    dragControls = new DragControls(controlArr, camera, renderer.domElement);
    dragControls.addEventListener('dragstart', (e) => {
        orbitControls.enabled = false;
    });
    dragControls.addEventListener('dragend', (e) => {
        orbitControls.enabled = true;
    });

    // kiwi loading, only do after cloth is done
    loader = new GLTFLoader();

    loader.load('../models/kiwi.glb', function(gltf) {
        kiwi = gltf.scene;
        kiwi.scale.set(5,5,5);
        kiwi.position.y = 7.5;
        kiwiGroup = kiwi;
        kiwi.traverse((o) => {
            if (o.isMesh) {
                o.castShadow = true;
                o.receiveShadow = true;
                o.frustumCulled = false;
                o.geometry.computeVertexNormals();
            }
        });

        mixer = new THREE.AnimationMixer(kiwi);
        mixer.clipAction(gltf.animations[0]).play();

        kiwiBod = new THREE.Mesh(
            new THREE.SphereBufferGeometry(
                bodRad,
                32,
                16
            ),
            new THREE.MeshBasicMaterial(
                {
                    transparent: true,
                    opacity: 0.1
                }
            )
        );
        kiwiBod.position.set(10,10,10);
        kiwiHead = new THREE.Mesh(
            new THREE.SphereBufferGeometry(
                headRad,
                32,
                16
            ),
            new THREE.MeshBasicMaterial(
                {
                    transparent: true,
                    opacity: 0.1
                }
            )
        )
        kiwiHead.position.set(
            kiwiBod.position.x+headXOff,
            kiwiBod.position.y+headYOff,
            kiwiBod.position.z+headZOff
        );

        scene.add(kiwi);

        scene.add(kiwiBod);
        scene.add(kiwiHead);
        controlArr.push(kiwiBod);

        modelReady = true;
        // after this point, animate() is run
    }, undefined, function(error) {
        console.error(error);
    });
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
            // figure out way to cap length difference
            
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

    updateCollision(dt);
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

var bodXOff = 0; var bodYOff = -2; var bodZOff = 3;
var headXOff = 0; var headYOff = 6; var headZOff = 5;

function updateCollision(dt) {
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            if (!(i == 0 && j == 0) /*&& !(i == 0 && j == horizNodes-1) &&
                !(i == vertNodes-1 && j == 0) && !(i == vertNodes-1 && j == horizNodes-1)*/) {
                // check for collisions here
                if (nodePos[i][j].y < 0 && Math.abs(nodePos[i][j].x) < 200
                        && Math.abs(nodePos[i][j].z) < 200) {
                    nodePos[i][j].y = 0;
                    nodeVel[i][j].y = 0;
                    var temp = nodeVel[i][j].clone();
                    temp.multiplyScalar(100);
                    temp.multiplyScalar(dt);
                    nodeVel[i][j].add(temp);
                }

                if (kiwiHead.position.distanceTo(nodePos[i][j]) < 3+headRad) {
                    var dir = nodePos[i][j].clone();
                    dir.sub(kiwiHead.position);

                    dir.normalize();

                    var odir = dir.clone();
                    odir.multiplyScalar(3+headRad);
                    odir.add(kiwiHead.position);
                    nodePos[i][j].x = odir.x;
                    nodePos[i][j].y = odir.y;
                    nodePos[i][j].z = odir.z;

                    var dot = nodeVel[i][j].dot(dir);
                    dir.multiplyScalar(dot*(1+0.001));
                    nodeVel[i][j].sub(dir);
                }
            }
        }
    }
}

function animate() {
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            objArr[i][j].geometry.attributes.position.needsUpdate = true;
            objArr[i][j].geometry.attributes.color.needsUpdate = true;
            objArr[i][j].geometry.computeBoundingBox();
            objArr[i][j].geometry.computeBoundingSphere();
        }
    }

    if (modelReady) {
        // kiwiGroup.position.copy(kiwiBod.position);
        kiwiGroup.position.set(
            kiwiBod.position.x+bodXOff, 
            kiwiBod.position.y+bodYOff, 
            kiwiBod.position.z+bodZOff
        );
        kiwiHead.position.set(
            kiwiBod.position.x+headXOff,
            kiwiBod.position.y+headYOff,
            kiwiBod.position.z+headZOff
        );
    }
    // checkKeyPressed();
    totalDT += 1;
    if (!paused) {
        mixer.update(dt);
        for (let i = 0; i < 300; i++) {
            update(1/300);
        }
        updatePosAndColor();
    }
    orbitControls.update(1*dt);

    // adds line and renders scene
	renderer.render( scene, camera );
    stats.update();
}

// key handler booleans
var paused = true;
window.addEventListener( 'resize', onWindowResize, false );
window.addEventListener('keyup', onKeyUp, false);
window.addEventListener('touchstart', (e) => {
    e.preventDefault();
    orbitControls.enabled = false;
})
window.addEventListener('touchmove', (e) => {
    e.preventDefault();
    orbitControls.enabled = true;
});
window.addEventListener('touchend', (e) => {
    e.preventDefault();
    if (!orbitControls.enabled) {
        paused = !paused;
        orbitControls.endabled = true;
    }
});

function onWindowResize(){
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.render(scene, camera);
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
    updatePosAndColor();
}

function onKeyUp(event) {
    if (event.code == 'Space') {
        paused = !paused;
    }

    if (event.code == 'KeyR') {
        reset();
    }
}

setup();
if ( WebGL.isWebGLAvailable() ) {
    // Initiate function or other initializations here
    animate();
} else {
    const warning = WebGL.getWebGLErrorMessage();
    document.getElementById( 'container' ).appendChild( warning );
}

