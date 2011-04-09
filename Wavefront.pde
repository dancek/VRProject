
class Wavefront
{ 
  public Wavefront()
  {
     
  }
  
  public Geometry load(String name, String filename)
  {
    Geometry geom = new Geometry(name);
    BufferedReader reader = createReader(filename);
    
    try {
      String line;
      while ((line = reader.readLine()) != null)
      {
        process(line, geom); 
      }
      reader.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    
    return geom;
  }
  
  private void process(String lineStr, Geometry geom)
  {
    String[] pieces = lineStr.split(" ");
    
    if (pieces[0].equals("v"))
    {
      PVector v = new PVector(Float.parseFloat(pieces[1]), 
                              Float.parseFloat(pieces[2]), 
                              Float.parseFloat(pieces[3]));
      geom.vertices.add(v); 
    }
    else if (pieces[0].equals("f"))
    {
      int count = pieces.length;
      Face face = new Face(count-1);
      
      for (int i = 1; i < count; ++i)
      {
        String[] components = pieces[i].split("/");
        
        if (components.length == 1)
        {
          face.vertexIndexes[i-1] = Integer.parseInt(components[0])-1;
        }
        else if (components.length == 3)
        {
          face.vertexIndexes[i-1] = Integer.parseInt(components[0])-1;
          // TODO: texture and normal
        }        
      }
      
      geom.faces.add(face);
    }
  }
}

class Geometry
{
  public String name;
  
  public ArrayList vertices;
  
  public ArrayList faces;
  
  public Geometry(String _name)
  {
    this.vertices = new ArrayList();
    this.faces = new ArrayList();
    this.name = _name;
  }  
}

class Face
{ 
  public int count;
  
  public Integer vertexIndexes[];
  public Integer texcoordIndexes[];
  public Integer normalIndexes[];
  
  public Face(int _count)
  {
    this.count = _count;
    this.vertexIndexes = new Integer[_count];
    this.texcoordIndexes = new Integer[_count];
    this.normalIndexes = new Integer[_count];
  }
}

