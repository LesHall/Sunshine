//import processing.dxf.*;


int d = 1;  // pixels averaged in a square, set to 1 for no decimation
float diameter = 100;  // (mm)
float depth = 2; // (mm)
String filename = "Earth.png";  // input image file
PImage img;
String data_codes[] = {"polyhedron(points = [ "};


void setup() {
  size(512, 512, P3D);

  img = loadImage(filename);
  img.loadPixels();
  
  for (int i=0; i<=img.height; i+=d)
  {
    for (int j=0; j<img.width; j+=d)
    {
      float b = 0;
      for (int ii=0; ii<d; ++ii)
        for (int jj=0; jj<d; ++jj)
          b += brightness(img.get(j+jj, i+ii));
      b /= d*d*256;
      
      float r = diameter/2 + depth * b;
      if ( (i==0) || (i==img.height) )
        r = diameter/2;
      float theta = TWO_PI*j/img.width;
      float phi = PI*i/img.height;
      float x = r * cos(theta) * sin(phi);
      float y = r * sin(theta) * sin(phi);
      float z = r * cos(phi);
      
      String line[] = {};
      line = append(line, nf(x, 0, 0) );
      line = append(line, nf(y, 0, 0) );
      line = append(line, nf(z, 0, 0) );
      String l = join(line, ", ");
      String s[] = {"    [", l, "], "};
      l = join(s, "");
      data_codes = append(data_codes, l);
    }
//polyhedron(points = [ [x, y, z], ... ], 
//faces = [ [p1, p2, p3..], ... ], convexity = N);
  }
  data_codes = append(data_codes, "], faces = [ ");
  
  // add faces
  String points[] = {};
  for(int i=0; i<img.height; i+=d)
  {
    for (int j=0; j<img.width; j+=d)
    {
      String point1[] = {};
      point1 = append(point1, nf( i*img.width+j, 0, 0) );
      point1 = append(point1, nf( (i+1)*img.width+j, 0, 0) );
      point1 = append(point1, nf( (i+1)*img.width+(j+1), 0, 0) );
      String l;
      l = join(point1, ", ");
      String s1[] = {"    [", l, "]"};
      l = join(s1, "");
      String s3[] = {l, ", "};
      l = join(s3, "");
      points = append(points, l);
      
      String point2[] = {};;
      point2 = append(point2, nf( i*img.width+j, 0, 0) );
      point2 = append(point2, nf( (i+1)*img.width+(j+1), 0, 0) );
      point2 = append(point2, nf( i*img.width+(j+1), 0, 0) );
      l = join(point2, ", ");
      String s2[] = {"    [", l, "]"};
      l = join(s2, "");
      if ( (i*img.width+j)<(img.height)*(img.width) )
      {
        String s4[] = {l, ", \n"};
        l = join(s4, "");
      }
      points = append(points, l);
    }
  }
  data_codes = append(data_codes, join(points, "") );
  data_codes = append(data_codes, "],  convexity = 10);");
  
  
  // save and exit
  saveStrings("output.scad", data_codes);
  exit();
}

void draw()
{
}