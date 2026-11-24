import 'package:flutter/foundation.dart';

class IdentifyProvider extends ChangeNotifier {
  static const int totalSteps = 4;

  int _currentStep = 0;
  bool? _scratchesGlass;
  String? _luster;
  bool? _magnetic;
  final List<String> _colors = [];

  int get currentStep => _currentStep;
  bool? get scratchesGlass => _scratchesGlass;
  String? get luster => _luster;
  bool? get magnetic => _magnetic;
  List<String> get colors => List.unmodifiable(_colors);

  bool get canGoNext {
    switch (_currentStep) {
      case 0:
        return _scratchesGlass != null;
      case 1:
        return _luster != null;
      case 2:
        return _magnetic != null;
      case 3:
        return _colors.isNotEmpty;
      default:
        return false;
    }
  }

  bool get isLastStep => _currentStep == totalSteps - 1;

  double get hardnessValue => _scratchesGlass == true ? 6.0 : 3.0;

  void setScratchesGlass(bool value) {
    _scratchesGlass = value;
    notifyListeners();
  }

  void setLuster(String value) {
    _luster = value;
    notifyListeners();
  }

  void setMagnetic(bool value) {
    _magnetic = value;
    notifyListeners();
  }

  void toggleColor(String color) {
    if (_colors.contains(color)) {
      _colors.remove(color);
    } else {
      _colors.add(color);
    }
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1 && canGoNext) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 0;
    _scratchesGlass = null;
    _luster = null;
    _magnetic = null;
    _colors.clear();
    notifyListeners();
  }
}
