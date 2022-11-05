import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {GLTFLoader} from './GLTFLoader.js';
import {OrbitControls} from './OrbitControls.js';
import {DragControls} from './DragControls.js';
import WebGL from './webGLCheck.js';
import { OBJLoader } from './OBJLoader.js';
import { MTLLoader } from './MTLLoader.js';

// https://www.cgtrader.com/items/2766614/download-page 

// scene globals
var scene, renderer, loader, objLoader, mtlLoader;
var orbitControls, camera;
var raycaster, dragControls;
var kiwi, mixer;
var kiwiBod, kiwiHead, kiwiGroup;
var bodRad = 7; var headRad = 5;

// other render globals
var prevTime;

// force globals
var dampFricU, gravity, wind;
var mass, k, kv, kfric;
var airD, dragC;

// rope globals
var floorY, radius, stringTop
var restLen;
var nodePos, nodeVel, nodeAcc, vertNodes, horizNodes;
var currAcc, futureVel, futurePos;
var objArr, controlArr;
var cloth;
var bathHB, bath;

// stats and gui
var totalDT, stats;
var gui;
var dragObj, clothObj, simControlObj;
var dragF = false;
var moveTopLeft = true;
var moveTopRight = true;
var moveBotLeft = false;
var moveBotRight = false;
var topLeftNode, ogTopLeftNodePos;
var topRightNode, ogTopRightNodePos;
var botLeftNode, ogBotLeftNodePos;
var botRightNode, ogBotRightNodePos;
var numTimesteps = 200;
var ndt = 200;

function setup() {
    ///////////////////////// RENDERING INFO ////////////////////////////////////////////////////////

    scene = new THREE.Scene();
    scene.add(new THREE.AxesHelper(1000));

    // creates renderer and sets its size
    renderer = new THREE.WebGLRenderer({depth:true});
    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.setClearColor(0x555555);
    document.body.appendChild( renderer.domElement );

    // creates new camera / sets position / sets looking angle
    camera = new THREE.OrthographicCamera( window.innerWidth / - 2, window.innerWidth / 2, window.innerHeight / 2, window.innerHeight / - 2, 1, 1000 );
    camera.position.set( 0, 50, 200 );
    camera.lookAt( 0, 0, 0 );

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

    // hemisphere light for equal lighting
    var hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444 );
    hemiLight.position.set( 0, 300, 0 );
    scene.add( hemiLight );

    const light = new THREE.PointLight(0xffffff);
    light.position.set(0, 50, 50);
    scene.add(light);

    raycaster = new THREE.Raycaster();

    // date for dt purposes
    prevTime = new Date();

    //////////////////////// ROPE INFO ///////////////////////////////////////

    floorY = 0.0; radius = 5.0;
    mass = 1; k = 100; kv = 50; kfric = 1;
    dragC = 9; airD = 0.8;
    vertNodes = 20; horizNodes = 12;
    gravity = new THREE.Vector3(0.0, -0.2, 0.0);
    wind = new THREE.Vector3(0.0, 0.0, 0.4);
    stringTop = new THREE.Vector3(0.0, 50.0, 0.0);
    restLen = 2;

    currAcc = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    futureVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    futurePos = Array(vertNodes).fill(null).map(() => Array(horizNodes));

    nodePos = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeAcc = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    objArr = Array(vertNodes-1).fill(null).map(() => Array(horizNodes-1));

    // build the verts of the cloth

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodePos[i][j] = new THREE.Vector3(
                i*restLen,
                stringTop.y,
                restLen*j
            );
            nodeVel[i][j] = new THREE.Vector3(0.0,0.0,0.0);
            nodeAcc[i][j] = new THREE.Vector3(0.0,0.0,0.0);
        }
    }

    var geo = new THREE.PlaneGeometry(restLen * horizNodes, restLen * vertNodes, horizNodes-1, vertNodes-1);
    geo.setAttribute('color', new THREE.BufferAttribute(
        new Float32Array(horizNodes*vertNodes*3),
        3
    ));
    
    const positionAttribute = geo.getAttribute( 'position' );
    const colorAttribute = geo.getAttribute( 'color' );
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            positionAttribute.setXYZ( i*horizNodes+j, nodePos[i][j].x, nodePos[i][j].y, nodePos[i][j].z );
            colorAttribute.setXYZ(
                i*horizNodes+j, 
                (nodePos[i][j].x*10%256)/256,
                (nodePos[i][j].y*20%256)/256,
                (nodePos[i][j].z*30%256)/256
            );
        }
    }
    // geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    var material = new THREE.MeshPhysicalMaterial({
        side: THREE.DoubleSide,
        vertexColors: true
    });
    
    cloth = new THREE.Mesh(geo, material);
    scene.add(cloth);

    dampFricU = new THREE.Vector3(0,0,0);

    controlArr = [];
    dragControls = new DragControls(controlArr, camera, renderer.domElement);
    dragControls.addEventListener('dragstart', (e) => {
        orbitControls.enabled = false;
    });
    dragControls.addEventListener('dragend', (e) => {
        orbitControls.enabled = true;
    });

    ogTopLeftNodePos = nodePos[0][0].clone();
    topLeftNode = new THREE.Mesh(
        new THREE.SphereBufferGeometry(
            2,
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
    topLeftNode.position.set(nodePos[0][0].x, nodePos[0][0].y, nodePos[0][0].z);
    scene.add(topLeftNode);
    controlArr.push(topLeftNode);

    ogTopRightNodePos = nodePos[0][nodePos[0].length-1].clone();
    topRightNode = new THREE.Mesh(
        new THREE.SphereBufferGeometry(
            2,
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
    topRightNode.position.set(
        ogTopRightNodePos.x,
        ogTopRightNodePos.y,
        ogTopRightNodePos.z
    );
    scene.add(topRightNode);
    controlArr.push(topRightNode);

    ogBotLeftNodePos = new THREE.Vector3(10000, 10000, 10000);
    botLeftNode = new THREE.Mesh(
        new THREE.SphereBufferGeometry(
            2,
            32,
            16
        ),
        new THREE.MeshBasicMaterial(
            {
                transparent: true,
                opacity: 0
            }
        )
    );
    botLeftNode.position.copy(ogBotLeftNodePos);
    scene.add(botLeftNode);
    controlArr.push(botLeftNode);

    ogBotRightNodePos = new THREE.Vector3(10000, 10000, 10000);
    botRightNode = new THREE.Mesh(
        new THREE.SphereBufferGeometry(
            2,
            32,
            16
        ),
        new THREE.MeshBasicMaterial(
            {
                transparent: true,
                opacity: 0
            }
        )
    );
    botRightNode.position.copy(ogBotRightNodePos);
    scene.add(botRightNode);
    controlArr.push(botRightNode);

    // kiwi loading, only do after cloth is done
    loader = new GLTFLoader();
    objLoader = new OBJLoader();
    mtlLoader = new MTLLoader();

    ///////////////////////// STATS AND GUI /////////////////////////////////////////////////////////
    totalDT = 0;

    stats = new Stats();
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    gui = new GUI();
    // base is 246
    gui.width = 300;

    const windFolder = gui.addFolder('Wind Controls');
    windFolder.add(wind, 'x', -10, 10, 0.01).name('Wind X');
    windFolder.add(wind, 'y', 0, 10, 0.01).name('Wind Y');
    windFolder.add(wind, 'z', -10, 10, 0.01).name('Wind Z');

    dragObj = {
        dragC: dragC,
        airD: airD,
        dragF: false
    }
    const dragFolder = gui.addFolder('Drag Controls');
    dragFolder.add(dragObj, 'dragC', 0, 15, 0.1).name('Drag Coefficient');
    dragFolder.add(dragObj, 'airD', 0, 6, 0.1).name('Air Density');

    const gravityFolder = gui.addFolder('Gravity Controls');
    gravityFolder.add(gravity, 'y', -2, 0, 0.01).name('Gravity');

    clothObj = {
        k: k,
        kv: kv,
        mass: mass,
        restLen: restLen,
        topLeft: true,
        topRight: true,
        botLeft: false,
        botRight: false,
        top: false,
        left: false,
        right: false,
        bot: false,
        horizNodes: 12,
        vertNodes: 20
    }
    const clothFolder = gui.addFolder("Cloth Controls");
    clothFolder.add(clothObj, 'vertNodes').name('Vertical Nodes').onChange(() => {
        vertNodes = clothObj.vertNodes;
        reset();
    });
    clothFolder.add(clothObj, 'horizNodes').name('Horizontal Nodes').onChange(() => {
        horizNodes = clothObj.horizNodes;
        reset();
    });
    clothFolder.add(clothObj, 'k', 0, 5000, 5).name('Spring Coefficient').onChange(() => {
        k = clothObj.k;
    });
    clothFolder.add(clothObj, 'kv', 0, 1000, 1).name('Damping Factor').onChange(() => {
        kv = clothObj.kv;
    });
    clothFolder.add(clothObj, 'mass', 0, 10, 0.1).name('Vertex Mass').onChange(() => {
        mass = clothObj.mass;
    });
    clothFolder.add(clothObj, 'restLen', 0, 10, 0.1).name('Rest Length').onChange(() => {
        restLen = clothObj.restLen;
    });
    clothFolder.add(clothObj, 'topLeft').name("Pin Top Left").onChange(() => {
        if (clothObj.topLeft) {
            moveTopLeft = true;
            topLeftNode.material.opacity = 0.1;
            topLeftNode.position.copy(nodePos[0][0]);
        } else {
            moveTopLeft = false;
            topLeftNode.material.opacity = 0.0;
            botRightNode.position.copy(ogBotLeftNodePos);

        }
    });
    clothFolder.add(clothObj, 'topRight').name("Pin Top Right").onChange(() => {
        if (clothObj.topRight) {
            moveTopRight = true;
            topRightNode.material.opacity = 0.1;
            topRightNode.position.copy(nodePos[0][horizNodes-1]);
        } else {
            moveTopRight = false;
            topRightNode.material.opacity = 0.0;
            botRightNode.position.copy(ogBotLeftNodePos);
        }
    });
    clothFolder.add(clothObj, 'botLeft').name("Pin Bottom Left").onChange(() => {
        if (clothObj.botLeft) {
            moveBotLeft = true;
            botLeftNode.material.opacity = 0.1;
            botLeftNode.position.copy(nodePos[vertNodes-1][0]);
        } else {
            moveBotLeft = false;
            botLeftNode.material.opacity = 0.0;
            botRightNode.position.copy(ogBotLeftNodePos);
        }
    });
    clothFolder.add(clothObj, 'botRight').name("Pin Bottom Right").onChange(() => {
        if (clothObj.botRight) {
            moveBotRight = true;
            botRightNode.material.opacity = 0.1;
            botRightNode.position.copy(nodePos[vertNodes-1][horizNodes-1]);
        } else {
            moveBotRight = false;
            botRightNode.material.opacity = 0.0;
            botRightNode.position.copy(ogBotLeftNodePos);
        }
    });


    clothFolder.add(clothObj, 'top').name("Pin Top Row");
    clothFolder.add(clothObj, 'bot').name("Pin Bottom Row");
    clothFolder.add(clothObj, 'left').name("Pin Left Column");
    clothFolder.add(clothObj, 'right').name("Pin Right Column");

    const colorFolder = gui.addFolder("Cloth Colors");
    colorFolder.add(cloth.material, 'vertexColors');
    colorFolder
        .addColor(cloth.material, 'attenuationColor')
        .name("Attenuation Color")
        .onChange((value) => cloth.material.attenutationColor = value);
    colorFolder.add(cloth.material, 'attenuationDistance').name('Attenuation Distance');
    colorFolder.add(cloth.material, 'clearcoat', 0.0, 1.0, 0.01).name("Clear Coat");
    colorFolder.add(cloth.material, 'clearcoatRoughness', 0.0, 1.0, 0.01).name("Clear Coat Roughness");
    colorFolder.add(cloth.material, 'ior', 1.0, 2.333, 0.001).name("Index of Refraction");
    colorFolder.add(cloth.material, 'reflectivity', 0.0, 1.0, 0.01).name("Reflectivity");
    colorFolder.add(cloth.material, 'sheen', 0.0, 1.0, 0.01).name("Sheen");
    colorFolder.add(cloth.material, 'sheenRoughness', 0.0, 1.0, 0.01).name("Sheen Roughness");
    colorFolder
        .addColor(cloth.material, 'sheenColor')
        .name("Sheen Color")
        .onChange((value) => cloth.material.sheenColor = value);
    colorFolder.add(cloth.material, 'specularIntensity', 0.0, 1.0, 0.01).name("Specular Intensity");
    colorFolder
        .addColor(cloth.material, 'specularColor')
        .name("Specular Color")
        .onChange((value) => cloth.material.specularColor = value);
    colorFolder.add(cloth.material, 'thickness', 0.0, 1000, 0.1).name("Thickness");
    colorFolder.add(cloth.material, 'transmission', 0.0, 1.0, 0.01).name("Transmission");
    colorFolder.add(cloth.material, 'opacity', 0.0, 1.0, 0.01).name("Opacity");

    simControlObj = {
        reset: false,
        pause: true,
        numTimesteps: numTimesteps,
        kiwiAlive: false,
        bathAlive: false,
        ndt: ndt
    }
    const simControlFolder = gui.addFolder('Sim Control');

    simControlFolder.add(simControlObj, 'reset').name("Reset Sim").onChange(() => {
        reset();
    });

    simControlFolder.add(simControlObj, 'pause').name("Pause Sim").onChange(() => {
        paused = !paused;
    });

    simControlFolder.add(dragObj, 'dragF').name("Enable Drag").onChange(() => {
        dragObj.dragF = !dragF;
    });

    simControlFolder.add(simControlObj, 'numTimesteps', 1, 1000).name('Timesteps')
        .onChange(() => {
            numTimesteps = simControlObj.numTimesteps;
        });
        simControlFolder.add(simControlObj, 'ndt', 1, 1000).name('dt Control')
        .onChange(() => {
            ndt = simControlObj.ndt;
        });
    simControlFolder.add(simControlObj, 'kiwiAlive').name("Spawn Kiwi").onChange(() => {
        if (simControlObj.kiwiAlive) {
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
                            opacity: 0
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
                            opacity: 0
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
        } else {
            scene.remove(kiwi);
        }
    });
    simControlFolder.add(simControlObj, 'bathAlive').name("Spawn Bath").onChange(() => {
        if (simControlObj.bathAlive) {
            mtlLoader.load("../models/bath.mtl", function(mtl) {
                objLoader.setMaterials(mtl);
                objLoader.load("../models/bath.obj", function(obj) {
                
                    bathHB = new THREE.Mesh(
                        new THREE.BoxGeometry(22,17.5,52),
                        new THREE.MeshBasicMaterial(
                            {
                                transparent: true,
                                opacity: 0
                            }
                        )
                    );
            
                    obj.scale.set(0.03,0.03,0.03);
                    obj.rotation.y = Math.PI/2;
                    obj.position.y = 0.1
            
                    bathHB.position.set(
                        obj.position.x,
                        obj.position.y+8.75,
                        obj.position.z-0.25
                    );
            
                    bath = obj;
            
                    scene.add(bathHB);
                    scene.add(obj);
                    controlArr.push(bathHB);
                });
            });
        } else {
            scene.remove(bath);
        }
    });
}

function calculateMiscForces(pos, vels) {
    // var newVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodeAcc[i][j].x = 0; nodeAcc[i].y = 0; nodeAcc[i].z = 0;
            if (!paused) {
                nodeAcc[i][j].add(gravity);
                if (!dragF) nodeAcc[i][j].add(wind); 

                if (i != vertNodes-1 && j != horizNodes-1 && dragF) {
                    // compute drag per quad
                    // drag = -0.5(dragC * airD * |v|^2 * a * n)

                    // v
                    var v = vels[i][j].clone();
                    v.add(vels[i+1][j]);
                    v.add(vels[i][j+1]);
                    v.add(vels[i+1][j+1]);
                    v.multiplyScalar(1/4);
                    v.sub(wind);

                    var nStar = pos[i+1][j].clone();
                    var b = pos[i][j+1].clone();
                    nStar.sub(pos[i][j]);
                    b.sub(pos[i][j]);
                    
                    nStar.cross(b);

                    var x = (v.length()*v.dot(nStar))/(2*nStar.length());
                    nStar.multiplyScalar(x);
                    
                    nStar.multiplyScalar(dragC*-0.5*airD);
                    nStar.multiplyScalar(1/4);
                    nodeAcc[i][j].add(nStar);
                    nodeAcc[i+1][j].add(nStar);
                    nodeAcc[i][j+1].add(nStar);
                    nodeAcc[i+1][j+1].add(nStar);
                }
            } 
        }
    }
}

function calculateForces(pos, vels) {
    calculateMiscForces(pos, vels);

    for (let i = 0; i < vertNodes-1; i++) {
        for (let j = 0; j < horizNodes; j++) {
            var diff = pos[i][j].clone();
            diff.sub(pos[i+1][j])
            var stringF = -k*(restLen-diff.length());
            // figure out way to cap length difference
            
            diff.normalize();
            var projVbot = diff.dot(vels[i][j]);
            var projVtop = diff.dot(vels[i+1][j]);
            var dampF = -kv*(projVtop - projVbot);
            
            if (!dragF) {
                dampFricU.x = -kfric*((i===0?0:vels[i-1][j].x)-vels[i][j].x);
                dampFricU.y = 0;
                dampFricU.z = -kfric*((i===0?0:vels[i-1][j].z)-vels[i][j].z);
            }
            
            
            diff.multiplyScalar((stringF+dampF)*(1/mass));

            nodeAcc[i][j].sub(diff);
            nodeAcc[i][j].sub(dampFricU);
            nodeAcc[i+1][j].add(diff);
        }
    }  

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes-1; j++) {
            var diff = nodePos[i][j].clone();
            diff.sub(nodePos[i][j+1]);
            var stringF = -k*(restLen-diff.length());
            
            diff.normalize();
            var projVbot = diff.dot(vels[i][j]);
            var projVtop = diff.dot(vels[i][j+1]);
            var dampF = -kv*(projVtop - projVbot);

            diff.multiplyScalar((stringF+dampF)*(1/mass));

            nodeAcc[i][j].sub(diff);
            nodeAcc[i][j+1].add(diff);
        }
    }
}

