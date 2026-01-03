import SwiftUI
import AVFoundation
import FaceAISDK_Core

// 使用 @MainActor 确保在主线程访问
@MainActor
var FaceCameraSize: CGFloat {
    // 保持相机区域为屏幕宽度或高度的 70%，确保是正方形
    7 * min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 10
}

struct AddFaceByCamera: View {
    let faceID: String
    let onDismiss: (String?) -> Void
    
    @StateObject private var viewModel: AddFaceByCameraModel = AddFaceByCameraModel()
    @State private var showToast = false
    
    // 辅助函数：获取本地化提示
    private func localizedTip(for code: Int) -> String {
        let key = "Face_Tips_Code_\(code)"
        let defaultValue = "Add Face Tips Code=\(code)"
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
    
    var body: some View {
        // 🔴 修改点1：使用 ZStack 作为根容器，以便 Toast 能悬浮在最上层
        ZStack {
            // MARK: - 主内容区域
            VStack(spacing: 22) {
                // 1. 顶部提示区域
                Text(localizedTip(for: viewModel.sdkInterfaceTips.code))
                    .font(.system(size: 19).bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(Color.brown)
                    .cornerRadius(20)
                
                // 2. 核心区域：相机与确认弹窗的容器
                ZStack {
                    // 图层 A: 相机预览 (底层)
                    FaceAICameraView(session: viewModel.captureSession, cameraSize: FaceCameraSize)
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipShape(Circle()) // 裁剪为圆形
                        .background(Circle().fill(Color.white)) // 相机背景
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    
                    // 图层 B: 确认对话框 (顶层)
                    if viewModel.readyConfirmFace {
                        // 黑色半透明遮罩
                        Color.black.opacity(0.3)
                            .clipShape(Circle())
                        
                        ConfirmAddFaceDialog(
                            viewModel: viewModel,
                            cameraSize: FaceCameraSize,
                            onConfirm: {
                                print("FaceFeature: \(String(describing: viewModel.faceFeatureBySDKCamera))")
                                
                                // 保存人脸特征值
                                UserDefaults.standard.set(viewModel.faceFeatureBySDKCamera, forKey: faceID)
                                
                                // 触发 Toast
                                withAnimation {
                                    showToast = true
                                }
                                
                                // 延迟关闭页面，让用户看清 Toast（可选）
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    onDismiss(viewModel.faceFeatureBySDKCamera)
                                }
                            }
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: FaceCameraSize, height: FaceCameraSize)
                .animation(.easeInOut(duration: 0.25), value: viewModel.readyConfirmFace)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
            // 生命周期事件
            .onAppear {
                viewModel.initAddFace()
            }
            .onChange(of: viewModel.sdkInterfaceTips.code) { newValue in
                print("🔔 AddFaceBySDKCamera： \(viewModel.sdkInterfaceTips.message)")
            }
            .onDisappear {
                viewModel.stopAddFace()
            }
            
            // MARK: - Toast 弹窗区域 (悬浮层)
            // 🔴 修改点2：修复 Toast 逻辑
            if showToast {
                // 1. 尝试获取 faceFeature
                // let rawFeature = UserDefaults.standard.string(forKey: faceID)
				let rawFeature = viewModel.faceFeatureBySDKCamera
                
                // 2. 准备显示内容：如果有值则使用值，如果为 nil 则显示错误提示
                let displayMessage = rawFeature ?? "错误：未找到人脸特征信息 \(faceID)"
                
                // 3. 根据结果决定样式 (假设你的 ToastStyle 有 .success 和 .error)
                let displayStyle: ToastStyle = (rawFeature != nil) ? .success : .failure
                
                VStack {
                    Spacer()
                    CustomToastView(
                        message: displayMessage,
                        style: displayStyle
                    )
                    .padding(.bottom, 77)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(100) // 确保在最上层
                .onAppear {
                    // 自动消失逻辑：2秒后关闭 Toast
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }
            }
        }
    }
}

// ... ConfirmAddFaceDialog 保持不变 ...
struct ConfirmAddFaceDialog: View {
    let viewModel: AddFaceByCameraModel
    let cameraSize: CGFloat
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            Text("Confirm Add Face")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.brown)
                .padding(.top, 16)

            Image(uiImage: viewModel.croppedFaceImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

            Text("Ensure face is clear")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 按钮组
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.reInit()
                }) {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onConfirm()
                }) {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: cameraSize * 1.11)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
