import java.io.BufferedReader; 


class Wavefront
{ 
  public Wavefront()
  {
     
  }
  
  public Geometry load(String name, String filename)
  {
    Geometry geom = new Geometry(name);
    
    try 
    {
      BufferedReader in = new BufferedReader(new FileReader(filename));
      String str;
      while ((str = in.readLine()) != null) 
      {
        process(str, geom);
      }
      in.close();
    } catch (IOException e) {
      // oujee
    }
    
    return geom;
  }
  
  private void process(String lineStr, Geometry geom)
  {
    String[] pieces = lineStr.split(" ");
    
    if (pieces[0].equals("v"))
    {
      Float vdata[] = new Float[3];
      vdata[0] = Float.parseFloat(pieces[1]);
      vdata[2] = Float.parseFloat(pieces[2]);
      vdata[3] = Float.parseFloat(pieces[3]);
      geom.vertices.add(vdata); 
    }
    else if (pieces[0].equals("f"))
    {
      int count = pieces.length;
      for (int i = 0; i < count; ++i)
      {
        
      }
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
  int count;
  
  public Integer vertices[];
  public Integer texcoords[];
  public Integer normals[];
  
  public Face(int _count)
  {
    this.count = _count;
    this.vertices = new Integer[_count];
    this.texcoords = new Integer[_count];
    this.normals = new Integer[_count];
  }
}

