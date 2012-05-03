import megamu.mesh.*;

int numPoints = 20; //Number of source points
float pointMinX, pointMinY, pointMaxX, pointMaxY; //Area in which source points can spawn and move
Point[] points; //Data structure containing source points for all graphs
Point[] sortedPoints; //Data structure containing source points for all graphs, sorted by Y height
float[][] floatPoints; //Data structure containing source points for all graphs in expected format by mesh lib

PVector[] origins; //The points on the screen that will serve as origins for the side triangles
PVector[][] intersections; //Where the rays cast from the origins to the hull points intersecting with the hull, indexed by origin
PVector[][] oldIntersections; //The previous intersections array
float lastTriangleDrawTimeMs;
float triangleDrawDelayMs = 25;

Voronoi myVoronoi;
Delaunay myDelaunay;
Hull myHull;

MPolygon[] myRegions; //MPolygon regions from the voronoi diagram
MPolygon myHullRegion; //MPolygon of the convex hull
float[][] myEdges; //Edges from delaunay diagram
int[] hullExtrema; //Indices to points array of the points which lie on the convex hull

PVectorYDescending pVectorYDescending; //Comparator for sorting arrays in descending order of PVector.y value
QMath qMath; //Fuck java, I wanted this to be static

//Frame buffers for compositing
PGraphics voronoiFramebuffer;
PGraphics midgroundFramebuffer;
PGraphics foregroundFramebuffer;

void setup() {
  size(1024, 800, OPENGL);

  pointMinX = width / 4;
  pointMinY = height / 4;
  pointMaxX = width - (width / 4);
  pointMaxY = height - (height / 4);

  voronoiFramebuffer = createGraphics(width, height, P2D);//createGraphics(width / 2, height / 2);
  midgroundFramebuffer = createGraphics(width, height, P2D);
  foregroundFramebuffer = createGraphics(width, height, P2D);
  
  int numPoints = 20;
  

  points = new Point[numPoints];
  for (int i = 0; i < points.length; i++ ){
    points[i] = new Point(
        random(pointMinX, pointMaxX),
        random(pointMinY, pointMaxY)
    );
  }

  origins = new PVector[2];
  origins[0] =  new PVector(0, height / 2); //leftOrigin
  origins[1] = new PVector(width, height / 2); //rightOrigin


  lastTriangleDrawTimeMs = (-triangleDrawDelayMs) - 100; //Force triangles to draw immediately
  oldIntersections = new PVector[origins.length][];

  floatPoints = new float[points.length][2];
  pVectorYDescending = new PVectorYDescending();
  qMath = new QMath();

  //Set up for first frame
  update();
  setupIntersections();

  //frameRate(0.5);
}

void drawRegions(PGraphics graphics, MPolygon[] regions, int strokeWeight, color strokeColor) {
  for(MPolygon region : regions)
  {
    // an array of points
    float[][] regionCoordinates = region.getCoords();
    graphics.strokeWeight(strokeWeight);
    graphics.stroke(strokeColor);
    region.draw(graphics); 
  }
}

void setupIntersections() {
  intersections = new PVector[origins.length][hullExtrema.length];

  for (int i = 0; i < hullExtrema.length; i++) {
    int pointIndex = hullExtrema[i];
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
    for (int j = 0; j < origins.length; j++) {
      PVector origin = origins[j];

      //Cast a ray from that point to the target
      Ray ray = new Ray();
      ray.setOrigin(origin);
      ray.setDirection(PVector.sub(point, origin));
      PVector intersection = new PVector();
      MutableFloat distance = new MutableFloat(0);
      boolean hit = qMath.RayCast(ray, myHullRegion, Float.MAX_VALUE, distance, intersection, null/*PVector normal*/);
      //println("ray: " + ray + " hit: " + hit + " dist: " + distance + " intersection: " + intersection);
      //stroke(0, 255, 0);
      //line(origin.x, origin.y, point.x, point.y);
      intersections[j][i] = intersection;
    }
  }
}

