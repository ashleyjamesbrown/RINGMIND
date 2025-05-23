/**Render System Global Variables //<>// //<>//
 */
Renderer renderer;
PGraphics pg;
RenderContext renderContext;
PShader offscreenShader;

boolean useAdditiveBlend = false;
boolean useTrace = false;
boolean useFilters = false;
boolean GhostMoon = false;
int traceAmount=70;

/** 
 */
void renderSetup() {
  //Renderer Object
  renderer = new Renderer();
  renderer.withMoon = true;
  //PGraphics Object
  pg = createGraphics(1024, 1024, P3D);
  //RenderContext Object
  renderContext = new RenderContext();
  renderContext.pgfx = this;
  renderContext.shader = loadShader("texfrag.glsl", "texvert.glsl");
  renderContext.mat.spriteTexture = loadImage("partsmall.png");
  renderContext.mat.diffTexture = pg;
  renderContext.mat.strokeColor = 255;
  //PShader Object
  offscreenShader = loadShader("cloudy.glsl");
  //LOAD CUSTOM FILTERS
  loadFilters();
}

/**default overlay render without shader
 */
void renderOffScreenOnPGraphicsClean() {
  pg.beginDraw();
  pg.background(255, 255, 255); //no shader diffuse texture over the top
  pg.endDraw();
}

/**default overlay render using shader
 */
void renderOffScreenOnPGraphics() {
  pg.beginDraw();
  pg.shader(offscreenShader);
  offscreenShader.set("resolution", float(pg.width), float(pg.height));
  offscreenShader.set("time", float(millis()));
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
}

/**a little keyhole example
 */
void renderOffScreenOnPGraphics2() {
  pg.beginDraw();
  pg.background(0, 0, 0);
  //pg.stroke(255);
  //pg.fill(255);
  //pg.strokeWeight(100);
  //pg. line(0,0,pg.wdith,pg.height);

  //pg.ellipse(mouseX, mouseY, 200, 200);
  pg.endDraw();
}

/** Class Renderer
 * @author ashley james brown
 * @author Thomas Cann
 */
class Renderer {

  boolean withMoon = true;
  float scale=System.SCALE; 


