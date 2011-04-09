import java.lang.Exception;
import processing.opengl.*;

/* Place all your code into this file */

// Your global variables
color grayishColor = color(128);
//PFont fontMsg = loadFont("Univers66.vlw.gz");

final GameStateContext context = new GameStateContext();
final Renderer renderer = new Renderer();

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


// ---
/* Very simple cube, that is selectable but not physically simulated */
class selectableSimpleObject implements Selectable 
{    
  PVector position;
  float sideLength;
  boolean selected;
  boolean highLighted;
  color fillColor;
  color strokeColor;
  float rotationMatrix[][];
  
  public selectableSimpleObject(float _sideLength, 
                                float _posX, float _posY, float _posZ)
  {
    sideLength = _sideLength;
    position = new PVector(_posX, _posY, _posZ);
    selected = false;
    highLighted = false;
    fillColor   = color(0, 0, 110);
    strokeColor = color(255);
    rotationMatrix = new float[][] { { 1,0,0 }, 
                                     { 0,1,0 },
                                     { 0,0,1 }  };
  }
  
  // Executes once just after the object is selected (button pressed)
  public void initObjectSelection(int controllerID)
  {
    highLighted = false;
    selected = true;
    strokeColor = controllers6DOF[controllerID].controllerColor;
    
    controllers6DOF[controllerID].initRelativeRotation(rotationMatrix);
  }
  
  // Execute while the object is selected and selection button is down
  public void whileObjectSelection(int controllerID)
  {
    // Copy controller's location into position vector
    position.set(controllers6DOF[controllerID].x,
                 controllers6DOF[controllerID].y,
                 controllers6DOF[controllerID].z );
    
    // Add controller's rotation into the cube's current rotation.
    // Smooth rotation transition
    controllers6DOF[controllerID].copyRelativeRotation(rotationMatrix);
    
    // Below call would just copy the controller's rotation, causing a 
    // noticeable discontinuity in the rotation
    //controllers6DOF[controllerID].copyAbsoluteRotation(rotationMatrix);
  }
  
  // Executes once just after the selection button is released
  public void releaseObjectSelection(int controllerID)
  {
    selected = false;
  }
  
  // Executes when a controller without selection is above an selectable 
  // object. That object will be selected if the selection button is 
  // then pressed
  public void highlightWouldBeSelected(int controllerID)
  {
    highLighted = true;
    strokeColor = controllers6DOF[controllerID].controllerColor;
  }
  
  // Returns position of the object. You can disregard the rayOrigin and rayDirection
  // parameters
  public PVector getPosition(int controllerID)
  {
    return position;
  }
  
  // In Java, interface implementation can also be a function that does nothing
  public void updateObject()
  {
    // Uncomment this and you can remove the for-loop used for accessing 
    // individual selectable objects in the myInteraction() function.
    // Below code effectively causes the same result because
    highLighted = false;
  }
  
  public void render()
  {
    fill(fillColor);

    if(selected)
      stroke(strokeColor);
    else 
    {
      noStroke();
      if(highLighted) 
      {
        fill(0, 0, 210);
      }
    }
    
    pushMatrix();
    // Apply translate() and rotation()
    translate(position.x, position.y, position.z);
    applyMatrix(rotationMatrix[0][0], rotationMatrix[0][1], rotationMatrix[0][2], 0,
                rotationMatrix[1][0], rotationMatrix[1][1], rotationMatrix[1][2], 0,
                rotationMatrix[2][0], rotationMatrix[2][1], rotationMatrix[2][2], 0,
                                   0,                    0,                    0, 1 );
    // These glCullFace calls are needed because the perspective matrix 
    // for keystones is still buggy (has a negative eigenvalue). To be fixed.
    gl.glCullFace(GL.GL_FRONT);
    box(sideLength);
    gl.glCullFace(GL.GL_BACK);
    popMatrix();
  }
}



// ---
/* Simple physically simulated rigid cube, that is selectable */
class selectablePhysicsCube extends RigidBody implements Selectable 
{    
  float sideLength;
  float mass;
  boolean selected;
  boolean highLighted;
  color fillColor;
  color strokeColor;
  
  public selectablePhysicsCube(RigidBodyConstructionInfo CI, float _sideLength, 
                               float _mass, float startX, float startY, float startZ)
  {
    super(CI);
    sideLength = _sideLength;
    mass = _mass;
    selected = false;
    highLighted = false;
    fillColor   = color(110, 0, 0);
    strokeColor = color(255);
  }
  
  // Executes once just after the object is selected (button pressed)
  public void initObjectSelection(int controllerID)
  {
    highLighted = false;
    selected = true;
    strokeColor = controllers6DOF[controllerID].controllerColor;
    
    // JBullet (Physics Engine): Wake up the RigidBody
    this.activate();
    // JBullet (Physics Engine): Remove gravity
    this.setGravity(new Vector3f(0,0,0));
    
    // This needs to be called here, otherwise the call for
    // getRelativeRotation() doesn't work in whileObjectSelection() loop
    controllers6DOF[controllerID].initRelativeRotation(this);
  }
  
