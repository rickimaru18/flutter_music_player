import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_music_player/models/AudioModel.dart';

class MediaPlayerBloc {

  static const String _ACTION_GET_MUSIC_FILES = 'getMusicFiles';
  static const String _ACTION_PLAY_ALL = 'playAll';
  static const String _ACTION_PAUSE = 'pause';
  static const String _ACTION_RESUME = 'resume';
  static const String _ACTION_PLAY_SHUFFLE = 'playShuffle';
  static const String _ACTION_PLAY_MUSIC_FILE = 'playMusicFile';
  static const String _ACTION_SEEK_TO = 'seekTo';
  static const String _ACTION_PREVIOUS = 'previous';
  static const String _ACTION_NEXT = 'next';

  static const int _CODE_OK = 0;
  static const int _CODE_NG = -1;

  static const _SEC = const Duration(seconds: 1);

  static const _platform = const MethodChannel('com.rkfl.flutter_music_player/music');

  final _musicFilesStateController = StreamController<List<AudioModel>>();
  Sink<List<AudioModel>> get _musicFilesSink => _musicFilesStateController.sink;
  Stream<List<AudioModel>> get musicFiles => _musicFilesStateController.stream;

  //final _counterEventController = StreamController<CounterEvent>();
  // For events, exposing only a sink which is an input
  //Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  final _currentAudioStateController = StreamController<AudioModel>();
  Sink<AudioModel> get _currentAudioSink => _currentAudioStateController.sink;
  Stream<AudioModel> get currentAudio => _currentAudioStateController.stream;

  final _playbackTimeStateController = StreamController<double>();
  Sink<double> get playbackTimeSink => _playbackTimeStateController.sink;
  Stream<double> get playbackTime => _playbackTimeStateController.stream;

  final _playbackDurationStateController = StreamController<double>();
  Stream<double> get playbackDuration => _playbackDurationStateController.stream;

  final _isPlayingStateController = StreamController<int>();
  Sink<int> get _isPlayingSink => _isPlayingStateController.sink;
  Stream<int> get isPlaying => _isPlayingStateController.stream;

  List<AudioModel> _musicFiles = List<AudioModel>();

  AudioModel _currentAudio;

  Timer _playbackTimeTimer;

  double _playbackTime = 0.0;

  MediaPlayerBloc() {
    _isPlayingSink.add(-1);

    _platform.setMethodCallHandler((MethodCall method) {
      switch (method.method) {
        case 'updateCurrentAudio':
          Int32List args = method.arguments as Int32List;
          _updatePlaybackInfo(_musicFiles[args.elementAt(0)], true);
          break;
      }
    });
  }

  ///
  ///
  ///
  Future<void> getMusicFiles() async {
    try {
      final List<dynamic> result = await _platform.invokeListMethod(_ACTION_GET_MUSIC_FILES);
      print('Music files $result % .');

      _musicFiles.clear();
      _musicFiles.addAll(result.map(AudioModel.fromJson).toList());
      _musicFilesSink.add(_musicFiles);

      if (_currentAudio == null) {
        _currentAudio = _musicFiles.first;
        _currentAudioSink.add(_currentAudio);
      }
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
    }
  }

  ///
  ///
  ///
  Future<void> playAll() async {
    String musicFiles;

    try {
      final Int32List result = await _platform.invokeMethod(_ACTION_PLAY_ALL);

      if (result != null) {
        _updatePlaybackInfo(null, true);
      }

      musicFiles = 'Playing music successful: $result';
    } on PlatformException catch (e) {
      musicFiles = "Failed to get battery level: '${e.message}'.";
    }

    print(musicFiles);
  }

  ///
  ///
  ///
  Future<void> pause() async {
    try {
      final int result = await _platform.invokeMethod(_ACTION_PAUSE);

      if (result == _CODE_OK) {
        //_isPauseButtonPressed = true;

        if (_playbackTimeTimer != null && _playbackTimeTimer.isActive) {
          _playbackTimeTimer.cancel();
        }

        _isPlayingSink.add(0);
      }
    } on PlatformException catch (e) {
      print("Failed to pause: '${e.message}'.");
    }
  }

