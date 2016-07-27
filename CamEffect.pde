/**
*
* by Zappi, 2014
*
**/
import controlP5.*;
import gab.opencv.*;
import java.awt.*;
import processing.video.*;
Capture webcam;
OpenCV opencv;
ControlP5 cp5;
Knob Knob;
int type = 0, k = 10, n = 256, w = 320, h = 240;
PImage img;

void setup(){
  size(w,h);
  webcam = new Capture(this,w,h); 
  webcam.start();
  opencv = new OpenCV(this,w,h);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
  cp5 = new ControlP5(this);
  customize(cp5.addDropdownList("Effect").setPosition(0,18).setSize(200,200));
  Knob = cp5.addKnob("Value").setRange(0,255).setValue(10).setPosition(width-62,2).setRadius(30).setDragDirection(Knob.HORIZONTAL).setVisible(false);
}

void draw(){
  if(webcam.available()){
    webcam.read();
    if(type == 0) img = webcam; 
    else if(type == 1) img = makeToBp(webcam);
    else if(type == 2) img = makeToBpF(webcam);
    else if(type == 3) img = makeToReplication(makeToBpF(webcam));
    else if(type == 4) img = grayImg(webcam);
    else if(type == 5) img = sepia(webcam);
    else if(type == 6) img = makeToColor(webcam,0);
    else if(type == 7) img = makeToColor(webcam,1);
    else if(type == 8) img = makeToColor(webcam,2);
    else if(type == 9) img = reverseImg(webcam);
    else if(type == 10) img = mirror(webcam);
    else if(type == 11) img = normaliz(quantizationUniform(webcam,k,n));
    else if(type == 12) img = normaliz(quantizationNonUniform(webcam,k,n));
    else if(type == 13) img = binarization(webcam);
    Knob.setVisible(((type >= 0 && type<=10) ? false : true));
    image(img,0,0);
    noFill();
    stroke(0,255,0);
    strokeWeight(2);
    opencv.loadImage(img);
    Rectangle[] faces = opencv.detect();
    for(int i=0;i<faces.length;i++) rect(faces[i].x,faces[i].y,faces[i].width,faces[i].height,14,14,14,14);
  }
}

void customize(DropdownList ddl){
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(18);
  ddl.captionLabel().set("Effect");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  ddl.addItem("Normal",0);
  ddl.addItem("Bayer Pattern",1);
  ddl.addItem("Bayer Pattern False",2);
  ddl.addItem("Replication",3);
  ddl.addItem("Gray",4);
  ddl.addItem("Sepia",5);
  ddl.addItem("Red",6);
  ddl.addItem("Green",7);
  ddl.addItem("Blue",8);
  ddl.addItem("Reverse",9);
  ddl.addItem("Mirror",10);
  ddl.addItem("Quantization Uniform",11);
  ddl.addItem("Quantization Non Uniform",12);
  ddl.addItem("Binarizzazione",13);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255,128));
}

void controlEvent(ControlEvent e){
  if(e.isGroup()) type = (int)e.getGroup().getValue(); 
}

int Index(int i,int j,PImage source){ return j+(i*source.width); }
float log2(float x){ return (log(x)/log(2)); }
float truncate(float x,int digits){
  int d = (int)pow(10,digits);
  return int(x*d)/d;
}
float[] minImage(PImage source){
  float min[] = { red(source.pixels[0]), green(source.pixels[0]), blue(source.pixels[0]) };
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
       int loc = Index(i,j,source);
       if(min[0] > red(source.pixels[loc]) && min[1] > green(source.pixels[loc]) && min[2] > blue(source.pixels[loc])){
         min[0] = red(source.pixels[loc]);
         min[1] = green(source.pixels[loc]);
         min[2] = blue(source.pixels[loc]);
       }
    }
  }
  return min;
}
float[] maxImage(PImage source){
  float max[] = { red(source.pixels[0]), green(source.pixels[0]), blue(source.pixels[0]) };
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
       int loc = Index(i,j,source);
       if(max[0] < red(source.pixels[loc]) && max[1] < green(source.pixels[loc]) && max[2] < blue(source.pixels[loc])){
         max[0] = red(source.pixels[loc]);
         max[1] = green(source.pixels[loc]);
         max[2] = blue(source.pixels[loc]);
       }
    }
  }
  return max;
}
PImage normaliz(PImage source){
  float[] min = minImage(source);
  float[] max = maxImage(source);
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      float r = ceil(((red(source.pixels[loc])-min[0])/(max[0]-min[0]))*255);
      float g = ceil(((green(source.pixels[loc])-min[1])/(max[1]-min[1]))*255);
      float b = ceil(((blue(source.pixels[loc])-min[2])/(max[2]-min[2]))*255);
      destination.pixels[loc] = color(r,g,b);
    }
  }
  destination.updatePixels();
  return destination;
}
void Value(int theValue){ k = theValue; } 
color TransformColorToSepia(color inputColor){
  int outputRed = (int)((red(inputColor) * .393) + (green(inputColor) * .769) + (blue(inputColor) * .189));
  int outputGreen = (int)((red(inputColor) * .349) + (green(inputColor) * .686) + (blue(inputColor) * .168));
  int outputBlue = (int)((red(inputColor) * .272) + (green(inputColor) * .534) + (blue(inputColor) * .131));
  color outputColor = color(((outputRed < 255) ? outputRed : 255), ((outputGreen < 255) ? outputGreen : 255), ((outputBlue < 255) ? outputBlue : 255)); 
  return outputColor; 
}

