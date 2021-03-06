import java.lang.Exception;
import processing.opengl.*;

// DEBUG MODE
final boolean DEBUG = true;

/* Place all your code into this file */

// Your global variables
color grayishColor = color(128);
//PFont fontMsg = loadFont("Univers66.vlw.gz");

final GameStateContext context = new GameStateContext();
final Renderer renderer = new Renderer();
final Camera camera = new Camera();  // TODO: Camera class needs to be implemented

/**
 * Wavefront, Geometry and Face are defined in Wavefront.pde
 */

final Wavefront obj = new Wavefront();
final HashMap geom = new HashMap();

// This function is called only once in the setup() function
void mySetup()
{
  // First parameter is just a name given to the geometry
  geom.put("ramp", obj.load("ramp", "ruka_hyppyri1.obj"));
  
  smooth(); 
  context.registerState("Menu", new MenuState());
  context.registerState("SkiJump", new SkiJumpState());
  
  context.activateState("Menu");
}

// This function is called for each viewport in the draw() loop
// Place only drawing function calls here!
void myDraw()
{
  // Insert your draw code here
  
  // To preserve keystone correction, use only drawing and camera matrix 
  // altering functions like pushMatrix(), translate(), rotateX/Y/Z(), 
  // scale(), applyMatrix(), box(), sphere() etc.
  // DO NOT use projection matrix altering functions like perspective(), 
  // camera(), resetMatrix(), frustum(), beginCamera(), etc.
  context.draw();
}

// This function is called only once in the draw() loop
void myInteraction()
{
  // Insert your interaction code here
  context.interact();
  
  /* These should be done in the context.interact() method.
  
  // If Wiimotes are not present, you can simulate rotation
  if(INTERFACE_MODE == 0) // If emulating Wiimote with a mouse
  {
    float speed = 1.5;
    controllers6DOF[0].simulateRotation(speed);
  }
  
  // If space key or minus-button of blue Wiimote is being pressed down
  if(    (keyPressed && key == ' ') 
      || controllers6DOF[0].buttonMinus )
  {
    // Add into the scene a new physically simulated, red cube that can 
    // be selected by the user. See addPhysicsCube() definition at the
    // bottom of this file for details. 
    addPhysicsCube();
    playSound(4);
  }
    
  // If A-button of blue Wiimote is being pressed down
  if(controllers6DOF[0].buttonA)
  {
    float cubeSideLenght = 5;
    float posX = controllers6DOF[0].x;
    float posY = controllers6DOF[0].y;
    float posZ = controllers6DOF[0].z;
    // Create a new blue cube that can be selected by the user
    selectableSimpleObject sObject = new selectableSimpleObject(
                                                        cubeSideLenght, 
                                                        posX, posY, posZ);
    // Add it in the list of selectable objects, so it will become a 
    // candidate in the ray-based selection process
    selectableObjects.add(sObject);
  }
  
  if( controllers6DOF[0].buttonB )
  {
    context.activateState("SkiJump");
    SHOW_FPS = true;
  }
  else
    SHOW_FPS = false;

  int redCount = 0;
  int blueCount = 0;
  // Accessing individual selectable objects. This is kind of 'advanced'
  // and not often necessary, so no worries if this particular for-loop 
  // seems complex
  for ( int k = 0; k < selectableObjects.size(); k++ )
  {
    // Interface object
    Selectable so = (Selectable) selectableObjects.get(k);
    if(so instanceof selectablePhysicsCube)
    {
      ++redCount;
      // Cast the interface object into an instance of a specific class that
      // implements the interface, in order to access its public variables
      selectablePhysicsCube spCube = (selectablePhysicsCube) so;
      spCube.fillColor = color( 110, constrain(0.5*redCount, 0, 50), 0);
    }
    if(so instanceof selectableSimpleObject)
    {
      ++blueCount;
    }
  }
  grayishColor = color(constrain(128+redCount, 128, 255), 
                       constrain(128+ redCount*blueCount
                                     /(1+redCount+blueCount), 128, 255),
                       constrain(128+blueCount, 128, 255)               );
  */
}


interface GameState
{  
  void enter();
   
  void exit();
  
  void draw();
 
  void interact(int elapsed); 
}

class GameStateContext
{ 
  private GameState current;
  
  private HashMap states = new HashMap();
  
  private long last = System.currentTimeMillis();
  
  public void registerState(String id, GameState state)
  {
    if (!this.states.containsKey(id))
    {
      this.states.put(id, state);
    }
  }
  
  public void removeState(String id)
  {
    this.states.remove(id);
  }
  
  public void activateState(String id)
  {
    if (this.states.containsKey(id))
    {
      if (this.current != null)
      {
        this.current.exit();
      }
      
      this.current = (GameState)this.states.get(id);
      this.current.enter(); 
    }
  }
  
  public void interact()
  {
    long now = System.currentTimeMillis();
    int elapsed = (int)(now - this.last);
    this.last = now; 
    
    this.current.interact(elapsed);
  }
  
  public void draw()
  {
    this.current.draw();
  }
  
}