  /**Render Method
   *@param s Particle System to render.
   *@param ctx 
   *@param renderType
   */
  void render(System s, RenderContext ctx, int renderType) {
    PGraphicsOpenGL pg = (PGraphicsOpenGL) ctx.pgfx.g;
    
    if (s instanceof ResonantSystem) {
      ResonantSystem Rs =  (ResonantSystem)s;
      RingSystem rs = Rs.rs;
      MoonSystem ms = Rs.ms;
      push();
      shader(ctx.shader, POINTS);

      Material mat = RingMat1;
      if (mat == null) {
        mat = ctx.mat;
      }
      stroke(mat.strokeColor, mat.partAlpha);
      strokeWeight(mat.strokeWeight);

      ctx.shader.set("weight", mat.partWeight);
      ctx.shader.set("sprite", mat.spriteTexture);
      ctx.shader.set("diffTex", mat.diffTexture);
      ctx.shader.set("view", pg.camera); //don't touch that :-)


      if (renderType==1) {
        beginShape(POINTS);
      } else {
        beginShape(LINES);
      }
      for (int ringI = 0; ringI < rs.particles.size(); ringI++) {
        Particle p = rs.particles.get(ringI);
        vertex(scale*p.position.x, scale*p.position.y, scale*p.position.z);
      }
      endShape();

      pop();

      if (withMoon) {
        ellipseMode(CENTER);
        push();
        for (Particle p : ms.particles) {

          Moon m=(Moon)p;
          pushMatrix();
          //translate(width/2, height/2);
          fill(m.c);
          stroke(m.c);
          //strokeWeight(m.radius*scale);
          //strokeWeight(10);

          //beginShape(POINTS);
          translate(scale*m.position.x, scale*m.position.y, 0);
          sphere(m.radius*scale);
          //vertex(scale*m.position.x, scale*m.position.y, 2*m.radius*scale);
          //endShape();
          // circle(scale*position.x, scale*position.y, 2*radius*scale);
          popMatrix();
        }
        pop();
      }
    }else if (s instanceof RingmindSystem) {
      //--------------------------------------------RingSystemRender-------------------------------------------------- 
      RingmindSystem rms = (RingmindSystem)s;
      RingSystem rs = rms.rs;
      MoonSystem ms = rms.ms;
      push();
      shader(ctx.shader, POINTS);

      for (int i = 0; i < rs.rings.size(); i++) {
        Ring r = rs.rings.get(i);
        Material mat = r.material;
        if (mat == null) {
          mat = ctx.mat;
        }
        stroke(mat.strokeColor, mat.partAlpha);
        strokeWeight(mat.strokeWeight);

        ctx.shader.set("weight", mat.partWeight);
        ctx.shader.set("sprite", mat.spriteTexture);
        ctx.shader.set("diffTex", mat.diffTexture);
        ctx.shader.set("view", pg.camera); //don't touch that :-)


        if (renderType==1) {
          beginShape(POINTS);
        } else {
          beginShape(LINES);
        }
        for (int ringI = 0; ringI < r.getMaxRenderedParticle(); ringI++) {
          RingParticle p = r.particles.get(ringI);
          vertex(scale*p.position.x, scale*p.position.y, scale*p.position.z);
        }
        endShape();
      }
      pop();

      if (withMoon) {
        ellipseMode(CENTER);
        push();
        for (Particle p : ms.particles) {

          Moon m=(Moon)p;
          pushMatrix();
          //translate(width/2, height/2);
          fill(m.c);
          stroke(m.c);
          //strokeWeight(m.radius*scale);
          strokeWeight(1);

          //beginShape(POINTS);
          translate(scale*m.position.x, scale*m.position.y, 0);
          sphere(m.radius*scale);
          //vertex(scale*m.position.x, scale*m.position.y, 2*m.radius*scale);
          //endShape();
          // circle(scale*position.x, scale*position.y, 2*radius*scale);
          popMatrix();
        }
        pop();
      }
    } else if (s instanceof ShearSystem) {
      //--------------------------------------------ShearSystemRender--------------------------------------------------

      //println("TEST");
      ShearSystem ss = (ShearSystem)s;
      push();
      shader(ctx.shader, POINTS);

      Material mat = ss.material;
      if (mat == null) {
        mat = ctx.mat;
      }

      stroke(mat.strokeColor, mat.partAlpha);
      strokeWeight(mat.strokeWeight);

      ctx.shader.set("weight", mat.partWeight);
      ctx.shader.set("sprite", mat.spriteTexture);
      ctx.shader.set("diffTex", mat.diffTexture);
      ctx.shader.set("view", pg.camera); //don't touch that :-)

      //beginShape(POINTS);
      //for (int PP = 0; PP < ss.particles.size(); PP++) {
      //  ShearParticle sp = (ShearParticle)ss.particles.get(PP);

      //  fill(255);
      //  stroke(255);
      //  vertex(-sp.position.y*width/ss.Ly, -sp.position.x*height/ss.Lx, 2*scale*sp.radius*width/ss.Ly, 2*scale*sp.radius*height/ss.Lx);
      //}
      
      //endShape();
      pop();
      
      
     

      
      for (int PP = 0; PP < ss.particles.size(); PP++) {
        
        //Assigns a colour to particles that origonate on each of these band along the x axis
        // fill() determines the colour by fill(Red,Green,Blue) 
           ShearParticle sp = (ShearParticle)ss.particles.get(PP);
          fill(255);//White
          if(sp.InitPosition.x > ss.Lx/3){
          fill(225,0,255);//Purple
          }else if(sp.InitPosition.x > ss.Lx/6 && sp.InitPosition.x <= ss.Lx/3){
          fill(0,100,255);//Blue     
          }else if(sp.InitPosition.x > 0  && sp.InitPosition.x <= ss.Lx/6){
          fill(0,255,0);//Green
          }else if(sp.InitPosition.x >= -ss.Lx/6 && sp.InitPosition.x < 0){
          fill(255,255,0);//Yellow        
          }else if(sp.InitPosition.x >= -ss.Lx/3 && sp.InitPosition.x < -ss.Lx/6){
          fill(255,128,0);//Orange
          }else if(sp.InitPosition.x < -ss.Lx/3){
          fill(255,0,0);//Red
          }
          
          if(Toggle3D){
            //Renders low poly spheres
            push();
          translate(-sp.position.y*width/ss.Ly, -sp.position.x*height/ss.Lx, sp.position.z);
          sphereDetail(6);
          sphere(sp.radius*width/ss.Ly);      
            pop();
          }else{
            //Renders 2D circles
            ellipse(-sp.position.y*width/ss.Ly, -sp.position.x*height/ss.Lx, 2*sp.radius*width/ss.Ly, 2*sp.radius*height/ss.Lx);      
          }
      }

      
      if (ss.Guides) {
        //Renders the velocities and accelerations for particles
        //Has not been updated to work in 3D
        for (int PP = 0; PP < ss.particles.size(); PP++) {
          ShearParticle sp = (ShearParticle)ss.particles.get(PP);
          //ss.displayPosition(sp.position, 1, color(255, 0, 0));
          push();
          translate(-sp.position.y*width/ss.Ly, -sp.position.x*height/ss.Lx, 0);
          //circle(0, 0, 2*scale*sp.radius*width/ss.Ly);
          ss.displayPVector(sp.velocity, 1000, color(0, 255, 0)); //green
          ss.displayPVector(sp.acceleration, 10000000, color(0 , 0, 255)); //blue
          pop();
        }
      }
      //moonlet
      if (Moonlet) {
        fill(255);//Grey
        if(Toggle3D){
          //Renders 3D moonlet
          pushMatrix();
          lights();
          translate(-ss.moonlet.position.y*width/ss.Ly, -ss.moonlet.position.x*height/ss.Lx, ss.moonlet.position.z);
          sphereDetail(60);
          sphere(ss.moonlet.radius*width/ss.Ly);
          popMatrix();
        }else{
          //Renders 2D Moonlet
        ellipse(-ss.moonlet.position.y*width/ss.Ly, -ss.moonlet.position.x*height/ss.Lx, 2*ss.moonlet.radius*width/ss.Ly, 2*ss.moonlet.radius*height/ss.Lx);    
        }
    }
    
    //Adds a texture to the moonlet, slows things down a lot and doesn't look that good anyway 
    //pushMatrix();
    //fill(255);
    //sphereDetail(10);
    //PImage moonTexture;
    //PShape Moon;
    //moonTexture = loadImage("plutomap1k.jpg");
    //Moon = createShape(SPHERE, 200);
    //Moon.setTexture(moonTexture);
    //shape(Moon);
    //popMatrix();
    
      
    } else if (s instanceof TiltSystem) {
      //--------------------------------------------TiltSystemRender--------------------------------------------------
      push();
      shader(ctx.shader, POINTS);
      TiltSystem r = (TiltSystem)s;
      //Ring r = rs.rings.get(0);
      // Ring r = rs.rings.get(i);

      Material mat = r.material;
      if (mat == null) {
        mat = ctx.mat;
      }

      stroke(mat.strokeColor, mat.partAlpha);
      strokeWeight(mat.strokeWeight);

      ctx.shader.set("weight", mat.partWeight);
      ctx.shader.set("sprite", mat.spriteTexture);
      ctx.shader.set("diffTex", mat.diffTexture);
      ctx.shader.set("view", pg.camera); //don't touch that :-)

      beginShape(POINTS);
      for (int ringI = 0; ringI < r.particles.size(); ringI++) {
        TiltParticle tp = (TiltParticle)r.particles.get(ringI);
        PVector position1 = tp.displayRotate();
        vertex(scale*position1.x, scale*position1.y, scale*position1.z);
      }
      endShape();

      pop();
    }
  }

