// AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         titleSpacing: 12,
//         title: Material(
//           elevation: 2,
//           borderRadius: BorderRadius.circular(24),
//           clipBehavior: Clip.antiAlias, // 波纹不溢出
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: '搜索活动',
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(24),
//                 borderSide: BorderSide.none,
//               ),
//               prefixIcon: const Icon(Icons.search),
//               // 控制尾部图标的触控尺寸与对齐
//               suffixIconConstraints:
//                   const BoxConstraints(minWidth: 44, minHeight: 44),
//               suffixIcon: Padding(
//                 padding: const EdgeInsets.only(right: 6),
//                 child: InkResponse(
//                   radius: 22,
//                   onTap: () {
//                     // TODO: 跳转到 ProfilePage / 打开侧边栏
//                   },
//                   child: CircleAvatar(
//                     radius: 16,
//                     foregroundImage: NetworkImage(avatarUrl),
//                     child: const Icon(Icons.person, size: 18), // 加载失败的占位
//                   ),
//                 ),
//               ),
//             ),
//             onSubmitted: (kw) => debugPrint('搜索: $kw'),
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(56),
//           child: Container(
//             alignment: Alignment.centerLeft,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 children: [
//                   ..._tags.map((t) => Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ChoiceChip(
//                           label: Text(t),
//                           selected: _selected.contains(t),
//                           onSelected: (v) => setState(() {
//                             if (v) {
//                               _selected.add(t);
//                             } else {
//                               _selected.remove(t);
//                             }
//                             // TODO: 触发筛选逻辑
//                           }),
//                         ),
//                       )),
//                   const SizedBox(width: 4),
//                   OutlinedButton.icon(
//                     icon: const Icon(Icons.tune),
//                     label: const Text('筛选'),
//                     onPressed: () {
//                       // TODO: 打开筛选面板
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),