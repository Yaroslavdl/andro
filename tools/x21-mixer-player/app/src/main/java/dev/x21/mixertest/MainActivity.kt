package dev.x21.mixertest

import android.app.Activity
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Bundle
import android.os.Process
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.PI
import kotlin.math.sin

class MainActivity : Activity() {
    private val sampleRate = 48000
    private var track: AudioTrack? = null
    private var worker: Thread? = null
    private val running = AtomicBoolean(false)
    private var playing = false
    private lateinit var status: TextView
    private lateinit var button: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        volumeControlStream = AudioManager.STREAM_MUSIC

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(48, 48, 48, 48)
        }
        status = TextView(this).apply {
            textSize = 24f
            gravity = Gravity.CENTER
            text = "PAUSED\n48 kHz / stereo / PCM 16-bit\nUSAGE_MEDIA / MODE_STREAM"
        }
        button = Button(this).apply {
            text = "PLAY"
            textSize = 28f
            setOnClickListener { toggle() }
        }
        layout.addView(status)
        layout.addView(button)
        setContentView(layout)
        createTrack()
    }

    private fun createTrack() {
        val min = AudioTrack.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val bufferBytes = maxOf(min, sampleRate / 5 * 2 * 2)
        track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
                    .build()
            )
            .setTransferMode(AudioTrack.MODE_STREAM)
            .setBufferSizeInBytes(bufferBytes)
            .build()

        running.set(true)
        worker = Thread({ writerLoop() }, "x21-mixer-player").apply {
            priority = Thread.MAX_PRIORITY
            start()
        }
    }

    private fun toggle() {
        val t = track ?: return
        if (!playing) {
            t.play()
            playing = true
            button.text = "PAUSE"
            status.text = "PLAYING\n48 kHz / stereo / PCM 16-bit\nVerify AudioFlinger says MIXER"
        } else {
            t.pause()
            playing = false
            button.text = "PLAY"
            status.text = "PAUSED\n48 kHz / stereo / PCM 16-bit\nHUR should be silent"
        }
    }

    private fun writerLoop() {
        Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO)
        val frames = 960
        val samples = ShortArray(frames * 2)
        var frameIndex = 0L
        while (running.get()) {
            val sec = frameIndex.toDouble() / sampleRate
            val blockSecond = sec.toInt() % 5
            val freq = if ((sec.toInt() / 5) % 2 == 0) 440.0 else 660.0
            for (i in 0 until frames) {
                val t = (frameIndex + i).toDouble() / sampleRate
                val s = if (blockSecond == 4) 0 else (sin(2.0 * PI * freq * t) * 6500.0).toInt()
                samples[i * 2] = s.toShort()
                samples[i * 2 + 1] = s.toShort()
            }
            val n = track?.write(samples, 0, samples.size, AudioTrack.WRITE_BLOCKING) ?: break
            if (n > 0) frameIndex += (n / 2)
        }
    }

    override fun onDestroy() {
        running.set(false)
        track?.pause()
        track?.flush()
        track?.release()
        track = null
        worker?.interrupt()
        super.onDestroy()
    }
}
