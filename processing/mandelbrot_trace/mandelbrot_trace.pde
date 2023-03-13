float xOff = 0, yOff = 0;
float zoom = 1;
float zoomStrength = 0.05, moveSpeed = 0.05;
float maxIt = 11;
float windowRatio;
float traceLength = 20;
void setup() {
  size(1000, 1000);
  windowRatio = (float)width / height;
}
void zoomed(float x) {
  float deltaX = 4 * windowRatio / zoom, deltaY = 4 / zoom;
  zoom *= x;
  deltaX -= 4 * windowRatio / zoom;
  deltaY -= 4 / zoom;
  xOff += map(mouseX, 0, width, -0.5, 0.5) * deltaX;
  yOff += map(mouseY, 0, height, -0.5, 0.5) * deltaY;
}

void draw() {
  colorMode(RGB);
  background(0);
  float halfWindowWidth =  2 * windowRatio / zoom;
  float halfWindowHeight = 2 / zoom;
  float windowLeft = xOff - halfWindowWidth;
  float windowRight = xOff + halfWindowWidth;
  float windowTop = yOff -  halfWindowHeight;
  float windowBottom = yOff + halfWindowHeight;

  for (int i = 0; i < width; i++) {
    for (int k = 0; k < height; k++) {
      float realZ = 0, imgZ = 0, realC= map(i, 0, width, windowLeft, windowRight), imgC = map(k, 0, height, windowTop, windowBottom);
      int c = -1;
      while (c < maxIt && realZ * realZ + imgZ * imgZ < 4) {
        float img = realZ * imgZ * 2 + imgC;
        realZ = realZ * realZ - imgZ * imgZ + realC;
        imgZ = img;
        c++;
      }
      color col = color(map(c, 0, maxIt, 0, 255), 0, 0);
      set(i, k, col);
    }
  }
  updatePixels();
  if (traceLength > 0) {
    stroke(255);
    float realZ = 0, imgZ = 0, realC= map(mouseX, 0, width, windowLeft, windowRight), imgC = map(mouseY, 0, height, windowTop, windowBottom);
    int c = -1;
    float lastX = mouseX, lastY = mouseY;
    colorMode(HSB);
    while (c < traceLength && realZ * realZ + imgZ * imgZ < 4) {
      float img = realZ * imgZ * 2 + imgC;
      realZ = realZ * realZ - imgZ * imgZ + realC;
      imgZ = img;   
      circle(lastX, lastY, 10);
      line(lastX, lastY,
        map(realZ, windowLeft, windowRight, 0, width), map(imgZ, windowTop, windowBottom, 0, height));
      lastX = map(realZ, windowLeft, windowRight, 0, width);
      lastY = map(imgZ, windowTop, windowBottom, 0, height);
      c++;
    }
    circle(lastX, lastY, 10);
  }
}
void keyPressed() {
  if (keyCode == UP) maxIt += 5;
  if (keyCode == DOWN && maxIt >= 6) maxIt -= 5;
  if (key == 'w') zoomed(1 + zoomStrength);
  if (key == 's') zoomed(1 - zoomStrength);
  if (key == 'a' && traceLength >= 1) traceLength -= 1;
  if (key == 'd') traceLength += 1;
}
void mousePressed() {
  if (mouseButton == LEFT) zoomed(1 + zoomStrength);
  if (mouseButton == RIGHT) zoomed(1 - zoomStrength);
}
