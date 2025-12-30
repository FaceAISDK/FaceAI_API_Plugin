import SwiftUI
import UIKit


// 2. 定义一个管理类，用于被 UTS 调用
@objcMembers // 暴露给 UTS/Objective-C 运行时
public class SwiftUIManager: NSObject {
    
    // 静态方法：显示视图
    public static func showSwiftUIModal() {
        // 确保系统版本支持 SwiftUI
        if #available(iOS 13.0, *) {
            // 获取当前的 UIWindow / RootViewController
            guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                  let rootVC = keyWindow.rootViewController else {
                return
            }
            
            // 创建 HostingController
            // 注意：这里需要处理 dismiss 逻辑
            var hostingController: UIHostingController<FaceAINaviView>? = nil
            
            // let swiftView = FaceAINaviView() {
            //     // 关闭回调
            //     hostingController?.dismiss(animated: true, completion: nil)
            // }
			
			// 【修改后】正确的代码
			let swiftView = FaceAINaviView(onDismiss: {
			    // 这里是闭包的具体实现：让 hostingController 消失
			    hostingController?.dismiss(animated: true, completion: nil)
			})
            
            hostingController = UIHostingController(rootView: swiftView)
            
            // 设置模态样式
            hostingController?.modalPresentationStyle = .formSheet
            
            // 弹出视图
            rootVC.present(hostingController!, animated: true, completion: nil)
            
        } else {
            print("iOS version too low for SwiftUI")
        }
    }
}
