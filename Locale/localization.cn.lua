-- $Id$ 

local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "zhCN", false)

if not L then return end
--@do-not-package@
-- Header
L["ACCLOC_TITLE"] = "Accountant Classic"
L["ACCLOC_DESC"] = "追踪每个角色的所有收入与支出状况，并可显示当日小计、当周小计、以及自有记录起的总计。并可显示所有角色的总金额。"
L["ACCLOC_TIP"] = "单击打开 Accountant Classic\n右键点击打开设置\n右键并拖曳以移动图示按钮位置"
L["ACCLOC_TIP2"] = "右键并拖曳以移动图示按钮位置\n右键点击 Accountant Classic"
L["ACCLOC_TOT_IN"] = "总收入"
L["ACCLOC_TOT_OUT"] = "总支出"
L["ACCLOC_NET"] = "净收益/亏损"
L["ACCLOC_NETLOSS"] = "净亏损"
L["ACCLOC_NETPROF"] = "净收益"
L["ACCLOC_SOURCE"] = "类别"
L["ACCLOC_IN"] = "收入"
L["ACCLOC_OUT"] = "支出"
L["ACCLOC_WEEKSTART"] = "当周首日"
L["ACCLOC_SUM"] = "总金额"
L["ACCLOC_CHAR"] = "角色"
L["ACCLOC_MONEY"] = "金钱"
L["ACCLOC_UPDATED"] = "更新"

-- Section Labels
L["ACCLOC_QUEST"] = "任务奖励"
L["ACCLOC_MERCH"] = "商人"
L["ACCLOC_TRADE"] = "交易"
L["ACCLOC_MAIL"] = "邮寄"
L["ACCLOC_TRAIN"] = "训练费用"
L["ACCLOC_TAXI"] = "飞行花费"
L["ACCLOC_OTHER"] = "未知"
L["ACCLOC_REPAIR"] = "修理装备"
L["ACCLOC_LFG"] = "随机地城、团队与事件"

-- Buttons
L["ACCLOC_RESET"] = "归零"
L["ACCLOC_OPTBUT"] = "选项"
L["ACCLOC_EXIT"] = "离开"

-- Tabs
L["ACCLOC_SESS"] = "本次"
L["ACCLOC_DAY"] = "本日"
L["ACCLOC_PRVDAY"] = "上一日"
L["ACCLOC_WEEK"] = "本周"
L["ACCLOC_PRVWEEK"] = "上一周"
L["ACCLOC_MONTH"] = "本月"
L["ACCLOC_PRVMON"] = "上一月"
L["ACCLOC_YEAR"] = "今年"
L["ACCLOC_PRVYEAR"]	= "上一年"
L["ACCLOC_TOTAL"] = "总计"
L["ACCLOC_CHARS"] = "所有角色"

-- Options
L["ACCLOC_OPTS"] = "Accountant Classic 选项"
L["ACCLOC_MINIBUT"] = "显示小地图按钮"
L["ACCLOC_MINIBUTMONEY"] = "在小地图按钮的提示显示目前现金"
L["ACCLOC_MINIBUTSESSINF"] = "在小地图按钮的提示显示本次收入/支出"
L["ACCLOC_ONSCRMONEY"] = "在游戏画面显示目前现金"
L["ACCLOC_RSTPOSITION"] = "重置位置"
L["ACCLOC_RSTMNYFRM_TIP"] = "重置画面上显示现金的位置"
L["ACCLOC_BUTPOS"] = "小地图按钮位置"
L["ACCLOC_STARTWEEK"] = "一周的开始日"
L["ACCLOC_DONE"] = "完成"
L["ACCLOC_INTROTIPS"] = "显示指引提示"
L["ACCLOC_INTROTIPS_TIP"] = "选择是否在小地图按钮或浮动视窗显示额外的操作提示"
L["ACCLOC_REMOVECHAR"] = "选择要移除的角色:"
L["ACCLOC_REMOVECHAR_TIP"] = "被选取的角色的个人会计资料将会被移除。"
L["ACCLOC_CHARREMOVETEXT"] = "即将移除选取的角色。\n是否确定要从个人会计的资料库中移除下列角色?"
L["ACCLOC_CHARREMOVEDONE"] = "|cffffffff「%s - %s|cffffffff」角色的 Accountant Classic 资料已经移除。"
L["ACCLOC_DATEFORMAT"] = "选择日期格式："
L["ACCLOC_DATEFORMAT_TIP"] = "在「本周」与「所有角色」页签所显示的日期格式"
L["ACCLOC_LDBINFOTYPE"] = "在 LDB 支援的显示列上显示本次的净收入/净支出而非显示总金额"
L["ACCLOC_CROSSSERVER"]		= "显示所有服务器的角色信息"
L["ACCLOC_CROSSSERVER_TIP"]	= "启用以显示来自所有服务器的所有角色的金流信息。停用则仅会显示目前服务器的角色信息。"
L["ACCLOC_TRACKZONE"] = "追踪每笔收入/支出的地点"
L["ACCLOC_TRACKZONE_TIP"] = "启用以追踪每笔您的收入与支出的发生地点，并且在 Accountant Classic 窗口中，当鼠标移到每项金额时，显示这些地点的详细信息。"
L["ACCLOC_TRACKSUBZONE"] = "同时也追踪子区域信息"
L["ACCLOC_TRACKSUBZONE_TIP"] = "启用以追踪子区域信息。例如：「苏拉玛 - 秩序大殿」"

-- Misc
L["ACCLOC_RESET_CONF"] = "是否确定要将「%s」页签的资料归零?"
L["ACCLOC_NEWPROFILE"] = "%s的 Accountant Classic 数据已建立"
L["ACCLOC_LOADPROFILE"] = "%s的 Accountant Classic 数据已加载"
L["ACCLOC_LOADED"] = "Accountant Classic 插件已载入"
L["ACCLOC_GOLD"] = "金"
L["ACCLOC_SILVER"] = "银"
L["ACCLOC_CENT"] = "铜"
L["ACCLOC_ABOUT"] = "关于"
L["ACCLOC_CONFLICT"] = "侦测到冲突的插件 - |cFFFF0000Accountant|r。\n它已被停止启用，按下确定按键以重新载入游戏。"
L["ACCLOC_CLEANUPACCOUNTANT"] = "您以手动执行了以下函式\n|cFF00FF00AccountantClassic_CleanUpAccountantDB()|r\n以清除在 \"Accountant\" 插件里冲突的资料。\n现在请按下确定按键以重新载入游戏。 "
L["ACCLOC_SHOWALL"] = "显示所有角色"
L["ACCLOC_SHOWALLTIP"] = "显示所有角色的收入与支出加总"

-- Amount string for CHAT_MESSAGE_MONEY search
L["GOLD"]			= "(%d+)金币"
L["SILVER"]			= "(%d+)银币"
L["COPPER"]			= "(%d+)铜币"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Accountant Classic 按键设定"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "呼叫 Accountant Classic"
--@end-do-not-package@
--@localization(locale="zhCN", format="lua_additive_table")@
