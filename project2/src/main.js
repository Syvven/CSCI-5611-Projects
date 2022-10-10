import * as THREE from '../node_modules/three/src/Three.js';
import {GLTFLoader} from './GLTFLoader.js';
import {FlyControls} from './FlyControls.js';
import WebGL from './webGLCheck.js';
import { PlaneBufferGeometry } from '../node_modules/three/src/Three.js';

setup();

// scene globals
var scene, camera, renderer, flyControls, prevTime;

// other globals
var loader;
var geometry, material, cube;

function setup() {
    // boilerplate
    scene = new THREE.Scene();
    // creates new camera / sets position / sets looking angle
    camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 500 );
    camera.position.set( 0, 0, 20 );
    camera.lookAt( 0, 0, 0 );

    // creates renderer and sets its size
    renderer = new THREE.WebGLRenderer({depth:true});
    renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.setClearColor(0xffffff, 0);
    document.body.appendChild( renderer.domElement );

    // // other setup items go here
    // loader = new GLTFLoader();

    // loader.load('../models/kiwi.glb', function(gltf) {
    //     scene.add(gltf.scene);
    // }, undefined, function(error) {
    //     console.error(error);
    // });

    var groundTexture = new THREE.TextureLoader().load("../models/floor-min.png");
    groundTexture.weapS = groundTexture.wrapT = THREE.RepeatWrapping;
    groundTexture.encoding = THREE.sRGBEncoding;
    var groundMaterial = new THREE.MeshStandardMaterial({map:groundTexture});
    var mesh = new THREE.Mesh(new THREE.PlaneBufferGeometry(10,10),groundMaterial);
    mesh.position.y = 0.0;
    mesh.rotation.x = -Math.PI/2;
    scene.add(mesh);

    geometry = new THREE.BoxGeometry( 1, 1, 1 );
    material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
    cube = new THREE.Mesh( geometry, material );
    scene.add( cube );

    flyControls = new FlyControls(camera, renderer.domElement);
    flyControls.dragToLook = true;
    flyControls.movementSpeed = 10;
    flyControls.rollSpeed = 1;
    prevTime = new Date();

    var hemiLight = new THREE.HemisphereLight( 0xffffff, 0x444444 );
    hemiLight.position.set( 0, 300, 0 );
    scene.add( hemiLight );

    if ( WebGL.isWebGLAvailable() ) {
        // Initiate function or other initializations here
        animate();
    } else {
        const warning = WebGL.getWebGLErrorMessage();
        document.getElementById( 'container' ).appendChild( warning );
    }
}

function animate(dt) {

    // other code goes here
    cube.rotation.x += 0.01;
    cube.rotation.y += 0.01;

    var now = new Date();
    var secs = (now - prevTime) / 1000;
    prevTime = now;
    flyControls.update(1*secs);

    // adds line and renders scene
	renderer.render( scene, camera );
    requestAnimationFrame( animate );
}