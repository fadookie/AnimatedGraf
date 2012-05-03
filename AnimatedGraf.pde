import megamu.mesh.*;

Voronoi myVoronoi;
Delaunay myDelaunay;
MPolygon[] myRegions;
float[][] points;
float[][] myEdges;

void setup() {
  size(800, 800);
  
  int numPoints = 20;
  
  points = new float[20][2];
  			
  for (int i = 0; i < points.length; i++) {
    points[i][0] = random(0, width); //point x
    points[i][1] = random(0, height); //point y
  }
  
  myVoronoi = new Voronoi( points );
  myRegions = myVoronoi.getRegions();
  
  myDelaunay = new Delaunay( points );
  myEdges = myDelaunay.getEdges();

}

void draw() {
  for(int i=0; i<myRegions.length; i++)
  {
  	// an array of points
  	float[][] regionCoordinates = myRegions[i].getCoords();
  	
  	fill(255,0,0);
  	myRegions[i].draw(this); // draw this shape
  }
  
  stroke(color(0, 255, 0));
  strokeWeight(2);
  
  for(int i=0; i<myEdges.length; i++)
  {
  	float startX = myEdges[i][0];
  	float startY = myEdges[i][1];
  	float endX = myEdges[i][2];
  	float endY = myEdges[i][3];
  	line( startX, startY, endX, endY );
  }
  
  for (int i = 0; i < points.length; i++) {
    float[] pointRow = points[i];
    for (int j = 0; j < pointRow.length; j++) {
      ellipse(pointRow[0], pointRow[1], 5, 5);
    }
  }
}
