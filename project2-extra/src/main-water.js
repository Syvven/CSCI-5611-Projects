import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {GLTFLoader} from './GLTFLoader.js';
import {FlyControls} from './FlyControls.js';
import {OrbitControls} from './OrbitControls.js';
import {DragControls} from './DragControls.js';
import WebGL from './webGLCheck.js';

// basic rendering
var renderer, camera, scene, orbitControls;
var stats, prevTime, gui;

// Cell / Particle info
var numCellsX = 10; var cellW = 0.25;
var numCellsY = 10; var cellH = 0.25;
var numCellsZ = 10; var cellL = 0.25;
var tW = cellW * numCellsX;
var tL = cellL * numCellsZ;
var tH = cellH * numCellsY;
var htW = tW*0.5;
var htL = tL*0.5;
var htH = tH*0.5;
var cells = Array(numCellsX).fill(null).map(() => 
    Array(numCellsY).fill(null).map(() => 
        Array(numCellsZ)
    )
);

var krd = 1.84; 
var ksN = 1;
var ks = 0.1;
var ksr = 0.1;
var gravity = new THREE.Vector3(0, -2, 0);
var numParticles = 2700; // make sure this divided by nLevels can be square rooted
var nLevels = 3; 
var perLevel = numParticles / nLevels
var numXZ = Math.sqrt(perLevel);
var pRad = 0.2*(cellW*numCellsX / numXZ);
var drawRad = 10*pRad;
console.log(pRad);
var particles = Array(numParticles);
var particlesCreated = 0;

// sim info
var numTimesteps = 1;
var paused = true;

class Cell {
    constructor(i, j, k, center) {
        this.i = i; this.j = j; this.k = k;
        this.center = center;
        this.points = [];
    }
}

class Particle {
    constructor(pos, oldPos, vel, obj, press, dens, pressN, densN, listInd) {
        this.pos = pos;
        this.oldPos = oldPos;
        this.vel = vel;
        this.obj = obj;
        this.press = press;
        this.dens = dens;
        this.pressN = pressN;
        this.densN = densN;
        this.listInd = listInd;
        this.cell = null;
        this.cellIndex = -1;
    }
}

class Pair {
    constructor(p1, p2, q) {
        this.p1 = p1; this.p2 = p2;
        this.q = q; this.q2 = q*q; this.q3 = q*q*q;
    }
}

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
    camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 0.1, 5000 );
    camera.position.set( 5, 5, 5 );
    camera.lookAt( 0, 0, 0 );

    // flyControls = new FlyControls(camera, renderer.domElement);
    // flyControls.dragToLook = true;
    // flyControls.movementSpeed = 10;
    // flyControls.rollSpeed = 1;

    orbitControls = new OrbitControls(camera, renderer.domElement);
    orbitControls.enableDamping = true;
    orbitControls.zoomSpeed = 2;

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

    // date for dt purposes
    prevTime = new Date();

    stats = new Stats();
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    /////////////////// INITIALIZE WATER STUFF //////////////////////////////////////////
    for (let i = 0; i < numCellsX; i++) {
        for (let j = 0; j < numCellsY; j++) {
            for (let k = 0; k < numCellsZ; k++) {
                var cell = new Cell(
                    i, j, k, 
                    new THREE.Vector3(
                        -tW*0.5+cellW*i+cellW*0.5,
                        cellH * j + cellH/2,
                        -tL*0.5+cellL*k+cellL*0.5
                    )
                );
                cells[i][j][k] = cell;
                // // cube representation just for testing
                // var geometry = new THREE.BoxGeometry( cellW, cellL, cellH );
                // var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
                // var cube = new THREE.Mesh( geometry, material );
                // cube.position.copy(cell.center);
                // cube.material.wireframe = true;
                // scene.add( cube );
            }
        }
    }

    createParticles();

    gui = new GUI();
    // base is 246
    gui.width = 300;

    var simInfoObj = {
        reset: false,
        paused: paused,
        ks: ks,
        krd: krd,
        ksr: ksr,
        ksN: ksN,
        gravity: gravity
    }
    const simInfoFolder = gui.addFolder("Sim Info");
    simInfoFolder.add(simInfoObj, 'reset').name("Reset").onChange(() => {
        createParticles();
    });
    simInfoFolder.add(simInfoObj, 'paused').name("Pause").onChange(() => {
        paused = !paused;
    });
    simInfoFolder.add(simInfoObj, 'ks', 0, 1000, 0.01).name("ks");
    simInfoFolder.add(simInfoObj, 'krd', 0, 1000, 0.01).name("krd");
    simInfoFolder.add(simInfoObj, 'ksr', 0, 1000, 0.01).name("ksr");
    simInfoFolder.add(simInfoObj, 'ksN', 0, 1000, 0.01).name("ksN");
    simInfoFolder.add(simInfoObj.gravity, 'y', -1000, 1000, 0.01).name("Gravity Y");
}   

