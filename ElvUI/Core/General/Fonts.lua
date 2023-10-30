local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local _G = _G
local strsub = strsub
local strmatch = strmatch

function E:SetFont(obj, font, size, style, sR, sG, sB, sA, sX, sY, r, g, b, a)
	if not obj then return end

	if style == 'NONE' or not style then style = '' end

	local shadow = strsub(style, 0, 6) == 'SHADOW'
	if shadow then style = strsub(style, 7) end -- shadow isnt a real style

	obj:SetFont(font, size, style)
	obj:SetShadowColor(sR or 0, sG or 0, sB or 0, sA or (shadow and (style == '' and 1 or 0.6)) or 0)
	obj:SetShadowOffset(sX or (shadow and 1) or 0, sY or (shadow and -1) or 0)

	if r and g and b then
		obj:SetTextColor(r, g, b)
	end

	if a then
		obj:SetAlpha(a)
	end
end

local lastFont = {}
function E:UpdateBlizzardFonts()
	local db			= E.private.general
	local NORMAL		= E.media.normFont
	local NUMBER		= E.media.normFont
	local NAMEFONT		= LSM:Fetch('font', db.namefont)

	-- set an invisible font for xp, honor kill, etc
	local COMBAT		= (E.eyefinity or E.ultrawide) and E.Media.Fonts.Invisible or LSM:Fetch('font', db.dmgfont)

	if db.replaceNameFont then _G.UNIT_NAME_FONT = NAMEFONT end
	if db.replaceCombatFont then _G.DAMAGE_TEXT_FONT = COMBAT end
	if db.replaceCombatText then -- Blizzard_CombatText
		E:SetFont(_G.CombatTextFont, COMBAT, 120, 'SHADOW')
	end
	if db.replaceBubbleFont then
		local BUBBLE = LSM:Fetch('font', db.chatBubbleFont)
		E:SetFont(_G.ChatBubbleFont, BUBBLE, db.chatBubbleFontSize, db.chatBubbleFontOutline)	-- 13
	end
	if db.replaceNameplateFont then
		local PLATE = LSM:Fetch('font', db.nameplateFont)
		local LARGE = LSM:Fetch('font', db.nameplateLargeFont)

		E:SetFont(_G.SystemFont_NamePlate,				PLATE, db.nameplateFontSize,		db.nameplateFontOutline)		-- 9
		E:SetFont(_G.SystemFont_NamePlateFixed,			PLATE, db.nameplateFontSize,		db.nameplateFontOutline)		-- 9
		E:SetFont(_G.SystemFont_LargeNamePlate,			LARGE, db.nameplateLargeFontSize,	db.nameplateLargeFontOutline)	-- 12
		E:SetFont(_G.SystemFont_LargeNamePlateFixed,	LARGE, db.nameplateLargeFontSize,	db.nameplateLargeFontOutline)	-- 12
	end

	if db.replaceBlizzFonts then
		local size, style, blizz = E.db.general.fontSize, E.db.general.fontStyle, db.blizzardFontSize
		if lastFont.font == NORMAL and lastFont.size == size and lastFont.style == style and lastFont.blizz == blizz then
			return -- only execute this when needed as it's excessive to reset all of these
		end

		_G.STANDARD_TEXT_FONT = NORMAL

		lastFont.font = NORMAL
		lastFont.size = size
		lastFont.style = style
		lastFont.blizz = blizz

		-->  large fonts (over x2)
		local yourmom   = size * 4.5 -- 54
		local titanic   = size * 4.0 -- 48
		local monstrous = size * 3.5 -- 42
		local colossal  = size * 3.0 -- 36
		local massive   = size * 2.5 -- 30
		local gigantic  = size * 2.0 -- 24

		-->  normal fonts
		local enormous	= size * 1.9 -- 22.8
		local mega		= size * 1.7 -- 20.4
		local huge		= size * 1.5 -- 18
		local large		= size * 1.3 -- 15.6
		local big       = size * 1.2 -- 14.4
		local medium	= size * 1.1 -- 13.2
		----- size      = size * 1.0 -- 12

		-->  small fonts (under x1)
		local small		= size * 0.9 -- 10.8
		local tiny		= size * 0.8 -- 9.6

		-- handle outlines
		local prefix = strmatch(style, '(SHADOW)') or strmatch(style, '(MONOCHROME)') or ''
		local thick, outline = prefix..'THICKOUTLINE', prefix..'OUTLINE'

		-- number fonts
		E:SetFont(_G.SystemFont_Outline_Small,				NUMBER, blizz and 10 or small, 'OUTLINE')
		E:SetFont(_G.Number11Font,							NUMBER, blizz and 11 or small)
		E:SetFont(_G.Number12Font_o1,						NUMBER, blizz and 12 or size, 'OUTLINE')
		E:SetFont(_G.NumberFont_OutlineThick_Mono_Small,	NUMBER, blizz and 12 or size, 'OUTLINE')
		E:SetFont(_G.Number13Font,							NUMBER, blizz and 13 or medium)
		E:SetFont(_G.Number13FontGray,						NUMBER, blizz and 13 or medium, 'SHADOW')
		E:SetFont(_G.Number13FontWhite,						NUMBER, blizz and 13 or medium, 'SHADOW')
		E:SetFont(_G.Number13FontYellow,					NUMBER, blizz and 13 or medium, 'SHADOW')
		E:SetFont(_G.NumberFont_Outline_Med,				NUMBER, blizz and 14 or medium, 'OUTLINE')
		E:SetFont(_G.Number14FontGray,						NUMBER, blizz and 14 or medium, 'SHADOW')
		E:SetFont(_G.Number14FontWhite,						NUMBER, blizz and 14 or medium, 'SHADOW')
		E:SetFont(_G.NumberFont_Outline_Large,				NUMBER, blizz and 16 or big, outline)
		E:SetFont(_G.SystemFont_Shadow_Large_Outline,		NUMBER, blizz and 16 or big, 'SHADOWOUTLINE')
		E:SetFont(_G.Number18Font,							NUMBER, blizz and 18 or large)
		E:SetFont(_G.Number18FontWhite,						NUMBER, blizz and 18 or large, 'SHADOW')
		E:SetFont(_G.NumberFont_Outline_Huge,				NUMBER, blizz and 30 or mega, thick)

		-- quest fonts (shadow variants)
		E:SetFont(_G.QuestFont_Shadow_Small,				NORMAL, blizz and 14 or medium, 'SHADOW', 0.49, 0.35, 0.05, 1)
		E:SetFont(_G.QuestFont_Shadow_Huge,					NORMAL, blizz and 20 or large, 'SHADOW', 0.49, 0.35, 0.05, 1)	-- Quest Title
		E:SetFont(_G.QuestFont_Shadow_Super_Huge,			NORMAL, blizz and 22 or large, 'SHADOW', 0.49, 0.35, 0.05, 1)
		E:SetFont(_G.QuestFont_Shadow_Enormous,				NORMAL, blizz and 25 or mega, 'SHADOW', 0.49, 0.35, 0.05, 1)

		-- game fonts
		E:SetFont(_G.SystemFont_Tiny,						NORMAL, blizz and 9 or tiny)
		E:SetFont(_G.AchievementFont_Small,					NORMAL, blizz and 10 or small)				-- Achiev dates
		E:SetFont(_G.FriendsFont_Small,						NORMAL, blizz and 10 or small, 'SHADOW')
		E:SetFont(_G.Game10Font_o1,							NORMAL, blizz and 10 or small, 'OUTLINE')
		E:SetFont(_G.InvoiceFont_Small,						NORMAL, blizz and 10 or small)				-- Mail
		E:SetFont(_G.ReputationDetailFont,					NORMAL, blizz and 10 or small, 'SHADOW')	-- Rep Desc when clicking a rep
		E:SetFont(_G.SpellFont_Small,						NORMAL, blizz and 10 or small)
		E:SetFont(_G.SubSpellFont,							NORMAL, blizz and 10 or small)				-- Spellbook Sub Names
		E:SetFont(_G.SystemFont_Shadow_Small,				NORMAL, blizz and 10 or small, 'SHADOW')
		E:SetFont(_G.SystemFont_Small,						NORMAL, blizz and 10 or small)
		E:SetFont(_G.Tooltip_Small,							NORMAL, blizz and 10 or small)
		E:SetFont(_G.FriendsFont_11,						NORMAL, blizz and 11 or small, 'SHADOW')
		E:SetFont(_G.FriendsFont_UserText,					NORMAL, blizz and 11 or small, 'SHADOW')
		E:SetFont(_G.GameFontHighlightSmall2,				NORMAL, blizz and 11 or small, 'SHADOW')	-- Skill or Recipe description on TradeSkill frame
		E:SetFont(_G.GameFontNormalSmall2,					NORMAL, blizz and 11 or small, 'SHADOW')	-- MissionUI Followers names
		E:SetFont(_G.Number11Font,							NORMAL, blizz and 11 or small)
		E:SetFont(_G.Fancy12Font,							NORMAL, blizz and 12 or size)				-- Added in 7.3.5 used for ?
		E:SetFont(_G.FriendsFont_Normal,					NORMAL, blizz and 12 or size, 'SHADOW')
		E:SetFont(_G.Game12Font,							NORMAL, blizz and 12 or size)				-- PVP Stuff
		E:SetFont(_G.InvoiceFont_Med,						NORMAL, blizz and 12 or size)				-- Mail
		E:SetFont(_G.Number12Font,							NORMAL, blizz and 12 or size)
		E:SetFont(_G.NumberFont_Shadow_Small,				NORMAL, blizz and 12 or size, 'SHADOW')
		E:SetFont(_G.SystemFont_Med1,						NORMAL, blizz and 12 or size)
		E:SetFont(_G.SystemFont_Shadow_Med1,				NORMAL, blizz and 12 or size, 'SHADOW')
		E:SetFont(_G.Tooltip_Med,							NORMAL, blizz and 12 or size)
		E:SetFont(_G.Game13FontShadow,						NORMAL, blizz and 13 or medium, 'SHADOW')	-- InspectPvpFrame
		E:SetFont(_G.GameFontNormalMed1,					NORMAL, blizz and 13 or medium, 'SHADOW')	-- WoW Token Info
		E:SetFont(_G.NumberFontNormalSmall,					NORMAL, blizz and 13 or medium, 'OUTLINE')	-- Calendar, EncounterJournal
		E:SetFont(_G.QuestFont,								NORMAL, blizz and 13 or medium)
		E:SetFont(_G.SystemFont_Med2,						NORMAL, blizz and 13 or medium)
		E:SetFont(_G.SystemFont_Outline,					NORMAL, blizz and 13 or medium, outline)	-- WorldMap, Pet level
		E:SetFont(_G.DestinyFontMed,						NORMAL, blizz and 14 or medium)				-- Added in 7.3.5 used for ?
		E:SetFont(_G.Fancy14Font,							NORMAL, blizz and 14 or medium)				-- Added in 7.3.5 used for ?
		E:SetFont(_G.FriendsFont_Large,						NORMAL, blizz and 14 or medium, 'SHADOW')
		E:SetFont(_G.GameFontHighlightMedium,				NORMAL, blizz and 14 or medium, 'SHADOW')	-- Fix QuestLog Title mouseover
		E:SetFont(_G.GameFontNormalMed2,					NORMAL, blizz and 14 or medium, 'SHADOW')	-- Quest tracker
		E:SetFont(_G.GameFontNormalMed3,					NORMAL, blizz and 14 or medium, 'SHADOW')
		E:SetFont(_G.GameTooltipHeader,						NORMAL, blizz and 14 or medium)
		E:SetFont(_G.NumberFont_Shadow_Med,					NORMAL, blizz and 14 or medium, 'SHADOW')	-- Chat EditBox
		E:SetFont(_G.PriceFont,								NORMAL, blizz and 14 or medium)
		E:SetFont(_G.SystemFont_Med3,						NORMAL, blizz and 14 or medium)
		E:SetFont(_G.SystemFont_Shadow_Med2,				NORMAL, blizz and 14 or medium, 'SHADOW')	-- Shows Order resourses on OrderHallTalentFrame
		E:SetFont(_G.SystemFont_Shadow_Med3,				NORMAL, blizz and 14 or medium, 'SHADOW')
		E:SetFont(_G.Game15Font_o1,							NORMAL, blizz and 15 or medium)				-- CharacterStatsPane, ItemLevelFrame
		E:SetFont(_G.MailFont_Large,						NORMAL, blizz and 15 or medium)				-- Mail
		E:SetFont(_G.Number15Font,							NORMAL, blizz and 15 or medium)
		E:SetFont(_G.QuestFont_Large,						NORMAL, blizz and 15 or medium)
		E:SetFont(_G.Game16Font,							NORMAL, blizz and 16 or big)				-- Added in 7.3.5 used for ?
		E:SetFont(_G.GameFontNormalLarge,					NORMAL, blizz and 16 or big, 'SHADOW')
		E:SetFont(_G.QuestFont_Larger,						NORMAL, blizz and 16 or big)				-- Wrath
		E:SetFont(_G.SystemFont_Large,						NORMAL, blizz and 16 or big)
		E:SetFont(_G.SystemFont_Shadow_Large,				NORMAL, blizz and 16 or big, 'SHADOW')
		E:SetFont(_G.Game18Font,							NORMAL, blizz and 18 or big)				-- MissionUI Bonus Chance
		E:SetFont(_G.GameFontNormalLarge2,					NORMAL, blizz and 18 or big, 'SHADOW')		-- Garrison Follower Names
		E:SetFont(_G.QuestFont_Huge,						NORMAL, blizz and 18 or big)				-- Quest rewards title, Rewards
		E:SetFont(_G.SystemFont_Shadow_Large2,				NORMAL, blizz and 18 or big, 'SHADOW')		-- Auction House ItemDisplay
		E:SetFont(_G.SystemFont_Huge1, 						NORMAL, blizz and 20 or large)				-- Garrison Mission XP
		E:SetFont(_G.SystemFont_Huge1_Outline,				NORMAL, blizz and 20 or large, outline)		-- Garrison Mission Chance
		E:SetFont(_G.Fancy22Font,							NORMAL, blizz and 22 or large)				-- Talking frame Title font
		E:SetFont(_G.PVPArenaTextString,					NORMAL, blizz and 22 or large, outline)
		E:SetFont(_G.PVPInfoTextString,						NORMAL, blizz and 22 or large, outline)
		E:SetFont(_G.SystemFont_OutlineThick_Huge2,			NORMAL, blizz and 22 or large, thick)
		E:SetFont(_G.Fancy24Font,							NORMAL, blizz and 24 or huge)				-- Artifact frame - weapon name
		E:SetFont(_G.Game24Font,							NORMAL, blizz and 24 or huge)				-- Garrison Mission level, in detail frame
		E:SetFont(_G.GameFontHighlightHuge2,				NORMAL, blizz and 24 or huge, 'SHADOW')
		E:SetFont(_G.GameFontNormalHuge2,					NORMAL, blizz and 24 or huge, 'SHADOW')		-- Mythic weekly best dungeon name
		E:SetFont(_G.QuestFont_Super_Huge,					NORMAL, blizz and 24 or huge)
		E:SetFont(_G.SubZoneTextString,						NORMAL, blizz and 24 or huge, outline)
		E:SetFont(_G.SystemFont_Huge2,						NORMAL, blizz and 24 or huge)				-- Mythic+ Score
		E:SetFont(_G.BossEmoteNormalHuge,					NORMAL, blizz and 25 or mega, 'SHADOW')		-- Talent Title
		E:SetFont(_G.SystemFont_Shadow_Huge3,				NORMAL, blizz and 25 or mega, 'SHADOW')		-- FlightMap
		E:SetFont(_G.ZoneTextString,						NORMAL, blizz and 25 or mega, outline)
		E:SetFont(_G.SubZoneTextFont,						NORMAL, blizz and 26 or mega, outline)		-- WorldMap, SubZone
		E:SetFont(_G.SystemFont_Shadow_Huge4,				NORMAL, blizz and 27 or mega, 'SHADOW')
		E:SetFont(_G.Game30Font,							NORMAL, blizz and 30 or enormous)			-- Mission Level
		E:SetFont(_G.QuestFont_Enormous, 					NORMAL, blizz and 30 or enormous)			-- Garrison Titles
		E:SetFont(_G.CoreAbilityFont,						NORMAL, blizz and 32 or enormous)			-- Core abilities, title
		E:SetFont(_G.DestinyFontHuge,						NORMAL, blizz and 32 or enormous)			-- Garrison Mission Report
		E:SetFont(_G.GameFont_Gigantic,						NORMAL, blizz and 32 or enormous, 'SHADOW')	-- Used at the install steps
		E:SetFont(_G.SystemFont_OutlineThick_WTF,			NORMAL, blizz and 32 or enormous, outline)	--  WorldMap

		-- big fonts
		E:SetFont(_G.QuestFont_39,							NORMAL, blizz and 39 or gigantic)			-- Wrath
		E:SetFont(_G.Game40Font,							NORMAL, blizz and 40 or gigantic)
		E:SetFont(_G.Game42Font,							NORMAL, blizz and 42 or gigantic)			-- PVP Stuff
		E:SetFont(_G.Game46Font,							NORMAL, blizz and 46 or massive)			-- Added in 7.3.5 used for ?
		E:SetFont(_G.Game48Font,							NORMAL, blizz and 48 or massive)
		E:SetFont(_G.Game48FontShadow,						NORMAL, blizz and 48 or massive, 'SHADOW')
		E:SetFont(_G.Game60Font,							NORMAL, blizz and 60 or colossal)
		E:SetFont(_G.Game72Font,							NORMAL, blizz and 72 or monstrous)
		E:SetFont(_G.Game120Font,							NORMAL, blizz and 120 or titanic)

		do -- special stuff for raid warnings because they animate
			E:SetFont(_G.SystemFont_Shadow_Huge1,			NORMAL, blizz and 20 or mega, outline)	-- Raid Warning, Boss emote frame too

			-- fix the blurr on the frames
			local warn = _G.RaidWarningFrame
			local warnTimings = warn and warn.timings
			if warnTimings then
				-- NOTE these also exist: RAID_NOTICE_SCALE_UP_TIME (0.2) and RAID_NOTICE_SCALE_DOWN_TIME (0.4)
				-- however even no addons, during the animation they look blurry.
				warnTimings.RAID_NOTICE_MIN_HEIGHT = blizz and 20 or mega
				warnTimings.RAID_NOTICE_MAX_HEIGHT = blizz and 30 or gigantic
			end

			local boss = _G.RaidBossEmoteFrame
			local bossTimings = boss and boss.timings
			if bossTimings then
				bossTimings.RAID_NOTICE_MIN_HEIGHT = blizz and 20 or mega
				bossTimings.RAID_NOTICE_MAX_HEIGHT = blizz and 30 or gigantic
			end
		end
	end
end
