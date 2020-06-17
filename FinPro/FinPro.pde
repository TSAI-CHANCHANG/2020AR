import gab.opencv.*;
import processing.video.*;
import java.util.Set;
import java.util.Arrays;

final boolean MARKER_TRACKER_DEBUG = false;
final boolean BALL_DEBUG = false;

final boolean USE_SAMPLE_IMAGE = false;
final boolean MANUAL=true;

// We've found that some Windows build-in cameras (e.g. Microsoft Surface)
// cannot work with processing.video.Capture.*.
// Instead we use DirectShow Library to launch these cameras.
final boolean USE_DIRECTSHOW = true;


// final double kMarkerSize = 0.036; // [m]
final double kMarkerSize = 0.024; // [m]

Capture cap;
DCapture dcap;
OpenCV opencv;

float fov = 45; // for camera capture

// final int[] towardsList = {0x1228, 0x0690};
// int towards = 0x1228; // the target marker that the ball flies towards
int towardscnt = 0;   // if ball reached, +1 to change the target

final int[] towardsList = {0x005A, 0x0272};
int towards = 0x005A;

final float GA = 9.80665;

PVector lookVector;
PVector pos;
PVector posarr;
int stop=0;
float anglez=0;
float wz=0.1;
float pos1=0;
float v=1;
int test=1;

final int totalFrame = 30;
final int totalFrameArr = 30;
final float snowmanSize = 0.020;
int frameCnt = 0;
int frameArr = 0;

HashMap<Integer, PMatrix3D> markerPoseMap;

MarkerTracker markerTracker;
PImage img;
PShape  man;

KeyState keyState;


void selectCamera() {
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default");
    cap = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    //cap = new Capture(this, cameras[5]);

    // Or, the settings can be defined based on the text in the list
    cap = new Capture(this, 1280, 720, "USB2.0 HD UVC WebCam", 30);
  }
}

void settings() {
  if (USE_SAMPLE_IMAGE) {
    // Here we introduced a new test image in Lecture 6 (20/05/27)
    size(1280, 720, P3D);
    opencv = new OpenCV(this, "./marker_test2.jpg");
    // size(1000, 730, P3D);
    // opencv = new OpenCV(this, "./marker_test.jpg");
  } else {
    if (USE_DIRECTSHOW) {
      dcap = new DCapture();
      size(dcap.width, dcap.height, P3D);
      opencv = new OpenCV(this, dcap.width, dcap.height);
    } else {
      selectCamera();
      size(cap.width, cap.height, P3D);
      opencv = new OpenCV(this, cap.width, cap.height);
    }
  }
}

void setup() {
  background(0);
  smooth();

  markerTracker = new MarkerTracker(kMarkerSize);

  if (!USE_DIRECTSHOW)
    cap.start();

  // Align the camera coordinate system with the world coordinate system
  PMatrix3D cameraMat = ((PGraphicsOpenGL)g).camera;
  cameraMat.reset();

  keyState = new KeyState();

  pos = new PVector(); 
  posarr =new PVector();
  markerPoseMap = new HashMap<Integer, PMatrix3D>();  // hashmap (code, pose)
    man = loadShape("man.obj");
}


