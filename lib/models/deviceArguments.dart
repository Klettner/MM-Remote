class DeviceArguments {
  String deviceName;
  String ip;
  String port;
  String apiKey;

  DeviceArguments(this.deviceName, this.ip, this.port, this.apiKey);

  DeviceArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    ip = map[ip];
    port = map[port];
    apiKey = map[apiKey];
  }
}