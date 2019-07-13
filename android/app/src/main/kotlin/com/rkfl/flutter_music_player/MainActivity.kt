package com.rkfl.flutter_music_player

import android.os.Bundle
import com.rkfl.flutter_music_player.managers.MethodChannelManager
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannelManager.setupMethodChannel(flutterView, this)
    }

}
