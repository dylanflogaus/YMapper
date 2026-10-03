import 'package:ymapper/core/drone_mapping_engine.dart';
import 'package:ymapper/presets/camera_preset.dart';
import 'package:dji_waypoint_engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Area missions fill a shape with a coverage pattern. Path missions fly
/// along a shape and capture from that path.
enum MissionType { area, path }

enum AreaShape { polygon }

enum PathShape { circle }

class ValueListenables extends ChangeNotifier {
  /// Altitude in meters
  final _altitude = ValueNotifier<int>(50);
  int get altitude => _altitude.value;
  set altitude(int value) {
    _altitude.value = value;
    notifyListeners();
  }

  /// Ground offset in metres (e.g., rooftop height above ground)
  final _groundOffset = ValueNotifier<int>(0);
  int get groundOffset => _groundOffset.value;
  set groundOffset(int value) {
    _groundOffset.value = value;
    notifyListeners();
  }

  /// Forward overlap in percentage
  final _forwardOverlap = ValueNotifier<int>(60);
  int get forwardOverlap => _forwardOverlap.value;
  set forwardOverlap(int value) {
    _forwardOverlap.value = value;
    notifyListeners();
  }

  /// Side overlap in percentage
  final _sideOverlap = ValueNotifier<int>(40);
  int get sideOverlap => _sideOverlap.value;
  set sideOverlap(int value) {
    _sideOverlap.value = value;
    notifyListeners();
  }

  final _rotation = ValueNotifier<int>(0);
  int get rotation => _rotation.value;
  set rotation(int value) {
    _rotation.value = value;
    notifyListeners();
  }

  /// Speed in m/s
  final _speed = ValueNotifier<double>(4.0);
  double get speed => _speed.value;
  set speed(double value) {
    _speed.value = value;
    notifyListeners();
  }

  final _cameraAngle = ValueNotifier<int>(-90);
  int get cameraAngle => _cameraAngle.value;
  set cameraAngle(int value) {
    _cameraAngle.value = value;
    notifyListeners();
  }

  /// Sensor width in mm
  final _sensorWidth = ValueNotifier<double>(13.2);
  double get sensorWidth => _sensorWidth.value;
  set sensorWidth(double value) {
    _sensorWidth.value = value;
    notifyListeners();
  }

  /// Sensor height in mm
  final _sensorHeight = ValueNotifier<double>(8.8);
  double get sensorHeight => _sensorHeight.value;
  set sensorHeight(double value) {
    _sensorHeight.value = value;
    notifyListeners();
  }

  /// Focal length in mm
  final _focalLength = ValueNotifier<double>(8.8);
  double get focalLength => _focalLength.value;
  set focalLength(double value) {
    _focalLength.value = value;
    notifyListeners();
  }

  /// Image width in pixels
  final _imageWidth = ValueNotifier<int>(4000);
  int get imageWidth => _imageWidth.value;
  set imageWidth(int value) {
    _imageWidth.value = value;
    notifyListeners();
  }

  /// Image height in pixels
  final _imageHeight = ValueNotifier<int>(3000);
  int get imageHeight => _imageHeight.value;
  set imageHeight(int value) {
    _imageHeight.value = value;
    notifyListeners();
  }

  /// Delay at waypoint in seconds
  final _delayAtWaypoint = ValueNotifier<int>(0);
  int get delayAtWaypoint => _delayAtWaypoint.value;
  set delayAtWaypoint(int value) {
    _delayAtWaypoint.value = value;
    notifyListeners();
  }

  /// Show point locations
  final _showPoints = ValueNotifier<bool>(false);
  bool get showPoints => _showPoints.value;
  set showPoints(bool value) {
    _showPoints.value = value;
    notifyListeners();
  }

  /// fill the generated flight grid with a crosshatch flight pattern
  final _fillGrid = ValueNotifier<bool>(false);
  bool get fillGrid => _fillGrid.value;
  set fillGrid(bool value) {
    _fillGrid.value = value;
    notifyListeners();
  }

  /// Create camera point locations
  final _createCameraPoints = ValueNotifier<bool>(false);
  bool get createCameraPoints => _createCameraPoints.value;
  set createCameraPoints(bool value) {
    _createCameraPoints.value = value;
    notifyListeners();
  }

  /// What to do when the mission is finished
  final _onFinished = ValueNotifier<FinishAction>(FinishAction.noAction);
  FinishAction get onFinished => _onFinished.value;
  set onFinished(FinishAction value) {
    _onFinished.value = value;
    notifyListeners();
  }

  /// What to do when the drone loses connection
  final _rcLostAction = ValueNotifier<RCLostAction>(RCLostAction.hover);
  RCLostAction get rcLostAction => _rcLostAction.value;
  set rcLostAction(RCLostAction value) {
    _rcLostAction.value = value;
    notifyListeners();
  }

  final _missionType = ValueNotifier<MissionType>(MissionType.area);
  MissionType get missionType => _missionType.value;
  set missionType(MissionType value) {
    if (_missionType.value == value) return;
    _missionType.value = value;
    _clearGeneratedFlight();
  }

  final _areaShape = ValueNotifier<AreaShape>(AreaShape.polygon);
  AreaShape get areaShape => _areaShape.value;
  set areaShape(AreaShape value) {
    if (_areaShape.value == value) return;
    _areaShape.value = value;
    _clearGeneratedFlight();
  }

