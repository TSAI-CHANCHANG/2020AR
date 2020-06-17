void manual_control(PMatrix3D pose_this,PMatrix3D pose_target,PMatrix3D pose_trigger,float pos,float v,float anglez,float wz){
    PVector disV = new PVector();
    disV.x = pose_trigger.m03 - pose_this.m03;
    disV.y = pose_trigger.m13 - pose_this.m13;
    disV.z = pose_trigger.m23 - pose_this.m23;
    float diss = disV.mag();
    pushMatrix();
        applyMatrix(pose_target);
        noStroke();
        fill(0, 0, 255);
        box(0.01);
    popMatrix();
    pushMatrix();
        applyMatrix(pose_trigger);
        noStroke();
        fill(255, 0, 0);
        sphere(0.005);
    popMatrix();
    if(diss<0.01){
        pushMatrix();
            applyMatrix(pose_this);
            rotateZ(160.5);
            scale(0.001,0.001, 0.001);
            rotateX(180.5);
            shape(man);
            translate(-pos, 0, 0);
            noStroke();
            fill(123, 123, 0);
            arrow();
        popMatrix();
            pos+=v;
    }
    else{
        pushMatrix();
            applyMatrix(pose_this);
            rotateZ(-anglez);
            rotateZ(160.5);
            scale(0.001,0.001, 0.001);
            rotateX(180.5);
            shape(man);
            noStroke();
            fill(123, 123, 0);
            arrow();
        popMatrix();
      anglez+=wz;            
      }
}
 void archer(PMatrix3D pose_this,float anglez){
    pushMatrix();
        applyMatrix(pose_this);
        rotateZ(-anglez);
        rotateZ(160.5);
        scale(0.001,0.001, 0.001);
        rotateX(180.5);
        shape(man);
        noStroke();
        fill(123, 123, 0);
        arrow();
    popMatrix();
 }

 float distanceM(PMatrix3D pose_dest,PMatrix3D pose_this){
     PVector disVector = new PVector();
    disVector.x = pose_dest.m03 - pose_this.m03;
    disVector.y = pose_dest.m13 - pose_this.m13;
    disVector.z = pose_dest.m23 - pose_this.m23;
    float dis = disVector.mag();
    return dis;
 }