  ///
  ///
  ///
  Future<void> resume() async {
    try {
      final int result = await _platform.invokeMethod(_ACTION_RESUME);

      if (result == _CODE_OK) {
        //_isPauseButtonPressed = false;
        _playbackTimeTimer = Timer.periodic(_SEC, _handlePlaybackTimeTimeout);
        _isPlayingSink.add(1);
      }
    } on PlatformException catch (e) {
      print("Failed to resume: '${e.message}'.");
    }
  }

  ///
  ///
  ///
  Future<void> playShuffle() async {
    String musicFiles;

    try {
      final Int32List result = await _platform.invokeMethod(_ACTION_PLAY_SHUFFLE);

      if (result != null) {
        _updatePlaybackInfo(_musicFiles[result.elementAt(0)], true);
      }

      musicFiles = 'Playing music files shuffle: $result % .';
    } on PlatformException catch (e) {
      musicFiles = "Shuffling music files failed: '${e.message}'.";
    }

    print(musicFiles);
  }

  ///
  ///
  ///
  Future<void> playMusicFile(AudioModel audio) async {
    String musicFiles;

    try {
      final Int32List result = await _platform.invokeMethod(_ACTION_PLAY_MUSIC_FILE, audio.id);

      if (result != null) {
        _updatePlaybackInfo(audio, true);
      }

      musicFiles = 'Playing music file successful: $result';
    } on PlatformException catch (e) {
      musicFiles = "Failed to play music file: '${e.message}'.";
    }

    print(musicFiles);
  }

  ///
  ///
  ///
  Future<void> seekTo(double time) async {
    try {
      final int result = await _platform.invokeMethod(_ACTION_SEEK_TO, time.toInt());

      if (result == _CODE_OK) {
        _playbackTime = time;
      }
    } on PlatformException catch (e) {
      print("Seek to failed: '${e.message}'.");
    }
  }

  ///
  ///
  ///
  Future<void> previous() async {
    String musicFiles;

    try {
      final Int32List result = await _platform.invokeMethod(_ACTION_PREVIOUS);

      if (result != null) {
        _updatePlaybackInfo(_musicFiles[result.elementAt(0)], true);
      }

      musicFiles = 'Previous sucessful: $result';
    } on PlatformException catch (e) {
      musicFiles = "Previous failed: '${e.message}'.";
    }

    print(musicFiles);
  }

  ///
  ///
  ///
  Future<void> next() async {
    String musicFiles;

    try {
      final Int32List result = await _platform.invokeMethod(_ACTION_NEXT);

      if (result != null) {
        _updatePlaybackInfo(_musicFiles[result.elementAt(0)], true);
      }

      musicFiles = 'Next successful: $result';
    } on PlatformException catch (e) {
      musicFiles = "Next failed: '${e.message}'.";
    }

    print(musicFiles);
  }

  ///
  ///
  ///
  void _updatePlaybackInfo(AudioModel currentAudio, bool isPlaying) {
    if (_playbackTimeTimer != null && _playbackTimeTimer.isActive) {
      _playbackTimeTimer.cancel();
    }

    if (currentAudio != null) {
      _currentAudio = currentAudio;
      _currentAudioSink.add(_currentAudio);
    }

    _isPlayingSink.add(isPlaying ? 1 : 0);
    _playbackTime = 0.0;
    playbackTimeSink.add(0.0);
    _playbackTimeTimer = Timer.periodic(_SEC, _handlePlaybackTimeTimeout);
  }

  ///
  ///
  ///
  void _handlePlaybackTimeTimeout(Timer t) {  // callback function
    double playbackTimeTmp = _playbackTime + 1000.0;

    if (playbackTimeTmp >= _currentAudio.playbackDuration) {
      playbackTimeTmp = _currentAudio.playbackDuration;
      t.cancel();
    }

    _playbackTime = playbackTimeTmp;
    playbackTimeSink.add(_playbackTime);
  }

}