  /**Render Method
   *@param s Particle System to render.
   *@param ctx 
   *@param renderType
   */
  void renderComms(System s, RenderContext ctx, int renderType) {
    PGraphicsOpenGL pg = (PGraphicsOpenGL) ctx.pgfx.g;
    RingmindSystem rms= (RingmindSystem)s;
    push();
    shader(ctx.shader, POINTS);

    Ring r = rms.rs.rings.get(0);
    // Ring r = rs.rings.get(i);

    Material mat = r.material;
    if (mat == null) {
      mat = ctx.mat;
    }

    stroke(mat.strokeColor, mat.partAlpha);
    strokeWeight(mat.strokeWeight);

    ctx.shader.set("weight", mat.partWeight);
    ctx.shader.set("sprite", mat.spriteTexture);
    ctx.shader.set("diffTex", mat.diffTexture);
    ctx.shader.set("view", pg.camera); //don't touch that :-)


    //now lets go through all those particles and see if they are near to another and draw lines between them

    //stroke(255);
    //strokeWeight(10);
     if (renderType==1) {
       beginShape(LINES);
      } else {
       beginShape(POINTS);
      }
    
    for (int i=0; i <1000; i++) {
      RingParticle rp = (RingParticle) r.particles.get(i);
      float distance=0;
      for (int j=0; j <3000; j++) {
        RingParticle rpj = (RingParticle) r.particles.get(j);
        distance = dist(scale*rp.position.x, scale*rp.position.y, scale*rpj.position.x, scale*rpj.position.y);
        if (distance < 20) {
          vertex(scale*rp.position.x, scale*rp.position.y);
          vertex(scale*rpj.position.x, scale*rpj.position.y);
        }
      }
    }
    endShape();

    pop();
  }
}

