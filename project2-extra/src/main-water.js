import * as THREE from '../node_modules/three/src/Three.js';
import Stats from '../node_modules/stats.js/src/Stats.js';
import GUI from '../node_modules/dat.gui/src/dat/gui/GUI.js';
import {GLTFLoader} from './GLTFLoader.js';
import {FlyControls} from './FlyControls.js';
import {OrbitControls} from './OrbitControls.js';
import {DragControls} from './DragControls.js';
import { TransformControls } from './TransformControls.js';
import WebGL from './webGLCheck.js';

// basic rendering
var renderer, camera, scene, orbitControls;
var stats, prevTime, gui, dragControls;

// Cell / Particle info
var numCellsX = 1; var cellW = 400/numCellsX;
var numCellsY = 1; var cellH = 400/numCellsY;
var numCellsZ = 1; var cellL = 400/numCellsZ;
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

var krd = 5; 
var ksN = 1000;
var ks = 1000;
var ksr = 60;
var gravity = new THREE.Vector3(0, -164, 0);
var numParticles = 1125; // make sure this divided by nLevels can be square rooted
var nLevels = 5; 
var perLevel = numParticles / nLevels
var numXZ = Math.sqrt(perLevel);
var pRad = 1;
var drawRad = 18*pRad;
console.log(pRad);
var particles = Array(numParticles);
var particlesCreated = 0;

// sim info
var numTimesteps = 5;
var paused = true;
var lWall, rWall, fWall, bWall;

function inBounds(i, j, k) {
    if (i === numCellsX || i < 0) return false;
    if (j === numCellsY || j < 0) return false;
    if (k === numCellsZ || k < 0) return false;
    console.log(i, j, k)
    return true;
}

