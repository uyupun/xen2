import Flutter
import CoreMotion

// MARK: - ImuPlugin

/// CoreMotion を EventChannel 経由で Flutter に公開するプラグイン。
/// CMMotionManager のインスタンスは Apple の推奨に従い 1 つのみ生成する。
final class ImuPlugin: NSObject {
    private let motionManager = CMMotionManager()
    /// センサーコールバックを受け取るキュー（メインスレッドを占有しない）
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.name = "imu_fusion.motion"
        q.maxConcurrentOperationCount = 1
        return q
    }()

    private static let updateInterval: TimeInterval = 1.0 / 100.0 // 100 Hz

    static func register(binaryMessenger: FlutterBinaryMessenger) -> ImuPlugin {
        let plugin = ImuPlugin()
        plugin.setupChannels(binaryMessenger: binaryMessenger)
        return plugin
    }

    private func setupChannels(binaryMessenger: FlutterBinaryMessenger) {
        let interval = ImuPlugin.updateInterval

        FlutterEventChannel(name: "imu_fusion/accelerometer", binaryMessenger: binaryMessenger)
            .setStreamHandler(AccelerometerHandler(manager: motionManager, queue: queue, interval: interval))

        FlutterEventChannel(name: "imu_fusion/gyroscope", binaryMessenger: binaryMessenger)
            .setStreamHandler(GyroscopeHandler(manager: motionManager, queue: queue, interval: interval))

        FlutterEventChannel(name: "imu_fusion/magnetometer", binaryMessenger: binaryMessenger)
            .setStreamHandler(MagnetometerHandler(manager: motionManager, queue: queue, interval: interval))

        // DeviceMotion は OS 内部のカルマンフィルタ済み姿勢データを提供する
        FlutterEventChannel(name: "imu_fusion/attitude", binaryMessenger: binaryMessenger)
            .setStreamHandler(AttitudeHandler(manager: motionManager, queue: queue, interval: interval))
    }
}

// MARK: - Helpers

private func currentMs() -> Int {
    Int(Date().timeIntervalSince1970 * 1000)
}

/// EventSink への書き込みはメインスレッドで行う
private func sendToSink(_ sink: @escaping FlutterEventSink, _ value: Any) {
    DispatchQueue.main.async { sink(value) }
}

// MARK: - AccelerometerHandler

private final class AccelerometerHandler: NSObject, FlutterStreamHandler {
    private let manager: CMMotionManager
    private let queue: OperationQueue
    private let interval: TimeInterval

    init(manager: CMMotionManager, queue: OperationQueue, interval: TimeInterval) {
        self.manager = manager
        self.queue = queue
        self.interval = interval
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard manager.isAccelerometerAvailable else {
            return FlutterError(code: "UNAVAILABLE", message: "Accelerometer not available", details: nil)
        }
        manager.accelerometerUpdateInterval = interval
        manager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard self != nil else { return }
            if let error = error {
                sendToSink(events, FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            guard let data = data else { return }
            // 単位: g → m/s² 変換 (1g = 9.81 m/s²)
            let g = 9.81
            sendToSink(events, [
                "x": data.acceleration.x * g,
                "y": data.acceleration.y * g,
                "z": data.acceleration.z * g,
                "timestamp": currentMs(),
            ])
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        manager.stopAccelerometerUpdates()
        return nil
    }
}

// MARK: - GyroscopeHandler

private final class GyroscopeHandler: NSObject, FlutterStreamHandler {
    private let manager: CMMotionManager
    private let queue: OperationQueue
    private let interval: TimeInterval

    init(manager: CMMotionManager, queue: OperationQueue, interval: TimeInterval) {
        self.manager = manager
        self.queue = queue
        self.interval = interval
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard manager.isGyroAvailable else {
            return FlutterError(code: "UNAVAILABLE", message: "Gyroscope not available", details: nil)
        }
        manager.gyroUpdateInterval = interval
        manager.startGyroUpdates(to: queue) { [weak self] data, error in
            guard self != nil else { return }
            if let error = error {
                sendToSink(events, FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            guard let data = data else { return }
            sendToSink(events, [
                "x": data.rotationRate.x,
                "y": data.rotationRate.y,
                "z": data.rotationRate.z,
                "timestamp": currentMs(),
            ])
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        manager.stopGyroUpdates()
        return nil
    }
}

// MARK: - MagnetometerHandler

private final class MagnetometerHandler: NSObject, FlutterStreamHandler {
    private let manager: CMMotionManager
    private let queue: OperationQueue
    private let interval: TimeInterval

    init(manager: CMMotionManager, queue: OperationQueue, interval: TimeInterval) {
        self.manager = manager
        self.queue = queue
        self.interval = interval
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard manager.isMagnetometerAvailable else {
            return FlutterError(code: "UNAVAILABLE", message: "Magnetometer not available", details: nil)
        }
        manager.magnetometerUpdateInterval = interval
        manager.startMagnetometerUpdates(to: queue) { [weak self] data, error in
            guard self != nil else { return }
            if let error = error {
                sendToSink(events, FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            guard let data = data else { return }
            sendToSink(events, [
                "x": data.magneticField.x,
                "y": data.magneticField.y,
                "z": data.magneticField.z,
                "timestamp": currentMs(),
            ])
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        manager.stopMagnetometerUpdates()
        return nil
    }
}

// MARK: - AttitudeHandler

/// OSのカルマンフィルタ済み姿勢データを提供する（CMDeviceMotion）。
/// 参照フレーム: xArbitraryZVertical（磁北不要、ジャイロ+加速度で動作）
private final class AttitudeHandler: NSObject, FlutterStreamHandler {
    private let manager: CMMotionManager
    private let queue: OperationQueue
    private let interval: TimeInterval

    init(manager: CMMotionManager, queue: OperationQueue, interval: TimeInterval) {
        self.manager = manager
        self.queue = queue
        self.interval = interval
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard manager.isDeviceMotionAvailable else {
            return FlutterError(code: "UNAVAILABLE", message: "DeviceMotion not available", details: nil)
        }
        manager.deviceMotionUpdateInterval = interval
        manager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: queue
        ) { [weak self] motion, error in
            guard self != nil else { return }
            if let error = error {
                sendToSink(events, FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            guard let motion = motion else { return }
            let q = motion.attitude.quaternion
            let att = motion.attitude
            sendToSink(events, [
                "qw": q.w,
                "qx": q.x,
                "qy": q.y,
                "qz": q.z,
                "roll": att.roll,
                "pitch": att.pitch,
                "yaw": att.yaw,
                "timestamp": currentMs(),
            ])
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        manager.stopDeviceMotionUpdates()
        return nil
    }
}
