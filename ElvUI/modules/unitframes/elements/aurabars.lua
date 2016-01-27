local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local tostring = tostring
local format = format
--WoW API / Variables
local CreateFrame = CreateFrame
local IsShiftKeyDown = IsShiftKeyDown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local UnitIsFriend = UnitIsFriend

function UF:Construct_AuraBars()
	local bar = self.statusBar

	self:SetTemplate('Default')

	bar:SetInside(self)
	UF['statusbars'][bar] = true
	UF:Update_StatusBar(bar)

	UF:Configure_FontString(bar.spelltime)
	UF:Configure_FontString(bar.spellname)
	UF:Update_FontString(bar.spelltime)
	UF:Update_FontString(bar.spellname)

	bar.spellname:ClearAllPoints()
	bar.spellname:Point('LEFT', bar, 'LEFT', 2, 0)
	bar.spellname:Point('RIGHT', bar.spelltime, 'LEFT', -4, 0)
	bar.spellname:SetWordWrap(false)

	bar.iconHolder:SetTemplate('Default')
	bar.icon:SetInside(bar.iconHolder)
	bar.icon:SetDrawLayer('OVERLAY')

	bar.bg = bar:CreateTexture(nil, 'BORDER')
	bar.bg:Hide()


	bar.iconHolder:RegisterForClicks('RightButtonUp')
	bar.iconHolder:SetScript('OnClick', function(self)
		if E.db.unitframe.auraBlacklistModifier == "NONE" or not ((E.db.unitframe.auraBlacklistModifier == "SHIFT" and IsShiftKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "ALT" and IsAltKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "CTRL" and IsControlKeyDown())) then return; end
		local auraName = self:GetParent().aura.name

		if auraName then
			E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
			E.global['unitframe']['aurafilters']['Blacklist']['spells'][auraName] = {
				['enable'] = true,
				['priority'] = 0,
			}
			UF:Update_AllFrames()
		end
	end)
end

function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', nil, frame)
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.gap = (-E.Border + E.Spacing*3)
	auraBar.spacing = (-E.Border + E.Spacing*3)
	auraBar.spark = true
	auraBar.filter = UF.AuraBarFilter
	auraBar.PostUpdate = UF.ColorizeAuraBars


	return auraBar
end

local huge = math.huge
function UF.SortAuraBarReverse(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	return compa < compb
end

function UF.SortAuraBarDuration(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa > compb
end

function UF.SortAuraBarDurationReverse(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa < compb
end

function UF.SortAuraBarName(a, b)
	return a.name > b.name
end

function UF:AuraBarFilter(unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID)
	if not self.db then return; end
	local db = self.db.aurabar

	local returnValue = true
	local passPlayerOnlyCheck = true
	local anotherFilterExists = false
	local playerOnlyFilter = false
	local isPlayer = unitCaster == 'player' or unitCaster == 'vehicle'
	local isFriend = UnitIsFriend('player', unit)
	local auraType = isFriend and db.friendlyAuraType or db.enemyAuraType

	if UF:CheckFilter(db.playerOnly, isFriend) then
		if isPlayer then
			returnValue = true;
		else
			returnValue = false;
		end

		passPlayerOnlyCheck = returnValue
		playerOnlyFilter = true
	end

	if UF:CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == 'buffs' and not isStealable) or (self.type == 'debuffs' and debuffType and not E:IsDispellableByMe(debuffType)) or debuffType == nil then
			returnValue = false;
		end
		anotherFilterExists = true
	end

	if UF:CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == true then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.noDuration, isFriend) then
		if (duration == 0 or not duration) then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	if db.maxDuration > 0 then
		if(duration and (duration > db.maxDuration)) then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useBlacklist, isFriend) then
		local blackList = (E.global['unitframe']['aurafilters']['Blacklist'].spells[spellID] or E.global['unitframe']['aurafilters']['Blacklist'].spells[name])
		if blackList and blackList.enable then
			returnValue = false;
		end

		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useWhitelist, isFriend) then
		local whiteList = (E.global['unitframe']['aurafilters']['Whitelist'].spells[spellID] or E.global['unitframe']['aurafilters']['Whitelist'].spells[name])
		if whiteList and whiteList.enable then
			returnValue = true;
		elseif not anotherFilterExists and not playerOnlyFilter then
			returnValue = false
		end

		anotherFilterExists = true
	end

	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells
		local spell = (spellList[spellID] or spellList[name])

		if type == 'Whitelist' then
			if spell and spell.enable and passPlayerOnlyCheck then
				returnValue = true
			elseif not anotherFilterExists then
				returnValue = false
			end
		elseif type == 'Blacklist' and spell and spell.enable then
			returnValue = false
		end
	end

	return returnValue
end

local GOTAK_ID = 86659
local GOTAK = GetSpellInfo(GOTAK_ID)
function UF:ColorizeAuraBars(event, unit)
	local bars = self.bars
	for index = 1, #bars do
		local frame = bars[index]
		if not frame:IsVisible() then break end
		local spellName = frame.statusBar.aura.name
		local spellID = frame.statusBar.aura.spellID
		local colors = E.global.unitframe.AuraBarColors[spellID] or E.global.unitframe.AuraBarColors[tostring(spellID)] or E.global.unitframe.AuraBarColors[spellName]

		if E.db.unitframe.colors.auraBarTurtle and (E.global.unitframe.aurafilters.TurtleBuffs.spells[spellID] or E.global.unitframe.aurafilters.TurtleBuffs.spells[spellName]) and not colors and (spellName ~= GOTAK or (spellName == GOTAK and spellID == GOTAK_ID)) then
			colors = E.db.unitframe.colors.auraBarTurtleColor
		end

		if colors then
			frame.statusBar:SetStatusBarColor(colors.r, colors.g, colors.b)
			frame.statusBar.bg:SetTexture(colors.r * 0.25, colors.g * 0.25, colors.b * 0.25)
		else
			local r, g, b = frame.statusBar:GetStatusBarColor()
			frame.statusBar.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25)
		end

		if UF.db.colors.transparentAurabars and not frame.statusBar.isTransparent then
			UF:ToggleTransparentStatusBar(true, frame.statusBar, frame.statusBar.bg, nil, true)
		elseif(frame.statusBar.isTransparent and not UF.db.colors.transparentAurabars) then
			UF:ToggleTransparentStatusBar(false, frame.statusBar, frame.statusBar.bg, nil, true)
		end

		if(UF.db.colors.transparentAurabars) then
			local _, _, _, alpha = frame:GetBackdropColor()
			if colors then
				frame:SetBackdropColor(colors.r * 0.58, colors.g * 0.58, colors.b * 0.58, alpha)
			else
				local r, g, b = frame.statusBar:GetStatusBarColor()
				frame:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha)
			end
		end
	end
end