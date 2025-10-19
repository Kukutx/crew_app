# crew_app

A new Flutter project.

## Getting Started

1. 安装 Flutter 3.35.2 / Dart 3.9.0，并执行 `flutter pub get`。
2. 通过 `flutterfire configure` 写入 Firebase 配置（或使用示例中的默认配置）。
3. 运行 `flutter run`，选择目标模拟器/真机。
4. 观察终端输出以确认应用成功连接 Firebase 与后端 API。

## 后端联通自测步骤

1. 使用 `flutter run` 启动应用，保持终端窗口开启以查看日志。
2. 在登录页点击 **Sign in with Google**（或其他 Firebase Auth 提供的登录方式）。
3. 登录完成后，终端中应出现 `Ensure user success: <userId>` 日志，同时可以在抓包工具中看到 `POST /api/v1/users/ensure` 请求，其 `Authorization` 头为 `Bearer <Firebase ID Token>`。
4. 如果后端成功返回用户资料，应用会静默刷新用户信息；若出现 401/403，会打印可读错误日志并弹出轻量提示，可再次尝试登录触发重试（最多 3 次，指数退避）。

## 常见故障排查

- 前端未带 `Authorization` 头 → 返回 401，确认是否在刷新 token 后再调用接口。
- `firebaseUid` 与 ID Token 中的 `uid` 不一致 → 返回 403，检查请求体与当前登录用户是否匹配。
- Firebase 项目不一致（`aud`/`iss` 不匹配）→ 401 或 403，确保移动端使用的 Firebase 配置与后端校验的项目一致。
- CORS 拦截或 `baseUrl` 配错 → 网络层直接失败，使用抓包或日志确认请求是否发往正确域名并允许跨域。
- 仅调用 `google_sign_in` 而未完成 Firebase Auth 登录 → 无法获得 `getIdToken()`，需在拿到 Google Credential 后交给 Firebase Auth。
- 未刷新旧 token → 后端拒绝访问，务必调用 `user.getIdToken(true)` 或服务封装的 `ensureUser()` 以强制刷新。
