import 'package:litchi_waypoint_engine/engine.dart';
import 'package:test/test.dart';

void main() {
  test('serializes an explicit aircraft heading', () {
    final csv = LitchiCsv.generateCsv([
      const Waypoint(
        latitude: 39.7833981,
        longitude: -75.6097506,
        altitude: 50,
        speed: 4,
        heading: 270,
      ),
    ]);

    final row = csv.split('\r\n').last.split(',');
    expect(row[3], equals('270.0'));
  });

  test('serializes a focus POI waypoint', () {
    final csv = LitchiCsv.generateCsv([
      const Waypoint(
        latitude: 39.784,
        longitude: -75.61,
        altitude: 50,
        speed: 4,
        gimbalMode: GimbalMode.focusPoi,
        poi: Poi(
          latitude: 39.7833981,
          longitude: -75.6097506,
          altitude: -50,
        ),
      ),
    ]);

    final row = csv.split('\r\n').last.split(',');
    expect(row[6], equals('1'));
    expect(row[7], equals('0'));
    expect(row[10], equals('39.7833981'));
    expect(row[11], equals('-75.6097506'));
    expect(row[12], equals('-50'));
  });
}
