-- $Id$ 

local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "koKR", false)

if not L then return end
--@do-not-package@
-- Header
L["ACCLOC_TITLE"] = "가계부"
L["ACCLOC_DESC"] = "와우 내에서 수입과 지출을 기록하는 애드온입니다."
L["ACCLOC_TIP"] = "왼쪽 클릭으로 가계부를 엽니다.\n오른쪽 클릭으로 가계부 설정을 엽니다."
L["ACCLOC_TIP2"] = "왼쪽클릭하여 드래그하면 버튼을 이동합니다.\n오른쪽 클릭으로 가계부를 엽니다."
L["ACCLOC_TOT_IN"] = "총수입"
L["ACCLOC_TOT_OUT"] = "총지출"
L["ACCLOC_NET"] = "순이익 / 손해"
L["ACCLOC_NETLOSS"] = "지출"
L["ACCLOC_NETPROF"] = "순이익"
L["ACCLOC_SOURCE"] = "출처"
L["ACCLOC_IN"] = "수입"
L["ACCLOC_OUT"] = "지출"
L["ACCLOC_WEEKSTART"] = "주 시작"
L["ACCLOC_SUM"] = "합계"
L["ACCLOC_CHAR"] = "합계"
L["ACCLOC_MONEY"] = "골드"
L["ACCLOC_UPDATED"] = "최근 확인 날짜"

-- Section Labels
L["ACCLOC_QUEST"] = "퀘스트 보상"
L["ACCLOC_MERCH"] = "상점"
L["ACCLOC_TRADE"] = "거래"
L["ACCLOC_MAIL"] = "우편"
L["ACCLOC_TRAIN"] = "기술 습득"
L["ACCLOC_TAXI"] = "비행 요금"
L["ACCLOC_OTHER"] = "기타"
L["ACCLOC_REPAIR"] = "수리 비용"
L["ACCLOC_LFG"] = "던전 및 공격대"

-- Buttons
L["ACCLOC_RESET"] = "초기화"
L["ACCLOC_OPTBUT"] = "설정"
L["ACCLOC_EXIT"] = "닫기"

-- Tabs
L["ACCLOC_SESS"] = "현재"
L["ACCLOC_DAY"] = "일"
-- L["ACCLOC_PRVDAY"] = ""
L["ACCLOC_WEEK"] = "주"
-- L["ACCLOC_PRVWEEK"] = ""
L["ACCLOC_MONTH"] = "월"
L["ACCLOC_PRVMON"] = "지난 달"
L["ACCLOC_TOTAL"] = "합계"
L["ACCLOC_CHARS"] = "총 합계"

-- Options
L["ACCLOC_OPTS"] = "Accountant 설정"
L["ACCLOC_MINIBUT"] = "미니맵 버튼 표시"
L["ACCLOC_MINIBUTMONEY"] = "미니맵 버튼 툴팁에 현재 소지 금액을 표시합니다."
L["ACCLOC_MINIBUTSESSINF"] = "미니맵 버튼 툴팁에 현재 수입/지출 내역을 표시합니다."
L["ACCLOC_ONSCRMONEY"] = "소지 금액 창 표시"
L["ACCLOC_RSTPOSITION"] = "위치 초기화"
L["ACCLOC_RSTMNYFRM_TIP"] = "소지 금액 창의 위치 초기화"
L["ACCLOC_BUTPOS"] = "미니맵 버튼 위치"
L["ACCLOC_STARTWEEK"] = "시작"
L["ACCLOC_DONE"] = "완료"
L["ACCLOC_INTROTIPS"] = "명령어를 툴팁에 표시"
L["ACCLOC_INTROTIPS_TIP"] = "가계부나 미니맵 버튼에 화면에 사용할 수 있는 명령어를 툴팁에 표시합니다."
L["ACCLOC_REMOVECHAR"] = "삭제할 캐릭터를 선택하세요."
L["ACCLOC_REMOVECHAR_TIP"] = "가계부 데이터에서 선택한 캐릭터의 정보를 삭제합니다."
L["ACCLOC_CHARREMOVETEXT"] = "선택한 캐릭터의 가계부 내용을 삭제합니다. 선택한 캐릭터의 데이터를 삭제하시겠습니까?"
L["ACCLOC_CHARREMOVEDONE"] = "|cffffffff\"%s - %s|cffffffff\" 의 데이터가 삭제되었습니다."
L["ACCLOC_DATEFORMAT"] = "날짜 형식 선택:"
L["ACCLOC_DATEFORMAT_TIP"] = "날짜 형식은 총 합계 또는 주 탭에서 확인하세요."
L["ACCLOC_LDBINFOTYPE"] = "접속한 캐릭터의 골드 수입/지출 내역을 LDB에 표시합니다."

-- Misc
L["ACCLOC_RESET_CONF"] = "\"%s\" 의 데이터를 삭제합니까?"
L["ACCLOC_NEWPROFILE"] = "새 Accountant 프로필"
L["ACCLOC_LOADPROFILE"] = "로드된 Accountant 프로필"
L["ACCLOC_LOADED"] = "로드됨"
L["ACCLOC_GOLD"] = "골드 "
L["ACCLOC_SILVER"] = "실버 "
L["ACCLOC_CENT"] = "코퍼"
L["ACCLOC_ABOUT"] = "대하여"
L["ACCLOC_CONFLICT"] = "충돌하는 애드온을 발견 - |cFFFF0000Accountant|r 애드온을 사용중입니다."
L["ACCLOC_CLEANUPACCOUNTANT"] = "데이터 충돌을 해결하기 위하여 |cFF00FF00AccountantClassic_CleanUpAccountantDB()|r 함수를 수동으로 호출하였습니다. 확인 버튼을 누르면 UI를 재시작합니다."
-- L["ACCLOC_SHOWALL"] = ""
-- L["ACCLOC_SHOWALLTIP"] = ""

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT"] = "Accountant"
L["BINDING_NAME_ACCOUNTANTTOG"] = "Toggle Accountant"
--@end-do-not-package@
--@localization(locale="koKR", format="lua_additive_table")@