void draw() {
  ArrayList<Marker> markers = new ArrayList<Marker>();
  markerPoseMap.clear();

  if (!USE_SAMPLE_IMAGE) {
    if (USE_DIRECTSHOW) {
      img = dcap.updateImage();
      opencv.loadImage(img);
    } else {
      if (cap.width <= 0 || cap.height <= 0) {
        println("Incorrect capture data. continue");
        return;
      }
      opencv.loadImage(cap);
    }
  }

  // use orthographic camera to draw images and debug lines
  // translate matrix to image center
  ortho();
  pushMatrix();
    translate(-width/2, -height/2,-(height/2)/tan(radians(fov)));
    markerTracker.findMarker(markers);
  popMatrix();

  // use perspective camera
  perspective(radians(fov), float(width)/float(height), 0.01, 1000.0);

  // setup light
  // (cf. drawSnowman.pde)
  ambientLight(180, 180, 180);
  directionalLight(180, 150, 120, 0, 1, 0);
  lights();

  // for each marker, put (code, matrix) on hashmap 
  for (int i = 0; i < markers.size(); i++) {
    Marker m = markers.get(i);
    markerPoseMap.put(m.code, m.pose);
  }
    int s=markerPoseMap.size()-1;  
    Set<Integer> codeset=markerPoseMap.keySet();
    Object[] codearr =codeset.toArray();
    Arrays.sort(codearr);
//MANUAL CONTROL TRIIGER,ACHER,TARGET
    if(s==-1);
    else if(s==0){//one Marker stand
      PMatrix3D pose_this=markerPoseMap.get(codearr[0]);
      archer(pose_this,160.5);
    }
    else{
      if (MANUAL){//if we have only 2 markers then the target will also be trigger
        PMatrix3D pose_this=markerPoseMap.get(codearr[0]);
        PMatrix3D pose_target=markerPoseMap.get(codearr[s]);
        PMatrix3D pose_trigger=markerPoseMap.get(codearr[1]);
        float diss=distanceM(pose_trigger,pose_this);
        //target
        pushMatrix();
          applyMatrix(pose_target);
          noStroke();
          fill(0, 0, 255);
          box(0.01);
        popMatrix();
        //trigger
        pushMatrix();
        applyMatrix(pose_trigger);
          noStroke();
          fill(255, 0, 0);
          sphere(0.005);
        popMatrix();
        //control if dis between archer and trigger<0.1 then shot the arrow
        if(diss<0.1){
          pushMatrix();
            applyMatrix(pose_this);
            rotateZ(160.5);
            scale(0.001,0.001, 0.001);
            rotateX(180.5);
            shape(man);
            translate(-pos1, 0, 0);
            noStroke();
            fill(123, 123, 0);
            arrow();
          popMatrix();
          pos1+=v;
        }
        else{
          archer(pose_this,anglez);
            anglez+=wz;
        }
      }else{
        PMatrix3D pose_this=markerPoseMap.get(codearr[0]);
        PMatrix3D pose_target=markerPoseMap.get(codearr[s]);
        pushMatrix();
            applyMatrix(pose_target);
            noStroke();
            fill(0, 0, 255);
            box(0.01);
        popMatrix();
        //two Marker, then shot the arrow
        if (s==1){
          float angle = rotateToMarker(pose_this, pose_target);
          PVector disVector = new PVector();
          disVector.x = pose_target.m03 - pose_this.m03;
          disVector.y = pose_target.m13 - pose_this.m13;
          disVector.z = pose_target.m23 - pose_this.m23;
          float dis = disVector.mag();
          pos.x = frameCnt * dis / totalFrame;
          pushMatrix();
            applyMatrix(pose_this);
            rotateZ(angle);
            rotateZ(160.5);
            scale(0.001,0.001, 0.001);
            rotateX(180.5);
            shape(man);
            translate(-1000*pos.x, pos.y, pos.z);
            noStroke();
            fill(123, 123, 0);
            arrow();
          popMatrix();
          frameCnt++;
          if (frameCnt == totalFrameArr) {
                pos = new PVector();
                frameCnt = 0;
              }
          }// more than 3 markers,find the most close Marker to target, then move to it and shot the arrow
        else{
          //find max ID and min ID marker
          float mindis=100000;
          int minMarkerID=1;
          for(int i=1;i<s;i++){
              PMatrix3D p=markerPoseMap.get(codearr[i]);
              PVector v = new PVector();
              v.x = p.m03 - pose_this.m03;
              v.y = p.m13 - pose_this.m13;
              v.z = p.m23 - pose_this.m23;
              float pLen = v.mag();
              if(pLen<mindis){
                mindis=pLen;
                minMarkerID=i;
              }
          }
          PMatrix3D pose_dest=markerPoseMap.get(codearr[minMarkerID]);

          float angle = rotateToMarker(pose_this, pose_dest);
          float dis=distanceM(pose_dest,pose_this);
          float angle1 = rotateToMarker(pose_dest, pose_target);
          float dArr=distanceM(pose_dest,pose_target);

          if(stop==0){
            pos.x = frameCnt * dis / totalFrame;
            //pos.z = disVector.z*frameCnt;
            pushMatrix();
              applyMatrix(pose_this);
              rotateZ(angle);
              rotateZ(160.3);
              translate(-pos.x, pos.y, pos.z);
              scale(0.001,0.001, 0.001);
              rotateX(180.5);
              shape(man);
              noStroke();
              fill(123, 123, 0);
              arrow();
            popMatrix();
            frameCnt++;
            if (frameCnt == totalFrame) {
              pos = new PVector();
              frameCnt = 0;
              stop=1;
            }
          }
          else{
            posarr.x = frameArr * dArr / totalFrameArr;
            //float ang= frameArr * anglez / totalFrameArr;
              pushMatrix();
                applyMatrix(pose_dest);
                rotateZ(angle1);
                rotateZ(160.5);
                scale(0.001,0.001, 0.001);
                rotateX(180.5);
                shape(man);
                translate(-1000*posarr.x, posarr.y, posarr.z);
                noStroke();
                fill(123, 123, 0);
                arrow();
              popMatrix();
              frameArr++;
            if (frameArr == totalFrameArr) {
              posarr = new PVector();
              frameArr = 0;
              stop=0;
            }
          }      
        }        
      }
    }

  noFill();
  strokeWeight(3);
  stroke(255, 0, 0);
  line(0, 0, 0, 0.02, 0, 0); // draw x-axis
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 0.02, 0); // draw y-axis
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 0.02); // draw z-axis

  noLights();
  keyState.getKeyEvent();

  System.gc();
}

void captureEvent(Capture c) {
  PGraphics3D g;
  if (!USE_DIRECTSHOW && c.available())
      c.read();
}


float rotateToMarker(PMatrix3D thisMarker, PMatrix3D lookAtMarker) {
  PVector relativeVector = new PVector();
  relativeVector.x = lookAtMarker.m03 - thisMarker.m03;
  relativeVector.y = lookAtMarker.m13 - thisMarker.m13;
  relativeVector.z = lookAtMarker.m23 - thisMarker.m23;
  float relativeLen = relativeVector.mag();

  relativeVector.normalize();

  float[] defaultLook = {1, 0, 0, 0};
  lookVector = new PVector();
  lookVector.x = thisMarker.m00 * defaultLook[0];
  lookVector.y = thisMarker.m10 * defaultLook[0];
  lookVector.z = thisMarker.m20 * defaultLook[0];

  lookVector.normalize();

  float angle = PVector.angleBetween(relativeVector, lookVector);
  if (relativeVector.x * lookVector.y - relativeVector.y * lookVector.x < 0)
    angle *= -1;

  return angle;
}