//----------------------------------------------------------------------------------------

/** Class RenderContext - what it is going to render (material and shader) and where (PApplet - sketch).
 * @author ashley james brown march-may.2019
 */
class RenderContext {
  RenderContext() {
    mat = new Material();
  }
  PShader shader;
  Material mat;
  PApplet pgfx;
}

//-----------------------------------------------------------------------------------------
/**
 *Custom Shaders for filter effects
 */
PShader gaussianBlur, metaBallThreshold;

/** Configures Filters
 */
void loadFilters() {

  // Load and configure the filters
  gaussianBlur = loadShader("gaussianBlur.glsl");
  gaussianBlur.set("kernelSize", 32); // How big is the sampling kernel?
  gaussianBlur.set("strength", 7.0); // How strong is the blur?

  //maybe? gives a kind of metaball effect but only at certain angles
  metaBallThreshold = loadShader("threshold.glsl");
  metaBallThreshold.set("threshold", 0.5);
  metaBallThreshold.set("antialiasing", 0.05); // values between 0.00 and 0.10 work best
}

/** Applies Filters
 */
void applyFilters() {
  // Vertical blur pass
  gaussianBlur.set("horizontalPass", 0);
  filter(gaussianBlur);

  // Horizontal blur pass
  gaussianBlur.set("horizontalPass", 1);
  filter(gaussianBlur);

  //remove this for just a blurry thing without going to black and white but when backgroudn trails work could be glorious overly bright for teh abstract part
  // filter(metaBallThreshold); //this desnt work too well with depth rendering.
}

//-----------------------------------------------------------------------------------------

/** Class Material - represents a Material used to texture particles
 * @author ashley james brown march-may.2019
 */
class Material {
  PImage diffTexture;
  PImage spriteTexture;
  color strokeColor = 255;
  float partWeight = 1;      //do not change or sprite texture wont show unless its 1.
  float partAlpha = 0;       //trick to fade out to black.
  float strokeWeight = 1;    //usually 1 so we can see our texture but if we turn off we can make a smaller particle point as long as the weight above is bigger than 1.
}

/** Ring Particle Materials
 */
Material RingMat1, RingMat2, RingMat3, RingMat4, RingMat5, RingMat6;

/** Shearing Particle Material
 */
Material ShearMat1;

/** Method that assigns material objects to all the Material variables. 
 *  
 */