class Cell {
    constructor(i, j, k, center) {
        this.counter = 0;
        this.i = i; this.j = j; this.k = k;
        this.center = center;
        this.points = [];
        this.adjCells = [];
    }
    getAdjacent(i, j, k) {
        if (inBounds(i+1, j, k)) this.adjCells.push(cells[i+1][j][k]);
        if (inBounds(i, j+1, k)) this.adjCells.push(cells[i][j+1][k]);
        if (inBounds(i, j, k+1)) this.adjCells.push(cells[i][j][k+1]);
        if (inBounds(i+1, j+1, k)) this.adjCells.push(cells[i+1][j+1][k]);
        if (inBounds(i+1, j, k+1)) this.adjCells.push(cells[i+1][j][k+1]);
        if (inBounds(i, j+1, k+1)) this.adjCells.push(cells[i][j+1][k+1]);
        if (inBounds(i+1, j+1, k+1)) this.adjCells.push(cells[i+1][j+1][k+1]);

        if (inBounds(i-1, j, k)) this.adjCells.push(cells[i-1][j][k]);
        if (inBounds(i, j-1, k)) this.adjCells.push(cells[i][j-1][k]);
        if (inBounds(i, j, k-1)) this.adjCells.push(cells[i][j][k-1]);
        if (inBounds(i-1, j-1, k)) this.adjCells.push(cells[i-1][j-1][k]);
        if (inBounds(i-1, j, k-1)) this.adjCells.push(cells[i-1][j][k-1]);
        if (inBounds(i, j-1, k-1)) this.adjCells.push(cells[i][j-1][k-1]);
        if (inBounds(i-1, j-1, k-1)) this.adjCells.push(cells[i-1][j-1][k-1]);

        if (inBounds(i-1, j-1, k+1)) this.adjCells.push(cells[i-1][j-1][k+1]);
        if (inBounds(i-1, j+1, k-1)) this.adjCells.push(cells[i-1][j+1][k-1]);
        if (inBounds(i+1, j-1, k-1)) this.adjCells.push(cells[i+1][j-1][k-1]);
        if (inBounds(i+1, j+1, k-1)) this.adjCells.push(cells[i+1][j+1][k-1]);
        if (inBounds(i+1, j-1, k+1)) this.adjCells.push(cells[i+1][j-1][k+1]);
        if (inBounds(i-1, j+1, k+1)) this.adjCells.push(cells[i-1][j+1][k+1]);
        if (inBounds(i+1, j-1, k)) this.adjCells.push(cells[i+1][j-1][k]);
        if (inBounds(i-1, j+1, k)) this.adjCells.push(cells[i-1][j+1][k]);
        if (inBounds(i+1, j, k-1)) this.adjCells.push(cells[i+1][j][k-1]);
        if (inBounds(i-1, j, k+1)) this.adjCells.push(cells[i-1][j][k+1]);
        if (inBounds(i, j+1, k-1)) this.adjCells.push(cells[i][j+1][k-1]);
        if (inBounds(i, j-1, k+1)) this.adjCells.push(cells[i][j-1][k+1]);
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
    camera.position.set( 300, 300, 300 );
    camera.lookAt( 0, 0, 0 );

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



    var controlArr = [];
    // dragControls = new DragControls(controlArr, camera, renderer.domElement);
    // dragControls.addEventListener('dragstart', (e) => {
    //     orbitControls.enabled = false;
    //     if (e.position.z > 1) {
    //         dragR = true;
    //     } else if (e.position.z < -1) {
    //         dragL = true;
    //     } else if (e.position.x > 1) {
    //         dragF = true;
    //     } else if (e.position.x < -1) {
    //         dragB = true;
    //     }
    // });
    // dragControls.addEventListener('dragend', (e) => {
    //     if (dragR) dragR = false;
    //     if (dragL) dragL = false;
    //     if (dragB) dragB = false;
    //     if (dragF) dragF = false;
    //     orbitControls.enabled = true;
    // });
    var material = new THREE.MeshPhysicalMaterial({side: THREE.DoubleSide});
    material.transparent = true;
    material.opacity = 0.3;
    material.reflectivity = 0;
    material.transmission = 1.0;
    material.roughness = 0.7;
    material.metalness = 0;
    material.clearcoat = 0.3;
    material.clearcoatRoughness = 0.25;
    material.color = new THREE.Color(0xffffff);
    material.ior = 1.2;
    material.thickness = 10.0;
    lWall = new THREE.Mesh(new THREE.PlaneBufferGeometry(400,400, 10, 10),material);
    lWall.position.y = 200;
    lWall.position.z = -200;
    scene.add(lWall);
    controlArr.push(lWall);

    rWall = new THREE.Mesh(new THREE.PlaneBufferGeometry(400,400, 10, 10),material);
    rWall.position.y = 200;
    rWall.position.z = 200;
    scene.add(rWall);
    controlArr.push(rWall);

    fWall = new THREE.Mesh(new THREE.PlaneBufferGeometry(400,400, 10, 10),material);
    fWall.position.y = 200;
    fWall.rotation.y = -Math.PI/2;
    fWall.position.x = 200;
    scene.add(fWall);
    controlArr.push(fWall);

    bWall = new THREE.Mesh(new THREE.PlaneBufferGeometry(400,400, 10, 10),material);
    bWall.position.y = 200;
    bWall.rotation.y = -Math.PI/2;
    bWall.position.x = -200;
    scene.add(bWall);
    controlArr.push(bWall);

    var transformControls = new TransformControls(camera, renderer.domElement);
    var c1 = transformControls.attach(bWall);
    c1.showZ = false;
    c1.showY = false;
    c1.addEventListener('dragging-changed', function (event) {
        orbitControls.enabled = !event.value
        //dragControls.enabled = !event.value
    })
    c1.addEventListener('objectChange', function (e) {
        if (bWall.position.x < -200) {
            bWall.position.x = -200;
        }
        if (bWall.position.x > -40) {

            bWall.position.x = -40;
        }
        bWall.position.needsUpdate = true;
    });
    scene.add(c1);
    transformControls = new TransformControls(camera, renderer.domElement);
    var c2 = transformControls.attach(fWall);
    c2.showZ = false;
    c2.showY = false;
    c2.addEventListener('dragging-changed', function (event) {
        orbitControls.enabled = !event.value
        //dragControls.enabled = !event.value
    });
    c2.addEventListener('objectChange', function (e) {
        if (fWall.position.x > 200) {
            fWall.position.x = 200;
        }
        if (fWall.position.x < 40) {

            fWall.position.x = 40;
        }
        fWall.position.needsUpdate = true;
    });
    scene.add(c2);
    transformControls = new TransformControls(camera, renderer.domElement);
    var c3 = transformControls.attach(lWall);
    c3.showX = false;
    c3.showY = false;
    c3.addEventListener('dragging-changed', function (event) {
        orbitControls.enabled = !event.value
        //dragControls.enabled = !event.value
    });
    c3.addEventListener('objectChange', function (e) {
        if (lWall.position.z < -200) {
            lWall.position.z = -200;
        }
        if (lWall.position.z > -40) {

            lWall.position.z = -40;
        }
        lWall.position.needsUpdate = true;
    });
    scene.add(c3);
    transformControls = new TransformControls(camera, renderer.domElement);
    var c4 = transformControls.attach(rWall);
    c4.showX = false;
    c4.showY = false;
    c4.addEventListener('dragging-changed', function (event) {
        orbitControls.enabled = !event.value
        //dragControls.enabled = !event.value
    });
    c4.addEventListener('objectChange', function (e) {
        if (rWall.position.z > 200) {
            rWall.position.z = 200;
        }
        if (rWall.position.z < 40) {

            rWall.position.z = 40;
        }
        rWall.position.needsUpdate = true;
    });
    scene.add(c4);

    // hemisphere light for equal lighting
    var hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444 );
    hemiLight.position.set( 0, 300, 0 );
    scene.add( hemiLight );

