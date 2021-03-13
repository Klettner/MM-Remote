import 'package:hive/hive.dart';
import 'package:mm_remote/models/deviceArguments.dart';

void deleteDeviceArguments(String deviceName) {
  final deviceArgumentsBox = Hive.box('deviceArguments');

  deviceArgumentsBox.delete(deviceName);
}

Iterable<dynamic> getAllDeviceArguments() {
  final deviceArgumentsBox = Hive.box('deviceArguments');
  return deviceArgumentsBox.values;
}

void persistDeviceArguments(DeviceArguments device) {
  final deviceArgumentsBox = Hive.box('deviceArguments');
  deviceArgumentsBox.put(device.deviceName, device);
}

DeviceArguments getDeviceArgument(String deviceName) {
  final deviceArgumentsBox = Hive.box('deviceArguments');
  return deviceArgumentsBox.get(deviceName);
}

void updateApiKey(String deviceName, String apiKey) {
  DeviceArguments deviceArguments = Hive.box('deviceArguments').get(deviceName);
  deviceArguments.apiKey = apiKey;
  deviceArguments.save();
}
