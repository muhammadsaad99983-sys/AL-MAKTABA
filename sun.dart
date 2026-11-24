import 'dart:math' as math;

class SunPos {
  final double azimuth; // degrees from north, clockwise
  final double altitude; // degrees above the horizon
  const SunPos(this.azimuth, this.altitude);
}

SunPos sunPosition(DateTime when, double lat, double lon) {
  final double d = when.toUtc().millisecondsSinceEpoch / 86400000.0 - 10957.5;
  const double r = math.pi / 180;
  final double l = 280.460 + 0.9856474 * d;
  final double g = (357.528 + 0.9856003 * d) * r;
  final double lam = (l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)) * r;
  final double eps = (23.439 - 0.0000004 * d) * r;
  final double ra = math.atan2(math.cos(eps) * math.sin(lam), math.cos(lam));
  final double dec = math.asin(math.sin(eps) * math.sin(lam));
  final double gmst = 280.46061837 + 360.98564736629 * d;
  final double h = (gmst + lon) * r - ra;
  final double phi = lat * r;
  final double alt = math.asin(math.sin(phi) * math.sin(dec) + math.cos(phi) * math.cos(dec) * math.cos(h));
  final double a = math.atan2(math.sin(h), math.cos(h) * math.sin(phi) - math.tan(dec) * math.cos(phi));
  final double az = ((a / r) + 180) % 360;
  return SunPos(az < 0 ? az + 360 : az, alt / r);
}
