float xOff = 0, yOff = 0;
float zoom = 1;
float zoomStrength = 0.05, moveSpeed = 0.05;
float maxIt = 10;
float windowRatio;
Color background = new Color(255, 255, 255, 0.5);
LinearGradient xGradient;
LinearGradient yGradient;
void setup() {
  size(1000, 1000);
  windowRatio = (float)width / height;
  xGradient = new LinearGradient(new Color[]{new Color(255, 0, 0), new Color(0, 0, 255)}, width);
  yGradient = new LinearGradient(new Color[]{new Color(255, 0, 0), new Color(0, 255, 0)}, height);
}

void linearInterpolation(Color col1, Color col2, int a, int b, Color[] arr) {
  float length = abs(b - a);
  Color diff = col2.minusN(col1);


  Color buff = new Color(col1);

  for (int i = a; i < b; i++) {
    buff.plus(diff, length);
    arr[i] = new Color(buff);
  }
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
  loadPixels();
  float halfWindowWidth =  2 * windowRatio / zoom;
  float halfWindowHeight = 2 / zoom;
  float windowLeft = xOff - halfWindowWidth;
  float windowRight = xOff + halfWindowWidth;
  float windowTop = yOff -  halfWindowHeight;
  float windowBottom = yOff + halfWindowHeight;
  for (int i = 0; i < width; i++) {
    for (int k = 0; k < height; k++) {
      //Color col = xGradient.gradientArr[i].mixN(yGradient.gradientArr[k]);
      float realZ = 0, imgZ = 0, realC= map(i, 0, width, windowLeft, windowRight), imgC = map(k, 0, height, windowTop, windowBottom);
      int c = -1;
      while (c < maxIt && realZ * realZ + imgZ * imgZ < 4) {
        float img = realZ * imgZ * 2 + imgC;
        realZ = realZ * realZ - imgZ * imgZ + realC;
        imgZ = img;
        c++;
      }
      realZ = realZ < -2 ? -2 : realZ > 2 ? 2 : realZ;
      imgZ = imgZ < -2 ? -2 : imgZ > 2 ? 2 : imgZ;
     
     color col = xGradient.gradientArr[(int)map(realZ, -2, 2, 0, width - 1)].mixN(
        yGradient.gradientArr[(int)map(imgZ, -2, 2, 0, height - 1)]).col();
     
     pixels[k * width + i] = col;
    }
  }
  updatePixels();
  noLoop();
}
void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  if (scroll < 0) zoomed(1 + zoomStrength);
  if (scroll > 0) zoomed(1 - zoomStrength);
  redraw();
}
void mousePressed() {
  if (mouseButton == LEFT) maxIt += 5;
  if (mouseButton == RIGHT && maxIt > 5) maxIt -= 5;
  redraw();
}
