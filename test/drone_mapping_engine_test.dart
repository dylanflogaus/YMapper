import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ymapper/core/drone_mapping_engine.dart';

void main() {
  final engine = DroneMappingEngine(
    altitude: 50,
    forwardOverlap: 0.6,
    sideOverlap: 0.4,
    sensorWidth: 13.2,
    sensorHeight: 8.8,
    focalLength: 8.8,
    imageWidth: 4000,
    imageHeight: 3000,
    angle: 0,
    groundOffset: 0,
  );

  const center = LatLng(39.7833981, -75.6097506);
  const radius = 100.0;

  test('generates a closed circular path at the requested radius', () {
    final waypoints = engine.generateCircularWaypoints(center, radius);
    final distance = const Distance(roundResult: false);

    expect(waypoints.length, greaterThanOrEqualTo(13));
    expect(waypoints.first.latitude, closeTo(waypoints.last.latitude, 1e-9));
    expect(waypoints.first.longitude, closeTo(waypoints.last.longitude, 1e-9));

    for (final waypoint in waypoints.take(waypoints.length - 1)) {
      expect(
        distance.as(LengthUnit.Meter, center, waypoint),
        closeTo(radius, 0.01),
      );
    }
  });

  test('uses forward overlap to determine orbit point spacing', () {
    final waypoints = engine.generateCircularWaypoints(center, radius);
    final spacing = engine.footprintWidth * (1 - engine.forwardOverlap);
    final expectedPointCount =
        max(12, (2 * pi * radius / max(1.0, spacing)).ceil());

    expect(waypoints.length, expectedPointCount + 1);
  });
  test('calculates circular area and inward aircraft bearings', () {
    expect(
      DroneMappingEngine.calculateCircleArea(radius),
      closeTo(pi * radius * radius, 1e-9),
    );
    expect(
      DroneMappingEngine.bearingTo(LatLng(0, 1), LatLng(0, 0)),
      closeTo(270, 1e-9),
    );
    expect(DroneMappingEngine.normalizeHeading(270), closeTo(-90, 1e-9));
    expect(
      DroneMappingEngine.calculateOrbitPoiAltitude(
        flightAltitude: 50,
        radiusMeters: 100,
        cameraAngle: -45,
      ),
      closeTo(-50, 1e-9),
    );
  });
}
