-- $Id$ 
-- Thanks to Narumar and unw1s3
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "ruRU", false)

if not L then return end
--@do-not-package@
-- Header
L["ACCLOC_TITLE"] = "Accountant Classic"
-- L["ACCLOC_DESC"] = ""
L["ACCLOC_TIP"] = "Left-Click для открытия Accountant Classic.\nRight-Click для настройки Accountant Classic."
-- L["ACCLOC_TIP2"] = ""
L["ACCLOC_TOT_IN"] = "Всего Доходов"
L["ACCLOC_TOT_OUT"] = "Всего Расходов"
L["ACCLOC_NET"] = "Чистая прибыль / Убыток"
L["ACCLOC_NETLOSS"] = "Чистый Убыток"
L["ACCLOC_NETPROF"] = "Чистый Доход"
L["ACCLOC_SOURCE"] = "Источник"
L["ACCLOC_IN"] = "Доходы"
L["ACCLOC_OUT"] = "Расходы"
L["ACCLOC_WEEKSTART"] = "Начало недели"
L["ACCLOC_SUM"] = "ИТОГО"
L["ACCLOC_CHAR"] = "Персонаж"
L["ACCLOC_MONEY"] = "Деньги"
L["ACCLOC_UPDATED"] = "Обновлено"

-- Section Labels
L["ACCLOC_QUEST"] = "Награда за Квесты"
L["ACCLOC_MERCH"] = "Торговцы"
L["ACCLOC_TRADE"] = "Обмен"
L["ACCLOC_MAIL"] = "Почта"
L["ACCLOC_TRAIN"] = "Расходы на обучение/тренеровки"
L["ACCLOC_TAXI"] = "Воздушное Такси"
L["ACCLOC_OTHER"] = "Неизвестный"
L["ACCLOC_REPAIR"] = "Затраты на ремонт"
-- L["ACCLOC_LFG"] = ""

-- Buttons
L["ACCLOC_RESET"] = "Сбросить"
L["ACCLOC_OPTBUT"] = "Опции"
L["ACCLOC_EXIT"] = "Закрыть"

-- Tabs
L["ACCLOC_SESS"] = "Сессия"
L["ACCLOC_DAY"] = "День"
-- L["ACCLOC_PRVDAY"] = ""
L["ACCLOC_WEEK"] = "Неделя"
-- L["ACCLOC_PRVWEEK"] = ""
-- L["ACCLOC_MONTH"] = ""
-- L["ACCLOC_PRVMON"] = ""
L["ACCLOC_TOTAL"] = "Все"
L["ACCLOC_CHARS"] = "Все Персонажи"

-- Options
L["ACCLOC_OPTS"] = "Настройки"
L["ACCLOC_MINIBUT"] = "Показывать значек у миникарты"
-- L["ACCLOC_MINIBUTMONEY"] = ""
-- L["ACCLOC_MINIBUTSESSINF"] = ""
-- L["ACCLOC_ONSCRMONEY"] = ""
-- L["ACCLOC_RSTPOSITION"] = ""
-- L["ACCLOC_RSTMNYFRM_TIP"] = ""
L["ACCLOC_BUTPOS"] = "Позиция на миникарте"
L["ACCLOC_STARTWEEK"] = "Начало недели"
L["ACCLOC_DONE"] = "Готово"
-- L["ACCLOC_INTROTIPS"] = ""
-- L["ACCLOC_INTROTIPS_TIP"] = ""
-- L["ACCLOC_REMOVECHAR"] = ""
-- L["ACCLOC_REMOVECHAR_TIP"] = ""
-- L["ACCLOC_CHARREMOVETEXT"] = ""
-- L["ACCLOC_CHARREMOVEDONE"] = ""
-- L["ACCLOC_DATEFORMAT"] = ""
-- L["ACCLOC_DATEFORMAT_TIP"] = ""
-- L["ACCLOC_LDBINFOTYPE"] = ""

-- Misc
L["ACCLOC_RESET_CONF"] = "Вы уверены, что хотите сбросить"
L["ACCLOC_NEWPROFILE"] = "Создать новый профиль для"
L["ACCLOC_LOADPROFILE"] = "Загрузить профиль для"
L["ACCLOC_LOADED"] = "Загрузка аддона"
L["ACCLOC_GOLD"] = " зол. "
L["ACCLOC_SILVER"] = " сер. "
L["ACCLOC_CENT"] = " м. "
L["ACCLOC_ABOUT"] = "Об Аддоне"
-- L["ACCLOC_CONFLICT"] = ""
-- L["ACCLOC_CLEANUPACCOUNTANT"] = ""
-- L["ACCLOC_SHOWALL"] = ""
-- L["ACCLOC_SHOWALLTIP"] = ""

-- Amount string for CHAT_MESSAGE_MONEY search
L["GOLD"]			= "(%d+) |4золотая:золотые:золотых;"
L["SILVER"]			= "(%d+) |4серебряная:серебряные:серебряных;"
L["COPPER"]			= "(%d+) |4медная монета:медные монеты:медных монет;"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Переключить Accountant Classic"
--@end-do-not-package@
--@localization(locale="ruRU", format="lua_additive_table")@
