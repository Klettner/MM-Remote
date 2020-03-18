class DeviceArguments {
  String deviceName;
  String ip;
  String port;

  DeviceArguments(this.deviceName, this.ip, this.port);

  DeviceArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    ip = map[ip];
    port = map[port];
  }
}