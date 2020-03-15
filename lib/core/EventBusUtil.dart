import 'package:event_bus/event_bus.dart';

class FilePathEvent {
  String path;
  FilePathEvent(this.path);
}

class FilesPushEvent {}

class GlobalEventBus {
  EventBus event;
  factory GlobalEventBus() => _getInstance();

  static GlobalEventBus get instance => _getInstance();

  static GlobalEventBus _instance;

  GlobalEventBus._internal() {
    event = EventBus();
  }

  static GlobalEventBus _getInstance() {
    if (_instance == null) {
      _instance = GlobalEventBus._internal();
    }
    return _instance;
  }
}
