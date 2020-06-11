PShape man;

void setup() {
  size(512, 512, P3D);
  man = loadShape("man.obj");
}

void draw() {
  background(0xffffff);
  translate(width/2, height/2);
  lights();
  camera(0,-200,300, 0,0,0, 0,1,0);
  shape(man);
  man.rotateY(.01);
}
