import 'dart:convert';

class AudioModel {

  final int id;
  final String path;
  final String name;
  final String album;
  final String artist;
  final double playbackDuration;

  AudioModel([
      this.id = 0,
      this.path = "",
      this.name = "",
      this.album = "",
      this.artist = "",
      this.playbackDuration = 0.0
  ]);

  static AudioModel fromJson(dynamic json) {
    dynamic jsonTmp = jsonDecode(json);

    return AudioModel(
        jsonTmp['id'],
        jsonTmp['path'],
        jsonTmp['name'],
        jsonTmp['album'],
        jsonTmp['artist'],
        jsonTmp['playbackDuration'].toDouble()
    );
  }

}