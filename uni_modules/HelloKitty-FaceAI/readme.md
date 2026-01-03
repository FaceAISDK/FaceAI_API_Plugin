# HelloKitty-FaceAI



## 人脸识别，活体检测状态码
   人脸识别，活体检测状态码含义
```
    public static let DEFAULT = 0
    public static let VERIFY_SUCCESS = 1           // 1   人脸识别对比成功大于设置的threshold
    public static let VERIFY_FAILED = 2            // 2   人脸识别对比识别小于设置的threshold
    public static let MOTION_LIVENESS_SUCCESS = 3  // 3   动作活体检测成功（基本不用，还有后续动作）
    public static let MOTION_LIVENESS_TIMEOUT = 4  // 4   动作活体超时
    public static let NO_FACE_MULTI = 5            // 5   多次没有检测到人脸
    public static let NO_FACE_FEATURE = 6          // 6   没有对应的人脸特征值
    public static let COLOR_LIVENESS_SUCCESS = 7   // 7   炫彩活体成功
    public static let COLOR_LIVENESS_FAILED = 8    // 8   炫彩活体失败
    public static let COLOR_LIVENESS_LIGHT_TOO_HIGH = 9 // 9   炫彩活体失败，光线亮度过高
    public static let ALL_LIVENESS_SUCCESS = 10    // 10  所有的活体检测完成(包括动作和炫彩)
```