class MenuState implements GameState
{ 
  public void enter()
  {
    
  }
 
  public void exit()
  {
    
  }
 
  public void draw()
  {
    renderer.drawText("Press B to skijump", 10, 30, 0, 1);
    renderer.drawText("TODO: cool graphics and maybe music.", 10, 50, 0, 1);
  } 
  
  public void interact(int elapsed)
  {
    if(controllers6DOF[0].buttonB || controllers6DOF[1].buttonB)
    {
      context.activateState("SkiJump");
    } 
  }
}

class SkiJumpState implements GameState
{
  public void enter()
  {
    
  }
 
  public void exit()
  {
    
  }
 
  public void draw()
  { 
    renderer.drawSkybox(0,0,0,10000);
    
    pushMatrix();
    translate(750, 800, -1200);
    scale(100,100,100);
    gl.glDisable(GL.GL_CULL_FACE);
    pushMatrix();
    rotateZ(PI);
    rotateY(PI);
    renderer.drawGeometry((Geometry)geom.get("ramp"));
    popMatrix();
    gl.glEnable(GL.GL_CULL_FACE);
    popMatrix();

    renderer.drawText("Press B when ready...", 10, 30, 0, 1);
    if(DEBUG) {
      renderer.drawText("("+RUIScamX+","+RUIScamY+","+RUIScamZ+")", 10, 200, 0, 1);
    }
  } 
  
  public void interact(int elapsed)
  {
    // Doing this only once per cycle
    camera.nextStep(elapsed, 0);
    camera.applyCamera();    
        
    if(DEBUG) { // move camera with mouse and WSAD
      float MOUSE_SCALE = 0.01;
      float KEY_SCALE = 5;
      camera.yaw   += MOUSE_SCALE * (mouseX-pmouseX);
      camera.pitch += MOUSE_SCALE * (mouseY-pmouseY);
      if(keyPressed) {
        PVector move = new PVector();
        if(key == 'w') move.add(RUIScameraForward);
        if(key == 's') move.sub(RUIScameraForward);
        if(key == 'a') move.sub(RUIScameraRight);
        if(key == 'd') move.add(RUIScameraRight);
        move.mult(KEY_SCALE);
        camera.move(move);
      }
    }
    
    if(controllers6DOF[0].buttonB || controllers6DOF[1].buttonB)
    {
      // Start
      // a track for testing
      ArrayList cameraTrack = new ArrayList();
      cameraTrack.add(new PVector(0,0,0));
      cameraTrack.add(new PVector(0,250,-350));
      cameraTrack.add(new PVector(0,250,-400));
      cameraTrack.add(new PVector(0,300,-700));
      cameraTrack.add(new PVector(0,400,-800));
      camera.setCameraTrack(cameraTrack);
    }      
  }  
}

class Renderer
{
  public void drawText(String message, float x, float y, float z, float scaler)
  {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    fill(200,255,100);
    translate(HUDobjectWorldX(x,y,z,0),
              HUDobjectWorldY(x,y,z,0),
              HUDobjectWorldZ(x,y,z,0) );
    RUISinverseCameraRotation();
    scale(scaler, scaler, 1);
    textFont(fontFPS, 10);  
    gl.glDisable(GL.GL_CULL_FACE);
    text(message,0,0,0);
    gl.glEnable(GL.GL_CULL_FACE);
    popMatrix();
    hint(ENABLE_DEPTH_TEST);  
  } 
  
  public void drawGeometry(Geometry geom)
  {
    PVector colorTest = new PVector(200,0,0);
    
    for (int i = 0; i < geom.faces.size(); ++i)
    {
      Face face = (Face)geom.faces.get(i);
      
      if (face.count == 4)
      {
        this.ColoredQuad( (PVector)geom.vertices.get(face.vertexIndexes[0]),
                          (PVector)geom.vertices.get(face.vertexIndexes[1]),
                          (PVector)geom.vertices.get(face.vertexIndexes[2]),
                          (PVector)geom.vertices.get(face.vertexIndexes[3]),
                          colorTest, colorTest, colorTest, colorTest);
      }
      else if (face.count == 3)
      {
        this.ColoredTriangle( (PVector)geom.vertices.get(face.vertexIndexes[0]),
                              (PVector)geom.vertices.get(face.vertexIndexes[1]),
                              (PVector)geom.vertices.get(face.vertexIndexes[2]),
                              colorTest, colorTest, colorTest);
      }
    }
  }
  
