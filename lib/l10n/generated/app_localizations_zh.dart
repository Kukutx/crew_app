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
  String get about_current_version => '当前版本';

  @override
  String get about_build_number => '构建号';

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
  String get action_cancel => '取消';

  @override
  String get action_create => '创建';

  @override
  String get action_follow => '关注';

  @override
  String get action_following => '已关注';

  @override
  String get action_logout => '退出登录';

  @override
  String get action_register => '报名';

  @override
  String get action_register_now => '立即报名';

  @override
  String get chinese => '中文';

  @override
  String get city_field_label => '城市/地点（可编辑）';

  @override
  String get city_loading => '正在获取…';

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
  String get event_meeting_point_view_button => '查看地图';

  @override
  String get event_meeting_point_hint => '点击按钮即可打开地图查看集合地点。';

  @override
  String get event_copy_address_button => '复制地址';

  @override
  String get event_copy_address_success => '地址已复制';

  @override
  String get event_participants_title => '参与人数';

  @override
  String get event_route_start_label => '起点';

  @override
  String get event_route_end_label => '终点';

  @override
  String get event_time_title => '活动时间';

  @override
  String get event_start_time_label => '开始时间';

  @override
  String get event_end_time_label => '结束时间';

  @override
  String get event_fee_title => '报名费用';

  @override
  String get event_fee_free => '免费';

  @override
  String get event_expense_calculate_button => '计算费用';

  @override
  String get event_group_expense_title => '多人记账';

  @override
  String get event_waypoints_title => '途径点';

  @override
  String get event_route_type_title => '路线类型';

  @override
  String get event_route_type_round => '往返路线';

  @override
  String get event_route_type_one_way => '单程路线';

  @override
  String get event_status_reviewing => '审核中';

  @override
  String get event_status_recruiting => '招募中';

  @override
  String get event_status_ongoing => '进行中';

  @override
  String get event_status_ended => '已结束';

  @override
  String get event_title_field_label => '活动标题';

  @override
  String get messages_tab_private => '私聊';

  @override
  String get messages_tab_groups => '群聊';

  @override
  String get system_notifications_tab_notifications => '系统通知';

  @override
  String get system_notifications_tab_customer_service => '客服';

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
  String get create_moment_type_section_title => '选择瞬间类型';

  @override
  String get create_moment_type_instant => '即时瞬间';

  @override
  String get create_moment_type_event => '活动瞬间';

  @override
  String get create_moment_event_link_label => '已关联活动';

  @override
  String get create_moment_event_link_value => '自驾游 · 活动进行中';

  @override
  String get create_moment_submit_button => '发布';

  @override
  String create_moment_preview_message(Object featureName) {
    return '$featureName 功能即将上线';
  }

  @override
  String get create_event_title => '创建活动';

  @override
  String get feature_not_ready => '该功能正在开发中';

  @override
  String get filter => '筛选';

  @override
  String get followed => '已关注';

  @override
  String get favorites_empty => '暂无收藏~';

  @override
  String get language => '语言';

  @override
  String get load_failed => '加载失败';

  @override
  String location_coordinates(Object lat, Object lng) {
    return '位置：$lat, $lng';
  }

  @override
  String get login_footer => '继续即表示同意我们的服务条款与隐私政策';

  @override
  String get login_prompt => '点击上方按钮登录体验更多功能';

  @override
  String get login_subtitle => '基于地理位置组织活动，一键加入你的 Crew';

  @override
  String get login_title => '欢迎来到 Crew';

  @override
  String get login_agreement_prefix => '我已阅读并同意';

  @override
  String get login_agreement_terms => '《用户协议》';

  @override
  String get login_agreement_privacy => '《隐私政策》';

  @override
  String get login_agreement_children => '《未成年人个人信息保护规则》';

  @override
  String get login_failed_message => '登录失败，请稍后重试';

  @override
  String get logout_success => '已退出登录';

  @override
  String get map => '地图';

  @override
  String get map_clear_selected_point => '清除';

  @override
  String get map_clear_waypoint => '清除途经点';

  @override
  String get map_add_waypoint_tip => '单击地图添加途经点，长按调整起点和终点';

  @override
  String get map_select_location_destination_tip => '点击地图选择终点。';

  @override
  String get map_guide_step_1 => '长按地图选择起点位置';

  @override
  String get map_guide_step_2 => '长按地图选择终点位置';

  @override
  String get map_guide_step_3 => '步骤 3：点击地图添加途径点（可选）';

  @override
  String get map_guide_waypoint_step_3 => '步骤 3：点击\"添加途径点\"按钮，然后点击地图添加途径点（可选）';

  @override
  String get map_guide_waypoint_manage => '在列表中拖拽可调整顺序，左滑可删除途径点';

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
  String get map_select_location_title => '选择起点位置';

  @override
  String get map_select_location_tip => '在地图长按可精确调整位置。';

  @override
  String get messages => '消息';

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
  String get chat_attachment_image => '图片';

  @override
  String get chat_attachment_live_location => '实时位置共享';

  @override
  String get chat_composer_emoji_tooltip => '表情';

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
  String get preferences_gender_custom => '自定义';

  @override
  String get preferences_gender_custom_field_label => '自定义性别';

  @override
  String get preferences_gender_custom_field_hint => '请输入你的性别';

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
  String get search_hint => '搜索活动';

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
  String get settings_section_notifications => '通知设置';

  @override
  String get settings_section_developer => '开发者工具';

  @override
  String get settings_help_feedback => '帮助与反馈';

  @override
  String get settings_app_version => '关于 Crew';

  @override
  String get settings_subscription_current_plan => '当前订阅计划';

  @override
  String get settings_subscription_plan_free => 'Free';

  @override
  String get settings_subscription_plan_plus => 'Plus';

  @override
  String get settings_subscription_plan_pro => 'Pro';

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
  String get support_feedback_title => '意见反馈';

  @override
  String get support_feedback_description_label => '反馈描述';

  @override
  String get support_feedback_description_hint => '请详细描述您的问题与建议';

  @override
  String get support_feedback_media_label => '图片与视频';

  @override
  String get support_feedback_phone_label => '手机号码';

  @override
  String get support_feedback_phone_hint => '请输入手机号';

  @override
  String get support_feedback_submit => '提交反馈';

  @override
  String get support_feedback_description_required => '请填写反馈描述。';

  @override
  String get support_feedback_max_attachments => '最多可上传4个附件。';

  @override
  String get support_feedback_add_photo => '选择图片';

  @override
  String get tag_city_explore => '城市探索';

  @override
  String get tag_easy_social => '轻松社交';

  @override
  String get tag_walk_friendly => '步行友好';

  @override
  String get to_be_announced => '待公布';

  @override
  String get unknown => '未知';

  @override
  String get unfollowed => '已取消关注';

  @override
  String get disclaimer_acknowledge => '我已阅读并同意上述条款';

  @override
  String get disclaimer_exit => '退出';

  @override
  String get disclaimer_accept => '同意';

  @override
  String get map_quick_actions_my_moments => '我的瞬间';

  @override
  String get map_quick_actions_my_drafts => '我的草稿';

  @override
  String get map_quick_actions_add_friend => '添加好友';

  @override
  String get map_quick_actions_my_event => '我的活动';

  @override
  String get map_quick_actions_my_ledger => '我的账本';

  @override
  String get map_quick_actions_wallet => '我的钱包';

  @override
  String get map_quick_actions_bottom_scan => '扫一扫';

  @override
  String get map_quick_actions_bottom_support => '帮助与客服';

  @override
  String get map_quick_actions_bottom_settings => '设置';

  @override
  String get qr_scanner_title => '扫描二维码';

  @override
  String get qr_scanner_instruction => '请将二维码对准扫描框中心';

  @override
  String get qr_scanner_torch_hint => '轻触照亮';

  @override
  String get qr_scanner_my_code => '我的二维码';

  @override
  String get qr_scanner_album => '相册';

  @override
  String get my_moments_title => '我的瞬间';

  @override
  String get my_drafts_title => '我的草稿';

  @override
  String get my_drafts_section_saved => '已保存的草稿';

  @override
  String get my_drafts_resume_button => '继续编辑';

  @override
  String get map_selection_sheet_tap_to_expand => '点击展开';

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
  String get map_apply_location => '应用位置';

  @override
  String get wallet_title => '我的钱包';

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
  String get road_trip_create_button => '创建';

  @override
  String get road_trip_continue_button => '继续';

  @override
  String get road_trip_tab_route => '路线';

  @override
  String get road_trip_tab_waypoints => '途径点';

  @override
  String get road_trip_image_picker_failed => '选择图片失败，请检查权限设置';

  @override
  String get road_trip_basic_section_title => '基础信息';

  @override
  String get road_trip_basic_section_subtitle => '命名旅程并锁定时间';

  @override
  String get road_trip_basic_title_label => '旅程标题';

  @override
  String get road_trip_basic_title_hint => '如：五渔村海岸线一日自驾';

  @override
  String get road_trip_basic_title_required => '请输入标题';

  @override
  String get road_trip_basic_date_label => '活动日期';

  @override
  String get road_trip_basic_date_hint => '点击选择日期范围';

  @override
  String get road_trip_route_section_title => '路线类型';

  @override
  String get road_trip_route_section_subtitle => '选择往返或单程路线';

  @override
  String get road_trip_route_add_waypoint => '添加途经点';

  @override
  String get road_trip_route_add_to_forward => '添加到去程';

  @override
  String get road_trip_route_add_to_return => '添加到返程';

  @override
  String get road_trip_route_type_round => '往返';

  @override
  String get road_trip_route_type_one_way => '单程';

  @override
  String road_trip_route_waypoints_one_way(int count) {
    return '途经点（单程） · 共 $count 个';
  }

  @override
  String get road_trip_route_forward_label => '去程';

  @override
  String get road_trip_route_return_label => '返程';

  @override
  String road_trip_route_waypoints_count(int count) {
    return ' · 共 $count 个';
  }

  @override
  String road_trip_route_waypoint_label(int index) {
    return '途经点 $index';
  }

  @override
  String get road_trip_team_section_title => '团队配置';

  @override
  String get road_trip_team_section_subtitle => '人数限制与费用模式';

  @override
  String get road_trip_team_pricing_free => '免费';

  @override
  String get road_trip_team_pricing_paid => '收费';

  @override
  String get road_trip_team_max_participants_label => '人数上限';

  @override
  String get road_trip_team_max_participants_hint => '例如 4';

  @override
  String get road_trip_team_max_participants_error => '请输入≥1的整数';

  @override
  String get road_trip_team_price_label => '人均费用 (€)';

  @override
  String get road_trip_team_price_free_hint => '免费活动';

  @override
  String get road_trip_team_price_paid_hint => '例如 29.5';

  @override
  String get road_trip_preferences_section_title => '个性设置';

  @override
  String get road_trip_preferences_car_type_label => 'Vehicle type (optional)';

  @override
  String get road_trip_preferences_car_sedan => 'Sedan';

  @override
  String get road_trip_preferences_car_suv => 'SUV';

  @override
  String get road_trip_preferences_car_hatchback => 'Hatchback';

  @override
  String get road_trip_preferences_car_van => 'Van';

  @override
  String get road_trip_preferences_tag_label => '添加标签';

  @override
  String get road_trip_preferences_tag_hint => '添加';

  @override
  String get road_trip_gallery_section_title => '旅程影像';

  @override
  String get road_trip_gallery_section_subtitle => '可选择多张，首张默认为封面';

  @override
  String get road_trip_gallery_select_images => '选择图片';

  @override
  String get road_trip_gallery_add_more => '追加图片';

  @override
  String get road_trip_gallery_empty_hint => '还没有选择图片，点击下方按钮添加';

  @override
  String get road_trip_gallery_cover_label => '封面';

  @override
  String road_trip_gallery_image_label(int index) {
    return '第 $index 张';
  }

  @override
  String get road_trip_gallery_set_cover => '设为封面';

  @override
  String get road_trip_story_section_title => '活动亮点';

  @override
  String get road_trip_story_section_subtitle => '告诉伙伴们为什么要来';

  @override
  String get road_trip_story_description_label => '详细描述';

  @override
  String get road_trip_story_description_hint => '路线亮点、注意事项、装备建议…';

  @override
  String get road_trip_story_description_required => '请输入描述';

  @override
  String get road_trip_disclaimer_section_title => '发起者免责声明';

  @override
  String get road_trip_disclaimer_section_subtitle => '向伙伴说明风险、特殊要求…';

  @override
  String get road_trip_disclaimer_content_label => '免责声明内容';

  @override
  String get road_trip_disclaimer_content_hint => '例如风险提示、特殊说明等';

  @override
  String get road_trip_create_success_title => '创建成功！';

  @override
  String get road_trip_create_success_message => '您的自驾游已成功创建，现在可以供其他人加入了。';

  @override
  String get road_trip_create_failed_title => '创建失败';

  @override
  String get road_trip_create_failed_message => '无法创建您的自驾游，请重试。';

  @override
  String get road_trip_create_done_button => '完成';

  @override
  String get road_trip_validation_date_range_required => '请选择活动日期范围';

  @override
  String get road_trip_validation_title_max_length => '标题不能超过20个字符';

  @override
  String get road_trip_validation_price_invalid => '请输入有效的人均费用（0-100）';

  @override
  String get road_trip_validation_coordinate_invalid => '坐标值无效，请重新选择位置';

  @override
  String get road_trip_validation_max_participants_invalid =>
      '请输入有效的人数上限（≥1的整数）';

  @override
  String road_trip_create_success(Object action, Object id) {
    return '$action成功：$id';
  }

  @override
  String road_trip_create_failed(Object error) {
    return '创建失败：$error';
  }

  @override
  String get action_update => '更新';

  @override
  String get share_error_retry => '分享失败，请稍后重试';

  @override
  String get event_members_list => '成员';

  @override
  String get event_member_role_organizer => '组织者';

  @override
  String get event_member_role_participant => '参与者';

  @override
  String get event_organizer_disclaimer_title => '发起人免责声明';

  @override
  String get event_organizer_disclaimer_content =>
      '本活动由发起人自行发布并负责组织，Crew 仅提供信息展示与沟通工具。请在参与前自行核实活动详情与安全保障，并根据自身情况评估风险。如遇异常情况或争议，请及时与发起人沟通或联系 Crew 寻求协助。';

  @override
  String get event_organizer_disclaimer_acknowledge => '我知道了';

  @override
  String get event_action_edit => '编辑';

  @override
  String get event_action_delete => '删除';

  @override
  String get event_edit_not_implemented => '活动编辑提交暂未接入后端';

  @override
  String get event_delete_not_implemented => '活动删除暂未接入后端';

  @override
  String get moment_post_ip_location_label => 'IP属地';

  @override
  String get moment_post_ip_location_prefix => 'IP属地：';

  @override
  String get moment_post_ip_location_unknown => '未知';

  @override
  String get profile_followers => '粉丝';

  @override
  String get profile_following => '关注';

  @override
  String get profile_events => '活动';

  @override
  String get profile_view_guestbook => '查看留言簿';

  @override
  String get profile_message_button => '私信';
}
