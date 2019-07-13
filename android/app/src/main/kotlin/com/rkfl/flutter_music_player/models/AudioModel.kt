package com.rkfl.flutter_music_player.models

data class AudioModel(
        val id: Int,
        val path: String,
        val name: String,
        val album: String,
        val artist: String,
        val playbackDuration: Int
) {

    override fun toString(): String {
        val sb = StringBuffer()

        sb.append("{")
        sb.append("\"id\": ").append(this.id).append(",")
        sb.append("\"path\": \"").append(this.path).append("\",")
        sb.append("\"name\": \"").append(this.name).append("\",")
        sb.append("\"album\": \"").append(this.album).append("\",")
        sb.append("\"artist\": \"").append(this.artist).append("\",")
        sb.append("\"playbackDuration\": ").append(this.playbackDuration)
        sb.append("}")

        return sb.toString()
    }

}