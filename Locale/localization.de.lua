-- $Id$ 
-- DE Translation, thanks to snj & JokerGermany, IsabelGarcia, pas06
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "deDE", false)

if not L then return end
--@do-not-package@
-- Header
L["ACCLOC_TITLE"] = "Accountant Classic"
L["ACCLOC_DESC"] = "Ein einfaches Hilfsprogramm, um deine Ein- und Ausgaben in WoW zu überwachen."
L["ACCLOC_TIP"] = "Linke Maustaste drücken, um Accountant Classic zu öffnen.\nRechte Maustaste drücken, um die Accountant-Classic-Optionen anzuzeigen.\nLinke Maustaste gedrückt halten und ziehen, um diese Schaltfläche zu verschieben."
L["ACCLOC_TIP2"] = "Rechtsklick, um Accountant Classic zu öffnen.\nLinke Maustaste gedrückt halten und ziehen, um diese Schaltfläche zu verschieben."
L["ACCLOC_TOT_IN"] = "Gesamteinnahmen"
L["ACCLOC_TOT_OUT"] = "Gesamtausgaben"
L["ACCLOC_NET"] = "Nettoertrag / -verlust"
L["ACCLOC_NETLOSS"] = "Nettoverlust"
L["ACCLOC_NETPROF"] = "Nettoertrag"
L["ACCLOC_SOURCE"] = "Quelle"
L["ACCLOC_IN"] = "Einnahmen"
L["ACCLOC_OUT"] = "Ausgaben"
L["ACCLOC_WEEKSTART"] = "Wochenbeginn"
L["ACCLOC_SUM"] = "Gesamtsumme"
L["ACCLOC_CHAR"] = "Charakter"
L["ACCLOC_MONEY"] = "Geld"
L["ACCLOC_UPDATED"] = "Aktualisiert"

-- Section Labels
L["ACCLOC_QUEST"] = "Questbelohnungen"
L["ACCLOC_MERCH"] = "Händler"
L["ACCLOC_TRADE"] = "Handelsfenster"
L["ACCLOC_MAIL"] = "Post"
L["ACCLOC_TRAIN"] = "Ausbildungskosten"
L["ACCLOC_TAXI"] = "Reisekosten"
L["ACCLOC_OTHER"] = "Unbekannt"
L["ACCLOC_REPAIR"] = "Reparaturkosten"
L["ACCLOC_LFG"] = "Dungeon-, SZ-Browser u. Szenario"

-- Buttons
L["ACCLOC_RESET"] = "Zurücksetzen"
L["ACCLOC_OPTBUT"] = "Optionen"
L["ACCLOC_EXIT"] = "Beenden"

-- Tabs
L["ACCLOC_SESS"] = "Diese Sitzung"
L["ACCLOC_DAY"] = "Heute"
L["ACCLOC_PRVDAY"] = "Vorh. Tag"
L["ACCLOC_WEEK"] = "Diese Woche"
L["ACCLOC_PRVWEEK"] = "Vorh. Woche"
L["ACCLOC_MONTH"] = "Dieser Monat"
L["ACCLOC_PRVMON"] = "Vorh. Monat"
L["ACCLOC_TOTAL"] = "Gesamt"
L["ACCLOC_CHARS"] = "Alle Chars"

-- Options
L["ACCLOC_OPTS"] = "Accountant-Classic-Optionen"
L["ACCLOC_MINIBUT"] = "Minikartenbutton zeigen"
L["ACCLOC_MINIBUTMONEY"] = "Gold im Tooltip des Minikartenbuttons anzeigen"
L["ACCLOC_MINIBUTSESSINF"] = "Sitzungsinformationen im Tooltip des Minikartenbuttons anzeigen"
L["ACCLOC_ONSCRMONEY"] = "Geld am Bildschirm zeigen"
L["ACCLOC_RSTPOSITION"] = "Position zurücksetzen"
L["ACCLOC_RSTMNYFRM_TIP"] = "Position des Geldfensters zurücksetzen"
L["ACCLOC_BUTPOS"] = "Minimap-Button Position"
L["ACCLOC_STARTWEEK"] = "Beginn der Woche"
L["ACCLOC_DONE"] = "Fertig"
L["ACCLOC_INTROTIPS"] = "Einführungstipps anzeigen"
L["ACCLOC_INTROTIPS_TIP"] = "Aktiviert/Deaktiviert die Anzeige von Bedienungstipps im Tooltip der Minikartenschaltfläche und des Geldfensters."
L["ACCLOC_REMOVECHAR"] = "Wähle den Charakter, der entfernt werden soll:"
L["ACCLOC_REMOVECHAR_TIP"] = "Die Accountant-Classic-Daten des ausgewählten Charakters werden entfernt."
L["ACCLOC_CHARREMOVETEXT"] = "Der ausgewählte Charakter ist kurz davor, gelöscht zu werden.\nBist du sicher, dass du den folgenden Charakter aus Accountant Classic entfernen willst?"
L["ACCLOC_CHARREMOVEDONE"] = "|cffffffffDie Accountant-Classic-Daten für den Charakter \"%s - %s|cffffffff\" wurden gelöscht."
L["ACCLOC_DATEFORMAT"] = "Wähle das Datumsformat aus:"
L["ACCLOC_DATEFORMAT_TIP"] = "Datumsformat in den Reitern 'Alle Chars' und 'Woche'."
-- L["ACCLOC_LDBINFOTYPE"] = ""

-- Misc
L["ACCLOC_RESET_CONF"] = "Bist du sicher, dass Du die Daten \"%s\" zurücksetzen willst?"
L["ACCLOC_NEWPROFILE"] = "Neues Accountant-Classic-Profil für %s erstellt"
L["ACCLOC_LOADPROFILE"] = "Accountant-Classic-Profil für %s geladen"
L["ACCLOC_LOADED"] = "Accountant Classic gestartet."
L["ACCLOC_GOLD"] = "g "
L["ACCLOC_SILVER"] = "s "
L["ACCLOC_CENT"] = "k"
L["ACCLOC_ABOUT"] = "Über"
L["ACCLOC_CONFLICT"] = "Das konflikterzeugende Addon |cFFFF0000Accountant|r wurde entdeckt und ist gestartet.\nEs wurde deaktiviert. Klicke auf Okay, um das Spiel neu zu laden."
L["ACCLOC_CLEANUPACCOUNTANT"] = "Du hast die Funktion |cFF00FF00AccountantClassic_CleanUpAccountantDB()|r\n manuell aufgerufen, um problematische Daten, die \nin 'Accountant' existierten, zu bereinigen.\nKlicke jetzt auf Okay, um das Spiel neu zu laden."
L["ACCLOC_SHOWALL"] = "Alle Charaktere zeigen"
L["ACCLOC_SHOWALLTIP"] = "Zeigt Einnahmen und Ausgaben aller Charaktere"

-- Amount string for CHAT_MESSAGE_MONEY search
L["GOLD"]			= "(%d+) Gold"
L["SILVER"]			= "(%d+) Silber"
L["COPPER"]			= "(%d+) Kupfer"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANTTOG"] = "Accountant Classic anzeigen/ausblenden"
--@end-do-not-package@
--@localization(locale="deDE", format="lua_additive_table")@