void createMaterials() {

  //----------- Materials for RingSystem ---------------

  // first ring material is the deafult material fully showing
  RingMat1 =  new Material();
  RingMat1.strokeColor = color(255, 255, 255);
  RingMat1.spriteTexture = loadImage("partsmall.png");
  RingMat1.diffTexture = pg;
  RingMat1.strokeWeight = 1; //.1;
  RingMat1.partWeight = 10;
  RingMat1.partAlpha=255;

  //pink
  // second ring material to be different just as proof of concept
  RingMat2 =  new Material();
  RingMat2.strokeColor = color(203, 62, 117);
  RingMat2.spriteTexture = loadImage("partsmall.png");
  RingMat2.diffTexture = pg;
  RingMat2.strokeWeight = 2.1;//.1
  RingMat2.partWeight = 10;
  RingMat2.partAlpha=255;

  // second ring material to be different just as proof of concept
  //more blue
  RingMat3 =  new Material();
  RingMat3.strokeColor = color(54, 73, 232);
  RingMat3.spriteTexture = loadImage("partsmall.png");
  RingMat3.diffTexture = pg;
  RingMat3.strokeWeight = 2.1;//.1
  RingMat3.partWeight = 10;
  RingMat3.partAlpha=255;

  RingMat4 =  new Material();
  RingMat4.strokeColor = color(204, 206, 153);
  RingMat4.spriteTexture = loadImage("partsmall.png");
  RingMat4.diffTexture = pg;
  RingMat4.strokeWeight = 2.1;//.1
  RingMat4.partWeight = 10;
  RingMat4.partAlpha=255;

  RingMat5 =  new Material();
  RingMat5.strokeColor = color(153, 21, 245);
  RingMat5.spriteTexture = loadImage("partsmall.png");
  RingMat5.diffTexture = pg;
  RingMat5.strokeWeight = 2.1;//.1
  RingMat5.partWeight = 10;
  RingMat5.partAlpha=255;

  RingMat6 =  new Material();
  RingMat6.strokeColor = color(24, 229, 234);
  RingMat6.spriteTexture = loadImage("partsmall.png");
  RingMat6.diffTexture = pg;
  RingMat6.strokeWeight = 2.1;//.1
  RingMat6.partWeight = 10;
  RingMat6.partAlpha=255;

  //----------- Materials for ShearSystem ---------------

  ShearMat1 =  new Material();
  ShearMat1.strokeColor = color(255, 255, 255);
  ShearMat1.spriteTexture = loadImage("partsmall.png");
  ShearMat1.diffTexture = pg;
  ShearMat1.strokeWeight = 2.1;//.1
  ShearMat1.partWeight = 10;
  ShearMat1.partAlpha=255;
}



//----------Palette-----------------
//#FEB60A,#FF740A,#D62B00,#A30000,#640100,#FEB60A,#FF740A,#D62B00
//fire
//153,21,245
//----------------------------------

//----------------------------CAMERA-------------------------------------------------------------

import remixlab.bias.*;
import remixlab.bias.event.*;
import remixlab.dandelion.constraint.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;
import remixlab.fpstiming.*;
import remixlab.proscene.*;
import remixlab.util.*;

Scene scene;

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void initScene() {

  scene = new Scene(this);
  // edit the json file for the starting view.
  // turn off the dispose method
  unregisterMethod("dispose", scene); //stops it autosaving the camera from where we last had it ech time and loads our default first bit of data for where we are looking

  scene.eyeFrame().setDamping(0.05); //0 is a little too rigid
  scene.eye().centerScene(); //center the entire scene

  scene.eye().setPosition(new Vec(0, 0, 0)); //center the eye
  scene.camera().lookAt(scene.center()); // point it at 0,0,0

  //load json file with predone camera paths.... 
  scene.loadConfig(); //this also laods how the camera looks when we startup the very beginning but we will overwrite by using the scenes to change that.

  //trun off debug guides
  scene.setGridVisualHint(false);
  scene.setAxesVisualHint(false);

  //must set scene to be big so it redners properly
  scene.setRadius(500); //how big is the scene - bigger means slower to load at startup

  scene.showAll();

}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// camera setups

