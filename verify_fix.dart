import 'dart:typed_data';

// Mocking the structure that was causing issues
class MockPicture {
  final Uint8List? bytes;
  final Uint8List? pictureData;
  final Uint8List? data;

  MockPicture({this.bytes, this.pictureData, this.data});
}

class MockMetadata {
  final List<MockPicture>? pictures;
  final Uint8List? image;
  final Uint8List? coverImage;

  MockMetadata({this.pictures, this.image, this.coverImage});
}

// Logic extracted from file_scanner_service.dart for verification
Uint8List? verifyGetMetadataImage(dynamic metadata) {
  try {
    if (metadata == null) return null;

    if (metadata.pictures != null && (metadata.pictures as List).isNotEmpty) {
      final picture = (metadata.pictures as List).first;

      try {
        if (picture.bytes is Uint8List) {
          return picture.bytes as Uint8List;
        }
      } catch (_) {}

      try {
        if (picture.pictureData is Uint8List) {
          return picture.pictureData as Uint8List;
        }
      } catch (_) {}

      try {
        if (picture.data is Uint8List) {
          return picture.data as Uint8List;
        }
      } catch (_) {}
    }

    try {
      if (metadata.image is Uint8List) {
        return metadata.image as Uint8List;
      }
    } catch (_) {}

    try {
      if (metadata.coverImage is Uint8List) {
        return metadata.coverImage as Uint8List;
      }
    } catch (_) {}
  } catch (e) {
    print('Error: $e');
  }
  return null;
}

void main() {
  final testBytes = Uint8List.fromList([1, 2, 3]);

  print('Test 1: Access via .bytes');
  final meta1 = MockMetadata(pictures: [MockPicture(bytes: testBytes)]);
  assert(verifyGetMetadataImage(meta1) == testBytes);
  print('Test 1 Passed');

  print('Test 2: Access via .pictureData (fallback)');
  final meta2 = MockMetadata(pictures: [MockPicture(pictureData: testBytes)]);
  assert(verifyGetMetadataImage(meta2) == testBytes);
  print('Test 2 Passed');

  print('Test 3: Access via .data (fallback)');
  final meta3 = MockMetadata(pictures: [MockPicture(data: testBytes)]);
  assert(verifyGetMetadataImage(meta3) == testBytes);
  print('Test 3 Passed');

  print('Test 4: Access via .image (metadata level)');
  final meta4 = MockMetadata(image: testBytes);
  assert(verifyGetMetadataImage(meta4) == testBytes);
  print('Test 4 Passed');

  print('Verification Finished Successfully!');
}