    // const light = new THREE.PointLight(0xffffff);
    // light.position.set(0, 50, 50);
    // scene.add(light);

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
    for (let i = 0; i < numCellsX; i++) {
        for (let j = 0; j < numCellsY; j++) {
            for (let k = 0; k < numCellsZ; k++) {
                cells[i][j][k].getAdjacent(i, j, k);
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
    simInfoFolder.add(simInfoObj, 'ks', 0, 5000, 0.01).name("ks").onChange(() => {
        ks = simInfoObj.ks;
    });
    simInfoFolder.add(simInfoObj, 'krd', 0, 5000, 0.01).name("krd").onChange(() => {
        krd = simInfoObj.krd;
    });
    simInfoFolder.add(simInfoObj, 'ksr', 0, 5000, 0.01).name("ksr").onChange(() => {
        ksr = simInfoObj.ksr;
    });
    simInfoFolder.add(simInfoObj, 'ksN', 0, 5000, 0.01).name("ksN").onChange(() => {
        ksN = simInfoObj.ksN;
    });
    simInfoFolder.add(simInfoObj.gravity, 'y', -1000, 1000, 0.01).name("Gravity Y").onChange(() => {
        gravity.y = simInfoObj.gravity.y;
    });
}   

function createParticles() {
    var index = 0;
    for (let i = 0; i < numXZ; i++) {
        for (let k = 0; k < numXZ; k++) {
            for (let j = 0; j < nLevels; j++) {
                if (particlesCreated > 0) {
                    scene.remove(particles[index].obj);
                }
                var geometry = new THREE.SphereGeometry(drawRad, 10, 10);
                var material = new THREE.MeshPhysicalMaterial({color: 0x00f0ff});
                var a = Math.random();
                var b = Math.random();
                var particle = new Particle(
                    new THREE.Vector3( // pos
                        -tW*0.5+(drawRad-4)*2*i+drawRad+a,
                        (drawRad-4)*2*j+drawRad + j + a + b,
                        -tL*0.5+(drawRad-4)*2*k+drawRad+b
                    ),
                    new THREE.Vector3( // oldPos
                        -tW*0.5+(drawRad-4)*2*i+drawRad+a,
                        (drawRad-4)*2*j+drawRad + j + a + b,
                        -tL*0.5+(drawRad-4)*2*k+drawRad+b
                    ),
                    new THREE.Vector3(0,0,0), // vel
                    new THREE.Mesh(geometry, material), // object
                    0.0, 0.0, 0.0, 0.0, index // press, dens, pressN, densN, listInd
                )
                material.reflectivity = 0
                material.transmission = 1.0
                material.roughness = 0.7
                material.metalness = 0
                material.clearcoat = 0
                material.clearcoatRoughness = 0.25
                material.color = new THREE.Color(0x0000ff)
                material.ior = 1.2
                material.thickness = 10.0
                particle.obj.position.copy(particle.pos);

                var min = Infinity;
                var minCell = null;
                for (let a = 0; a < numCellsX; a++) {
                    for (let b = 0; b < numCellsY; b++) {
                        for (let c = 0; c < numCellsZ; c++) {
                            var dist = particle.pos.distanceTo(cells[a][b][c].center);
                            if (dist < min) {
                                minCell = cells[a][b][c];
                                min = dist;
                            }
                        }
                    }
                }

                particle.cell = minCell;
                minCell.points.push(particle);

                scene.add(particle.obj);
                particles[index++] = particle;
            }
        } 
    }
    console.log(particles);
    particlesCreated += numParticles;
    if (particlesCreated > numParticles) particlesCreated = numParticles;
}

function update(dt) {
    var dtGrav = gravity.clone();
    dtGrav.multiplyScalar(dt);
    for (let a = 0; a < numParticles; a++) {
        var p = particles[a];
        p.vel = p.pos.clone();
        p.vel.sub(p.oldPos);
        p.vel.multiplyScalar(1/dt);
        p.vel.add(dtGrav);

        if (p.pos.y < drawRad) {
            p.pos.y = drawRad+2;
            p.vel.y *= -0.3;
        }
        if (p.pos.y > tH) {
            p.pos.y = tH-drawRad+2;
            p.vel.y *= -0.3;
        }
        if (p.pos.x < bWall.position.x+drawRad) {
            p.pos.x = bWall.position.x+drawRad+1;
            p.vel.x *= -0.3;
        }
        if (p.pos.x > fWall.position.x-drawRad) {
            p.pos.x = fWall.position.x-drawRad-1;
            p.vel.x *= -0.3;
        }
        if (p.pos.z < lWall.position.z+drawRad) {
            p.pos.z = lWall.position.z+drawRad+1;
            p.vel.z *= -0.3;
        }
        if (p.pos.z > rWall.position.z-drawRad) {
            p.pos.z = rWall.position.z-drawRad-1;
            p.vel.z *= -0.3;
        }

        p.oldPos = p.pos.clone();
        var vel = p.vel.clone();
        vel.multiplyScalar(dt);
        p.pos.add(vel);
        p.dens = 0.0;
        p.densN = 0.0;

        if ( Math.abs(p.pos.x - p.cell.center.x) > cellW ||
                Math.abs(p.pos.y - p.cell.center.y) > cellH ||
                Math.abs(p.pos.z - p.cell.center.z) > cellL ) {
            var i = p.cell.i; var j = p.cell.j; var k = p.cell.k;
            if (p.pos.x > p.cell.center.x) (i == numCellsX-1) ? 0 : i++;
            else (i == 0) ? 0 : i--;
            if (p.pos.y > p.cell.center.y) (j == numCellsY-1) ? 0 : j++;
            else (j == 0) ? 0 : j--;
            if (p.pos.z > p.cell.center.z) (k == numCellsZ-1) ? 0 : k++;
            else (k == 0) ? 0 : k--;
            
            p.cell.points[p.index] = null;
            p.cell = cells[i][j][k];
            p.cell.points[p.index] = p;
        }
    }

    var pairs = [];
    for (let i = 0; i < numParticles; i++) {
        var p = particles[i];
        for (let j = 0; j < p.cell.points.length; j++) {
            if (p.cell.points[j] != null && i < p.cell.points[j].listInd) {
                var dist = p.pos.distanceTo(p.cell.points[j].pos);
                if (dist < ksr) {
                    var q = 1 - (dist/ksr);
                    pairs.push({
                        p1: p,
                        p2: p.cell.points[j], 
                        q: q,
                        q2: q*q,
                        q3: q*q*q
                    });
                }
            }
        }

        for (let j = 0; j < p.cell.adjCells.length; j++) {
            var ind = p.cell.adjCells[j];
            var c = cells[ind.i][ind.j][ind.k];
            for (let k = 0; k < c.points.length; k++) {
                if (c.points[k] != null && i < c.points[k].listInd) {
                    var dist = p.pos.distanceTo(c.points[k].pos);
                    if (dist < ksr) {
                        var q = 1 - (dist/ksr);
                        pairs.push({
                            p1: p,
                            p2: c.points[k], 
                            q: q,
                            q2: q*q,
                            q3: q*q*q
                        });
                    }
                }
            }
        }
    }

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
        if (p.press > 3) p.press = 30;
        if (p.pressN > 30) p.pressN = 300;
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
        if (!paused) update(1/100);
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