  final _pathShape = ValueNotifier<PathShape>(PathShape.circle);
  PathShape get pathShape => _pathShape.value;
  set pathShape(PathShape value) {
    if (_pathShape.value == value) return;
    _pathShape.value = value;
    _clearGeneratedFlight();
  }

  bool get isPolygonArea =>
      missionType == MissionType.area && areaShape == AreaShape.polygon;

  bool get isCirclePath =>
      missionType == MissionType.path && pathShape == PathShape.circle;

  void _clearGeneratedFlight() {
    _photoLocations.value = [];
    _flightLine.value = null;
    _takeoffPath.value = null;
    _returnPath.value = null;
    notifyListeners();
  }

  /// Polygon of the area to map
  final _polygon = ValueNotifier<List<LatLng>>([]);
  List<LatLng> get polygon => _polygon.value;
  set polygon(List<LatLng> value) {
    _polygon.value = List<LatLng>.from(value);
    notifyListeners();
  }

  void addPolygonPoint(LatLng point) {
    _polygon.value = [..._polygon.value, point];
    notifyListeners();
  }

  void updatePolygonPoint(int index, LatLng point) {
    if (index < 0 || index >= _polygon.value.length) return;
    final updatedPolygon = List<LatLng>.from(_polygon.value);
    updatedPolygon[index] = point;
    _polygon.value = updatedPolygon;
    notifyListeners();
  }

  void removePolygonPoint(LatLng point) {
    final updatedPolygon = List<LatLng>.from(_polygon.value)..remove(point);
    _polygon.value = updatedPolygon;
    notifyListeners();
  }

  /// Center of the circular orbit.
  final _circleCenter = ValueNotifier<LatLng?>(null);
  LatLng? get circleCenter => _circleCenter.value;

  /// Radius of the circular orbit in meters.
  final _circleRadiusMeters = ValueNotifier<double?>(null);
  double? get circleRadiusMeters => _circleRadiusMeters.value;

  void setCircleCenter(LatLng? value) {
    _circleCenter.value = value;
    if (value == null) {
      _circleRadiusMeters.value = null;
    }
    notifyListeners();
  }

  void updateCircleCenter(LatLng value) {
    _circleCenter.value = value;
    notifyListeners();
  }

  void setCircleRadius(double? value) {
    _circleRadiusMeters.value = value != null && value > 0 ? value : null;
    notifyListeners();
  }

  void clearCircle() {
    _circleCenter.value = null;
    _circleRadiusMeters.value = null;
    notifyListeners();
  }

  bool get isCircularOrbit =>
      isCirclePath && circleCenter != null && circleRadiusMeters != null;

  bool get hasActiveGeometry {
    if (isCirclePath) return isCircularOrbit;
    return isPolygonArea && polygon.length > 2;
  }

  List<LatLng> get activeBoundary {
    if (isCirclePath) {
      if (!isCircularOrbit) return const [];
      return DroneMappingEngine.generateCircleBoundary(
          circleCenter!, circleRadiusMeters!);
    }
    return isPolygonArea ? polygon : const [];
  }

  /// User defined home point
  final _homePoint = ValueNotifier<LatLng?>(null);
  LatLng? get homePoint => _homePoint.value;
  set homePoint(LatLng? value) {
    _homePoint.value = value;
    notifyListeners();
  }

  /// List of photo markers
  final _photoLocations = ValueNotifier<List<LatLng>>([]);
  List<LatLng> get photoLocations => _photoLocations.value;
  set photoLocations(List<LatLng> value) {
    _photoLocations.value = value;
    notifyListeners();
  }

  /// Flight line
  final _flightLine = ValueNotifier<Polyline?>(null);
  Polyline? get flightLine => _flightLine.value;
  set flightLine(Polyline? value) {
    _flightLine.value = value;
    notifyListeners();
  }

  /// Takeoff line from home to first waypoint
  final _takeoffPath = ValueNotifier<Polyline?>(null);
  Polyline? get takeoffLine => _takeoffPath.value;
  set takeoffLine(Polyline? value) {
    _takeoffPath.value = value;
    notifyListeners();
  }

  /// Return line from last waypoint to home
  final _returnPath = ValueNotifier<Polyline?>(null);
  Polyline? get returnLine => _returnPath.value;
  set returnLine(Polyline? value) {
    _returnPath.value = value;
    notifyListeners();
  }

  int get generatedPointCount {
    if (isCircularOrbit && _photoLocations.value.length > 1) {
      return _photoLocations.value.length - 1;
    }
    return _photoLocations.value.length;
  }

  void clearPlanningGeometry() {
    _polygon.value = [];
    _circleCenter.value = null;
    _circleRadiusMeters.value = null;
    _homePoint.value = null;
    _photoLocations.value = [];
    _flightLine.value = null;
    _takeoffPath.value = null;
    _returnPath.value = null;
    notifyListeners();
  }

  final _selectedCameraPreset = ValueNotifier<CameraPreset?>(null);
  CameraPreset? get selectedCameraPreset => _selectedCameraPreset.value;
  set selectedCameraPreset(CameraPreset? value) {
    _selectedCameraPreset.value = value;
  }

  void notify() => notifyListeners();
}
