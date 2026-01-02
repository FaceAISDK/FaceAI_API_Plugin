import SwiftUI
import UIKit
import FaceAISDK_Core 

@objcMembers
public class SwiftUIManager: NSObject {
	
	

	// MARK: - 人脸识别
	public static func showFaceVerify(_ faceID: String,
	                                  _ threshold: NSNumber,
	                                  _ faceLivenessType: NSNumber,
	                                  _ motionLivenessTypes: String,
	                                  _ callback: @escaping (NSNumber) -> Void) {
	    
	    // 定义变量名为 topVC
	    guard let topVC = getTopViewController() else {
	        print("Error: Could not find top ViewController")
	        return
	    }
	    
	    var hostingController: UIHostingController<VerifyFaceView>? = nil
	    
		let floatThreshold = threshold.floatValue
        let sdkView = VerifyFaceView(
            faceID: faceID,
            threshold: floatThreshold, 
            onDismiss: { (resultCode: Int) in // 假设 VerifyFaceView 返回的是 Int
                
                DispatchQueue.main.async {
                    hostingController?.dismiss(animated: true) {
                        // ✅ 修复点2：显式将 Int 转换为 NSNumber
                        let numberCode = NSNumber(value: resultCode)
                        callback(numberCode)
                    }
                }
            }
        )
	    
	    hostingController = UIHostingController(rootView: sdkView)
	    hostingController?.modalPresentationStyle = .fullScreen
	    
	    topVC.present(hostingController!, animated: true, completion: nil)
	}
	
	
	
	
	
	
    
    // MARK: - 录入人脸方法
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
			    DispatchQueue.main.async {
					hostingController?.dismiss(animated: true) {
					    let faceFeature = resultJsonString ?? "Add Face Feature Failed"
					    callback(faceFeature)
					}
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