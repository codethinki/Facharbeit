int particleCount = 2000; //<>// //<>// //<>//
int gridDens = 10;
int ticks = 150;

PVector gridStart, gridSize = new PVector(700, 700);

int framesPerDraw = 1;

PVector systemStart = new PVector(-2, -2), systemEnd = new PVector(2, 2);

ArrayList<ArrayList<Particle>> rows = new ArrayList<ArrayList<Particle>>();
ArrayList<ArrayList<Particle>> columns = new ArrayList<ArrayList<Particle>>();

void setup() {
  size(1000, 1000);
  gridStart = new PVector((width - gridSize.x) / 2, (height - gridSize.y) / 2);

  for (int i = 0; i < gridDens; i ++) {
    columns.add(new ArrayList<Particle>());
    ArrayList<Particle> line = columns.get(i);

    float x = (i + 1) * (gridSize.x / (gridDens + 1));
    float cX = map(x, 0, gridSize.x, systemStart.x, systemEnd.x);

    for (int k = 0; k < particleCount; k ++) {
      float y = k * (gridSize.y / particleCount);
      float cY = map(y, 0, gridSize.y, systemStart.y, systemEnd.y);

      line.add(new Particle(x, y, ticks));
      Particle particle = line.get(k);
      particle.c = new PVector(cX, cY);
      particle.z = new PVector(cX, cY);
    }
  }
  for (int i = 0; i < gridDens; i ++) {
    rows.add(new ArrayList<Particle>());
    ArrayList<Particle> line = rows.get(i);

    float y = (i + 1) * (gridSize.x / (gridDens + 1));
    float cY = map(y, 0, gridSize.y, systemStart.y, systemEnd.y);

    for (int k = 0; k < particleCount; k ++) {
      float x = k * (gridSize.y / particleCount);
      float cX = map(x, 0, gridSize.x, systemStart.x, systemEnd.x);
      line.add(new Particle(x, y, ticks));
      Particle particle = line.get(k);
      particle.c = new PVector(cX, cY);
      particle.z = new PVector(cX, cY);
    }
  }
}
void draw() {
  background(0);
  for (int i = 0; i < framesPerDraw; i++) {
    if (!rows.get(0).get(0).moving) {
      newTransformDest(rows);
      newTransformDest(columns);
    }

    tickLines(rows);
    tickLines(columns);
  }
  translate(gridStart.x, gridStart.y);

  strokeWeight(5);

  stroke(255, 255, 0);
  drawParticles(rows);

  stroke(0, 255, 255);
  drawParticles(columns);
}
void newTransformDest(ArrayList<ArrayList<Particle>> lines) {
  for (ArrayList<Particle> line : lines)
    for (Particle particle : line) {
      float img = particle.z.x * particle.z.y * 2 + particle.c.y;
      particle.z.x = particle.z.x * particle.z.x - particle.z.y * particle.z.y + particle.c.x;
      particle.z.y = img;

      particle.addPoint(map(particle.z.x, systemStart.x, systemEnd.x, 0, gridSize.x), map(particle.z.y, systemStart.y, systemEnd.y, 0, gridSize.y));
    }
}

void tickLines(ArrayList<ArrayList<Particle>> lines) {
  for (int k = 0; k < lines.size(); k++) {
    ArrayList<Particle> line = lines.get(k);
    for (int i = 0; i < line.size(); i++) {
      Particle particle = line.get(i);
      particle.tick();
      if (particle.pos.x > gridSize.x * 2 || particle.pos.x < -gridSize.x || particle.pos.y > gridSize.y * 2 || particle.pos.y < -gridSize.y) line.remove(i--);
    }
    if (line.isEmpty()) lines.remove(k);
  }
}

void drawParticles(ArrayList<ArrayList<Particle>> lines) {
  for (ArrayList<Particle> line : lines)
    for (int i = 1; i < line.size(); i++) {
      PVector pos1 = line.get(i - 1).pos;
      PVector pos2 = line.get(i).pos;
      line(pos1.x, pos1.y, pos2.x, pos2.y);
      //circle(pos2.x, pos2.y, 4);
    }
}
void keyPressed() {
}
void mousePressed() {
  if (mouseButton == LEFT) framesPerDraw++;
  if (mouseButton == RIGHT && framesPerDraw > 0) framesPerDraw--;
}
