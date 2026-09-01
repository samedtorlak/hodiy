import 'package:adhan/adhan.dart';

double qiblaBearing(double lat, double lon) {
  return Qibla(Coordinates(lat, lon)).direction;
}
