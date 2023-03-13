class Particle {
  ArrayList<Float> x = new ArrayList<Float>();
  ArrayList<Float> y = new ArrayList<Float>();
  PVector pos;
  PVector z = new PVector(0, 0);
  PVector c = new PVector(0, 0);
  float vX, vY, aX, aY;
  int detail;
  boolean moving = false;
  int tickCount = 0;

  Particle(float x, float y, int detail) {
    pos = new PVector(x, y);
    this.x.add(x);
    this.y.add(y);
    this.detail = detail;
  }

  void addPoint(float x, float y) {
    this.x.add(x);
    this.y.add(y);
  }

  void draw() {
    circle(pos.x, pos.y, 5);
  }

  void tick() {
    if (moving && tickCount >= detail) {
      x.remove(0);
      y.remove(0);
      vX = 0;
      vY = 0;
      pos.x = x.get(0);
      pos.y = y.get(0);

      moving = false;
      tickCount = 0;
    }

    if (!moving && x.size() > 1) {
      aX = (x.get(1) - x.get(0)) / (pow(detail/2, 2));
      aY = (y.get(1) - y.get(0)) / (pow(detail/2, 2));

      vX = 0;
      vY = 0;

      moving = true;
      tickCount = 0;
    }
    if (moving) {
      if (tickCount == detail/2) {
        aX *= -1;
        aY *= -1;
      }
      vX += aX;
      vY += aY;
      pos.x += vX;
      pos.y += vY;

      tickCount++;
    }
  }
}
