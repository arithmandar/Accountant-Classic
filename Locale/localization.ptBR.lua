-- $Id$ 
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "ptBR", false)

if not L then return end
--@do-not-package@
-- Header
L["ACCLOC_TITLE"] = "Accountant Classic"
L["ACCLOC_DESC"] = "Uma ferramenta básica para monitorar entradas e saídas no WoW."
L["ACCLOC_TIP"] = "Clique esquerdo abre o Accountant Classic.\nClique direito abre as opções do Accountant Classic.\nClique esquerdo + Arrastar move o botão."
L["ACCLOC_TIP2"] = "Cloque com o botão esquerdo e segure para mover este botão.\nClique com o botão direito para abrir o Accountant Classic."
L["ACCLOC_TOT_IN"] = "Total de Entradas"
L["ACCLOC_TOT_OUT"] = "Total de Saídas"
L["ACCLOC_NET"] = "Lucro / Prejuízo Líquido"
L["ACCLOC_NETLOSS"] = "Prejuízo Líquido"
L["ACCLOC_NETPROF"] = "Lucro Líquido"
L["ACCLOC_SOURCE"] = "Fonte"
L["ACCLOC_IN"] = "Entradas"
L["ACCLOC_OUT"] = "Saídas"
L["ACCLOC_WEEKSTART"] = "Começo da Semana"
L["ACCLOC_SUM"] = "Soma Total"
L["ACCLOC_CHAR"] = "Personagem"
L["ACCLOC_MONEY"] = "Dinheiro"
L["ACCLOC_UPDATED"] = "Atualizado"

-- Section Labels
L["ACCLOC_QUEST"] = "Ganho de Missões"
L["ACCLOC_MERCH"] = "Comerciantes"
L["ACCLOC_TRADE"] = "Janela de Negociação"
L["ACCLOC_MAIL"] = "Correio"
L["ACCLOC_TRAIN"] = "Custos de Treinamento"
L["ACCLOC_TAXI"] = "Tarifas de Voo"
L["ACCLOC_OTHER"] = "Desconhecido"
L["ACCLOC_REPAIR"] = "Custo de Reparo"
L["ACCLOC_LFG"] = "Fila de Masmorras, Raids, Cenários"

-- Buttons
L["ACCLOC_RESET"] = "Reset"
L["ACCLOC_OPTBUT"] = "Opções"
L["ACCLOC_EXIT"] = "Sair"

-- Tabs
L["ACCLOC_SESS"] = "Esta Sessão"
L["ACCLOC_DAY"] = "Hoje"
-- L["ACCLOC_PRVDAY"] = ""
L["ACCLOC_WEEK"] = "Esta Semana"
L["ACCLOC_PRVWEEK"] = "Semana Passada"
L["ACCLOC_MONTH"] = "Este Mês"
L["ACCLOC_PRVMON"] = "Mês Passado (or \"Mês Ant.\" if you need a smaller version)"
L["ACCLOC_TOTAL"] = "Total"
L["ACCLOC_CHARS"] = "Todos Personagens"

-- Options
L["ACCLOC_OPTS"] = "Opções do Accountant Classic"
L["ACCLOC_MINIBUT"] = "Mostrar botão no Minimapa"
L["ACCLOC_MINIBUTMONEY"] = "Mostrar dinheiro no tooltip do botão, no minimapa."
L["ACCLOC_MINIBUTSESSINF"] = "Mostrar informações da sessão no tooltip do botão, no minimapa."
L["ACCLOC_ONSCRMONEY"] = "Mostrar dinheiro na tela"
L["ACCLOC_RSTPOSITION"] = "Resetar posição"
L["ACCLOC_RSTMNYFRM_TIP"] = "Resetar a posição do quadro de dinheiro na tela."
L["ACCLOC_BUTPOS"] = "Posição do Botão do Minimapa"
L["ACCLOC_STARTWEEK"] = "Começo da Semana"
L["ACCLOC_DONE"] = "Feito"
L["ACCLOC_INTROTIPS"] = "Mostrar Dicas Informativas"
-- L["ACCLOC_INTROTIPS_TIP"] = ""
L["ACCLOC_REMOVECHAR"] = "Selecione o personagem a ser removido:"
L["ACCLOC_REMOVECHAR_TIP"] = "Os personagens selecionados terão seus dados deletados do Accountant Classic."
L["ACCLOC_CHARREMOVETEXT"] = "O personagem selecionado será removido.\nTem certeza que deseja remover o personagem selecionado do Accountant Classic?"
L["ACCLOC_CHARREMOVEDONE"] = "|cffffffff\"%s - %s|cffffffff\" Dados do personagem foram removidos do Accountant Classic."
L["ACCLOC_DATEFORMAT"] = "Selecione o formato da data:"
-- L["ACCLOC_DATEFORMAT_TIP"] = ""
-- L["ACCLOC_LDBINFOTYPE"] = ""

-- Misc
L["ACCLOC_RESET_CONF"] = "Você tem certeza que deseja resetar os dados de \"%s\"?"
L["ACCLOC_NEWPROFILE"] = "Novo perfil de %s criado no Accountant Classic"
L["ACCLOC_LOADPROFILE"] = "Perfil de %s carregado pelo Accountant Classic"
L["ACCLOC_LOADED"] = "Accountant Classic carregado."
-- L["ACCLOC_GOLD"] = ""
-- L["ACCLOC_SILVER"] = ""
-- L["ACCLOC_CENT"] = ""
L["ACCLOC_ABOUT"] = "Sobre"
-- L["ACCLOC_CONFLICT"] = ""
-- L["ACCLOC_CLEANUPACCOUNTANT"] = ""
-- L["ACCLOC_SHOWALL"] = ""
-- L["ACCLOC_SHOWALLTIP"] = ""

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANTTOG"] = "Alternar Accountant Classic"
--@end-do-not-package@
--@localization(locale="ptBR", format="lua_additive_table")@
