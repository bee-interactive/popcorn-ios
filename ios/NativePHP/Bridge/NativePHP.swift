import UIKit
import AudioToolbox
import LocalAuthentication

@_cdecl("NativePHPShowShareSheet")
public func NativePHPShowShareSheet(
    cTitle: UnsafePointer<CChar>?,
    cText:  UnsafePointer<CChar>?,
    cUrl:   UnsafePointer<CChar>?
) {
    print("called from PHP")
    // Convert C strings to Swift strings
    guard
        let cTitle = cTitle, let cText = cText, let cUrl = cUrl
    else {
        return
    }
    
    let title = String(cString: cTitle)
    let text  = String(cString: cText)
    let url   = String(cString: cUrl)
    
    // Construct the items you want to share
    // e.g., you might combine them or interpret them as needed.
    var shareItems: [Any] = []
    if !title.isEmpty { shareItems.append(title) }
    if !text.isEmpty  { shareItems.append(text) }
    if !url.isEmpty   { shareItems.append(URL(string: url) ?? url) }
    
    DispatchQueue.main.async {
        // Get the topmost view controller from the active scene
        guard let window = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows
            .filter({ $0.isKeyWindow }).first else {
            return
        }
        guard let rootVC = window.rootViewController else {
            return
        }
        
        // Create and present a UIActivityViewController
        let activityVC = UIActivityViewController(
            activityItems: shareItems,
            applicationActivities: nil
        )
        
        // On iPad, UIActivityViewController must be presented in a popover.
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view // or another view that makes sense in your context
            popover.permittedArrowDirections = .any
        }
        
        rootVC.present(activityVC, animated: true, completion: nil)
    }
}

@_cdecl("NativePHPShowAlert")
public func NativePHPShowAlert(
    cTitle: UnsafePointer<CChar>?,
    cMessage: UnsafePointer<CChar>?,
    cButtonTitles: UnsafePointer<UnsafePointer<CChar>?>?,
    cButtonCount: Int32,
    callback: @escaping @convention(c) (Int32) -> Void
) {
    // Convert C strings to Swift strings
    let title = cTitle != nil ? String(cString: cTitle!) : ""
    let message = cMessage != nil ? String(cString: cMessage!) : ""
    
    // Convert button titles array
    var buttonTitles: [String] = []
    if let cButtonTitles = cButtonTitles {
        for i in 0..<cButtonCount {
            if let cString = cButtonTitles[Int(i)] {
                buttonTitles.append(String(cString: cString))
            }
        }
    }

    DispatchQueue.main.async {
        // Get the topmost view controller from the active scene
        guard let window = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows
            .filter({ $0.isKeyWindow }).first else {
            print("Error: Unable to find the key window.")
            return
        }
        guard let rootVC = window.rootViewController else {
            print("Error: Unable to find root view controller.")
            return
        }

        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Add buttons to the alert
        for (index, buttonTitle) in buttonTitles.enumerated() {
            alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
                callback(Int32(index))
            }))
        }

        // Present the alert
        rootVC.present(alertController, animated: true, completion: nil)
    }
}


@_cdecl("NativePHPVibrate")
public func NativePHPVibrate() {
    // For example, trigger haptic feedback using UIKit or CoreHaptics
    // Example: simple "vibrate" using AudioServicesPlaySystemSound
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
}

@_cdecl("NativePHPOpenCamera")
public func NativePHPOpenCamera() {
    DispatchQueue.main.async {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            nativephp_camera_finish_blocking(nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = MyCameraDelegate.shared // see below
        rootVC.present(picker, animated: true)
    }
}

class MyCameraDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = MyCameraDelegate()

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            // Convert to base64
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                let base64String = jpegData.base64EncodedString()
                
                // Call the C function "nativephp_camera_callback"
                base64String.withCString { cString in
                    nativephp_camera_finish_blocking(cString)
                }
            } else {
                // If encoding failed, pass an empty string or some error
                nativephp_camera_finish_blocking(nil)
            }
        } else {
            // Canceled or no image
            nativephp_camera_finish_blocking(nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        nativephp_camera_finish_blocking(nil)
    }
}

@_silgen_name("nativephp_camera_finish_blocking")
func nativephp_camera_finish_blocking(_ base64Image: UnsafePointer<CChar>?)

@_cdecl("NativePHPLocalAuthChallenge")
public func NativePHPLocalAuthChallenge() {
    // Must do UI on main thread
    DispatchQueue.main.async {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { 
            // If device can't do biometrics, just "fail"
            nativephp_biometrics_finish_blocking(0)
            return
        }

        let reason = "Authenticate to proceed"
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, err in
            if success {
                // Auth succeeded
                nativephp_biometrics_finish_blocking(1)
            } else {
                // Auth failed or canceled
                nativephp_biometrics_finish_blocking(0)
            }
        }
    }
}

@_silgen_name("nativephp_biometrics_finish_blocking")
func nativephp_biometrics_finish_blocking(_ success: Int32)

@_cdecl("NativePHPRegisterForPushNotifications")
public func NativePHPRegisterForPushNotifications() {
    // 1. Request user authorization for push notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        guard error == nil else {
            print("Error requesting notification permission:", error!)
            return
        }
        guard granted else {
            print("User denied push notification permission.")
            return
        }

        // 2. If granted, register with APNs to get a device token
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

@_silgen_name("NativePHPSetPushToken")
func NativePHPSetPushTokenC(_ token: UnsafePointer<CChar>?)
