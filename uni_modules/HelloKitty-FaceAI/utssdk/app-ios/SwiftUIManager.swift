import SwiftUI
import UIKit

// 2. 定义一个管理类，用于被 UTS 调用
@objcMembers // 暴露给 UTS/Objective-C 运行时
public class SwiftUIManager: NSObject {
    
    // 静态方法：显示视图
    public static func showSwiftUIModal() {
        // 1. 获取 KeyWindow (iOS 15+ 推荐使用 WindowScene)
        // 考虑到 UTS 插件可能运行在不同环境，这里使用兼容性写法，优先获取活跃的 Scene
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first 
            ?? UIApplication.shared.keyWindow // 降级兜底
        
        guard let rootVC = keyWindow?.rootViewController else {
            print("❌ Error: Could not find rootViewController")
            return
        }
        
        // 2. 查找最顶层的 ViewController
        // 关键步骤：如果有弹窗正在显示（比如 uni.showModal），直接用 rootVC present 会失败
        var topController = rootVC
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        // 3. 定义 HostingController 变量
        var hostingController: UIHostingController<FaceAINaviView>? = nil
        
        // 4. 创建 SwiftUI View
        // 闭包中引用 hostingController 来执行 dismiss
        let swiftView = FaceAINaviView(onDismiss: {
            hostingController?.dismiss(animated: true, completion: nil)
        })
        
        // 5. 初始化 HostingController
        hostingController = UIHostingController(rootView: swiftView)
		hostingController?.view.backgroundColor = UIColor.brown // 保持和 SwiftUI 内部颜色一致，或者用 .black
		hostingController?.modalPresentationStyle = .fullScreen
        
        // 6. 【关键修改】设置为全屏模式
        // .fullScreen: 完全覆盖，底层视图可能会被系统卸载以节省内存（推荐用于相机/重型页面）
        // .overFullScreen: 覆盖在上面，底层视图保持渲染（如果你需要背景半透明选这个）
        hostingController?.modalPresentationStyle = .fullScreen
        
        // 7. 弹出视图
        // 建议关闭 animated 或根据需求开启，全屏启动通常希望像新页面一样滑入
        topController.present(hostingController!, animated: true, completion: nil)
    }
}