function createParticles() {
    var index = 0;
    for (let i = 0; i < numXZ; i++) {
        for (let k = 0; k < numXZ; k++) {
            for (let j = 0; j < nLevels; j++) {
                if (particlesCreated > 0) {
                    scene.remove(particles[index].obj);
                }
                var geometry = new THREE.SphereGeometry(drawRad, 16, 16);
                var material = new THREE.MeshPhysicalMaterial({color: 0x00f0ff});
                var a = Math.random();
                var b = Math.random();
                var particle = new Particle(
                    new THREE.Vector3( // pos
                        -tW*0.5+pRad*2*i+pRad+a,
                        pRad*2*j+pRad + j,
                        -tL*0.5+pRad*2*k+pRad+b
                    ),
                    new THREE.Vector3( // oldPos
                        -tW*0.5+pRad*2*i+pRad+a,
                        pRad*2*j+pRad + j,
                        -tL*0.5+pRad*2*k+pRad+b
                    ),
                    new THREE.Vector3(0,0,0), // vel
                    new THREE.Mesh(geometry, material), // object
                    0.0, 0.0, 0.0, 0.0, index // press, dens, pressN, densN, listInd
                )
                material.reflectivity = 0
                material.transmission = 1
                material.roughness = 1
                material.metalness = 0
                material.color = new THREE.Color(0x00ffff)
                material.ior = 1.7
                material.thickness = 10.0
                particle.obj.position.copy(particle.pos);
                scene.add(particle.obj);
                particles[index++] = particle;
            }
        } 
    }
    particlesCreated += numParticles;
    if (particlesCreated > numParticles) particlesCreated = numParticles;
}

function update(dt) {
    var dtGrav = gravity.clone();
    dtGrav.multiplyScalar(dt);
    for (let i = 0; i < numParticles; i++) {
        var p = particles[i];
        p.vel = p.pos.clone();
        p.vel.sub(p.oldPos);
        p.vel.multiplyScalar(1/dt);
        p.vel.add(dtGrav);

        if (p.pos.y < drawRad) {
            p.pos.y = drawRad;
            p.vel.y *= -0.3;
        }
        if (p.pos.x < -htW) {
            p.pos.x = -htW;
            p.vel.x *= -0.3;
        }
        if (p.pos.x > htW) {
            p.pos.x = htW;
            p.vel.x *= -0.3;
        }
        if (p.pos.z < -htL) {
            p.pos.z = -htL;
            p.vel.z *= -0.3;
        }
        if (p.pos.z > htL) {
            p.pos.z = htL;
            p.vel.z *= -0.3;
        }

        p.oldPos = p.pos.clone();
        var vel = p.vel.clone();
        vel.multiplyScalar(dt);
        p.pos.add(vel);
        p.dens = 0.0;
        p.densN = 0.0;
    }

    var pairs = [];
    for (let i = 0; i < numParticles; i++) {
        for (let j = 0; j < numParticles; j++) {
            var dist = particles[i].pos.distanceTo(particles[j].pos);
            if (dist < ksr && i < j) {
                var q = 1 - (dist/ksr);
                pairs.push(new Pair(
                    particles[i], 
                    particles[j], 
                    q
                ));
            }
        }
    }

    // if (pairs.length != 0) {
    //     console.log(pairs);
    //     quit();
    // }
    for (let i = 0; i < pairs.length; i++) {
        var pair = pairs[i];
        // if (pair.p1.dens == NaN) pair.p1.dens = 0;
        // if (pair.p2.dens == NaN) pair.p2.dens = 0;
        pair.p1.dens += pair.q2;
        pair.p2.dens += pair.q2;
        pair.p1.densN += pair.q3;
        pair.p2.densN += pair.q3;
    }

    for (let i = 0; i < numParticles; i++) {
        var p = particles[i];
        p.press = ks*(p.dens-krd);
        p.pressN = ksN*(p.densN);
        if (p.press > 30) p.press = 30;
        if (p.pressN > 300) p.pressN = 300;
    }

    for (let i = 0; i < pairs.length; i++) {
        var pair = pairs[i];
        var tp = (pair.p1.press + pair.p2.press) * pair.q + (pair.p1.pressN + pair.p2.pressN) * pair.q2;
        var d = tp * (dt * dt);
        var apos = pair.p1.pos.clone();
        var bpos = pair.p2.pos.clone();
        apos.sub(bpos);
        apos.normalize();
        apos.multiplyScalar(d);
        bpos.sub(pair.p1.pos);
        bpos.normalize();
        bpos.multiplyScalar(d);

        pair.p1.pos.add(apos);
        pair.p2.pos.add(bpos);
    }
}

function updateParticlePos() {
    for (let i = 0; i < numParticles; i++) {
        var p = particles[i];
        p.obj.position.copy(p.pos);
        p.obj.position.needsUpdate = true;
    }
}

function animate() {
    requestAnimationFrame( animate );
    var now = new Date();
    var dt = (now - prevTime) / 1000;
    prevTime = now;

    for (let i = 0; i < numTimesteps; i++) {
        if (!paused) update(dt);
    }
    updateParticlePos();

    orbitControls.update(dt);

    renderer.render( scene, camera );
    stats.update();
}

window.addEventListener( 'resize', (e) => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.render(scene, camera);
});

setup();
if ( WebGL.isWebGLAvailable() ) {
    // Initiate function or other initializations here
    animate();
} else {
    const warning = WebGL.getWebGLErrorMessage();
    document.getElementById( 'container' ).appendChild( warning );
}