void update() {
  //Update point positions
  for (int i = 0; i < points.length; i++) {
    Point point = points[i];
    if (
        i == points.length - 1
        //false
        ) {
      //Set a point to the mouse
      point.x = mouseX;//constrain(mouseX, pointMinX, pointMaxX);
      point.y = mouseY;//constrain(mouseY, pointMinY, pointMaxY);
    } else {
      point.x += random(-5, 5);
      point.y += random(-5, 5);
      point.x = constrain(point.x, pointMinX, pointMaxX);
      point.y = constrain(point.y, pointMinY, pointMaxY);
    }
    point.isOnHull = false; //Assume we're not on the hull, if we are we'll get flagged later
  }

  //Sort point positions by Y order, descending
  sortedPoints = Arrays.copyOf(points, points.length);
  Arrays.sort(sortedPoints, pVectorYDescending);

  //Copy points data structure to floatPoints array for use by mesh library
  for (int i = 0; i < sortedPoints.length; i++) {
    Point point = sortedPoints[i];
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
}

void draw() {
  //=============UPDATE===============//
  update();
  
  //==============DRAW================//


  //===== voronoiFramebuffer draw ====//

  voronoiFramebuffer.beginDraw();

  voronoiFramebuffer.background(0, 128, 255);

  //Draw delaunay edges
  voronoiFramebuffer.pushStyle();
  voronoiFramebuffer.stroke(32, 68, 95);
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
  voronoiFramebuffer.strokeJoin(BEVEL);
  drawRegions(voronoiFramebuffer, myRegions, 16, color(0, 0, 0)); // draw black edge borders for edge lines
  drawRegions(voronoiFramebuffer, myRegions, 8, color(255, 255, 255)); // draw white edge lines
  voronoiFramebuffer.popStyle();
  voronoiFramebuffer.endDraw();


  //========== OPENGL draw ===========//

  background(60);


  //=== midgroundFramebuffer draw ====//

  //Draw side triangles
  midgroundFramebuffer.beginDraw();
  midgroundFramebuffer.background(0,0); //Refresh this buffer with pure 0% alpha
  midgroundFramebuffer.pushStyle();
  midgroundFramebuffer.noStroke();

  if ((millis() - lastTriangleDrawTimeMs) > triangleDrawDelayMs) {
    lastTriangleDrawTimeMs = millis();
    setupIntersections();
  }

  if (oldIntersections != null) {
    for (int i = 0; i < oldIntersections.length; i++) {
      PVector origin = origins[i];
      if (origin != null) {
        PVector[] intersectionsForOrigin  = oldIntersections[i];
        if (intersectionsForOrigin != null) {
          Arrays.sort(intersectionsForOrigin, pVectorYDescending);
          for (int j = 0; j < (intersectionsForOrigin.length - 1); j++) {
            PVector intersection = intersectionsForOrigin[j];
            PVector lowerIntersection = intersectionsForOrigin[j+1];
            if ((intersection == null) || (lowerIntersection == null)) {
              continue;
            }

            float jRGB = map(j, 0, intersectionsForOrigin.length, 0, 32);
            float frequency = 0.3;
            float red   = sin(frequency*jRGB + 0) * 127 + 128;
            float green = sin(frequency*jRGB + 2) * 127 + 128;
            float blue  = sin(frequency*jRGB + 4) * 127 + 128;

            midgroundFramebuffer.fill(red, green, blue); 
            midgroundFramebuffer.triangle(origin.x, origin.y, intersection.x, intersection.y, lowerIntersection.x, lowerIntersection.y);
          }
        }
        oldIntersections = Arrays.copyOf(intersections, intersections.length);
      }
    }
  } else {
    oldIntersections = intersections;
  }
  midgroundFramebuffer.popStyle();
  midgroundFramebuffer.endDraw();


  //========== OPENGL draw ===========//

  image(midgroundFramebuffer, 0, 0);

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


  //=== foregroundFramebuffer draw ===//

  foregroundFramebuffer.beginDraw();

  foregroundFramebuffer.background(0,0); //Refresh this buffer with pure 0% alpha
  foregroundFramebuffer.stroke(255, 0, 0);

  //Draw convex hull outline
  foregroundFramebuffer.pushStyle();
  foregroundFramebuffer.noFill();
  foregroundFramebuffer.strokeWeight(16);
  foregroundFramebuffer.stroke(0, 0, 0);
  myHullRegion.draw(foregroundFramebuffer);
  foregroundFramebuffer.strokeWeight(8);
  foregroundFramebuffer.stroke(255, 255, 255);
  myHullRegion.draw(foregroundFramebuffer);
  foregroundFramebuffer.popStyle();

  //Draw mouse cursor dot
  foregroundFramebuffer.pushStyle();
  foregroundFramebuffer.noStroke();
  foregroundFramebuffer.fill(255, 172, 47);
  foregroundFramebuffer.ellipse(mouseX, mouseY, 10, 10);
  foregroundFramebuffer.popStyle();

  foregroundFramebuffer.endDraw();


  //========== OPENGL draw ===========//

  //Draw origin points
  /*
  pushStyle();
  noStroke();
  int _color = 0;
  for (Point point : sortedPoints) {
    fill(0, _color, 0);
    ellipse(point.x, point.y, 10, 10);
    _color += 10;
  }
  popStyle();
  */

  //Finally, draw the foregroundFramebuffer to our native OPENGL PGraphics
  image(foregroundFramebuffer, 0, 0);
}
