
class Color {
  float r, g, b, a;

  Color(Color col) {
    r = col.r;
    g = col.g;
    b = col.b;
    this.a = col.a;
  }
  Color(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
    a = 1;
  }
  Color(float r, float g, float b, float a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  Color minusN(Color col) {
    return new Color(r - col.r, g - col.g, b - col.b);
  }
  Color minusN(Color col, float divisor) {
    return new Color(r - col.r/divisor, g - col.g/divisor, b - col.b/divisor);
  }
  void minus(Color col) {
    r -= col.r;
    g -= col.g;
    b -= col.b;
  }
  void minus(Color col, float divisor) {
    r -= col.r/divisor;
    g -= col.g/divisor;
    b -= col.b/divisor;
  }

  Color plusN(Color col) {
    return new Color(r + col.r, g + col.g, b + col.b, a);
  }
  Color plusN(Color col, float divisor) {
    return new Color(r + col.r/divisor, g + col.g/divisor, b + col.b/divisor, a);
  }
  void plus(Color col) {
    r += col.r;
    g += col.g;
    b += col.b;
  }
  void plus(Color col, float divisor) {
    r += col.r/divisor;
    g += col.g/divisor;
    b += col.b/divisor;
  }
  Color mixN(Color col) {
    float alpha = col.a + a;
    return new Color((col.r * col.a + r * a)/alpha, (col.g * col.a + g * a)/alpha, (col.b * col.a + b * a)/alpha, alpha/2);
  }
  color mixColor(Color col) {
    float alpha = col.a + a;
    return color((col.r * col.a + r * a)/alpha, (col.g  * col.a + g * a)/alpha, (col.b * col.a + b * a)/alpha, alpha / 2 * 255);
  }
  void mix(Color col) {
    float alpha = col.a + a;
    r = (r * a + col.r * col.a)/alpha;
    g = (g * g + col.g * col.a)/alpha;
    b = (b * b + col.b * col.a)/alpha;
  }
  color col() {
    return color(r, g, b, a * 255);
  }
  void reset() {
    r = 0;
    g = 0;
    b = 0;
    a = 1;
  }
}
