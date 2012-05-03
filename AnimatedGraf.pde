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
QMath qMath; //Fuck java
PGraphics voronoiFramebuffer;
PGraphics foregroundFramebuffer;

PVectorYDescending pVectorYDescending;

void setup() {
  size(1024, 800, OPENGL);

  pointMinX = width / 4;
  pointMinY = height / 4;
  pointMaxX = width - (width / 4);
  pointMaxY = height - (height / 4);

  voronoiFramebuffer = createGraphics(width, height, P2D);//createGraphics(width / 2, height / 2);
  foregroundFramebuffer = createGraphics(width, height, P2D);
  
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
  qMath = new QMath();

  //frameRate(30);
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
  voronoiFramebuffer.beginDraw();

  color backgroundColor = color(0, 128, 255);
  background(backgroundColor);
  voronoiFramebuffer.background(backgroundColor);

  //Draw delaunay edges
  voronoiFramebuffer.pushStyle();
  voronoiFramebuffer.stroke(color(32, 68, 95));
  voronoiFramebuffer.strokeWeight(8);

  for(int i=0; i<myEdges.length; i++)
  {
  	float startX = myEdges[i][0];
  	float startY = myEdges[i][1];
  	float endX = myEdges[i][2];
  	float endY = myEdges[i][3];
  	voronoiFramebuffer.line( startX, startY, endX, endY );
  }
  voronoiFramebuffer.popStyle();

  //Draw voronoi regions
  voronoiFramebuffer.pushStyle();
  voronoiFramebuffer.noFill();
  for(int i=0; i<myRegions.length; i++)
  {
  	// an array of points
  	float[][] regionCoordinates = myRegions[i].getCoords();
    voronoiFramebuffer.strokeWeight(16);
    voronoiFramebuffer.stroke(color(0, 0, 0));
  	myRegions[i].draw(voronoiFramebuffer); // draw this shape
    voronoiFramebuffer.strokeWeight(8);
    voronoiFramebuffer.stroke(color(255, 255, 255));
  	myRegions[i].draw(voronoiFramebuffer); // draw this shape
  }
  voronoiFramebuffer.popStyle();
  voronoiFramebuffer.endDraw();

  //Draw convex hull texture from voronoi diagram framebuffer
  pushStyle();
  noStroke();
  noFill();
  beginShape();
  texture(voronoiFramebuffer);
  float[][] hullCoords = myHullRegion.getCoords();
  for (int i = 0; i < hullCoords.length; i++) {
    vertex(hullCoords[i][0], hullCoords[i][1], hullCoords[i][0], hullCoords[i][1]);
  }
  endShape();
  popStyle();

  foregroundFramebuffer.beginDraw();
  foregroundFramebuffer.background(0,0); //Refresh this buffer with pure 0% alpha
  foregroundFramebuffer.stroke(color(255, 0, 0));

  //Draw side triangles
  foregroundFramebuffer.pushStyle();
  foregroundFramebuffer.strokeWeight(4);
  for (int pointIndex : hullExtrema) {
    Point point = points[pointIndex];

    //Determine what point the triangle should originate from
    /*
    PVector origin;
    if (point.x < width / 2) {
      origin = leftOrigin;
    } else {
      origin = rightOrigin;
    }
    */
    PVector[] origins = new PVector[2];
    origins[0] = leftOrigin;
    origins[1] = rightOrigin;

    for (PVector origin : origins) {

      //Cast a ray from that point to the target
      Ray ray = new Ray();
      ray.setOrigin(origin);
      ray.setDirection(PVector.sub(point, origin));
      PVector intersection = new PVector();
      MutableFloat distance = new MutableFloat(0);
      boolean hit = qMath.RayCast(ray, myHullRegion, Float.MAX_VALUE, distance, intersection, null/*PVector normal*/);
      println("ray: " + ray + " hit: " + hit + " dist: " + distance + " intersection: " + intersection);
      //stroke(0, 255, 0);
      //line(origin.x, origin.y, point.x, point.y);
      foregroundFramebuffer.strokeWeight(2);
      if(hit) {
        foregroundFramebuffer.stroke(255, 0, 0);
      } else {
        foregroundFramebuffer.stroke(0, 0, 255);
      }
      foregroundFramebuffer.line(ray.origin.x, ray.origin.y, intersection.x, intersection.y);
    }
  }
  foregroundFramebuffer.popStyle();

  //Draw convex hull outline
  foregroundFramebuffer.pushStyle();
  foregroundFramebuffer.noFill();
  foregroundFramebuffer.strokeWeight(16);
  foregroundFramebuffer.stroke(color(0, 0, 0));
  myHullRegion.draw(foregroundFramebuffer);
  foregroundFramebuffer.strokeWeight(8);
  foregroundFramebuffer.stroke(color(255, 255, 255));
  myHullRegion.draw(foregroundFramebuffer);
  foregroundFramebuffer.popStyle();

  foregroundFramebuffer.endDraw();


  //Draw origin points
  /*
  pushStyle();
  noStroke();
  int _color = 0;
  for (Point point : points) {
    fill(0, _color, 0);
    ellipse(point.x, point.y, 10, 10);
    _color += 10;
  }
  popStyle();
  */

  image(foregroundFramebuffer, 0, 0);
}
