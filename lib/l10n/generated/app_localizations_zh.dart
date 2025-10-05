// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get about => '关于';

  @override
  String get about_content => '这是一个通用设置页示例';

  @override
  String get about_section_version_details => '版本信息';

  @override
  String get about_current_version => '当前版本';

  @override
  String get about_build_number => '构建号';

  @override
  String get about_latest_version => '最新版本';

  @override
  String get about_check_updates => '查看最新版本';

  @override
  String get about_update_status_up_to_date => '当前已是最新版本。';

  @override
  String about_update_status_optional(Object version) {
    return '有可用的新版本 $version。';
  }

  @override
  String about_update_status_required(Object version) {
    return '需要升级到版本 $version 才能继续使用。';
  }

  @override
  String get about_update_status_unknown => '暂时无法获取最新版本信息。';

  @override
  String get action_apply => '应用';

  @override
  String get action_cancel => '取消';

  @override
  String get action_create => '创建';

  @override
  String get action_follow => '关注';

  @override
  String get action_following => '已关注';

  @override
  String get action_login => '登录';

  @override
  String get action_logout => '退出登录';

  @override
  String get action_register => '报名';

  @override
  String get action_register_now => '立即报名';

  @override
  String get action_replace => '替换';

  @override
  String get action_reset => '重置';

  @override
  String get action_restore_defaults => '恢复默认';

  @override
  String get action_retry => '重试';

  @override
  String get browsing_history => '浏览记录';

  @override
  String get chinese => '中文';

  @override
  String get city_field_label => '城市/地点（可编辑）';

  @override
  String get city_loading => '正在获取…';

  @override
  String get dark_mode => '深色模式';

  @override
  String get email_unbound => '未绑定邮箱';

  @override
  String get user_display_name_fallback => '用户';

  @override
  String get english => '英文';

  @override
  String get events => '活动';

  @override
  String get event_description_field_label => '活动描述';

  @override
  String get event_details_title => '活动详情';

  @override
  String get event_meeting_point_title => '集合地点';

  @override
  String get event_participants_title => '参与人数';

  @override
  String get event_time_title => '活动时间';

  @override
  String get event_title_field_label => '活动标题';

  @override
  String get events_open_chat => '进入群聊';

  @override
  String get events_tab_favorites => '我喜欢的';

  @override
  String get events_tab_registered => '我报名的';

  @override
  String get events_title => '活动';

  @override
  String get create_event_title => '创建活动';

  @override
  String get feature_not_ready => '该功能正在开发中';

  @override
  String get filter => '筛选';

  @override
  String get filter_category => '分类';

  @override
  String get filter_date => '日期';

  @override
  String get filter_date_any => '不限';

  @override
  String get filter_date_this_month => '本月';

  @override
  String get filter_date_this_week => '本周';

  @override
  String get filter_date_today => '今天';

  @override
  String get filter_distance => '距离';

  @override
  String get filter_only_free => '仅显示免费活动';

  @override
  String get followed => '已关注';

  @override
  String get favorites_empty => '暂无收藏~';

  @override
  String get favorites_title => '收藏';

  @override
  String get history_empty => '暂无历史记录~';

  @override
  String get history_title => '历史记录';

  @override
  String get industry_label_optional => '行业（选填）';

  @override
  String get interest_tags_title => '兴趣标签';

  @override
  String get language => '语言';

  @override
  String get load_failed => '加载失败';

  @override
  String location_coordinates(Object lat, Object lng) {
    return '位置：$lat, $lng';
  }

  @override
  String get location_unavailable => '无法获取定位';

  @override
  String get login_footer => '继续即表示同意我们的服务条款与隐私政策';

  @override
  String get login_prompt => '点击上方按钮登录体验更多功能';

  @override
  String get login_side_info => '发现周边活动 · 快速组局 · 订阅解锁高级玩法';

  @override
  String get login_subtitle => '基于地理位置组织活动，一键加入你的 Crew';

  @override
  String get login_title => '欢迎来到 Crew';

  @override
  String get logout_success => '已退出登录';

  @override
  String get map => '地图';

  @override
  String get group => '群聊';

  @override
  String get max_interest_selection => '最多只能选择 5 个兴趣标签喵~';

  @override
  String get my_events => '我的活动';

  @override
  String get my_favorites => '我的收藏';

  @override
  String chat_members_count(Object count) {
    return '$count 位成员';
  }

  @override
  String get chat_you_label => '我';

  @override
  String get chat_message_input_hint => '发送一条消息…';

  @override
  String chat_reply_count(Object count) {
    return '$count 条回复';
  }

  @override
  String get no_events => '暂无活动';

  @override
  String get no_events_found => '没有找到活动';

  @override
  String get not_logged_in => '未登录';

  @override
  String get preferences_title => '个人资料';

  @override
  String get please_enter_city => '请输入城市';

  @override
  String get please_enter_event_title => '请输入活动标题';

  @override
  String get profile_title => '个人中心';

  @override
  String get profile_roles_label => '角色';

  @override
  String get profile_subscription_status_active => '订阅已激活';

  @override
  String get profile_subscription_status_inactive => '暂无订阅';

  @override
  String get profile_sync_error => '无法同步个人信息';

  @override
  String get registration_not_implemented => '报名功能尚未实现';

  @override
  String get registration_open => '正在报名中';

  @override
  String get share_card_title => '邀请朋友';

  @override
  String get share_card_subtitle => '把这个活动卡片分享给好友吧';

  @override
  String get share_card_qr_caption => '扫描二维码查看活动详情';

  @override
  String get share_action_copy_link => '复制链接';

  @override
  String get share_action_save_image => '保存活动';

  @override
  String get share_action_share_system => '系统分享';

  @override
  String get share_copy_success => '活动链接已复制';

  @override
  String get share_save_success => '分享卡片已保存到相册';

  @override
  String get share_save_failure => '保存分享卡片失败';

  @override
  String get school_label_optional => '学校（选填）';

  @override
  String get search_hint => '搜索活动';

  @override
  String get search_tags_hint => '搜索标签...';

  @override
  String get settings => '设置';

  @override
  String get settings_section_general => '通用';

  @override
  String get settings_section_support => '关于与支持';

  @override
  String get settings_section_subscription => '订阅与付费';

  @override
  String get settings_section_privacy => '隐私与安全';

  @override
  String get settings_section_account => '账号信息';

  @override
  String get settings_section_notifications => '通知设置';

  @override
  String get settings_section_developer => '开发者工具';

  @override
  String get settings_help_feedback => '帮助与反馈';

  @override
  String get settings_help_feedback_subtitle => 'FAQ，联系支持';

  @override
  String get settings_app_version => '应用版本信息';

  @override
  String get settings_app_version_subtitle => '查看版本和构建信息';

  @override
  String get settings_subscription_current_plan => '当前订阅计划';

  @override
  String settings_subscription_current_plan_value(Object plan) {
    return '$plan 计划';
  }

  @override
  String get settings_subscription_plan_free => 'Free';

  @override
  String get settings_subscription_plan_plus => 'Plus';

  @override
  String get settings_subscription_plan_pro => 'Pro';

  @override
  String get settings_subscription_upgrade => '升级订阅';

  @override
  String get settings_subscription_cancel => '取消订阅';

  @override
  String get settings_subscription_payment_methods => '支付方式管理';

  @override
  String get settings_location_permission => '位置权限';

  @override
  String get settings_location_permission_allow => '允许定位';

  @override
  String get settings_location_permission_while_using => '仅在使用时允许';

  @override
  String get settings_location_permission_deny => '拒绝定位';

  @override
  String get settings_manage_blocklist => '屏蔽 / 拉黑管理';

  @override
  String get settings_privacy_documents => '隐私政策 / 用户协议';

  @override
  String get settings_account_info => '账号信息';

  @override
  String get settings_account_email_label => '邮箱';

  @override
  String get settings_account_uid_label => 'UID';

  @override
  String get settings_account_delete => '删除账号';

  @override
  String get settings_notifications_activity => '活动提醒';

  @override
  String get settings_notifications_following => '关注用户动态';

  @override
  String get settings_notifications_push => '推送开关';

  @override
  String get settings_notifications_push_subtitle => '在此设备接收推送通知';

  @override
  String get settings_saved_toast => '设置已更新';

  @override
  String get report_issue => '问题反馈';

  @override
  String get report_issue_description => '提交截图和日志，帮助我们快速定位问题。';

  @override
  String get feedback_thanks => '感谢你的反馈！';

  @override
  String get student_verification => '学生认证';

  @override
  String get tag_city_explore => '城市探索';

  @override
  String get tag_easy_social => '轻松社交';

  @override
  String get tag_free => '免费';

  @override
  String get tag_friends => '朋友在';

  @override
  String get tag_music => '音乐';

  @override
  String get tag_nearby => '附近';

  @override
  String get tag_party => '派对';

  @override
  String get tag_sports => '运动';

  @override
  String get tag_today => '今天';

  @override
  String get tag_trending => '热门';

  @override
  String get tag_walk_friendly => '步行友好';

  @override
  String get to_be_announced => '待公布';

  @override
  String get unknown => '未知';

  @override
  String get unfollowed => '已取消关注';

  @override
  String get verification_preferences => '认证和偏好';

  @override
  String version_label(Object version) {
    return '版本 $version';
  }

  @override
  String get disclaimer_acknowledge => '我已阅读并同意上述条款';

  @override
  String get disclaimer_exit => '退出';

  @override
  String get disclaimer_accept => '同意';
}
