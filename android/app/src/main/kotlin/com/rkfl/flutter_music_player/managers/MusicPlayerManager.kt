package com.rkfl.flutter_music_player.managers

import android.content.Context
import android.media.MediaPlayer
import android.provider.MediaStore
import android.util.Log
import com.rkfl.flutter_music_player.models.AudioModel

object MusicPlayerManager {

    private const val CODE_OK = 0
    private const val CODE_NG = -1

    private var mMediaPlayer: MediaPlayer? = null

    private var mAudioList: HashMap<Int, AudioModel> = HashMap()

    private lateinit var mAudioPlaybackIDs: IntArray

    private var mCurrentAudioPlaybackIdx = -1

    /**
     *
     */
    fun getAllAudioFromDevice(context: Context): List<String> {
        val tempAudioList = ArrayList<String>()

        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
                MediaStore.Audio.AudioColumns.DATA,
                MediaStore.Audio.AudioColumns.TITLE,
                MediaStore.Audio.AudioColumns.ALBUM,
                MediaStore.Audio.ArtistColumns.ARTIST,
                MediaStore.Audio.AudioColumns.DURATION
        )
        /*val c = context.contentResolver.query(
                uri,
                projection,
                MediaStore.Audio.Media.DATA + " like ? ",
                arrayOf("%utm%"),
                null
        )*/
        val c = context.contentResolver.query(
                uri,
                projection,
                MediaStore.Audio.Media.IS_MUSIC,
                null,
                null
        )

        Log.i("SHIT", ">>> 1.) Content Resolver :$c")

        if (c != null) {
            Log.i("SHIT", "HAS NEXT? :${c.count}")

            mAudioList.clear()

            var idCnt = -1
            while (c.moveToNext()) {
                val audioModel = AudioModel(
                        ++idCnt,
                        c.getString(0),
                        c.getString(1),
                        c.getString(2),
                        c.getString(3),
                        c.getInt(4)
                )

                Log.i("Name :${audioModel.name}", " Album :${audioModel.album}")
                Log.i("Path :${audioModel.path}", " Artist :${audioModel.artist}")

                mAudioList[audioModel.id] = audioModel
                tempAudioList.add(audioModel.toString())
            }

            mAudioPlaybackIDs = mAudioList.keys.toIntArray()

            c.close()
        }

        /*val selection = MediaStore.Audio.Media.IS_MUSIC + " != 0"

        val projection = arrayOf(
                MediaStore.Audio.AudioColumns.DATA,
                MediaStore.Audio.AudioColumns.TITLE,
                MediaStore.Audio.AudioColumns.ALBUM,
                MediaStore.Audio.ArtistColumns.ARTIST
        )
        val cursor = this.managedQuery(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                null, null)

        Log.e("SHIT", "Content Resolver :$cursor")
        Log.e("SHIT", "HAS NEXT? :${cursor.count}")

        val songs = ArrayList<String>()
        while (cursor.moveToNext()) {
            val shit = cursor.getString(0) + "||" + cursor.getString(1) + "||" + cursor.getString(2) + "||" + cursor.getString(3);
            Log.e("SHIT", "shit :$shit")
            songs.add(shit)
        }*/

        return tempAudioList
    }

    /**
     *
     */
    fun playAll() : IntArray {
        return play(mAudioPlaybackIDs[
                if (mCurrentAudioPlaybackIdx == -1) ++mCurrentAudioPlaybackIdx else mCurrentAudioPlaybackIdx]
        )
    }

    /**
     *
     */
    fun pause() : Int {
        if (mMediaPlayer == null || !mMediaPlayer!!.isPlaying) {
            return CODE_NG
        }

        mMediaPlayer!!.pause()

        return CODE_OK
    }

    /**
     *
     */
    fun resume() : Int {
        if (mMediaPlayer == null || mMediaPlayer!!.isPlaying) {
            return CODE_NG
        }

        mMediaPlayer!!.start()

        return CODE_OK
    }

    /**
     *
     */
    fun playShuffle() : IntArray {
        mAudioPlaybackIDs = mAudioPlaybackIDs.toList().shuffled().toIntArray()
        return play(mAudioPlaybackIDs[
                if (mCurrentAudioPlaybackIdx == -1) ++mCurrentAudioPlaybackIdx else mCurrentAudioPlaybackIdx]
        )
    }

    /**
     *
     */
    fun playMusicFile(id: Int) : IntArray {
        mCurrentAudioPlaybackIdx = mAudioPlaybackIDs.indexOf(id)
        return play(mAudioPlaybackIDs[mCurrentAudioPlaybackIdx])
    }

    /**
     *
     */
    fun seekTo(time: Int) : Int {
        if (mMediaPlayer == null) {
            return CODE_NG
        }

        mMediaPlayer!!.seekTo(time)
        return CODE_OK
    }

    /**
     *
     */
    fun previous() : IntArray {
        if (mCurrentAudioPlaybackIdx > 0) {
            --mCurrentAudioPlaybackIdx
        }
        return play(mAudioPlaybackIDs[mCurrentAudioPlaybackIdx])
    }

    /**
     *
     */
    fun next() : IntArray {
        if (mCurrentAudioPlaybackIdx < mAudioPlaybackIDs.size - 1) {
            ++mCurrentAudioPlaybackIdx
        }
        return play(mAudioPlaybackIDs[mCurrentAudioPlaybackIdx])
    }

    /**
     *
     */
    private fun createStartMediaPlayer() : Int {
        if (mMediaPlayer != null) {
            if (mMediaPlayer!!.isPlaying) {
                return 1
            }

            return 0
        }

        //val audioUri = Uri.parse(mAudioList[mCurrentAudioId]?.path)
        //mMediaPlayer = MediaPlayer.create(context, audioUri)
        //mMediaPlayer!!.start() // no need to call prepare(); create() does that for you
        mMediaPlayer = MediaPlayer()

        mMediaPlayer!!.setOnCompletionListener {
            if (mCurrentAudioPlaybackIdx == mAudioList.size - 1) {
                mCurrentAudioPlaybackIdx = -1
            }

            it.reset()
            val audioId = mAudioPlaybackIDs[++mCurrentAudioPlaybackIdx]
            it.setDataSource(mAudioList[audioId]?.path)
            it.prepare()
            it.start()

            MethodChannelManager.invokeMethod(
                    MethodChannelManager.ACTION_UPDATE_CURRENT_AUDIO,
                    intArrayOf(audioId, it.duration)
            )
        }

        return 0
    }

    /**
     *
     */
    private fun play(audioId: Int) : IntArray {
        val audioPath = mAudioList[audioId]?.path!!
        setDataSourceAndStart(audioPath)
        return intArrayOf(audioId, mMediaPlayer!!.duration)
    }

    /**
     *
     */
    private fun setDataSourceAndStart(path: String) : Int {
        val ret = createStartMediaPlayer()

        mMediaPlayer!!.stop()
        mMediaPlayer!!.reset()
        mMediaPlayer!!.setDataSource(path)
        mMediaPlayer!!.prepare()
        mMediaPlayer!!.start()

        return CODE_OK
    }

}