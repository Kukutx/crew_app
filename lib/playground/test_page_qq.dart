
import 'package:crew_app/features/events/presentation/map/events_map_page.dart';
import 'package:crew_app/features/events/presentation/search_events_page.dart';
import 'package:crew_app/features/profile/presentation/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';










class HomeP11age extends StatelessWidget {
  const HomeP11age({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("首页")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 跳转到 Profile 页面（带自定义动画）
            Navigator.of(context).push(_createRoute());
          },
          child: Text("进入 Profile"),
        ),
      ),
    );
  }

  /// 自定义转场动画
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfileqqPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 从右往左滑入
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

class ProfileqqPage extends StatelessWidget {
  const ProfileqqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // 监听手势返回
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta != null && details.primaryDelta! > 20) {
            Navigator.pop(context); // 往右滑返回
          }
        },
        child: Container(
          color: Colors.blue,
          child: Center(
            child: Text(
              "Profile 页面",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}














// class ShellDemo extends StatelessWidget {
//   const ShellDemo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return QQSwipeShellV2(
//       home: const SearchEventsPage(),       // 你的主页面
//       profile: const ProfilePage(), // 你的个人主页（建议 Scaffold 全屏）
//     );
//   }
// }



// class QQSwipeShellV2 extends StatefulWidget {
//   final Widget home;     // 主页面
//   final Widget profile;  // 个人主页（左侧）
//   final bool openFromAnywhere; // 关着时是否全屏可右滑触发
//   const QQSwipeShellV2({
//     super.key,
//     required this.home,
//     required this.profile,
//     this.openFromAnywhere = true, // 你需要整页可滑 -> true
//   });

//   @override
//   State<QQSwipeShellV2> createState() => _QQSwipeShellV2State();
// }

// class _QQSwipeShellV2State extends State<QQSwipeShellV2> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 260),
//     value: 0, // 0=关闭，1=打开
//   );

//   static const double _minFling = 500; // 甩动阈值(px/s)
//   static const double _profileWidthPct = 0.86; // 打开后主页面缩放比例≈QQ
//   Offset? _startGlobal;
//   bool _dragging = false;

//   bool get _isOpen => _ctrl.value >= 1.0 - 1e-6;

//   void _onHStart(DragStartDetails d, Size size) {
//     final canStart =
//         widget.openFromAnywhere || _isOpen || d.globalPosition.dx <= 24; // 兼容：已开任意处左滑可关
//     if (!canStart) return;
//     _dragging = true;
//     _startGlobal = d.globalPosition;
//     _ctrl.stop();
//   }

//   void _onHUpdate(DragUpdateDetails d, Size size) {
//     if (!_dragging || _startGlobal == null) return;
//     final dx = d.globalPosition.dx - _startGlobal!.dx; // 右滑正、左滑负
//     final delta = dx / size.width;
//     _ctrl.value = (_ctrl.value + delta).clamp(0.0, 1.0);
//     _startGlobal = d.globalPosition;
//   }

//   void _onHEnd(DragEndDetails d) {
//     if (!_dragging) return;
//     _dragging = false;

//     final vx = d.velocity.pixelsPerSecond.dx;
//     if (vx.abs() > _minFling) {
//       vx > 0 ? _open() : _close();
//       return;
//     }
//     _ctrl.value >= 0.5 ? _open() : _close();
//   }

//   Future<void> _open() async {
//     await _ctrl.animateTo(1.0, curve: Curves.easeOutCubic);
//     HapticFeedback.selectionClick();
//   }

//   Future<void> _close() async {
//     await _ctrl.animateTo(0.0, curve: Curves.easeOutCubic);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     final maxSlide = size.width * 0.78; // 主页面最大右移距离（留出左侧Profile可见区）
//     final minScale = _profileWidthPct;  // 主页面最小缩放（越小层次感越强）

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque, // 整页接管
//       onHorizontalDragStart: (d) => _onHStart(d, size),
//       onHorizontalDragUpdate: (d) => _onHUpdate(d, size),
//       onHorizontalDragEnd: _onHEnd,
//       child: AnimatedBuilder(
//         animation: _ctrl,
//         builder: (_, __) {
//           final t = _ctrl.value; // 0→1

//           // 主页面：右移 + 缩放 + 圆角 + 阴影（更像 QQ）
//           final homeTranslateX = t * maxSlide;
//           final homeScale = 1 - (1 - minScale) * t;

//           // Profile：保持在左侧，做轻微视差（更“跟手”）
//           final profileParallax = (1 - t) * 24; // 打开时基本贴边
//           return Stack(
//             children: [
//               // 左侧 Profile 层
//               Transform.translate(
//                 offset: Offset(-profileParallax, 0),
//                 child: SizedBox(
//                   width: size.width, // 全屏承载
//                   height: size.height,
//                   child: widget.profile,
//                 ),
//               ),

//               // 主页面（右移+缩放）
//               Transform(
//                 transform: Matrix4.identity()
//   ..translateByDouble(homeTranslateX, 0, 0, 1.0) // 第4个参数 w=1.0
//   ..scaleByDouble(homeScale, homeScale, 1.0, 1.0), // 第4个参数 w=1.0
//                 alignment: Alignment.centerLeft, // 以左侧为轴更贴近 QQ
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20 * t),
//                     boxShadow: t == 0
//                         ? const []
//                         : [
//                             BoxShadow(
//                               blurRadius: 18 * t,
//                               spreadRadius: 2 * t,
//                               color: Colors.black.withValues(alpha: .22 * t),
//                             ),
//                           ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20 * t),
//                     child: widget.home,
//                   ),
//                 ),
//               ),

//               // 点击空白关闭
//               if (t > 0)
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     ignoring: t < 0.02,
//                     child: GestureDetector(onTap: _close),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }