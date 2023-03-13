class LinearGradient {
  Color[] gradientArr;


  LinearGradient(Color[] colors, int detail) {
    gradientArr = new Color[detail];
    int a = 0, b = 0;
    float l = detail / colors.length;
    for (int i = 0; i < colors.length - 2; i++) {
      b += l;
      linearInterpolation(colors[i], colors[i + 1], (int)a, (int)b, gradientArr);
      a = b;
    }
    linearInterpolation(colors[colors.length - 2], colors[colors.length - 1], (int)b, (int) detail, gradientArr);
  }

  void display(float h) {
    float lineLength = (float)width / gradientArr.length;
    for (int i = 0; i < gradientArr.length; i++) {
      stroke(gradientArr[i].r, gradientArr[i].g, gradientArr[i].b);
      line(i * lineLength, h, (i + 1) * lineLength, h);
    }
  }
}
