void checkPressed() {

}

void mouseWheel(MouseEvent event) {
    
}

void mouseReleased() {
  // mouseCast = true;
  // mouseRay = cameraRay(mouseX, mouseY);
  // mouseOrig = new Vec3(camera.position.x, camera.position.y, camera.position.z);
}

void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
  if (key == 'r') reset();
}

// Vec3 cameraRay(float x, float y) {
//   float imageAspectRatio = camera.aspectRatio;  //assuming width > height 
//   float px = (2 * ((x + 0.5) / displayWidth) - 1) * tan(camera.fovy / 2 * PI / 180) * imageAspectRatio; 
//   float py = (1 - 2 * ((y + 0.5) / displayHeight) * tan(camera.fovy / 2 * PI / 180)); 
//   Vec3 rayOrigin = new Vec3(camera.position.x, camera.position.y, camera.position.z); 
//   Vec3 rayDirection = new Vec3(px, py, -1);  //note that this just equal to Vec3f(Px, Py, -1); 
//   rayDirection = rayDirection.normalized();  //it's a direction so don't forget to normalize
//   return rayDirection;
// }
