import SwiftUI
import UIKit

// 1. 定义一个标准的 SwiftUI 视图
@available(iOS 13.0, *)
struct MySwiftUIView: View {
    var title: String
    // 用于关闭页面的回调
    var onClose: (() -> Void)?

    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "swift")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("This is a native SwiftUI View")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    // 点击关闭
                    onClose?()
                }) {
                    Text("Close Modal")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}
