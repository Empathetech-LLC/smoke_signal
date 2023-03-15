import 'constants.dart';

// Returns whether the passed path refers to one of the stored asset images
bool isAssetImage(String? path) {
  if (path == null || path == '') return false;

  final List<String> assetImages = [
    appIconPath,
    darkForestPath,
    smokeSignalPath,
  ];

  return assetImages.contains(path);
}