function checkPinnedPoint(i,j) {
    if (clothObj.topLeft && (i == 0 && j == 0))
        return false;

    if (clothObj.topRight && (i == 0 && j == horizNodes-1))
        return false;

    if (clothObj.botLeft && (i == vertNodes-1 && j == 0))
        return false;

    if (clothObj.botRight && (i == vertNodes-1 && j == horizNodes-1)) 
        return false;

    if (clothObj.left && (j == 0)) return false;
    
    if (clothObj.right && (j == horizNodes-1)) return false; 
    if (clothObj.top && (i == 0)) return false; 
    if (clothObj.bot && (i == vertNodes-1)) return false;
    
    return true;
}

function getRandomArbitrary(min, max) {
    return Math.random() * (max - min) + min;
}

var veltemp;
function update(dt) {
    dragC = dragObj.dragC;
    airD = dragObj.airD;
    dragF = dragObj.dragF;
    // start with current Velocity
    // calculate forces
    // currentAcceleration = function(current_velocity)
    calculateForces(nodePos, nodeVel);
    // loop through all nodes, 
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            // Heun?
            // futureVel[i][j] = nodeVel[i][j] + nodeAcc[i][j]*dt
            futureVel[i][j] = nodeVel[i][j].clone();
            currAcc[i][j] = nodeAcc[i][j].clone();
            nodeAcc[i][j].multiplyScalar(dt);
            futureVel[i][j].add(nodeAcc[i][j]);

            // futurePos[i][j] = nodePos[i][j] + futureVel[i][j]*dt
            futurePos[i][j] = nodePos[i][j].clone();
            veltemp = futureVel[i][j].clone();
            veltemp.multiplyScalar(dt);
            futurePos[i][j].add(veltemp);
        }
    }
    // calculate forces using new future velocity
    calculateForces(futurePos, futureVel);
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            if (checkPinnedPoint(i,j)) {
                nodeAcc[i][j].add(currAcc[i][j]);
                nodeAcc[i][j].multiplyScalar(0.5*dt);
                nodeVel[i][j].add(nodeAcc[i][j]);
                veltemp = nodeVel[i][j].clone();
                veltemp.multiplyScalar(dt);
                nodePos[i][j].add(veltemp);

                if (nodePos[i][j].y < 0 && Math.abs(nodePos[i][j].x) < 200
                        && Math.abs(nodePos[i][j].z) < 200) {
                    nodePos[i][j].y = 0;
                    var fric = nodeVel[i][j].clone();
                    fric.multiplyScalar(-0.01);
                    nodeVel[i][j].add(fric);
                }

                if (simControlObj.bathAlive) {
                    var bbox = new THREE.Box3().setFromObject(bathHB);
                    if (bbox.containsPoint(nodePos[i][j])) {
                        var distToTop = bbox.max.y - nodePos[i][j].y; 
                        var distToBot = nodePos[i][j].y - bbox.min.y;
                        var distY = Math.min(distToTop, distToBot);
                        if (distY === distToBot) {
                            var ymod = -1.01;
                        } else {
                            var ymod = 1.01;
                        }

                        var distToLeft = nodePos[i][j].x - bbox.min.x;
                        var distToRight = bbox.max.x - nodePos[i][j].x;
                        var distX = Math.min(distToLeft, distToRight);
                        if (distX === distToLeft) {
                            var xmod = -1.01;
                        } else {
                            var xmod = 1.01;
                        }

                        var distToFront = bbox.max.z - nodePos[i][j].z;
                        var distToBack = nodePos[i][j].z - bbox.min.z;
                        var distZ = Math.min(distToFront, distToBack);
                        if (distZ === distToBack) {
                            var zmod = -1.01;
                        } else {
                            var zmod = 1.01;
                        }

                        var minXYZ = Math.min(distX, distY, distZ);
                        distZ = (distZ === minXYZ) ? distZ+1*zmod : 0;
                        distY = (distY === minXYZ) ? distY+1*ymod : 0;
                        distX = (distX === minXYZ) ? distX+1*xmod : 0;

                        nodePos[i][j].x += distX;
                        nodePos[i][j].y += distY;
                        nodePos[i][j].z += distZ;
                    }
                }
                
                if (simControlObj.kiwiAlive) {
                    if (kiwiHead.position.distanceTo(nodePos[i][j]) < 1+headRad) {
                        var dir = nodePos[i][j].clone();
                        dir.sub(kiwiHead.position);
    
                        dir.normalize();
    
                        var odir = dir.clone();
                        odir.multiplyScalar(1+headRad);
                        odir.add(kiwiHead.position);
                        nodePos[i][j].x = odir.x;
                        nodePos[i][j].y = odir.y;
                        nodePos[i][j].z = odir.z;
    
                        var dot = nodeVel[i][j].dot(dir);
                        dir.multiplyScalar(dot*(1+0.1));
                        nodeVel[i][j].sub(dir);
                    }
    
                    if (kiwiBod.position.distanceTo(nodePos[i][j]) < 1+bodRad) {
                        var dir = nodePos[i][j].clone();
                        dir.sub(kiwiBod.position);
    
                        dir.normalize();
    
                        var odir = dir.clone();
                        odir.multiplyScalar(1+bodRad);
                        odir.add(kiwiBod.position);
                        nodePos[i][j].x = odir.x;
                        nodePos[i][j].y = odir.y;
                        nodePos[i][j].z = odir.z;
    
                        var dot = nodeVel[i][j].dot(dir);
                        dir.multiplyScalar(dot*(1+0.001));
                        nodeVel[i][j].sub(dir);
                    }
                }
            } else {
                nodeVel[i][j].x = 0; nodeVel[i][j].y = 0; nodeVel[i][j].z = 0;
            }
        }
    }
}

