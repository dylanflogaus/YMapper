import 'package:xml/xml.dart';

import 'enums.dart';

/// Used for `takePhoto`,  `startRecord`, `stopRecord` actions
class CameraControlParams extends XmlElement {
  final int payloadPosition;

  CameraControlParams({required this.payloadPosition})
      : super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:payloadPositionIndex",
            children: [XmlText(payloadPosition.toString())],
          )
        ]);
}

class GimbalRotateParams extends XmlElement {
  final double pitch;
  final int payloadPosition;

  GimbalRotateParams({required this.pitch, required this.payloadPosition})
      : super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:gimbalPitchRotateAngle",
            children: [XmlText(pitch.toString())],
          ),
          XmlElement.tag(
            "wpml:payloadPositionIndex",
            children: [XmlText(payloadPosition.toString())],
          )
        ]);
}

class GimbalAbsoluteRotateParams extends XmlElement {
  final double pitch;
  final double yaw;
  final bool rotatePitch;
  final bool rotateYaw;
  final int payloadPosition;

  /// Seconds the gimbal action waits while the camera moves.
  ///
  /// A value of `0` completes the action immediately.
  final double rotateDuration;

  GimbalAbsoluteRotateParams({
    required this.pitch,
    required this.yaw,
    required this.payloadPosition,
    this.rotatePitch = true,
    this.rotateYaw = true,
    this.rotateDuration = 0,
  }) : super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:gimbalHeadingYawBase",
            children: [XmlText("north")],
          ),
          XmlElement.tag(
            "wpml:gimbalRotateMode",
            children: [XmlText("absoluteAngle")],
          ),
          XmlElement.tag(
            "wpml:gimbalPitchRotateEnable",
            children: [XmlText(rotatePitch ? "1" : "0")],
          ),
          XmlElement.tag(
            "wpml:gimbalPitchRotateAngle",
            children: [XmlText(pitch.toString())],
          ),
          XmlElement.tag(
            "wpml:gimbalRollRotateEnable",
            children: [XmlText("0")],
          ),
          XmlElement.tag(
            "wpml:gimbalRollRotateAngle",
            children: [XmlText("0")],
          ),
          XmlElement.tag(
            "wpml:gimbalYawRotateEnable",
            children: [XmlText(rotateYaw ? "1" : "0")],
          ),
          XmlElement.tag(
            "wpml:gimbalYawRotateAngle",
            children: [XmlText(yaw.toString())],
          ),
          XmlElement.tag(
            "wpml:gimbalRotateTimeEnable",
            children: [XmlText(rotateDuration > 0 ? "1" : "0")],
          ),
          XmlElement.tag(
            "wpml:gimbalRotateTime",
            children: [XmlText(rotateDuration.toString())],
          ),
          XmlElement.tag(
            "wpml:payloadPositionIndex",
            children: [XmlText(payloadPosition.toString())],
          ),
        ]);
}

class RotateYawParams extends XmlElement {
  /// Target aircraft yaw relative to geographic north, in degrees.
  ///
  /// `0` is north, `90` is east, and the valid range is `-180` through `180`.
  final double heading;
  final AircraftPathMode pathMode;

  RotateYawParams({
    required this.heading,
    this.pathMode = AircraftPathMode.clockwise,
  }) : super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:aircraftHeading",
            children: [XmlText(heading.toString())],
          ),
          XmlElement.tag(
            "wpml:aircraftPathMode",
            children: [XmlText(pathMode.name)],
          ),
        ]);
}

class HoverParams extends XmlElement {
  /// Time in seconds
  final num hoverTime;

  HoverParams({required this.hoverTime})
      : assert(hoverTime > 0, "Hover time can't be 0"),
        super(XmlName("wpml:actionActuatorFuncParam"), [], [
          XmlElement.tag(
            "wpml:hoverTime",
            children: [XmlText(hoverTime.toString())],
          )
        ]);
}
