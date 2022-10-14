import UIKit
import Flutter
import Mobile
import LocalAuthentication

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let applicationSupportsPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]

        MobileMigration(documentsPath, applicationSupportsPath)
        MobileInitApplication(applicationSupportsPath)

        
        let controller = self.window.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel.init(name: "method", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        channel.setMethodCallHandler { (call, result) in
            Thread {
                if call.method == "flatInvoke" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let method = args["method"] as? String,
                       let params = args["params"] as? String{
                        var error: NSError?
                        let data = MobileFlatInvoke(method, params, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "verifyAuthentication"{
                    let context = LAContext()
                    let can = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
                    guard can == true else {
                        result(false)
                        return
                    }
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "身份验证") { (success, error) in
                        result(success)
                    }

                }
                else if call.method == "iosSaveFileToImage"{
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let path = args["path"] as? String{
                        
                        do {
                            let fileURL: URL = URL(fileURLWithPath: path)
                                let imageData = try Data(contentsOf: fileURL)
                            
                            if let uiImage = UIImage(data: imageData) {
                                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                result("OK")
                            }else{
                                result(FlutterError(code: "", message: "Error loading image ", details: ""))
                            }
                            
                        } catch {
                                result(FlutterError(code: "", message: "Error loading image : \(error)", details: ""))
                        }
                        
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "iosGetDocumentDir" {
                    result(documentsPath)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }.start()
        }
        
        //
        let eventChannel = FlutterEventChannel.init(name: "flatEvent", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        class EventChannelHandler:NSObject, FlutterStreamHandler {
             func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
                 objc_sync_enter(mutex)
                 sink = events
                 objc_sync_exit(mutex)
                 return nil
             }
            
             func onCancel(withArguments arguments: Any?) -> FlutterError? {
                 objc_sync_enter(mutex)
                 sink = nil
                 objc_sync_exit(mutex)
                return nil
            }
        }
        class EventNotifyHandler:NSObject, MobileEventNotifyHandlerProtocol {
            func onNotify(_ message: String?) {
                objc_sync_enter(mutex)
                if sink != nil {
                    sink?(message)
                }
                objc_sync_exit(mutex)
            }
        }
        eventChannel.setStreamHandler(EventChannelHandler.init())
        MobileEventNotify(EventNotifyHandler.init())
        
        //
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


var sink : FlutterEventSink?
let mutex = NSObject.init()