function updatePosAndColor() {
    const positionAttribute = cloth.geometry.getAttribute( 'position' );
    const colorAttribute = cloth.geometry.getAttribute( 'color' );
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            positionAttribute.setXYZ( i*horizNodes+j, nodePos[i][j].x, nodePos[i][j].y, nodePos[i][j].z );
            if (cloth.material.vertexColors) {
                colorAttribute.setXYZ(
                    i*horizNodes+j, 
                    (nodePos[i][j].x*10%256)/256,
                    (nodePos[i][j].y*20%256)/256,
                    (nodePos[i][j].z*30%256)/256
                );
                cloth.geometry.attributes.color.needsUpdate = true;
            }
        }
    }
}

var bodXOff = 0; var bodYOff = -2; var bodZOff = 3.5;
var headXOff = 0; var headYOff = 6; var headZOff = 5;

function tempAnim() {
    requestAnimationFrame( tempAnim );
    renderer.render( scene, camera );
}

function animate() {
    requestAnimationFrame( animate );

    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    if (simControlObj.kiwiAlive) {
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
        if (!paused) mixer.update(dt);
    }
    if (simControlObj.bathAlive) {
        bath.position.set(
            bathHB.position.x,
            bathHB.position.y-8.75,
            bathHB.position.z+0.25
        )
    }

    if (moveTopLeft) nodePos[0][0].copy(topLeftNode.position);
    if (moveTopRight) nodePos[0][horizNodes-1].copy(topRightNode.position);
    if (moveBotLeft) nodePos[vertNodes-1][0].copy(botLeftNode.position);
    if (moveBotRight) nodePos[vertNodes-1][horizNodes-1].copy(botRightNode.position);

    // checkKeyPressed();
    totalDT += 1;
    for (let i = 0; i < numTimesteps; i++) {
        update(1/ndt);
    }
    // tempAnim();
    updatePosAndColor();
    orbitControls.update(1*dt);


    cloth.geometry.attributes.position.needsUpdate = true;
    cloth.geometry.computeVertexNormals(true);
    cloth.geometry.normalsNeedUpdate = true;
    cloth.geometry.computeBoundingBox();
    cloth.geometry.computeBoundingSphere();

    // adds line and renders scene
	renderer.render( scene, camera );
    stats.update();
}

