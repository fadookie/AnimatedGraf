class PVectorYDescending implements Comparator {
  int compare(Object _vect1, Object _vect2) {
   if ((_vect1 == null) || (_vect2 == null)) {
     return 0;
   }
   PVector vect1 = (PVector) _vect1;
   PVector vect2 = (PVector) _vect2;
   return floor(vect1.y - vect2.y);
  }
}
