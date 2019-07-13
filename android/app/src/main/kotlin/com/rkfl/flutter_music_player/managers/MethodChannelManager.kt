package com.rkfl.flutter_music_player.managers

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterView

object MethodChannelManager {

    private const val CHANNEL = "com.rkfl.flutter_music_player/music"

    private const val ACTION_GET_MUSIC_FILES = "getMusicFiles"
    private const val ACTION_PLAY_ALL = "playAll"
    private const val ACTION_PAUSE = "pause"
    private const val ACTION_RESUME = "resume"
    private const val ACTION_PLAY_SHUFFLE = "playShuffle"
    private const val ACTION_PLAY_MUSIC_FILE = "playMusicFile"
    private const val ACTION_SEEK_TO = "seekTo"
    private const val ACTION_PREVIOUS = "previous"
    private const val ACTION_NEXT = "next"

    const val ACTION_UPDATE_CURRENT_AUDIO = "updateCurrentAudio"

    private lateinit var mMethodChannel: MethodChannel

    /**
     *
     */
    fun setupMethodChannel(flutterView: FlutterView, context: Context) {
        mMethodChannel = MethodChannel(flutterView, CHANNEL)

        mMethodChannel.setMethodCallHandler { methodCall, result ->
            var isSuccess = true
            lateinit var actionResult: Any

            when (methodCall.method) {
                ACTION_GET_MUSIC_FILES -> {
                    /*runBlocking {
                        async { getAllAudioFromDevice() }.await()
                    }*/

                    actionResult = MusicPlayerManager.getAllAudioFromDevice(context)
                    /*actionResult = actionResult.joinToString(
                            prefix = "[",
                            postfix = "]"
                    )*/
                    //result.error("UNAVAILABLE", "Battery level not available.", null)
                }
                ACTION_PLAY_ALL -> {
                    actionResult = MusicPlayerManager.playAll()
                }
                ACTION_PAUSE -> {
                    actionResult = MusicPlayerManager.pause()
                }
                ACTION_RESUME -> {
                    actionResult = MusicPlayerManager.resume()
                }
                ACTION_PLAY_SHUFFLE -> {
                    actionResult = MusicPlayerManager.playShuffle()
                }
                ACTION_PLAY_MUSIC_FILE -> {
                    actionResult = MusicPlayerManager.playMusicFile(methodCall.arguments as Int)
                }
                ACTION_SEEK_TO -> {
                    actionResult = MusicPlayerManager.seekTo(methodCall.arguments as Int)
                }
                ACTION_PREVIOUS -> {
                    actionResult = MusicPlayerManager.previous()
                }
                ACTION_NEXT -> {
                    actionResult = MusicPlayerManager.next()
                }
                else -> {
                    isSuccess = false
                    result.notImplemented()
                }
            }

            if (isSuccess) {
                result.success(actionResult)
            }
        }
    }

    /**
     *
     */
    fun invokeMethod(action: String, args: Any?) : Boolean {
        mMethodChannel?.invokeMethod(action, args)
        return mMethodChannel != null
    }

}