// camera top down looking straight on down on the ring almost 2d from a zoom of 1000
void initCamera() {
  scene.camera().setOrientation(new Quat(0, 0, 0, 1));
  scene.camera().setPosition(new Vec(0, 0, 1000));
  scene.camera().setViewDirection(new Vec (0, 0, -1));
}

void zoomedCamera() {
  scene.camera().setOrientation(new Quat(0, 0, 0, 1));
  scene.camera().setPosition(new Vec(0, 0, 300));
  scene.camera().setViewDirection(new Vec (0, 0, -1));
}

void closerCamera() {
  scene.camera().setOrientation(new Quat(0, 0, 0, 1));
  scene.camera().setPosition(new Vec(0, 0, 670));
  scene.camera().setViewDirection(new Vec (0, 0, -1));
}

void toptiltCamera() {
  scene.camera().setOrientation(new Quat(-0.27797017, -0.8494466, -0.44852334));
  scene.camera().setPosition(new Vec(216.607, 262.6706, -178.04265));
  scene.camera().setViewDirection(new Vec (-0.50023884, -0.6601704, 0.5603001));
}

//zoomed far back distant view of ring system
void camera1() {
  scene.camera().setOrientation(new Quat(-0.95024925, -0.2884153, 0.11765616, 0.9159098));
  scene.camera().setPosition(new Vec(-800, 2100, 1800));
  scene.camera().setViewDirection(new Vec (0.2725, -0.7403, -0.61448));
}

//side tilt from the middle
void camera2() {
  scene.camera().setOrientation(new Quat(-0.9245066, 0.025740312, 0.38029608, 4.032707));
  scene.camera().setPosition(new Vec(-176, -208, 116));
  scene.camera().setViewDirection(new Vec (0.59, 0.703, -0.39));
}

//slightly angled from aboe the ring looking down
void camera3() {
  scene.camera().setOrientation(new Quat(-0.406788, -0.40678796, 0.817953, 1.7704078));
  scene.camera().setPosition(new Vec( -281.5827, 0.0, 212.75641));
  scene.camera().setViewDirection(new Vec ( 0.7974214, -5.960465E-8, -0.60342294));
}

//Zoomed out of Shearing box
void camera4() {
  scene.camera().setOrientation(new Quat(0.0, 0.0, 0.0, 0.0));
  scene.camera().setPosition(new Vec( 0.0, 0.0, 924.92285));
  scene.camera().setViewDirection(new Vec ( 0.0, 0.0, -1.0));
}

//left side rotated toward the camera straight in view
void camera6() {
  scene.camera().setOrientation(new Quat(0.071595766, -0.99373794, 0.08578421, 1.1399398));
  scene.camera().setPosition(new Vec(-342, -43, 160));
  scene.camera().setViewDirection(new Vec (0.8, 0.11, -0.42));
}

void camera9() {
  scene.camera().setOrientation(new Quat(-0.86009645, -0.5100075, -0.011246648, 1.7854911));
  scene.camera().setPosition(new Vec(-69.61055, 96.30619, -38.591106));
  scene.camera().setViewDirection(new Vec (0.48656437, -0.84730774, 0.21289584));

  //ideally translate for a better view
}

void camera10() {
  scene.camera().setOrientation(new Quat(-0.38721877, -0.87212867, 0.2990871, 2.547316));
  scene.camera().setPosition(new Vec(-85.0407, -32.172462, -231.61795));
  scene.camera().setViewDirection(new Vec (0.41859165, 0.43964458, 0.79466575 ));
}