PImage makeToBp(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int v, loc = Index(i,j,source);
      if((i%2 == 0 && j%2 == 0) || (i%2 != 0 && j%2 != 0)) v = (int)green(source.pixels[loc]);
      else if(i%2 != 0 && j%2 == 0) v = (int)blue(source.pixels[loc]);
      else v = (int)red(source.pixels[loc]);
      destination.pixels[loc] = color(v);
    }
  }
  destination.updatePixels();
  return destination;
}

PImage makeToBpF(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      float kr = 0, kg = 0, kb = 0;
      if((i%2 == 0 && j%2 == 0) || (i%2 != 0 && j%2 != 0)) kg = green(source.pixels[loc]);
      else if(i%2 != 0 && j%2 == 0) kb = blue(source.pixels[loc]);
      else kr = red(source.pixels[loc]);
      destination.pixels[loc] = color(kr,kg,kb);
    }
  }
  destination.updatePixels();
  return destination;
}

PImage makeToColor(PImage source,int type){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      float kr = 0, kg = 0, kb = 0;
      if((i%2 == 0 && j%2 == 0) || (i%2 != 0 && j%2 != 0)) kg = green(source.pixels[loc]);
      else if(i%2 != 0 && j%2 == 0) kb = blue(source.pixels[loc]);
      else kr = red(source.pixels[loc]);
      if(type == 0) destination.pixels[loc] = color(kr,0,0);
      if(type == 1) destination.pixels[loc] = color(0,kg,0);
      if(type == 2) destination.pixels[loc] = color(0,0,kb);
    }
  }
  destination.updatePixels();
  return destination;
}

PImage makeToReplication(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      
      int loc = Index(i,j,source);
        
        if(i%2 == 0){
            
            if(j%2 == 0){
              if(i < source.height-1 && j < source.width-1)
                destination.pixels[Index(i,j,source)] = color(red(source.pixels[Index(i,j+1,source)]), green(source.pixels[loc]), blue(source.pixels[Index(i+1,j,source)]));
              else if(i == source.height-1 && j < source.width-1)
                destination.pixels[Index(i,j,source)] = color(red(source.pixels[Index(i,j+1,source)]), green(source.pixels[loc]), blue(source.pixels[Index(i-1,j,source)]));
              else if(j < source.width-1)
                destination.pixels[Index(i,j,source)] = color(red(source.pixels[Index(i,j-1,source)]), green(source.pixels[loc]), blue(source.pixels[Index(i-1,j,source)]));
            }else
                destination.pixels[Index(i,j,source)] = color(red(source.pixels[loc]), green(source.pixels[Index(i,j-1,source)]), blue(source.pixels[Index(i+1,j-1,source)]));
          
        }else{
          
           if(j%2 == 0 && j < source.width-1)
             destination.pixels[Index(i,j,source)] = color(red(source.pixels[Index(i-1,j+1,source)]), green(source.pixels[Index(i,j+1,source)]), blue(source.pixels[loc])); 
           else
             destination.pixels[Index(i,j,source)] = color(red(source.pixels[Index(i-1,j,source)]), green(source.pixels[loc]), blue(source.pixels[Index(i,j-1,source)])); 
          
        }
    
    }
  }
  destination.updatePixels();
  return destination;
}

PImage grayImg(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
       int loc = Index(i,j,source);
       float r = red(source.pixels[loc]);
       float g = green(source.pixels[loc]);
       float b = blue(source.pixels[loc]);
       destination.pixels[loc] = color(0.2989*r+0.5870*g+0.1140*b);
    }
  }
  destination.updatePixels();
  return destination;
}

PImage sepia(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      destination.pixels[loc] = color(TransformColorToSepia(source.pixels[loc]));
    }
  }
  destination.updatePixels();
  return destination;
}

PImage quantizationUniform(PImage source,int k,int n){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      float r = (red(source.pixels[loc])*k)/n;
      float g = (green(source.pixels[loc])*k)/n;
      float b = (blue(source.pixels[loc])*k)/n;
      destination.pixels[loc] = color(r,g,b);
    }
  }
  destination.updatePixels();
  return destination;
}

PImage quantizationNonUniform(PImage source,int k,int n){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      float r = (log2(red(source.pixels[loc]))*k)/log2(n);
      float g = (log2(green(source.pixels[loc]))*k)/log2(n);
      float b = (log2(blue(source.pixels[loc]))*k)/log2(n);
      destination.pixels[loc] = color(r,g,b);
    }
  }
  destination.updatePixels();
  return destination;
}

PImage reverseImg(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.pixels.length;i++)
    destination.pixels[source.pixels.length-i-1] = source.pixels[i];
  destination.updatePixels();
  return destination;
}

PImage mirror(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.height;i++){
    for(int j=0;j<source.width;j++){
      int loc = Index(i,j,source);
      destination.pixels[(i+1)*source.width-j-1] = source.pixels[loc];
    }
  }
  destination.updatePixels();
  return destination;
}

PImage binarization(PImage source){
  PImage destination = createImage(source.width,source.height,RGB);
  for(int i=0;i<source.pixels.length;i++)
//  destination.pixels[i] = color(red(source.pixels[i])-25,green(source.pixels[i])-32,blue(source.pixels[i])-39);
    destination.pixels[i] = ((source.pixels[i] >= color(k)) ? color(255) : color(0));
  return destination;
}

void keyPressed(){
  if(key == '5') saveFrame("photo_"+year()+month()+day()+hour()+minute()+second()+".png");
}
