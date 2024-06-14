Map<String, List<String>> convertMap(Map<String, dynamic> mapData) {
  return mapData.map((key, value) {
    return MapEntry(key, List<String>.from(value));
  });
}

Map<String, String> convertMap2(Map<String, dynamic> mapData) {
  return mapData.map((key, value) {
    return MapEntry(key, value.toString());
  });
}

List<String> convertList(List<dynamic> listData) {
  return List<String>.from(listData);
}
