## 聊天（Chat）模块模型

- **ChatSummaryDto**：会话概览，含会话 ID、类型、标题、拥有者/活动关联、归档状态、创建时间、当前用户角色、已读序号、未读数以及最近一条消息摘要。
- **ChatMessageDto**：单条聊天消息，包含消息 ID、所在会话、发送者、消息类型、正文、扩展元数据、创建时间、序号与状态。
- **ChatMemberDto**：会话成员信息，包含成员加入/静音/离开时间、角色以及最近阅读的消息序号。
- **ChatReactionDto**：消息表情回应，记录消息 ID、用户、表情符号以及创建时间。
- **SendMessageRequest**：发送消息请求，需指定消息类型，可选正文与元数据 JSON。
- **AddMemberRequest**：邀请成员进群，需要用户 ID，角色默认 `Member`。
- **MarkReadRequest**：上报已读进度，包含会话 ID 与最大已读序号。
- **SetReactionRequest**：设置某条消息的表情反应，需提供 Emoji 字符串（最长 32）。

## 动态（Moments）模块模型

- **MomentSummaryDto**：动态列表项，含动态 ID、作者、标题、封面、国家/城市以及创建时间。
- **MomentDetailDto**：动态详情，包含作者信息、标题、正文、封面、国家/城市、创建时间、图片数组与评论列表。
- **MomentCommentDto**：动态评论，记录评论 ID、作者、内容与时间戳。
- **CreateMomentRequestDto**：创建动态请求，需要标题、封面、国家以及图片列表，可关联活动、补充正文与城市。
- **AddMomentCommentRequest**：发表评论请求，仅包含评论内容文本。

## 地点（Places）模块模型

- **PlaceSummaryDto**：地点摘要，包含 Place ID、名称、经纬度数组、类型列表。
- **PlaceDetailDto**：地点详情，在摘要基础上增加格式化地址。



















### 用户相关模型

- **EnsureUserRequest**（创建/同步当前登录用户资料时发送的请求体）
  字段：`firebaseUid`、`displayName`、`email`、`role`、`avatarUrl`、`bio`、`tags`。`tags` 可以为空，后端允许 `null`。
- **UserSummaryDto**（公开用户列表返回的简要信息）
  字段：`id`、`displayName`、`email`、`role`、`avatarUrl`、`createdAt`。
- **UserProfileDto**（用户详情页完整档案）
  包含：`id`、`displayName`、`email`、`role`、`bio`、`avatarUrl`、`followers`、`following`、`tags`、`activities`、`guestbook`、`history`。其中 `activities`、`guestbook`、`history` 分别对应以下 DTO。
  - **UserActivityDto**：`eventId`、`title`、`startTime`、`role`、`isCreator`、`confirmedParticipants`、`maxParticipants`。
  - **UserGuestbookEntryDto**：`id`、`authorId`、`authorDisplayName`、`content`、`rating`、`createdAt`。
  - **UserHistoryDto**：`id`、`eventId`、`eventTitle`、`role`、`occurredAt`。
- **AddGuestbookEntryRequest**（留言时发送）
  字段：`content`、`rating`（可选）。

### 活动相关模型

- **EventSummaryDto**（活动搜索等列表接口）
  字段：`id`、`ownerId`、`title`、`startTime`、`center`（经纬度数组）、`memberCount`、`maxParticipants`、`isRegistered`、`tags`。
- **EventCardDto**（活动推荐 feed 的单个卡片）
  字段：`id`、`ownerId`、`title`、`description`、`startTime`、`createdAt`、`coordinates`、`distanceKm`、`registrations`、`likes`、`engagement`、`tags`。
- **EventFeedResponseDto**（活动 feed 列表响应）
  字段：`events`（`EventCardDto` 列表）、`nextCursor`（游标分页）。
- **EventDetailDto**（活动详情页）
  字段：`id`、`ownerId`、`title`、`description`、`startTime`、`endTime`、`startPoint`、`endPoint`、`routePolyline`、`maxParticipants`、`visibility`、`segments`、`memberCount`、`isRegistered`、`tags`、`moments`。
  - `segments` 为 `EventSegmentDto` 列表，包含 `seq`、`waypoint`（经纬度数组）、`note`。
  - `moments` 为 `MomentSummaryDto` 列表，包含 `id`、`userId`、`userDisplayName`、`title`、`coverImageUrl`、`country`、`city`、`createdAt`。

### Flutter 数据建模建议

- 依据以上 DTO/Request 结构，分别在 `lib/models` 或 `lib/data/models` 下定义 `fromJson/toJson`。
- 注意 `Guid` 在 Flutter 中可按字符串处理；`DateTimeOffset` 序列化为 ISO8601 字符串，使用 `DateTime.parse` 并保留时区信息。
- 所有 `double[]` 字段（如 `center`、`coordinates`、`startPoint`）都表示 `[经度, 纬度]` 数组，可映射为 `List<double>`。