  public void drawSkybox(float x, float y, float z, float scaler)
  {
    pushMatrix();
      
      translate(-headX,-headY,-headZ);
      scale(scaler, scaler, scaler);
    
      PVector colorTop = new PVector(0,0,50);
      PVector colorBottom = new PVector(230,230,230);
    
      // TODO: how to disable outline drawing?!?
    
      gl.glDisable(GL.GL_CULL_FACE);
      noLights();
      
      // Front
      this.ColoredQuad( new PVector(-1,1,1), new PVector(-1,-1,1), new PVector(1,-1,1), new PVector(1,1,1),
                        colorTop, colorBottom, colorBottom, colorTop);
      
      // Right                                 
      this.ColoredQuad( new PVector(1,1,1), new PVector(1,-1,1), new PVector(1,-1,-1), new PVector(1,1,-1),
                        colorTop, colorBottom, colorBottom, colorTop);
              
      // Left          
      this.ColoredQuad( new PVector(-1,1,-1), new PVector(-1,-1,-1), new PVector(-1,-1,1), new PVector(-1,1,1),
                        colorTop, colorBottom, colorBottom, colorTop);
             
      // Back           
      this.ColoredQuad( new PVector(1,1,-1), new PVector(1,-1,-1), new PVector(-1,-1,-1), new PVector(-1,1,-1),
                        colorTop, colorBottom, colorBottom, colorTop);
      
      // Top           
      this.ColoredQuad( new PVector(-1,1,-1), new PVector(-1,1,1), new PVector(1,1,1), new PVector(1,1,-1),
                        colorTop, colorTop, colorTop, colorTop);
      
      // Bottom           
      this.ColoredQuad( new PVector(-1,-1,-1), new PVector(-1,-1,1), new PVector(1,-1,1), new PVector(1,-1,-1),
                        colorBottom, colorBottom, colorBottom, colorBottom);
      
      lights();
      gl.glEnable(GL.GL_CULL_FACE);
    popMatrix();
  }
  
  void TexturedQuad(PVector P1, PVector P2, PVector P3, PVector P4, PImage tex)
  {
    beginShape(QUADS);
      texture(tex);
      vertex (P1.x, P1.y, P1.z, 1, 0);
      vertex (P2.x, P2.y, P2.z, 0, 0);
      vertex (P3.x, P3.y, P3.z, 0, 1);
      vertex (P4.x, P4.y, P4.z, 1, 1);
    endShape();
  }
  
  void ColoredQuad( PVector p1, PVector p2, PVector p3, PVector p4,
                    PVector p1color, PVector p2color, PVector p3color, PVector p4color)
  {
    beginShape(QUADS);
      fill(p1color.x, p1color.y, p1color.z); vertex (p1.x, p1.y, p1.z);
      fill(p2color.x, p2color.y, p2color.z); vertex (p2.x, p2.y, p2.z);
      fill(p3color.x, p3color.y, p3color.z); vertex (p3.x, p3.y, p3.z);
      fill(p4color.x, p4color.y, p4color.z); vertex (p4.x, p4.y, p4.z);
    endShape();
  }
  
  void ColoredTriangle( PVector p1, PVector p2, PVector p3,
                    PVector p1color, PVector p2color, PVector p3color)
  {
    beginShape(TRIANGLES);
      fill(p1color.x, p1color.y, p1color.z); vertex (p1.x, p1.y, p1.z);
      fill(p2color.x, p2color.y, p2color.z); vertex (p2.x, p2.y, p2.z);
      fill(p3color.x, p3color.y, p3color.z); vertex (p3.x, p3.y, p3.z);
    endShape();
  }
}

class Camera 
{
  private ArrayList waypoints;
  
  private PVector eye;
  // camera orientation as three angles -- see http://en.wikipedia.org/wiki/Aircraft_principal_axes
  float yaw;
  float pitch;
  float roll;
  
  float speed;
  
  public Camera()
  {
    this.eye = new PVector();
    this.yaw = 0;
    this.pitch = 0;
    this.roll = 0;
    // constant speed for testing
    this.speed = 200;
  }
  
  public void setEye(PVector _eye)
  {
    this.eye = _eye;
  }
  
  public void move(float _x, float _y, float _z) {
    this.eye.x += _x;
    this.eye.y += _y;
    this.eye.z += _z;
  }
  
  public void move(PVector diff) {
    this.eye.add(diff);
  }
    
  public void setCameraTrack(ArrayList _waypoints)
  {
    this.waypoints = _waypoints;
  }
 
  // Calculate the next camera position
  public void nextStep(int elapsed, int type)
  {
    switch (type)
    {
      case 0:
        this.Lerp(elapsed);
        break;
    }
  }
 
  // Linear interpolation
  private void Lerp(int elapsed)
  {
    if (this.waypoints != null) {
      float distance = this.speed * elapsed / 1000;
      float travelled = 0;
      PVector tmp = new PVector();
      PVector next;
      while (!this.waypoints.isEmpty() && travelled < distance) {
        next = (PVector) this.waypoints.get(0);
        tmp.set(next);
        tmp.sub(this.eye);
        if (tmp.mag() > (distance - travelled)) {
          // travel towards next waypoint
          tmp.normalize();
          tmp.mult(distance - travelled);
          this.eye.add(tmp);
          travelled = distance;
        } else {
          // travel past next waypoint
          travelled += tmp.mag();
          this.eye.set(next);
          this.waypoints.remove(0);
        }
      }
    }
  }
 
  // Apply the camera transformation
  public void applyCamera()
  {
     RUIScameraPosition(this.eye.x, this.eye.y, this.eye.z);
     RUIScameraOrient(this.yaw, this.pitch, this.roll);
  }
}
