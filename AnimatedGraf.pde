import megamu.mesh.*;

Voronoi myVoronoi;
Delaunay myDelaunay;
Hull myHull;
MPolygon[] myRegions;
MPolygon myHullRegion;
int numPoints = 20;
PVector[] points;
float[][] myEdges;
float pointMinX, pointMinY, pointMaxX, pointMaxY;

void setup() {
  size(1024, 800);

  pointMinX = width / 4;
  pointMinY = height / 4;
  pointMaxX = width - (width / 4);
  pointMaxY = height - (height / 4);
  
  int numPoints = 20;
  

  points = new PVector[numPoints];
  for (int i = 0; i < points.length; i++ ){
    points[i] = new PVector();
  }
  			
  for (PVector point : points) {
    point.x = random(pointMinX, pointMaxX);
    point.y = random(pointMinY, pointMaxY);
  }
}

void draw() {
  //Update point positions
  for (PVector point : points) {
    point.x += random(-5, 5);
    point.y += random(-5, 5);
    point.x = constrain(point.x, pointMinX, pointMaxX);
    point.y = constrain(point.y, pointMinY, pointMaxY);
  }

  //TODO: Y sort

  float[][] floatPoints = new float[points.length][2];
  for (int i = 0; i < points.length; i++) {
    PVector point = points[i];
    floatPoints[i][0] = point.x;
    floatPoints[i][1] = point.y;
  }

  //Calculate voronoi diagram
  myVoronoi = new Voronoi( floatPoints );
  myRegions = myVoronoi.getRegions();
  
  //Calculate delaunay diagram
  myDelaunay = new Delaunay( floatPoints );
  myEdges = myDelaunay.getEdges();

  //Calculate convex hull
  myHull = new Hull( floatPoints ); 
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
  for (int i = 0; i < floatPoints.length; i++) {
    float[] pointRow = floatPoints[i];
    for (int j = 0; j < pointRow.length; j++) {
      ellipse(pointRow[0], pointRow[1], 5, 5);
    }
  }
  */
}
