float xOff = 0, yOff = 0;
float zoom = 1;
float zoomStrength = 0.05, moveSpeed = 0.05;
float maxIt = 11;
float traceLength = 20;
float windowRatio;

int mandelbrotStartX, mandelbrotStartY, mandelbrotEndX, mandelbrotEndY;

int fatouStartX, fatouStartY, fatouEndX, fatouEndY;

float halfWindowWidth =  2 * windowRatio / zoom;
float halfWindowHeight = 2 / zoom;
float windowLeft = xOff - halfWindowWidth;
float windowRight = xOff + halfWindowWidth;
float windowTop = yOff -  halfWindowHeight;
float windowBottom = yOff + halfWindowHeight;

void setup() {
  size(1500, 1000);
  windowRatio = (width/2.f) / height;

  mandelbrotStartX = 0;
  mandelbrotStartY = 0;
  mandelbrotEndX = width/2;
  mandelbrotEndY = height;

  fatouStartX = width/2;
  fatouStartY = 0;
  fatouEndX = width;
  fatouEndY = height;
}
void zoomed(float x) {
  float deltaX = 4 * windowRatio / zoom, deltaY = 4 / zoom;
  zoom *= x;
  deltaX -= 4 * windowRatio / zoom;
  deltaY -= 4 / zoom;
  if (mouseX >= mandelbrotStartX && mouseX <= mandelbrotEndX && mouseY >= mandelbrotStartY && mouseY <= mandelbrotEndY) {
    xOff += map(mouseX, mandelbrotStartX, mandelbrotEndX, -0.5, 0.5) * deltaX;
    yOff += map(mouseY, mandelbrotStartY, mandelbrotEndY, 0.5, -0.5) * deltaY;
  } else if (mouseX >= fatouStartX && mouseX <= fatouEndX && mouseY >= fatouStartY && mouseY <= fatouEndY) {
    xOff += map(mouseX, fatouStartX, fatouEndX, -0.5, 0.5) * deltaX;
    yOff += map(mouseY, fatouStartY, fatouEndY, -0.5, 0.5) * deltaY;
  }
}
void renderMandelbrot() {
  for (int i = mandelbrotStartX; i < mandelbrotEndX; i++) {
    float realCRef = map(i, mandelbrotStartX, mandelbrotEndX, windowLeft, windowRight);
    for (int k = mandelbrotStartY; k < mandelbrotEndY; k++) {
      float realZ = 0, imgZ = 0, realC = realCRef, imgC = map(k, mandelbrotStartY, mandelbrotEndY, windowTop, windowBottom);
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
}

void renderFatuSet() {
  if (mouseX >= mandelbrotStartX && mouseX <= mandelbrotEndX && mouseY >= mandelbrotStartY && mouseY <= mandelbrotEndY) {
    if (mouseButton == LEFT && mousePressed) maxIt += 5;
    else if (mouseButton == RIGHT && maxIt >= 6 && mousePressed) maxIt -= 5;

    float realCRef = map(mouseX, mandelbrotStartX, mandelbrotEndX, windowLeft, windowRight);
    float imgCRef = map(mouseY, mandelbrotStartY, mandelbrotEndY, windowTop, windowBottom);
    println(realCRef + "|" + imgCRef);
    for (int i = fatouStartX; i < fatouEndX; i++) {
      float realZRef = map(i, fatouStartX, fatouEndX, windowLeft, windowRight);
      for (int k = fatouStartY; k < fatouEndY; k++) {
        float realZ = realZRef, imgZ = map(k, fatouStartY, fatouEndY, windowTop, windowBottom), imgC = imgCRef, realC = realCRef;

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
  }
}
void draw() {
  colorMode(RGB);
  background(0);
  halfWindowWidth =  2 * windowRatio / zoom;
  halfWindowHeight = 2 / zoom;
  windowLeft = xOff - halfWindowWidth;
  windowRight = xOff + halfWindowWidth;
  windowTop = yOff +  halfWindowHeight;
  windowBottom = yOff - halfWindowHeight;

  renderMandelbrot();
  renderFatuSet();
  updatePixels();
}
void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  if (scroll > 0) zoomed(1 - zoomStrength);
  if (scroll < 0) zoomed(1 + zoomStrength);
}
