import megamu.mesh.*;

Voronoi myVoronoi;
Delaunay myDelaunay;
Hull myHull;
MPolygon[] myRegions;
MPolygon myHullRegion;
float[][] foregroundPoints;
float[][] myEdges;

void setup() {
  size(800, 800);
  
  int numPoints = 20;
  
  foregroundPoints = new float[20][2];
  			
  for (int i = 0; i < foregroundPoints.length; i++) {
    foregroundPoints[i][0] = random(0, width); //point x
    foregroundPoints[i][1] = random(0, height); //point y
  }
}

void draw() {
  //Update point positions
  for (int i = 0; i < foregroundPoints.length; i++) {
    foregroundPoints[i][0] += random(-5, 5); //x
    foregroundPoints[i][1] += random(-5, 5); //y
    foregroundPoints[i][0] = constrain(foregroundPoints[i][0], 0, width); //x
    foregroundPoints[i][1] = constrain(foregroundPoints[i][1], 0, height); //y
  }

  //Calculate voronoi diagram
  myVoronoi = new Voronoi( foregroundPoints );
  myRegions = myVoronoi.getRegions();
  
  //Calculate delaunay diagram
  myDelaunay = new Delaunay( foregroundPoints );
  myEdges = myDelaunay.getEdges();

  //Calculate convex hull
  myHull = new Hull( foregroundPoints ); 
  myHullRegion = myHull.getRegion();
  
  //==============DRAW================

  background(color(0, 128, 255));

  //Draw delaunay edges
  pushStyle();
  stroke(color(32, 68, 95));
  strokeWeight(8);

  for(int i=0; i<myEdges.length; i++)
  {
  	float startX = myEdges[i][0];
  	float startY = myEdges[i][1];
  	float endX = myEdges[i][2];
  	float endY = myEdges[i][3];
  	line( startX, startY, endX, endY );
  }
  popStyle();

  //Draw voronoi regions
  pushStyle();
  noFill();
  for(int i=0; i<myRegions.length; i++)
  {
  	// an array of points
  	float[][] regionCoordinates = myRegions[i].getCoords();
    strokeWeight(16);
    stroke(color(0, 0, 0));
  	myRegions[i].draw(this); // draw this shape
    strokeWeight(8);
    stroke(color(255, 255, 255));
  	myRegions[i].draw(this); // draw this shape
  }
  popStyle();

  stroke(color(255, 0, 0));

  //Draw convex hull
  pushStyle();
  noFill();
  strokeWeight(16);
  stroke(color(0, 0, 0));
  myHullRegion.draw(this);
  strokeWeight(8);
  stroke(color(255, 255, 255));
  myHullRegion.draw(this);
  popStyle();

  //Draw origin points
  /*
  for (int i = 0; i < foregroundPoints.length; i++) {
    float[] pointRow = foregroundPoints[i];
    for (int j = 0; j < pointRow.length; j++) {
      ellipse(pointRow[0], pointRow[1], 5, 5);
    }
  }
  */
}
