import 'package:event_bus/event_bus.dart';

class FilePathEvent {
  String path;
  FilePathEvent(this.path);
}

class FilesPushEvent {}

class Bus {
  EventBus event;
  factory Bus() => _getInstance();

  static Bus get instance => _getInstance();

  static Bus _instance;

  Bus._internal() {
    event = EventBus();
  }

  static Bus _getInstance() {
    if (_instance == null) {
      _instance = Bus._internal();
    }
    return _instance;
  }
}