void cameraChaos() {
  scene.camera().setOrientation(new Quat(0.40550593, -0.44041216, -0.80100065, 2.8794248));
  scene.camera().setPosition(new Vec(-525.04645, -798.2069, 295.27277 ));
  scene.camera().setViewDirection(new Vec (0.52437866, 0.79858387, -0.2954503));
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/** Method to Output Debug Information to Window Title Bar.
 */
void titleText() {
  String txt_fps;
  try {
    txt_fps = String.format(getClass().getSimpleName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f] [Time Elapsed in Seconds %d] [Simulation Time Elapsed in Hours %d]", width, height, frameCount, frameRate, int(millis()/1000.0), int(s.totalSystemTime/3600.0) );
  }
  catch(Exception e) {
    txt_fps = "";
  }
  surface.setTitle(txt_fps);
}

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-----------GUI---------------------

  Slider2D mm;
  float SliderScale = 1;

class ControlFrame extends PApplet{
  Boolean keepRingGap = false;
  String N = Integer.toString(n_particles);
  Textlabel LabelA; 




  int w, h;
  PApplet parent;

  public ControlFrame(PApplet _parent, int _w, int _h, String name){
    super();
    parent = _parent;
    w = _w;
    h = _h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  
  public void settings(){
  size(270,800);
  }
  
  public void setup(){
  PFont A = createFont("Verdana",9); 
  PFont B = createFont("Verdana",12); 
  PFont C = createFont("Verdana",8); 
  PFont D = createFont("Verdana",11); 
  
  ControlFont fontA = new ControlFont(A);  
  ControlFont fontB = new ControlFont(B);
  ControlFont fontC = new ControlFont(C);
  ControlFont fontD = new ControlFont(D);

  surface.setLocation(10,10);
  cp5 = new ControlP5(this);
  cp5.setFont(fontA);
  
  //PLAY
  
  cp5.addTextlabel("PLAY")
        .setPosition(115, 300)
        .setText("PLAY")
        .setFont(fontB)
        .setColorValue(0xff000000);
  
  //Slider to vary the orbital hight of the shearing box
  cp5.addSlider("Orbit Radius")
       .setRange(50000000, 300000000)
       .setValue(100000000)
       .setPosition(10, 330)
       .setSize(180, 20)
       .setColorLabel(0xff000000);
 
  
  //Slider to vary moonlet radius     
  cp5.addSlider("Moon Radius")
       //.plugTo(parent, "r0")
       .setRange(10, 300)
       .setValue(150)
       .setPosition(10, 360)
       .setSize(180, 20)
       .setColorLabel(0xff000000);
       
  //Slider to vary moonlet Density     
  cp5.addSlider("Moonlet Density")
        .setCaptionLabel("Moon Density")
        .setValue(1000)
        .setRange(0,10000)
        .setPosition(10,390)
        .setSize(180,20)
       .setColorLabel(0xff000000);
        
  //Slider to vary particle size
  cp5.addSlider("ParticleSize")
        .setCaptionLabel("Particle Size")
        .setRange(1,5)
        .setPosition(10,420)
        .setSize(180,20)
       .setColorLabel(0xff000000);
        
  // 2D slider that lets you pick of position on screen and for you to create a moonlet   
  mm = cp5.addSlider2D("MoonPosition")
         .setCaptionLabel("Moon Position")
         .setPosition(10,450)
         .setSize(250,125)
         .setMinMax(-1000,-500,1000,500)
         .setValue(0,0)
         .setFont(D)
         //.disableCrosshair()
       .setColorLabel(0xff000000)
       .setColorValue(0xff000000);
         
              
         //Turn moonlet on/off
  cp5.addButton("ToggleMoonlet")
        .setCaptionLabel("Toggle Moon")
        .setPosition(10, 610)
        .setSize(80, 50)  
        .setFont(fontA);
              
  //Creates a moonlet at position selected on the 2D slider; will remove old moonlet      
  cp5.addButton("CreateMoon")
        .setCaptionLabel("Create Moon")
        .setPosition(95, 610)
        .setSize(80, 50) 
        .setFont(fontA);

  //Resets the moonlet position and slider possition back to (0,0)       
  cp5.addButton("ResetMoon")
        .setCaptionLabel("Reset Moon")
        .setPosition(180,610)
        .setSize(80, 50)
        .setFont(fontA);

           
           // SETUP
  cp5.addTextlabel("Setup")
        .setPosition(110, 10)
        .setText("SETUP")
        .setFont(fontB)
        .setColorValue(0xff000000);
  
  //  //Half the dimensions of the shearing box
  cp5.addButton("ZoomIn")
        .setCaptionLabel("Zoom In")
        .setPosition(10,40)
        .setSize(55, 50)
        .setFont(fontC);
  
  //Double the dimensions of the shearing box
  cp5.addButton("ZoomOut")
        .setCaptionLabel("Zoom Out")
        .setPosition(75,40)
        .setSize(55, 50)
        .setFont(fontC);
  
  //Resets all particles to new random start points
  cp5.addButton("Reset")
        .setPosition(140, 40)
        .setSize(55, 50)
        .setFont(fontD);

        
  //Swaps between 2D and 3D (also calls Reset)
  cp5.addButton("Toggle3D")
        .setCaptionLabel("2D/3D")
        .setPosition(205, 40)
        .setSize(55, 50)
        .setFont(fontD);
        
  //Adds 100 particles to the shearing box (also calls Reset)  
  cp5.addButton("MoreParticles")
        .setCaptionLabel("+ 100")
        .setPosition(70,100)
        .setSize(50,50)
        .setFont(fontD);

  //Removes 100 particles from the shearing box (also calls Reset)  
  cp5.addButton("LessParticles")
        .setCaptionLabel("- 100")
        .setPosition(10,100)
        .setSize(50,50)
        .setFont(fontD);
        
  //Label displaying number of particles on screen
  cp5.addTextlabel("#Particles")
        .setPosition(130, 115)
        .setText("PARTICLES:")
        .setFont(fontD)
        .setColorValue(0xff000000);
  
  LabelA = cp5.addTextlabel("ParticleN")
        .setPosition(220, 115)
        .setText(N)
        .setFont(fontD)        
        .setColorValue(0xff000000);
        
                
  //Turns on/off the ring gap (also calls Reset)
  cp5.addButton("RingGap")
        .setPosition(10, 160)
        .setSize(120, 50)
        .setFont(fontD);
        
  //Turns on/off the top half of the ring (also calls Reset)      
  cp5.addButton("HalfRing")
        .setPosition(140, 160)
        .setSize(120, 50)
        .setFont(fontD);
       
  
}
  
  
  void draw(){
  background(190);
  }
  //These are all the methods corresponding to the buttons above so I won't commment them all again
  
  void ToggleMoonlet(){
    Moonlet = !Moonlet;
}

  void ZoomIn(){
     SliderScale *= 2;
     LX = LX/2;
     LY = LY/2;
     setupStates();
  }

  void ZoomOut(){
     SliderScale *= 0.5;
     LX = LX*2;
     LY = LY*2;
     setupStates();


  }

  void Reset(){
    setupStates();
  }

  void Toggle3D(){
  Toggle3D = !Toggle3D;
  Reset();
  }

  void RingGap(){
  RingGap = !RingGap;
  HalfRing = false;
  Reset();  
  }
  
  void HalfRing(){
  HalfRing = !HalfRing;
  RingGap = false;
  Reset();
  }
  
  void MoreParticles(){
  n_particles += 100;
  N = Integer.toString(n_particles);
  LabelA.setText(N);
  Reset();
  }
  
  void LessParticles(){
  n_particles -= 100;
  N = Integer.toString(n_particles);
  LabelA.setText(N);
  println(N);
  Reset();
  }

  void ResetMoon(){
  mm.setValue(0,0);
  CreateMoon();
  
  }
  
  void CreateMoon(){
  ShearSystem ss = (ShearSystem)s;
  Moonlet = true;

  ss.moonlet.position.y = -mm.getArrayValue()[0];
  ss.moonlet.position.x = -mm.getArrayValue()[1];
  ss.moonlet.position.z = 0;
  ss.moonlet.velocity = new PVector();
  ss.moonlet.velocity.y = 1.5 * ss.Omega0 * ss.moonlet.position.x;

  }
  
}
