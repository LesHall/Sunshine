/////////////////////////////////////////////////////
// 
// Elizabeth simage to SCAD converter
// one step toward an image to stl editor
// by Les Hall
// 



int d = 1;  // pixels averaged in a square, set to 1 for no decimation
float diameter = 100;  // (mm)
float depth = 2; // (mm)
String inFilename = "";  // input image filename
String outFilename = "";  // output filename of chosen output file format
PImage img;
String SCADdata[] = {"polyhedron(points = [ "};
boolean imageLoaded = false;
boolean imageDrawn = false;
boolean fileSaved = false;
int messageSize = 40;
float scale = 1;


void setup() {
  size(800, 600);
  
  textSize(messageSize);
  textAlign(CENTER, CENTER);

  selectInput("Select a file to process:", "fileSelected");
}



void draw() {

  if (imageDrawn && (!fileSaved)) {
    
    // convert the image to an SCAD file
    process_image();
    
    // draw the complete message
    draw_screen("\nClick to exit");
  }
  
  if (imageLoaded) {
    
    // calculate the scale of the image
    scale = ((float)width)/img.width;
    if (scale > (((float)height)/img.height) )
      scale = ((float)height)/img.height;
    
    // draw the screen
    draw_screen("Waiting for file to process\nClick to exit after processing");

    // process the image on the next frame
    // so the drawn image registers on screen
    imageLoaded = false;
    imageDrawn = true;
  }
}



void draw_screen(String message) {
  
  background(0, 255/2, 255);
  image(img, 0, 0, scale*img.width, scale*img.height);
  text(message, width/2, height - 2*messageSize);
}



void mouseReleased() {
  exit();
}



// convert image to SCAD file
// *** note:  convert to STL also ***
void process_image() {
  
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
      SCADdata = append(SCADdata, l);
    }
// polyhedron(points = [ [x, y, z], ... ], 
//            faces = [ [p1, p2, p3..], ... ], 
//            convexity = N);
  }
  SCADdata = append(SCADdata, "], faces = [ ");
  
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
  SCADdata = append(SCADdata, join(points, "") );
  SCADdata = append(SCADdata, "],  convexity = 10);");
  
  
  // save and exit
  //String[] parts = splitTokens(inFilename, ".");
  //parts[parts.length-1] = "scad";
  outFilename = inFilename + ".SCAD";
  saveStrings(outFilename, SCADdata);
  fileSaved = true;
}



void fileSelected(File selection) {
  
  if (selection == null) {
    
    println("Window was closed or the user hit cancel.");
  
  } else {
    
    inFilename = selection.getAbsolutePath();
    println("User selected " + inFilename);
    img = loadImage(inFilename);  // get image from disk
    img.loadPixels(); // load pixels from image to PImage
    imageLoaded = true;
  }
}