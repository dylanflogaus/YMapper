import 'package:dji_waypoint_engine/engine.dart';
import 'package:test/test.dart';

void main() {
  test('serializes a POI heading target', () {
    final heading = HeadingParam(
      headingMode: HeadingMode.towardPOI,
      poiPoint: PoiPoint(
        longitude: -75.6097506,
        latitude: 39.7833981,
        height: 0,
      ),
      headingPathMode: HeadingPathMode.followBadArc,
    );

    final xml = heading.toXmlString();

    expect(xml, contains('<wpml:waypointHeadingMode>towardPOI'));
    expect(
        xml, contains('<wpml:waypointPoiPoint>-75.609751,39.783398,0.000000'));
  });

  test('serializes a numeric smooth heading angle', () {
    final heading = HeadingParam(
      headingMode: HeadingMode.smoothTransition,
      headingAngle: -152,
      headingAngleEnable: true,
      headingPathMode: HeadingPathMode.followBadArc,
    );

    final xml = heading.toXmlString();

    expect(xml, contains('<wpml:waypointHeadingMode>smoothTransition'));
    expect(xml, contains('<wpml:waypointHeadingAngle>-152'));
    expect(xml, contains('<wpml:waypointHeadingAngleEnable>1'));
    expect(xml, isNot(contains('HeadingMode.smoothTransition')));
  });

  test('serializes persistent gimbal pitch with yaw before the photo', () {
    final placemark = Placemark(
      point: WaypointPoint(longitude: -75.6, latitude: 39.7),
      index: 1,
      height: 40,
      speed: 5,
      headingParam: HeadingParam(
        headingMode: HeadingMode.smoothTransition,
        headingAngle: 96,
        headingAngleEnable: true,
        headingPathMode: HeadingPathMode.followBadArc,
      ),
      turnParam: TurnParam(
        waypointTurnMode:
            WaypointTurnMode.toPointAndStopWithDiscontinuityCurvature,
        turnDampingDistance: 0,
      ),
      useStraightLine: true,
      gimbalHeadingParam: WaypointGimbalHeadingParam(pitch: -45, yaw: 0.0),
      actionGroup: ActionGroup(
        id: 1,
        startIndex: 1,
        endIndex: 1,
        mode: ActionMode.sequence,
        trigger: ActionTriggerType.reachPoint,
        actions: [
          Action(
            id: 3,
            actionFunction: ActionFunction.rotateYaw,
            actionParams: RotateYawParams(
              heading: 96,
              pathMode: AircraftPathMode.clockwise,
            ),
          ),
          Action(
            id: 4,
            actionFunction: ActionFunction.takePhoto,
            actionParams: CameraControlParams(payloadPosition: 0),
          ),
        ],
      ),
    );

    final xml = placemark.toXmlString();
    final yawIndex = xml.indexOf('<wpml:actionActuatorFunc>rotateYaw');
    final photoIndex = xml.indexOf('<wpml:actionActuatorFunc>takePhoto');

    expect(xml, contains('<wpml:waypointGimbalPitchAngle>-45.0'));
    expect(xml, contains('<wpml:waypointGimbalYawAngle>0.0'));
    expect(xml, contains('<wpml:aircraftHeading>96.0'));
    expect(xml, isNot(contains('gimbalRotate')));
    expect(yawIndex, greaterThanOrEqualTo(0));
    expect(photoIndex, greaterThan(yawIndex));
  });

  test('waits for the gimbal pitch to finish', () {
    final params = GimbalAbsoluteRotateParams(
      pitch: -45,
      yaw: 0,
      rotateYaw: false,
      rotateDuration: 2,
      payloadPosition: 0,
    );

    final xml = params.toXmlString();

    expect(xml, contains('<wpml:gimbalPitchRotateAngle>-45.0'));
    expect(xml, contains('<wpml:gimbalYawRotateEnable>0'));
    expect(xml, contains('<wpml:gimbalRotateTimeEnable>1'));
    expect(xml, contains('<wpml:gimbalRotateTime>2.0'));
  });

  test('serializes absolute gimbal pitch and yaw', () {
    final params = GimbalAbsoluteRotateParams(
      pitch: -45,
      yaw: 135,
      payloadPosition: 0,
    );

    final xml = params.toXmlString();

    expect(xml, contains('<wpml:gimbalRotateMode>absoluteAngle'));
    expect(xml, contains('<wpml:gimbalPitchRotateAngle>-45.0'));
    expect(xml, contains('<wpml:gimbalYawRotateAngle>135.0'));
  });
}