  // Execute while the object is selected and selection button is down
  public void whileObjectSelection(int controllerID)
  {
    float objectRadius = sideLength;
    
    // Copies controller's location into rigidBody (cube)
    controllers6DOF[controllerID].copyLocation(this, objectRadius);
    // Add controller's rotation into the cube's current rotation.
    // Smooth rotation transition
    controllers6DOF[controllerID].copyRelativeRotation(this);
    // Below call would just copy the controller's rotation, causing a 
    // noticeable discontinuity in the rotation
    //controllers6DOF[controllerID].copyAbsoluteRotation(this);
    
    // JBullet (Physics Engine): Wake up the RigidBody
    this.activate();
  }
  
  
  // Executes once just after the selection button is released
  public void releaseObjectSelection(int controllerID)
  {
    selected = false;
    
    // JBullet (Physics Engine): Make cube subject to gravity again
    this.setGravity(globalGravity);
    
    // JBullet (Physics Engine): Set cube into rest when you release it.
    this.setLinearVelocity(new Vector3f(0,0,0));
    this.setAngularVelocity(new Vector3f(0,0,0));
    
    // JBullet (Physics Engine): If you want to be able to throw the cube,
    // you need to derive the speed from the Controller (x,y,z) position
    // and uncomment the following lines.
    // this.setLinearVelocity(derivedSpeed); // Vector3f derivedSpeed
    // Set impulse value vector to derivedSpeed
    // derivedSpeed.scale(1/this.getInvMass());
    // this.applyCentralImpulse(derivedSpeed);
    
  }
  
  // Executes when a controller without selection is above an selectable 
  // object. That object will be selected if the selection button is 
  // then pressed
  public void highlightWouldBeSelected(int controllerID)
  {
    highLighted = true;
    strokeColor = controllers6DOF[controllerID].controllerColor;
  }
  
  // Returns position of the object. You can disregard the rayOrigin and rayDirection
  // parameters
  public PVector getPosition(int controllerID)
  {
    return(getRigidBodyLocation(this));
  }
  
  // In Java, interface implementation can also be a function that does nothing
  public void updateObject()
  {
    // Uncomment this and you can remove the for-loop used for accessing 
    // individual selectable objects in the myInteraction() function.
    // Below code effectively causes the same result because
    highLighted = false;
  }
  
  public void render()
  {
    fill(fillColor);

    if(selected)
      stroke(strokeColor);
    else 
    {
      noStroke();
      if(highLighted) 
      {
        fill(210, 0, 0);
      }
    }
    
    pushMatrix();
    
    // Apply translate() and rotation() using the cube's RigidBody 
    // location and rotation parameters
    rigidBodyTranslateAndRotate(this);

    // These glCullFace calls are needed because the perspective matrix 
    // for keystones is still buggy (has a negative eigenvalue). To be fixed.
    //gl.glCullFace(GL.GL_FRONT);
    box(sideLength);
    //gl.glCullFace(GL.GL_BACK);
    popMatrix();
  }
}


// Creates a new selectablePhysicsCube, initiates its variables, and
// binds its RigidBody into the JBullet simulation
void addPhysicsCube()
{
  float cubeSideLenght = 15;
  float cubeMass = 5;
  float posX =  150;
  float posY =  40;
  float posZ = -220;
  
  // Define parameters required by JBullet
  CollisionShape cubeShape = new BoxShape(new Vector3f(0.5*cubeSideLenght, 
                                                       0.5*cubeSideLenght, 
                                                       0.5*cubeSideLenght));
  Transform myTransform = new Transform(); 
  myTransform.origin.set(new Vector3f(posX, posY, posZ)); 
  myTransform.setRotation(new Quat4f(0, 0, 0, 1));
  DefaultMotionState motionState = new DefaultMotionState(myTransform);
  Vector3f myInertia = new Vector3f(1,1,1);
  cubeShape.calculateLocalInertia(cubeMass, myInertia);
  RigidBodyConstructionInfo rigidBodyCI = new RigidBodyConstructionInfo(cubeMass, 
                                                                        motionState, 
                                                                        cubeShape, 
                                                                        myInertia   );
  
  // Construct a new selectablePhysicsCube
  selectablePhysicsCube cubeRigidBody = new selectablePhysicsCube(rigidBodyCI, 
                                                                  cubeSideLenght, 
                                                                  cubeMass, 
                                                                  posX, posY, posZ);
  
  // Bind the cube's rigidBody into the JBullet simulation
  myWorld.addRigidBody(cubeRigidBody);
  
  // Add the newly created selectablePhysicsCube in the list of selectable objects, 
  // so it will become a candidate in the ray-based selection process
  selectableObjects.add(cubeRigidBody);
  
  // Additional physical cube parameters, not necessary to change these
  cubeRigidBody.setFriction(2);
  cubeRigidBody.setHitFraction(10.1);
  cubeRigidBody.setRestitution(0.5);
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
    renderer.drawText("Press B to skijump", 10, 30, -300, 1);
    renderer.drawText("TODO: cool graphics and maybe music.", 10, 50, -300, 1);
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
    translate(100, 500, -2000);
    scale(100,100,100);
    gl.glDisable(GL.GL_CULL_FACE);
    pushMatrix();
    rotateZ(PI);
    rotateY(PI/2);
    renderer.drawGeometry((Geometry)geom.get("ramp"));
    popMatrix();
    gl.glEnable(GL.GL_CULL_FACE);
    popMatrix();
    
    renderer.drawText("Press B when ready...", 10, 30, -300, 1);
  } 
  
  public void interact(int elapsed)
  {
    if(controllers6DOF[0].buttonB || controllers6DOF[1].buttonB)
    {
      // Start
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
      translate(x, y, z);
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

