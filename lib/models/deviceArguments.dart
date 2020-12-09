class DeviceArguments {
  String deviceName;
  String ip;
  String apiKey;

  DeviceArguments(this.deviceName, this.ip, this.apiKey);

  DeviceArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    ip = map[ip];
    apiKey = map[apiKey];
  }
}