// key handler booleans
var paused = true;
window.addEventListener( 'resize', onWindowResize, false );
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
    currAcc = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    futureVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    futurePos = Array(vertNodes).fill(null).map(() => Array(horizNodes));

    nodePos = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeVel = Array(vertNodes).fill(null).map(() => Array(horizNodes));
    nodeAcc = Array(vertNodes).fill(null).map(() => Array(horizNodes));

    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            nodePos[i][j] = new THREE.Vector3(
                i*restLen,
                stringTop.y,
                restLen*j
            );
            nodeVel[i][j] = new THREE.Vector3(0.0,0.0,0.0);
            nodeAcc[i][j] = new THREE.Vector3(0.0,0.0,0.0);
        }
    }
    if (moveTopLeft) topLeftNode.position.copy(nodePos[0][0]);
    if (moveTopRight) topRightNode.position.copy(nodePos[0][horizNodes-1]);
    if (moveBotLeft) botLeftNode.position.copy(nodePos[vertNodes-1][0]);
    if (moveBotRight) botRightNode.position.copy(nodePos[vertNodes-1][horizNodes-1]);

    scene.remove(cloth);

    var geo = new THREE.PlaneGeometry(restLen * horizNodes, restLen * vertNodes, horizNodes-1, vertNodes-1);
    geo.setAttribute('color', new THREE.BufferAttribute(
        new Float32Array(horizNodes*vertNodes*3),
        3
    ));

    const positionAttribute = geo.getAttribute( 'position' );
    const colorAttribute = geo.getAttribute( 'color' );
    for (let i = 0; i < vertNodes; i++) {
        for (let j = 0; j < horizNodes; j++) {
            positionAttribute.setXYZ( i*horizNodes+j, nodePos[i][j].x, nodePos[i][j].y, nodePos[i][j].z );
            colorAttribute.setXYZ(
                i*horizNodes+j, 
                (nodePos[i][j].x*10%256)/256,
                (nodePos[i][j].y*20%256)/256,
                (nodePos[i][j].z*30%256)/256
            );
        }
    }
    // geo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    var material = new THREE.MeshPhysicalMaterial({
        side: THREE.DoubleSide,
        vertexColors: true
    });
    
    cloth = new THREE.Mesh(geo, material);
    scene.add(cloth);
    
    updatePosAndColor();
}

setup();
if ( WebGL.isWebGLAvailable() ) {
    // Initiate function or other initializations here
    animate();
} else {
    const warning = WebGL.getWebGLErrorMessage();
    document.getElementById( 'container' ).appendChild( warning );
}

