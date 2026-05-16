package com.example.xen2

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class ImuPlugin : FlutterPlugin {
    private lateinit var sensorManager: SensorManager
    private val channels = mutableListOf<EventChannel>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        sensorManager = binding.applicationContext
            .getSystemService(Context.SENSOR_SERVICE) as SensorManager

        val messenger = binding.binaryMessenger

        channels += EventChannel(messenger, "imu_fusion/accelerometer").also {
            it.setStreamHandler(RawSensorHandler(sensorManager, Sensor.TYPE_ACCELEROMETER))
        }
        channels += EventChannel(messenger, "imu_fusion/gyroscope").also {
            it.setStreamHandler(RawSensorHandler(sensorManager, Sensor.TYPE_GYROSCOPE))
        }
        channels += EventChannel(messenger, "imu_fusion/magnetometer").also {
            it.setStreamHandler(RawSensorHandler(sensorManager, Sensor.TYPE_MAGNETIC_FIELD))
        }
        // OS フュージョン済み姿勢データ（内部でカルマンフィルタ等を使用）
        channels += EventChannel(messenger, "imu_fusion/attitude").also {
            it.setStreamHandler(RotationVectorHandler(sensorManager))
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channels.forEach { it.setStreamHandler(null) }
        channels.clear()
    }
}

private class RawSensorHandler(
    private val sensorManager: SensorManager,
    private val sensorType: Int,
) : EventChannel.StreamHandler {

    private var listener: SensorEventListener? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val sensor = sensorManager.getDefaultSensor(sensorType)
        if (sensor == null) {
            events.error("UNAVAILABLE", "Sensor type $sensorType not available on this device", null)
            return
        }

        listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                val payload = mapOf(
                    "x" to event.values[0].toDouble(),
                    "y" to event.values[1].toDouble(),
                    "z" to event.values[2].toDouble(),
                    "timestamp" to System.currentTimeMillis(),
                )
                mainHandler.post { events.success(payload) }
            }

            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
        }

        sensorManager.registerListener(
            listener,
            sensor,
            SensorManager.SENSOR_DELAY_GAME,
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(listener)
        listener = null
    }
}

private class RotationVectorHandler(
    private val sensorManager: SensorManager,
) : EventChannel.StreamHandler {

    private var listener: SensorEventListener? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        if (sensor == null) {
            events.error("UNAVAILABLE", "Rotation vector sensor not available on this device", null)
            return
        }

        listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                val q = FloatArray(4)
                SensorManager.getQuaternionFromVector(q, event.values)

                val rotMatrix = FloatArray(9)
                SensorManager.getRotationMatrixFromVector(rotMatrix, event.values)
                val orientation = FloatArray(3) // [azimuth, pitch, roll]
                SensorManager.getOrientation(rotMatrix, orientation)

                val payload = mapOf(
                    "qw" to q[0].toDouble(),
                    "qx" to q[1].toDouble(),
                    "qy" to q[2].toDouble(),
                    "qz" to q[3].toDouble(),
                    "yaw"   to orientation[0].toDouble(),
                    "pitch" to orientation[1].toDouble(),
                    "roll"  to orientation[2].toDouble(),
                    "timestamp" to System.currentTimeMillis(),
                )
                mainHandler.post { events.success(payload) }
            }

            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
        }

        sensorManager.registerListener(
            listener,
            sensor,
            SensorManager.SENSOR_DELAY_GAME,
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(listener)
        listener = null
    }
}
