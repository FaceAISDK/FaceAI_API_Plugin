import SwiftUI
import UIKit
import FaceAISDK_Core 

@objcMembers
public class SwiftUIManager: NSObject {
    
    // MARK: - 现有方法
    public static func showSwiftUIModal() {
        guard let topVC = getTopViewController() else { return }
        
        var hostingController: UIHostingController<FaceAINaviView>? = nil
        let swiftView = FaceAINaviView(onDismiss: {
            hostingController?.dismiss(animated: true, completion: nil)
        })
        
        hostingController = UIHostingController(rootView: swiftView)
        hostingController?.modalPresentationStyle = .fullScreen
        
        topVC.present(hostingController!, animated: true, completion: nil)
    }
    

    // MARK: - 【新增】录入人脸方法
    public static func showAddFaceByCamera(_ faceID: String, 
                                           _ mode: NSNumber, 
                                           _ showConfirm: Bool, 
                                           _ callback: @escaping (String) -> Void) {
        
        let modeInt = mode.intValue
        
        // 定义变量名为 topVC
        guard let topVC = getTopViewController() else {
            print("❌ Error: Could not find top ViewController")
            return
        }
        
        var hostingController: UIHostingController<AddFaceByCamera>? = nil
        
        let sdkView = AddFaceByCamera(
            faceID: faceID,
            // 如果 SDK View 需要 mode，这里传 modeInt
            // mode: modeInt, 
            onDismiss: { resultJsonString in
                hostingController?.dismiss(animated: true) {
                    let finalResult = resultJsonString ?? "{ \"code\": 500, \"msg\": \"Unknown error\" }"
                    callback(finalResult)
                }
            }
        )
        
        hostingController = UIHostingController(rootView: sdkView)
        hostingController?.modalPresentationStyle = .fullScreen
        
        topVC.present(hostingController!, animated: true, completion: nil)
    }


    // MARK: - 【辅助方法】获取顶层控制器
    private static func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first 
            ?? UIApplication.shared.keyWindow
        
        guard let rootVC = keyWindow?.rootViewController else { return nil }
        
        var topController = rootVC
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}