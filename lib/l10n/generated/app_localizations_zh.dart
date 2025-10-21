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
  String get event_detail_publish_plaza => '发布广场帖子';

  @override
  String get event_meeting_point_title => '集合地点';

  @override
  String get event_copy_address_button => '复制地址';

  @override
  String get event_copy_address_success => '地址已复制';

  @override
  String get event_participants_title => '参与人数';

  @override
  String get event_time_title => '活动时间';

  @override
  String get event_fee_title => '报名费用';

  @override
  String get event_fee_free => '免费';

  @override
  String get event_cost_calculator_title => '费用计算器';

  @override
  String get event_cost_calculator_description => '估算报名费用、拼车成本和佣金分成。';

  @override
  String get event_cost_calculator_button => '开始计算';

  @override
  String get event_cost_calculator_participants_label => '参与人数';

  @override
  String get event_cost_calculator_fee_label => '人均报名费 (¥)';

  @override
  String get event_cost_calculator_carpool_label => '拼车总费用 (¥)';

  @override
  String get event_cost_calculator_commission_label => '佣金比例 (%)';

  @override
  String get event_cost_calculator_total_income => '报名总收入';

  @override
  String get event_cost_calculator_commission_total => '佣金支出';

  @override
  String get event_cost_calculator_carpool_share => '人均拼车成本';

  @override
  String get event_cost_calculator_net_total => '扣除成本后净收入';

  @override
  String get event_cost_calculator_net_per_person => '人均净收入';

  @override
  String get event_cost_calculator_hint => '根据实际情况调整各项费用即可。';

  @override
  String get event_expense_section_title => '费用计算';

  @override
  String get event_expense_section_description => '和小伙伴一起记录旅途中的花费，活动结束后轻松结算。';

  @override
  String get event_expense_calculate_button => '计算费用';

  @override
  String get event_group_expense_title => '多人记账';

  @override
  String get event_group_expense_intro => '创建一个多人账本，随时记录本次活动的公共支出。';

  @override
  String get event_group_expense_hint => '添加参与者、实时登记费用，系统会自动帮你核对每个人的应付金额。';

  @override
  String get event_waypoints_title => '途径点';

  @override
  String get event_route_type_title => '路线类型';

  @override
  String get event_route_type_round => '往返路线';

  @override
  String get event_route_type_one_way => '单程路线';

  @override
  String get event_route_manage_button => '管理路线';

  @override
  String get event_waypoint_editor_title => '途径点与路线';

  @override
  String get event_waypoint_editor_empty => '暂无途径点';

  @override
  String get event_waypoint_editor_swipe_hint => '向左滑动标签即可删除。';

  @override
  String get event_waypoint_editor_add_button => '添加途径点';

  @override
  String get event_waypoint_picker_title => '选择途径点';

  @override
  String get event_waypoint_picker_tip => '在地图上长按以选择途径点。';

  @override
  String get event_waypoint_picker_confirm_title => '添加该途径点？';

  @override
  String get event_waypoint_picker_confirm_button => '添加途径点';

  @override
  String get event_distance_title => '总里程';

  @override
  String event_distance_value(String kilometers) {
    return '$kilometers 公里';
  }

  @override
  String get event_title_field_label => '活动标题';

  @override
  String get events_open_chat => '进入消息';

  @override
  String get messages_tab_private => '私聊';

  @override
  String get messages_tab_groups => '群聊';

  @override
  String get events_tab_invites => '召集';

  @override
  String get events_tab_moments => '瞬间';

  @override
  String get create_moment_title => '发布瞬间';

  @override
  String get create_moment_subtitle => '记录此刻的灵感，和身边的小伙伴一起探索城市。';

  @override
  String get create_moment_description_label => '想分享点什么？';

  @override
  String get create_moment_add_photo => '添加照片';

  @override
  String get create_moment_add_location => '添加地点';

  @override
  String get create_moment_submit_button => '发布';

  @override
  String create_moment_preview_message(Object featureName) {
    return '$featureName 功能即将上线';
  }

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
  String get map_clear_selected_point => '清除选点';

  @override
  String get map_location_info_title => '位置信息';

  @override
  String get map_location_info_address_loading => '正在获取地址…';

  @override
  String get map_location_info_address_unavailable => '暂无法获取地址';

  @override
  String get map_location_info_create_event => '在此创建活动';

  @override
  String get map_location_info_nearby_title => '附近地点';

  @override
  String get map_location_info_nearby_empty => '100 米内暂无兴趣点。';

  @override
  String get map_location_info_nearby_error => '无法加载附近地点。';

  @override
  String get map_place_details_title => '地点信息';

  @override
  String get map_place_details_not_found => '未找到该地点的详细信息。';

  @override
  String get map_place_details_error => '暂时无法加载地点详情。';

  @override
  String get map_place_details_missing_api_key => '地点搜索不可用：未配置 API 密钥。';

  @override
  String map_place_details_rating_value(Object rating) {
    return '评分 $rating';
  }

  @override
  String get map_place_details_no_rating => '暂无评分';

  @override
  String map_place_details_reviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条评论',
      one: '1 条评论',
      zero: '暂无评论',
    );
    return '$_temp0';
  }

  @override
  String get map_place_details_price_free => '价格等级：免费';

  @override
  String get map_place_details_price_inexpensive => '价格等级：\$';

  @override
  String get map_place_details_price_moderate => '价格等级：\$\$';

  @override
  String get map_place_details_price_expensive => '价格等级：\$\$\$';

  @override
  String get map_place_details_price_very_expensive => '价格等级：\$\$\$\$';

  @override
  String get map_place_details_price_unknown => '价格等级：未知';

  @override
  String get map_select_location_title => '选择起点位置';

  @override
  String get map_select_location_tip => '在地图长按可精确调整位置。';

  @override
  String get messages => '消息';

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
  String get chat_search_hint => '搜索聊天';

  @override
  String get chat_search_title => '搜索消息';

  @override
  String get chat_search_no_results => '没有符合搜索条件的消息。';

  @override
  String get chat_status_online => '在线';

  @override
  String chat_last_seen(Object time) {
    return '最近活跃 $time';
  }

  @override
  String get chat_action_video_call => '视频通话';

  @override
  String get chat_action_phone_call => '电话';

  @override
  String get chat_action_more_options => '更多操作';

  @override
  String get chat_action_open_settings => '聊天设置';

  @override
  String chat_action_unavailable(Object feature) {
    return '$feature 即将上线';
  }

  @override
  String get chat_attachment_more => '更多功能';

  @override
  String get chat_attachment_files => '快速附件';

  @override
  String get chat_attachment_media => '图片与视频';

  @override
  String get chat_attachment_live_location => '实时位置共享';

  @override
  String get chat_composer_emoji_tooltip => '表情';

  @override
  String get chat_composer_attach_tooltip => '文件';

  @override
  String get chat_composer_more_tooltip => '更多';

  @override
  String get chat_composer_send_tooltip => '发送消息';

  @override
  String get chat_composer_voice_tooltip => '语音消息';

  @override
  String get chat_voice_recording_title => '正在录制语音';

  @override
  String get chat_voice_recording_description => '松开即可结束录音，可选择发送或取消语音。';

  @override
  String get chat_voice_recording_cancel => '取消';

  @override
  String get chat_voice_recording_send => '发送';

  @override
  String get chat_voice_recording_sent_confirmation => '语音消息已发送。';

  @override
  String get chat_voice_recording_cancelled => '已取消录音。';

  @override
  String get chat_settings_title => '聊天设置';

  @override
  String get chat_settings_share => '分享';

  @override
  String get chat_settings_leave_group => '退出群组';

  @override
  String get chat_settings_remove_friend => '删除好友';

  @override
  String get chat_settings_leave_group_confirmation_title => '退出此群组？';

  @override
  String get chat_settings_leave_group_confirmation_message => '退出后将不再收到此群的消息。';

  @override
  String get chat_settings_remove_friend_confirmation_title => '删除该联系人？';

  @override
  String get chat_settings_remove_friend_confirmation_message =>
      '此聊天将从你的列表中移除。';

  @override
  String get chat_settings_notifications => '通知提醒';

  @override
  String get chat_settings_notifications_subtitle => '静音或开启消息提醒';

  @override
  String get chat_settings_shared_files => '共享图片与视频';

  @override
  String get chat_settings_shared_files_subtitle => '查看此聊天中的所有图片与视频';

  @override
  String get chat_settings_report => '举报';

  @override
  String get chat_shared_media_filter_all => '全部';

  @override
  String get chat_shared_media_filter_photos => '图片';

  @override
  String get chat_shared_media_filter_videos => '视频';

  @override
  String get chat_shared_media_empty => '当前还没有共享的图片或视频。';

  @override
  String chat_shared_media_caption(Object sender, Object time) {
    return '$sender · $time';
  }

  @override
  String get chat_settings_members_section => '成员信息';

  @override
  String get chat_settings_contact_section => '联系人信息';

  @override
  String chat_settings_contact_id(Object id) {
    return 'ID：$id';
  }

  @override
  String chat_settings_group_overview(Object memberLabel) {
    return '群组 · $memberLabel';
  }

  @override
  String get chat_settings_direct_overview => '私聊';

  @override
  String get no_events => '暂无活动';

  @override
  String get no_events_found => '没有找到活动';

  @override
  String get not_logged_in => '未登录';

  @override
  String get preferences_title => '个人资料';

  @override
  String get preferences_basic_info_title => '基础信息';

  @override
  String get preferences_display_name_label => '显示名称';

  @override
  String get preferences_display_name_placeholder => '你的 Crew 昵称';

  @override
  String get preferences_name_empty_error => '显示名称不能为空';

  @override
  String get preferences_gender_label => '性别';

  @override
  String get preferences_gender_female => '女生';

  @override
  String get preferences_gender_male => '男生';

  @override
  String get preferences_gender_other => '不透露';

  @override
  String get preferences_country_label => '国家 / 地区';

  @override
  String get preferences_country_hint => '在头像旁展示国旗';

  @override
  String get preferences_country_unset => '未设置';

  @override
  String get country_name_china => '中国';

  @override
  String get country_name_united_states => '美国';

  @override
  String get country_name_japan => '日本';

  @override
  String get country_name_korea => '韩国';

  @override
  String get country_name_united_kingdom => '英国';

  @override
  String get country_name_australia => '澳大利亚';

  @override
  String get preferences_bio_label => '个人简介';

  @override
  String get preferences_bio_hint => '写点想让大家了解的自己';

  @override
  String get preferences_bio_placeholder => '告诉伙伴们你热爱的事';

  @override
  String get preferences_tags_title => '兴趣标签';

  @override
  String get preferences_tags_empty_helper => '加几个标签，让大家更快认识你';

  @override
  String get preferences_add_tag_label => '新增标签';

  @override
  String get preferences_tag_input_hint => '输入后按回车添加';

  @override
  String get preferences_tag_duplicate => '这个标签已经添加过啦';

  @override
  String preferences_tag_limit_reached(Object count) {
    return '最多添加 $count 个标签';
  }

  @override
  String get preferences_recommended_tags_title => '热门标签';

  @override
  String get preferences_cover_action => '更换封面';

  @override
  String get preferences_avatar_action => '更换头像';

  @override
  String get preferences_feature_unavailable => '图片编辑功能即将上线';

  @override
  String get preferences_save_success => '个人资料已更新';

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
  String get subscription_plan_title => '订阅计划';

  @override
  String get subscription_plan_subtitle => '根据需求选择最适合你的方案，随时升级或取消。';

  @override
  String get subscription_plan_current_label => '当前订阅';

  @override
  String subscription_plan_current_hint(Object plan) {
    return '你正在使用 $plan 计划。';
  }

  @override
  String get subscription_plan_price_free => '免费';

  @override
  String get subscription_plan_price_plus => '¥28 / 月';

  @override
  String get subscription_plan_price_pro => '¥68 / 月';

  @override
  String get subscription_plan_button_selected => '当前方案';

  @override
  String subscription_plan_button_upgrade(Object plan) {
    return '升级至 $plan';
  }

  @override
  String subscription_plan_button_switch(Object plan) {
    return '切换至 $plan';
  }

  @override
  String get subscription_plan_button_cancel => '取消订阅';

  @override
  String get subscription_plan_cancel_description => '恢复为 Free 计划，保留基础功能。';

  @override
  String get subscription_plan_badge_popular => '热门推荐';

  @override
  String get subscription_plan_free_feature_discover => '探索周边活动和发起人';

  @override
  String get subscription_plan_free_feature_save => '收藏心仪玩法';

  @override
  String get subscription_plan_free_feature_notifications => '接收基础提醒';

  @override
  String get subscription_plan_plus_feature_filters => '高级筛选与智能推荐';

  @override
  String get subscription_plan_plus_feature_private => '创建更多私密局';

  @override
  String get subscription_plan_plus_feature_support => '专属优先客服';

  @override
  String get subscription_plan_pro_feature_collaboration => '团队协作面板';

  @override
  String get subscription_plan_pro_feature_insights => '详细数据洞察';

  @override
  String get subscription_plan_pro_feature_history => '无限制活动记录';

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
  String get blocklist_title => '拉黑用户';

  @override
  String get blocklist_empty => '暂时还没有拉黑任何人';

  @override
  String get blocklist_unblock => '取消拉黑';

  @override
  String get blocklist_unblock_confirm_title => '取消拉黑？';

  @override
  String blocklist_unblock_confirm_message(Object name) {
    return '确定要解除对$name的拉黑吗？';
  }

  @override
  String blocklist_unblocked_snackbar(Object name) {
    return '已取消拉黑 $name';
  }

  @override
  String get settings_privacy_documents => '隐私政策 / 用户协议';

  @override
  String get privacy_documents_page_title => '隐私政策与用户协议';

  @override
  String get privacy_documents_intro =>
      '我们珍视你的信任，本页概述我们如何处理你的数据以及保障 Crew 社区安全的使用规则。';

  @override
  String get privacy_documents_privacy_title => '隐私政策';

  @override
  String get privacy_documents_privacy_body =>
      '你在创建或管理账户时提供的姓名、联系方式与资料内容，以及为实现发现、安全和个性化功能所需的使用数据、设备信号和位置信息，都会被我们谨慎处理。\n\n我们仅将这些信息用于提供服务、发送重要通知并持续优化 Crew 体验。我们不会出售你的个人信息，访问权限仅限履行保密义务的团队成员与受托合作伙伴。\n\n你可以随时在“设置 > 账号”中查看、更新或申请删除个人数据，也可以直接与我们联系。';

  @override
  String get privacy_documents_user_agreement_title => '用户协议';

  @override
  String get privacy_documents_user_agreement_body =>
      '使用 Crew 即表示你同意：1）提供真实信息并妥善保护账户安全；2）遵守社区准则与相关法律，尊重其他成员；3）合理使用活动工具，禁止垃圾信息、骚扰或未经授权的商业行为；4）理解若违反政策，我们有权暂停或终止访问。\n\n部分功能依赖设备权限（例如定位）。你可以在设备中管理权限，但禁用后某些功能可能受限。';

  @override
  String get privacy_documents_contact_title => '联系我们';

  @override
  String get privacy_documents_contact_body =>
      '如需了解隐私或协议详情，可发送邮件至 support@crewapp.com，我们会尽快回复。';

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
  String get report_issue => '举报';

  @override
  String get report_issue_description => '请选择举报类型并填写详细说明，我们会尽快核查。';

  @override
  String get report_event_type_label => '举报类型';

  @override
  String get report_event_type_required => '请选择举报类型';

  @override
  String get report_event_type_misinformation => '信息不实或误导';

  @override
  String get report_event_type_illegal => '违规违法内容';

  @override
  String get report_event_type_fraud => '涉嫌欺诈或诈骗';

  @override
  String get report_event_type_other => '其他';

  @override
  String get report_event_content_label => '举报内容';

  @override
  String get report_event_content_hint => '请补充详细情况，方便我们尽快处理。';

  @override
  String get report_event_content_required => '请填写举报内容';

  @override
  String get report_event_attachment_label => '上传图片';

  @override
  String get report_event_attachment_optional => '选填，但有助于我们更快核查。';

  @override
  String get report_event_attachment_add => '添加图片';

  @override
  String get report_event_attachment_replace => '重新选择图片';

  @override
  String get report_event_attachment_empty => '未选择文件';

  @override
  String get report_event_attachment_error => '图片加载失败，请重试。';

  @override
  String get report_event_submit => '提交举报';

  @override
  String get report_event_submit_success => '感谢反馈，我们会尽快核查该活动。';

  @override
  String get report_direct_submit_success => '感谢反馈，我们会尽快审核此对话。';

  @override
  String get report_group_submit_success => '感谢反馈，我们会尽快审核此群聊。';

  @override
  String get report_user_type_harassment => '骚扰或辱骂他人';

  @override
  String get report_user_type_impersonation => '冒充他人或虚假身份';

  @override
  String get report_user_type_inappropriate => '发布不当内容';

  @override
  String get report_user_type_spam => '垃圾信息或广告';

  @override
  String get report_user_type_other => '其他与用户相关的问题';

  @override
  String get report_group_type_illegal => '群组含违规或违法内容';

  @override
  String get report_group_type_hate => '仇恨言论或辱骂行为';

  @override
  String get report_group_type_spam => '垃圾广告或推广';

  @override
  String get report_group_type_fraud => '涉嫌欺诈或诈骗';

  @override
  String get report_group_type_other => '其他与群组相关的问题';

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

  @override
  String get map_quick_trip_default_title => '自驾游';

  @override
  String map_quick_trip_description(Object start, Object destination) {
    return '从 $start 出发前往 $destination。';
  }

  @override
  String get map_quick_trip_created => '快速行程已创建。';

  @override
  String get map_quick_trip_create_failed => '创建行程失败。';

  @override
  String get map_quick_actions_title => '快捷操作';

  @override
  String get map_quick_actions_subtitle => '选择你想要进行的操作。';

  @override
  String get map_quick_actions_quick_trip => '快速自驾';

  @override
  String get map_quick_actions_quick_trip_desc => '在地图上直接选择起点和终点。';

  @override
  String get map_quick_actions_full_trip => '完整自驾活动';

  @override
  String get map_quick_actions_full_trip_desc => '打开完整表单规划详细行程。';

  @override
  String get map_quick_actions_create_moment => '分享瞬间';

  @override
  String get map_quick_actions_create_moment_desc => '向社区发布照片或动态。';

  @override
  String get map_quick_actions_empty_title => '暂无快捷操作';

  @override
  String get map_quick_actions_empty_message => '有新的快捷工具时会在这里显示。';

  @override
  String get map_quick_trip_select_start_tip => '在地图上长按选择起点。';

  @override
  String get map_selection_sheet_tap_to_expand => '点击展开';

  @override
  String get map_select_location_destination_tip => '点击地图选择终点。';

  @override
  String get map_select_location_destination_missing => '请选择终点后继续。';

  @override
  String get map_select_location_trip_title_label => '行程名称';

  @override
  String get map_select_location_trip_title_hint => '为此次行程起个名字';

  @override
  String get map_select_location_title_required => '请输入行程名称。';

  @override
  String get map_select_location_start_label => '起点';

  @override
  String get map_select_location_destination_label => '终点';

  @override
  String get map_select_location_open_detailed => '打开详细规划';

  @override
  String get map_select_location_create_trip => '创建快速行程';

  @override
  String get wallet_title => '我的钱包';

  @override
  String get wallet_overview_subtitle => '查看余额、积分与账单';

  @override
  String get wallet_balance_label => '可用余额';

  @override
  String wallet_last_updated(Object timeAgo) {
    return '$timeAgo前更新';
  }

  @override
  String get wallet_reserved_funds => '预留中';

  @override
  String get wallet_reward_points => '积分';

  @override
  String get wallet_quick_actions => '快速操作';

  @override
  String get wallet_action_top_up => '充值';

  @override
  String get wallet_action_withdraw => '提现';

  @override
  String get wallet_action_transfer => '转账';

  @override
  String get wallet_insights_title => '本月概览';

  @override
  String get wallet_insights_description => '随时掌握活动收入与订阅支出的趋势。';

  @override
  String get wallet_help_description => '钱包功能正在内测，当前为示例数据，欢迎先体验界面设计。';

  @override
  String get wallet_help_close => '知道了';

  @override
  String get wallet_insight_income => '活动收入';

  @override
  String get wallet_insight_expense => '订阅支出';

  @override
  String get wallet_view_statements => '账单与对账';

  @override
  String get wallet_view_statements_subtitle => '导出详细结算记录';

  @override
  String get wallet_manage_methods => '支付方式管理';

  @override
  String get wallet_manage_methods_subtitle => '管理银行卡与收款账户';

  @override
  String get wallet_recent_activity => '最近交易';

  @override
  String get wallet_activity_empty => '暂无交易记录';

  @override
  String get wallet_transaction_payout_title => '活动收入';

  @override
  String get wallet_transaction_payout_subtitle => '城市骑行团 · 4月12日';

  @override
  String get wallet_transaction_refund_title => '费用退款';

  @override
  String get wallet_transaction_refund_subtitle => '海岸露营会 · 行程取消';

  @override
  String get wallet_transaction_subscription_title => 'Crew Plus 订阅';

  @override
  String get wallet_transaction_subscription_subtitle => '自动续费';

  @override
  String get settings_developer_stripe_test => 'Stripe 支付测试';

  @override
  String get settings_developer_stripe_test_subtitle => '使用测试数据打开 Stripe 支付面板';

  @override
  String get developer_test_stripe_title => 'Stripe 支付测试';

  @override
  String get developer_test_stripe_description =>
      '使用 Stripe 的测试环境来模拟支付流程，方便在正式接入前验证。';

  @override
  String get developer_test_stripe_button => '开始测试支付';

  @override
  String get developer_test_stripe_last_status => '最近状态';

  @override
  String get developer_test_stripe_reset => '清除状态';

  @override
  String get developer_test_stripe_success => '支付已成功完成。';

  @override
  String get developer_test_stripe_cancelled => '支付已取消。';

  @override
  String get developer_test_stripe_option_registration_sponsor =>
      '报名费 + 赞助费（€1.00）';

  @override
  String get developer_test_stripe_option_registration_sponsor_detail =>
      '包含示例报名费以及可选的赞助费用。';

  @override
  String get developer_test_stripe_option_registration_only => '报名费（€0.50）';

  @override
  String get developer_test_stripe_option_registration_only_detail =>
      '仅包含基础报名费用。';

  @override
  String get developer_test_stripe_option_sponsor_only => '赞助费（€0.75）';

  @override
  String get developer_test_stripe_option_sponsor_only_detail => '仅包含赞助附加费用。';

  @override
  String developer_test_stripe_failure(Object error) {
    return '支付失败：$error';
  }
}
