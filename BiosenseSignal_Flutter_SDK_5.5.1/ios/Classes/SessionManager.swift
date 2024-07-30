
import Foundation
import Combine

class SessionManager:
        ImageDataSource,
        ImageListener,
        VitalSignsListener,
        SessionInfoListener,
        PPGDeviceInfoListener,
        FallDetectionListener {
    
    static let shared = SessionManager()
    
    var eventChannel: BiosenseSignalEventChannel?
    private var session: Session?
    private var ppgScanners = [String: PPGDeviceScanner]()
    
    let images = PassthroughSubject<ImageData, Never>()
    
    private init() {}
    
    func createSession(
        licenseKey: String,
        productId: String? = nil,
        deviceOrientation: Int? = nil,
        subjectSex: Int? = nil,
        subjectAge: Double? = nil,
        subjectWeight: Double? = nil,
        detectionAlwaysOn: Bool? = false,
        imageFormatMode: Int? = nil,
        strictMeasurementGuidance: Bool? = false,
        options: [String: Any]? = nil
    
    ) throws {
        var sessionBuilder = FaceSessionBuilder()
        if let subjectDemographic = resolveSubjectDemographic(sex: subjectSex, age: subjectAge, weight: subjectWeight) {
            sessionBuilder = sessionBuilder.withSubjectDemographic(subjectDemographic)
        }
        
        if let orientation = resolveDeviceOrientation(deviceOrientation: deviceOrientation) {
            sessionBuilder = sessionBuilder.withDeviceOrientation(orientation)
        }

        if let imageFormat = resolveImageFormat(imageFormatMode: imageFormatMode) {
            sessionBuilder = sessionBuilder.withImageFormatMode(imageFormat)
        }

        if let strictMeasurementGuidance = strictMeasurementGuidance {
            sessionBuilder = sessionBuilder.withStrictMeasurementGuidance(strictMeasurementGuidance)
        }

        if let detectionAlwaysOn = detectionAlwaysOn {
            sessionBuilder = sessionBuilder.withDetectionAlwaysOn(detectionAlwaysOn)
        }
        
        session = try sessionBuilder
            .withImageListener(self)
            .withVitalSignsListener(self)
            .withSessionInfoListener(self)
            .withOptions(options: options ?? [:])
            .build(licenseDetails: LicenseDetails(licenseKey: licenseKey, productId: productId))
    }
    
    func createPPGDeviceSession(
        licenseKey: String,
        productId: String? = nil,
        deviceId: String,
        deviceType: Int,
        subjectSex: Int? = nil,
        subjectAge: Double? = nil,
        subjectWeight: Double? = nil,
        fallDetection: Bool = false,
        options: [String: Any]? = nil) throws {
            if (resolveDeviceType(deviceType: deviceType) != PPGDeviceType.polar) {
                throw NSError(domain: AlertDomains.initialization, code: AlertCodes.ppgDeviceUnsupportedDeviceModelError)
            }
            
            var sessionBuilder = PolarSessionBuilder(polarDeviceID: deviceId)
            if let subjectDemographic = resolveSubjectDemographic(sex: subjectSex, age: subjectAge, weight: subjectWeight) {
                sessionBuilder = sessionBuilder.withSubjectDemographic(subjectDemographic)
            }
            
            if (fallDetection) {
                sessionBuilder = sessionBuilder.withFallDetectionListener(self)
            }

            session = try sessionBuilder
                .withVitalSignsListener(self)
                .withSessionInfoListener(self)
                .withPPGDeviceInfoListener(self)
                .withOptions(options: options ?? [:])
                .build(licenseDetails: LicenseDetails(licenseKey: licenseKey, productId: productId))
        }
    
    func startPPGDevicesScan(scannerId: String, deviceType: Int, timeout: Int?) throws {
        if (resolveDeviceType(deviceType: deviceType) != PPGDeviceType.polar) {
            return
        }

        let ppgScanListener = PPGDeviceScannerListenerImpl(eventChannel: eventChannel, scannerId: scannerId)
        let scanner = try PPGDeviceScannerFactory.create(ppgDeviceType: PPGDeviceType.polar, listener: ppgScanListener)
        
        ppgScanners[scannerId] = scanner
        if let timeout = timeout {
            try scanner.start(timeout: UInt(timeout))
        } else {
            try scanner.start()
        }
    }
    
    func stopPPGDevicesScan(scannerId: String) {
        ppgScanners[scannerId]?.stop()
    }
    
    func startSession(duration: Int?) throws {
        try session?.start(measurementDuration: UInt64(duration ?? 0))
    }

    func stopSession() throws {
        try session?.stop()
    }

    func terminateSession() {
        session?.terminate()
    }

    func getSessionState() -> SessionState? {
        return session?.state
    }

    func onImage(imageData: ImageData) {
        images.send(imageData)
        eventChannel?.sendEvent(name: NativeBridgeEvents.imageData , payload: imageData.toMap())
    }
    
    func onVitalSign(vitalSign: VitalSign) {
        if let map = vitalSign.toMap() {
            eventChannel?.sendEvent(name: NativeBridgeEvents.sessionVitalSign , payload: map)
        }
    }
    
    func onFinalResults(results: VitalSignsResults) {
        let finalResults = results.getResults().compactMap { result in
            result.toMap()
        }
        
        eventChannel?.sendEvent(name: NativeBridgeEvents.sessionFinalResults, payload: finalResults)
    }
    
    func onSessionStateChange(sessionState: SessionState) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.sessionStateChange, payload: sessionState.rawValue)
    }
    
    func onWarning(warningData: WarningData) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.sessionWarning, payload: warningData.toMap())
    }
    
    func onError(errorData: ErrorData) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.sessionError, payload: errorData.toMap())
    }
    
    func onLicenseInfo(licenseInfo: LicenseInfo) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.licenseInfo, payload: licenseInfo.toMap())
    }
    
    func onEnabledVitalSigns(enabledVitalSigns: SessionEnabledVitalSigns) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.enabledVitalSigns, payload: enabledVitalSigns.toMap())
    }
    
    func onPPGDeviceBatteryLevel(_ batteryLevel: UInt) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.ppgDeviceBatteryLevel, payload: batteryLevel)
    }
    
    func onPPGDeviceInfo(_ info: BiosenseSignal.PPGDeviceInfo) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.ppgDeviceInfo, payload: info.toMap())
    }
    
    func onFallDetectionData(_ data: FallDetectionData) {
        eventChannel?.sendEvent(name: NativeBridgeEvents.fallDetectionData, payload: data.toMap())
    }

    private func resolveDeviceOrientation(deviceOrientation: Int?) -> DeviceOrientation? {
        guard let orientation = deviceOrientation, let orientationEnum = DeviceOrientation.init(rawValue: orientation) else {
            return nil
        }
        
        return orientationEnum
    }

    private func resolveSubjectDemographic(sex: Int?, age: Double?, weight: Double?) -> SubjectDemographic? {
        if (sex == nil && age == nil && weight == nil) {
            return nil
        }
        
        var sdkAge: NSNumber?
        if let age = age {
            sdkAge = NSNumber.init(value: age)
        }
        
        var sdkWeight: NSNumber?
        if let weight = weight {
            sdkWeight = NSNumber.init(value: weight)
        }
        
        return SubjectDemographic(
            sex: Sex.init(rawValue: sex ?? 0) ?? Sex.unspecified,
            age: sdkAge,
            weight: sdkWeight)
    }

    private func resolveImageFormat(imageFormatMode: Int?) -> ImageFormatMode? {
        guard let imageFormat = imageFormatMode,
              let imageFormatEnum = ImageFormatMode.init(rawValue: imageFormat) else {
            return nil
        }

        return imageFormatEnum
    }
    
    private func resolveDeviceType(deviceType: Int) -> PPGDeviceType? {
        return PPGDeviceType.init(rawValue: deviceType)
    }
}

extension SessionManager {
    
    class PPGDeviceScannerListenerImpl: PPGDeviceScannerListener {
        var eventChannel: BiosenseSignalEventChannel?
        let scannerId: String
        
        
        init(eventChannel: BiosenseSignalEventChannel?, scannerId: String) {
            self.eventChannel = eventChannel
            self.scannerId = scannerId
        }
        
        func onPPGDeviceDiscovered(ppgDevice: PPGDevice) {
            let device = ppgDevice.toMap()
            let result: [String: Any] = [
                "scannerId": scannerId,
                "device": device
            ]
            eventChannel?.sendEvent(name: NativeBridgeEvents.ppgDeviceDiscovered, payload: result)
        }
        
        func onPPGDeviceScanFinished() {
            eventChannel?.sendEvent(name: NativeBridgeEvents.ppgDeviceScanFinished, payload: scannerId)
        }
    }
}
