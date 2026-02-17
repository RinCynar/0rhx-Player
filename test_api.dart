import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

void main() async {
  print('Checking if readMetadata is async...');
  final file = File('non_existent_file.mp3'); // Just to see the return type
  final result = readMetadata(file);
  print('Result type: ${result.runtimeType}');
  if (result is Future) {
    print('readMetadata IS ASYNC!');
  } else {
    print('readMetadata IS SYNC!');
  }
}
