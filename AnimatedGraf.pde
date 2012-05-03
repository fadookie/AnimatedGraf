import megamu.mesh.*;

Voronoi myVoronoi;
Delaunay myDelaunay;
Hull myHull;
MPolygon[] myRegions;
MPolygon myHullRegion;
int numPoints = 20;
Point[] points;
float[][] floatPoints;
float[][] myEdges;
int[] hullExtrema;
float pointMinX, pointMinY, pointMaxX, pointMaxY;
PVector leftOrigin, rightOrigin;

PVectorYDescending pVectorYDescending;

void setup() {
  size(1024, 800);

  pointMinX = width / 4;
  pointMinY = height / 4;
  pointMaxX = width - (width / 4);
  pointMaxY = height - (height / 4);
  
  int numPoints = 20;
  

  points = new Point[numPoints];
  for (int i = 0; i < points.length; i++ ){
    points[i] = new Point(
        random(pointMinX, pointMaxX),
        random(pointMinY, pointMaxY)
    );
  }

  leftOrigin = new PVector(0, height / 2);
  rightOrigin = new PVector(width, height / 2);

  floatPoints = new float[points.length][2];
  pVectorYDescending = new PVectorYDescending();
}

void draw() {
  //==============UPDATE================
  //Update point positions
  for (Point point : points) {
    point.x += random(-5, 5);
    point.y += random(-5, 5);
    point.x = constrain(point.x, pointMinX, pointMaxX);
    point.y = constrain(point.y, pointMinY, pointMaxY);
    point.isOnHull = false; //Assume we're not on the hull, if we are we'll get flagged later
  }

  //Sort point positions by Y order, descending
  Arrays.sort(points, pVectorYDescending);

  //Copy points data structure to floatPoints array for use by mesh library
  for (int i = 0; i < points.length; i++) {
    Point point = points[i];
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
  hullExtrema = myHull.getExtrema();

  //Flag Points on the hull as such
  for (int pointIndex : hullExtrema) {
    points[pointIndex].isOnHull = true;
  }
  
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

  //Draw side triangles
  pushStyle();
  strokeWeight(4);
  stroke(0, 255, 0);
  for (int pointIndex : hullExtrema) {
    Point point = points[pointIndex];
    PVector origin;
    if (point.x < width / 2) {
      origin = leftOrigin;
    } else {
      origin = rightOrigin;
    }
    line(origin.x, origin.y, point.x, point.y);
  }
  popStyle();

  //Draw origin points
  pushStyle();
  noStroke();
  int _color = 0;
  for (Point point : points) {
    fill(0, _color, 0);
    ellipse(point.x, point.y, 10, 10);
    _color += 10;
  }
  popStyle();
}
