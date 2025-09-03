// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController emailCtrl = TextEditingController();
//   final TextEditingController pwdCtrl = TextEditingController();
//   final TextEditingController phoneCtrl = TextEditingController();
//   String verificationId = "";

//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//   bool _initialized = false;

//   Future<void> _ensureInitialized() async {
//     if (!_initialized) {
//       await _googleSignIn.initialize();
//       _initialized = true;
//     }
//   }

//   // 邮箱登录
//   Future<void> loginWithEmail() async {
//     if (emailCtrl.text.isEmpty || pwdCtrl.text.isEmpty) {
//       _show("邮箱或密码不能为空");
//       return;
//     }
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: emailCtrl.text.trim(),
//         password: pwdCtrl.text,
//       );
//       _show("邮箱登录成功！");
//     } on FirebaseAuthException catch (e) {
//       _show("邮箱登录失败: ${e.message}");
//     } catch (e) {
//       _show("邮箱登录失败: $e");
//     }
//   }

//   // Google 登录
//   Future<void> loginWithGoogle() async {
//     try {
//       await _ensureInitialized();

//       // 触发用户登录授权流程
//       final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

//       // 获取 auth 信息
//       final GoogleSignInAuthentication googleAuth = googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.idToken,
//         idToken: googleAuth.idToken,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);
//       _show("Google 登录成功！");
//     } on FirebaseAuthException catch (e) {
//       _show("Google 登录失败: ${e.message}");
//     } catch (e) {
//       _show("Google 登录失败: $e");
//     }
//   }

//   // 手机号登录：请求验证码
//   Future<void> sendCode() async {
//     if (phoneCtrl.text.isEmpty) {
//       _show("手机号不能为空");
//       return;
//     }
//     try {
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneCtrl.text.trim(),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _auth.signInWithCredential(credential);
//           _show("手机号自动登录成功！");
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           _show("手机号验证失败: ${e.message}");
//         },
//         codeSent: (String verId, int? resendToken) {
//           verificationId = verId;
//           _show("验证码已发送！");
//         },
//         codeAutoRetrievalTimeout: (String verId) {
//           verificationId = verId;
//         },
//       );
//     } catch (e) {
//       _show("验证码发送失败: $e");
//     }
//   }

//   // 输入验证码后手动验证
//   Future<void> verifyCode(String smsCode) async {
//     if (smsCode.isEmpty) {
//       _show("验证码不能为空");
//       return;
//     }
//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: smsCode,
//       );
//       await _auth.signInWithCredential(credential);
//       _show("手机号登录成功！");
//     } on FirebaseAuthException catch (e) {
//       _show("验证码登录失败: ${e.message}");
//     } catch (e) {
//       _show("验证码登录失败: $e");
//     }
//   }

//   void _show(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     emailCtrl.dispose();
//     pwdCtrl.dispose();
//     phoneCtrl.dispose();
//     super.dispose();
//   }

//   Future<String?> _inputDialog(BuildContext context) async {
//     String code = "";
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("输入短信验证码"),
//         content: TextField(
//           onChanged: (val) => code = val,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(hintText: "123456"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, code),
//             child: const Text("确认"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("三合一登录")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // 邮箱 + 密码
//             TextField(
//               controller: emailCtrl,
//               decoration: const InputDecoration(labelText: "邮箱"),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: pwdCtrl,
//               decoration: const InputDecoration(labelText: "密码"),
//               obscureText: true,
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//                 onPressed: loginWithEmail, child: const Text("邮箱登录")),

//             const SizedBox(height: 20),
//             const Divider(),
//             const SizedBox(height: 20),

//             // Google 登录
//             ElevatedButton(
//                 onPressed: loginWithGoogle, child: const Text("Google 登录")),

//             const SizedBox(height: 20),
//             const Divider(),
//             const SizedBox(height: 20),

//             // 手机号
//             TextField(
//               controller: phoneCtrl,
//               decoration: const InputDecoration(labelText: "手机号（+39 333...）"),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(onPressed: sendCode, child: const Text("获取验证码")),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () async {
//                 final code = await _inputDialog(context);
//                 if (code != null) verifyCode(code);
//               },
//               child: const Text("输入验证码登录"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }