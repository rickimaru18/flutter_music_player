import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

import 'models/AudioModel.dart';
import 'blocs/MediaPlayerBloc.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((res) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XTN Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: Color(0xff9c11a9),
        primaryColorLight: Color(0xffce8ed4),
        primaryColorDark: Color(0xff6b0595),
        backgroundColor: Color(0xfff3e4f4),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  final _MEDIA_PLAYER_BLOC = MediaPlayerBloc();

  @override
  void initState() {
    super.initState();

    _setupPermission();
  }

  ///
  ///
  ///
  void _setupPermission() async {
    final permissionHandler = PermissionHandler();
    final PermissionStatus permission = await permissionHandler
        .checkPermissionStatus(PermissionGroup.storage);
    print("permission is " + permission.toString());

    if (permission == PermissionStatus.disabled ||
        permission == PermissionStatus.denied) {
      final List<PermissionGroup> permissions = List<PermissionGroup>();
      permissions.add(PermissionGroup.storage);
      final Map<PermissionGroup,
          PermissionStatus> status = await permissionHandler.requestPermissions(
          permissions);

      status.forEach((permissionGroup, status) {
        switch (status) {
          case PermissionStatus.granted:
            _MEDIA_PLAYER_BLOC.getMusicFiles();
            break;

          case PermissionStatus.denied:
            print("DENIED T_T");
            _exitApp();
            break;

          default:
            break;
        }
      });
    }
    else if (permission == PermissionStatus.granted) {
      _MEDIA_PLAYER_BLOC.getMusicFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: localTheme.backgroundColor,
      appBar: this._buildAppBar(),
      body: Column(
        children: <Widget>[
          this._buildMusicList(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2.0,
        highlightElevation: 0,
        backgroundColor: localTheme.primaryColorDark,
        child: const Icon(Icons.shuffle),
        onPressed: _MEDIA_PLAYER_BLOC.playShuffle,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4.0,
        color: localTheme.primaryColor,
        child: this._buildMusicControls(context),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    print("DISPOSE");
  }

  ///
  ///
  ///
  Widget _buildAppBar() {
    return AppBar(
      //title: Text(widget.title),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme
            .of(context)
            .primaryColor,
        onPressed: () {

        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.menu),
          color: Theme
              .of(context)
              .primaryColor,
          onPressed: () {

          },
        )
      ],
    );
  }

  ///
  ///
  ///
  Widget _buildMusicList(BuildContext context) {
    final localTheme = Theme.of(context);

    return Expanded(
      child: RefreshIndicator(
        child: StreamBuilder(
          stream: _MEDIA_PLAYER_BLOC.musicFiles,
          initialData: List<AudioModel>(),
          builder: (BuildContext context,
              AsyncSnapshot<List<AudioModel>> snapshot) {
            final musicFilesTmp = snapshot.data;

            return ListView.builder(
              itemCount: musicFilesTmp.length,
              itemBuilder: (context, index) {
                return ListTileTheme(
                  selectedColor: localTheme.primaryColorLight,
                  child: ListTile(
                    title: Text(
                      '${musicFilesTmp[index].name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('Album: ${musicFilesTmp[index].album}'),
                    selected: false, // TODO:
                    onTap: () {
                      _MEDIA_PLAYER_BLOC.playMusicFile(musicFilesTmp[index]);
                    },
                  ),
                );
              },
            );
          },
        ),
        onRefresh: _MEDIA_PLAYER_BLOC.getMusicFiles,
      ),
    );
  }

  ///
  ///
  ///
  Widget _buildMusicControls(BuildContext context) {
    final localTheme = Theme.of(context);

    return Container(
      height: 230.0,
      child: StreamBuilder(
        stream: _MEDIA_PLAYER_BLOC.currentAudio,
        initialData: AudioModel(),
        builder: (BuildContext context, AsyncSnapshot<AudioModel> snapshot) {
          final currentAudioTmp = snapshot.data;

          return Column(
            children: <Widget>[
              // song title
              Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0),
                  child: SizedBox(
                    height: 25.0,
                    child: Text(
                      currentAudioTmp == null
                          ? 'Song Title\n'
                          : '${currentAudioTmp.name}',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        letterSpacing: 1.0,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
              ),
              // artist
              Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                  child: Text(
                    currentAudioTmp == null ? 'Artist' : currentAudioTmp.album,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  )
              ),
              StreamBuilder(
                  stream: _MEDIA_PLAYER_BLOC.playbackTime,
                  initialData: 0.0,
                  builder: (BuildContext context,
                      AsyncSnapshot<double> snapshot) {
                    final playbackTimeTmp = snapshot.data;

                    return Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                        child: Slider(
                          inactiveColor: Colors.black12,
                          activeColor: Colors.white,
                          value: playbackTimeTmp,
                          // TODO: currentAudioTmp.playbackTime,
                          max: currentAudioTmp.playbackDuration,
                          onChangeEnd: _MEDIA_PLAYER_BLOC.seekTo,
                          onChanged: (val) {
                            _MEDIA_PLAYER_BLOC.playbackTimeSink.add(val);
                          },
                        )
                    );
                  }
              ),

              // control buttons
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Row(
                  children: <Widget>[
                    // previous button
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.skip_previous, size: 35.0),
                        color: Colors.white,
                        iconSize: 50.0,
                        onPressed: _MEDIA_PLAYER_BLOC.previous,
                      ),
                    ),
                    // play/pause button
                    StreamBuilder(
                      stream: _MEDIA_PLAYER_BLOC.isPlaying,
                      initialData: -1,
                      builder: (BuildContext context,
                          AsyncSnapshot<int> snapshot) {
                        final isPlayingTmp = snapshot.data;

                        return RawMaterialButton(
                          shape: const CircleBorder(),
                          fillColor: Colors.white,
                          splashColor: localTheme.primaryColorLight,
                          highlightColor: localTheme.primaryColorLight
                              .withOpacity(0.50),
                          elevation: 5.0,
                          highlightElevation: 5.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isPlayingTmp == 1 ? Icons.pause : Icons
                                  .play_arrow,
                              color: localTheme.primaryColorDark,
                              size: 35.0,
                            ),
                          ),
                          onPressed: isPlayingTmp == 1 ?
                          _MEDIA_PLAYER_BLOC.pause : isPlayingTmp == 0 ?
                          _MEDIA_PLAYER_BLOC.resume : _MEDIA_PLAYER_BLOC
                              .playAll,
                        );
                      },
                    ),
                    // next button
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.skip_next, size: 35.0),
                        color: Colors.white,
                        iconSize: 50.0,
                        onPressed: _MEDIA_PLAYER_BLOC.next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ///
  ///
  ///
  static Future<void> _exitApp() async {
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
  }

}