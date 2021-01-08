--[[ 
Created by CognizanceGaming 			 		http://czgames-ark.000webhostapp.com
												https://www.celestialheavens.com/forum/members/31088
----------------------------------------------------------------------------------------------------
Created with the help of Eksekk 			 	https://www.celestialheavens.com/forum/members/28848
Created with the help of cthscr 			 	https://www.celestialheavens.com/forum/members/30825
Created with the help of Azimovhaas8 	 		https://www.celestialheavens.com/forum/members/31086
--]]


-- [[ Cheat Console -- Shift+u ]] --
-- [[ Info -- F5 ]] --
-- [[ Cheat Info -- F6 ]] --


local spell, currentTime, lastTime, poisonMob, player
local hasCast, fromScript, fromParty = false, false, false
local movePos = {}
movePos[2] = {25,25,200}						-- Fire Bolt
movePos[18] = {75,75,200}						-- Lightning Bolt
local chance = {}
chance[11] = {0,0,0,70}							-- Incinerate HalfArmor chance requirement
chance[26] = {70,65,58,55}						-- Ice Bolt stun chance requirement
chance[32] = {85,80,75,70}						-- Ice Blast paralyze chance requirement
chance[34] = {85,80,75,70}						-- Stun paralyze chance requirement
chance[37] = {75,70,65,45}						-- Blades stun chance requirement
chance[39] = {70,65,58,55}						-- Rock Blast stun chance requirement
chance[24] = {Roll = {95,90,80,70}, Pull = 0.7} -- Poison Spray
chance[29] = {Roll = {92,86,78,65}, Pull = 0.8} -- Acid Burst
chance[90] = {Roll = {90,82,70,55}, Pull = 0.9} -- Toxic Cloud
local newPos = {X = 0, Y = 0, Z = 0}
local poisonedMobs = {}
local timerGo = false
local chainLightningCount = 0
local artifacts = {}
local artSt = 500
while artSt < 552 do
	table.insert(artifacts, artSt)
	artSt = artSt + 1
end
local cheatV = {}
cheatV["HP"] = 10000					-- cheat stats
cheatV["SP"] = 10000					-- cheat stats
cheatV["exp"] = 50000					-- cheat exp
cheatV["gold"] = 25000					-- cheat gold
cheatV["buff"] = {}
cheatV["buff"]["time"] = 9999999999		-- cheat buff
cheatV["buff"]["power"] = 500			-- cheat buff
cheatV["buff"]["skill"] = 60			-- cheat buff
cheatV["skillpoints"] = 20				-- cheat skillpoints
-- HP=100% MP=100%						-- cheat healme
-- Mob.HP=0%							-- cheat killall

local function NextAvailableSkill(t, i)
	for i = (i or -1) + 1, t.high do
		local v = t[i]
		if v > 0 then
			return i, v
		end
	end
end

function EnumAvailableSkills(class)
	return NextAvailableSkill, Game.Classes.Skills[class]
end

local is_int = function(n)
  return (type(n) == "number") and (math.floor(n) == n)
end

function events.LoadMap(WasInMap, Scripts)
	if not WasInMap then Timer(poisonDamage, math.floor((const.Minute/3)*2), true) end
end

function events.AfterLoadMap(t)
	LocalMonstersTxt()
	poisonedMobs = {}
	timerGo = false
end

local function rnd(min, max, count)
	local r = 0
	for i = 1, count do
		r = r + math.random(min, max)
	end
	return r
end

local function eraseSpell()
	local now = Game.Time
	if now - currentTime >= const.Minute/3 then
		spell = nil
		RemoveTimer(eraseSpell)
	end
	return
end

local function setWasAttack()
	if currentTime == nil then return end
	local now = Game.Time
	if(now - currentTime >= (const.Minute/3)) then
		fromParty = false
		RemoveTimer(setWasAttack)
	end
	return
end

function events.WindowMessage(t)
    if t.Msg == 0x201 then    -- WM_LBUTTONDOWN
		player = Party.Players[math.max(Game.CurrentPlayer, 0)]
		fromParty = true 
		Timer(setWasAttack, const.Minute/3, true)
		return
	end
end

function events.KeyDown(t)
	if t.Key == 65 then 
		player = Party.Players[math.max(Game.CurrentPlayer, 0)]
		fromParty = true 
		Timer(setWasAttack, const.Minute/3, true)
		return
	elseif t.Key == 116 then 
		local s = ""
		s = s .. "Shift+U = Cheat Menu \n"
		s = s .. "Cheats Info = F6 \n"
		s = s .. "ID Monster = Critical Hits \n"
		s = s .. "Unarmed = Bonus Damage \n"
		s = s .. "Fire Bolt + Chain Lightning = Chain Spells \n"
		s = s .. "Poison Spray + Acid Burst + Toxic Cloud = Poison DoT \n"
		s = s .. "Ice Bolt + Ice Blast = Stun/Paralyze Debuff \n"
		s = s .. "Stun = Paralyze Debuff \n"
		s = s .. "Blades + Rock Blast = Stun Debuff \n"
		s = s .. "Incinerate = Half Armor Debuff \n"
		MessageBox(s)
	elseif t.Key == 117 then
		local s = ""
		s = s .. "CHEAT MENU -- Shift+U\n"
		s = s .. "Example: What's the key? -> cheat | What cheat? -> setlevel 300 \n\n"
		s = s .. "|| cheat artifact ||\n    -> Grants party a random artifact\n\n"
		s = s .. "|| cheat stats ||\n    -> Player HP/SP = " .. cheatV.HP .. "HP/" .. cheatV.SP .. "SP\n\n"
		s = s .. "|| cheat exp ||\n    -> Add " .. cheatV.exp .. " exp to party\n\n"
		s = s .. "|| cheat gold ||\n    -> Add " .. cheatV.gold .. " gold to party\n\n"
		s = s .. "|| cheat buff # ||\n    -> Add all party spell buffs at Power[" .. cheatV.buff.power .. "]\n\n"
		s = s .. "|| cheat healme ||\n    -> Heals all party and conditions\n\n"
		s = s .. "|| cheat setlevel # ||\n    -> Set all player levels to entered level\n\n"
		s = s .. "|| cheat maxout # ||\n    -> Increase all players learned skills to entered skill level, max of 60, at grandmaster tier\n\n"
		s = s .. "|| cheat skills ||\n    -> Unlocks all available skills at current maximum mastery and minimum required skill\n\n"
		s = s .. "|| cheat killall ||\n    -> Kills all hostile enemies on the map and gives party the related exp\n\n"
		s = s .. "|| cheat skillpoints ||\n    -> Add " .. cheatV.skillpoints .. " skill points to all players\n\n"
		s = s .. "|| cheat god ||\n    -> Gives ALL skills at grandmaster level 60. Gives ALL spells. Gives ALL buffs. Level = 999. HP/SP = 10000HP/10000SP\n\n"
		MessageBox(s)
	elseif Keys.IsPressed(16) and t.Key == 85 then
		if Question("What's the key?"):lower() == "cheat" then 
			local cheat = Question("What cheat?"):lower()
			if cheat == "artifact" then
				evt.GiveItem(0,0,artifacts[math.random(1,51)])
			elseif cheat == "stats" then
				for _,p in Party.Players do p.HP = cheatV.HP p.SP = cheatV.SP end
			elseif cheat == "exp" or cheat == "xp" then
				evt.All.Add("Experience", cheatV.exp)
			elseif cheat == "gold" or cheat == "money" or cheat == "rich" then
				evt.Add("Gold", cheatV.gold)
			elseif cheat == "setlevel" or cheat == "level" or cheat == "levelup" then
				local level = Question("What level?"):lower()
				if is_int(tonumber(level)) then
					for _,p in Party do
						p.LevelBase = math.max(p.LevelBase, level)
					end
				end
			elseif cheat == "buff" or cheat == "protect" then
				for u,s in Party.SpellBuffs do 
					local Buff = s
					Buff.ExpireTime = cheatV.buff.time
					Buff.Power = cheatV.buff.power
					Buff.Skill = cheatV.buff.skill
				end
				for _,pl in Party do
					local buffs = {pl.SpellBuffs[const.PlayerBuff.Bless],pl.SpellBuffs[const.PlayerBuff.Fate],pl.SpellBuffs[const.PlayerBuff.Hammerhands],pl.SpellBuffs[const.PlayerBuff.Heroism],pl.SpellBuffs[const.PlayerBuff.Shield],pl.SpellBuffs[const.PlayerBuff.Stoneskin]}

					for u,s in pairs(buffs) do
						local Buff = s
						Buff.ExpireTime = cheatV.buff.time
						Buff.Power = cheatV.buff.power
						Buff.Skill = cheatV.buff.skill
					end
				end
			elseif cheat == "heal" or cheat == "healme" then
				for _, p in Party do
					for i in p.Conditions do
						p.Conditions[i] = 0
					end
					p.HP = p:GetFullHP()
					p.SP = p:GetFullSP()
				end
			elseif cheat == "maxout" or cheat == "max" then
				local skillLevel = Question("How high?"):lower()
				if is_int(tonumber(skillLevel)) then
					skillLevel = tonumber(skillLevel)
					if skillLevel > 60 then skillLevel = 60 end
					for _, pl in Party do
						for i, val in pl.Skills do
							if val ~= 0 then
								local skill, mastery = SplitSkill(val)
								pl.Skills[i] = JoinSkill(math.max(skill, skillLevel), math.max(mastery, const.GM))
							end
						end
					end
				end
			elseif cheat == "skills" or cheat == "allskills" then
				local LearnLevel = (Game.Version > 6 and {1, 4, 7, 10} or {1, 4, 12})

				for _, pl in Party do
					for i, learn in EnumAvailableSkills(pl.Class) do
						local skill, mastery = SplitSkill(pl.Skills[i])
						skill = math.max(skill, LearnLevel[learn])  -- learn at least the usual needed level
						mastery = math.max(mastery, learn)  -- learn the mastery
						pl.Skills[i] = JoinSkill(skill, mastery)
					end
				end
			elseif cheat == "killall" or cheat == "saveme" then
				for _,M in Map.Monsters do
					if not M.Hostile then goto _1 end
					M.HP = 0								-- Kill if you deal more than remaining hp
					M.HitPoints = 0									
					M.AIState = 4
					mem.call(0x42694B, 1, Game.MonstersTxt[M.Id].Experience)
					::_1::
				end
			elseif cheat == "points" or cheat == "skillpoints" then
				evt.All.Add("SkillPoints", cheatV.skillpoints)
			elseif cheat == "god" or cheat == "godmode" then
				for u,s in Party.SpellBuffs do 
					local Buff = s
					Buff.ExpireTime = cheatV.buff.time
					Buff.Power = cheatV.buff.power
					Buff.Skill = cheatV.buff.skill
				end
				
				for _, pl in Party do
					local buffs = {pl.SpellBuffs[const.PlayerBuff.Bless],pl.SpellBuffs[const.PlayerBuff.Fate],pl.SpellBuffs[const.PlayerBuff.Hammerhands],pl.SpellBuffs[const.PlayerBuff.Heroism],pl.SpellBuffs[const.PlayerBuff.Shield],pl.SpellBuffs[const.PlayerBuff.Stoneskin]}

					for u,s in pairs(buffs) do
						local Buff = s
						Buff.ExpireTime = cheatV.buff.time
						Buff.Power = cheatV.buff.power
						Buff.Skill = cheatV.buff.skill
					end
					
					for i, val in pl.Skills do
						local skill, mastery = SplitSkill(val)
						pl.Skills[i] = JoinSkill(math.max(skill, 60), math.max(mastery, const.GM))
					end
					for i in pl.Conditions do
						pl.Conditions[i] = 0
					end
					pl.LevelBase = math.max(pl.LevelBase, 999)
					pl.HP = cheatV.HP 
					pl.SP = cheatV.SP
					for i in pl.Spells do
						pl.Spells[i] = true
					end
				end
			end
		end
	else
	end
end

local function extraBurst(mob)	
	m = mob.Monster
	evt.CastSpell(15,spell.Mastery,spell.Skill,m.X+100,m.Y+100,m.Z+500,m.X,m.Y,m.Z)
	spell = nil
	return
end

local function aoe(mob)
	local pos = {X = mob.Monster.X, Y = mob.Monster.Y, Z = mob.Monster.Z}
	
	for _,m in Game.Map.Monsters do
		if m.HostileType == 0 then goto aoeSkip end
		if m == mob.Monster then goto aoeSkip end
		if m.AIState == 4 or m.AIState == 5 or AIState == 11 then goto aoeSkip end
		local mBound = math.sqrt((pos.X - m.X)^2 + (pos.Y - m.Y)^2 + (pos.Z - m.Z)^2)
		local damage = math.ceil(mob.Result / 3)
		
		if mBound < 3200 then
			if m.HP > damage then
				m.HP = m.HP - damage 			-- Deal damage
			else
				m.HP = 0									-- Kill if you deal more than remaining hp
				m.HitPoints = 0									
				m.AIState = 4
				mem.call(0x42694B, 1, Game.MonstersTxt[m.Id].Experience)
			end
		end
		::aoeSkip::
	end
	return
end

local function pushBack(p)
	if not p then return end
	local pos = {X = p.Monster.X, Y = p.Monster.Y, Z = p.Monster.Z}
	local from = {X = spell.FromX, Y = spell.FromY, Z = spell.FromZ}
	local newPos = {X = 0, Y = 0, Z = 0}
	local push = {}
	push[76] = 700
	push[70] = 350
	
	if not spell or push[spell.Spell] then return end
	if pos.X > from.X then newPos.X = pos.X + push[spell.Spell] else newPos.X = pos.X - push[spell.Spell] end
	if pos.Y > from.Y then newPos.Y = pos.Y + push[spell.Spell] else newPos.Y = pos.Y - push[spell.Spell] end
	
	if newPos.X ~= nil then
		p.X = newPos.X
		p.Y = newPos.Y
	end
	return
end

local function succMonstersTo(mob)
	local pos = {X = mob.Monster.X, Y = mob.Monster.Y, Z = mob.Monster.Z}
	
	for _,m in Game.Map.Monsters do
		if m.HostileType == 0 then goto succSkip end
		if m == mob.Monster then goto succSkip end
		if m.AIState == 4 or m.AIState == 5 or AIState == 11 then goto succSkip end
		local mBound = math.sqrt((pos.X - m.X)^2 + (pos.Y - m.Y)^2 + (pos.Z - m.Z)^2)
		local newPos = {X = 0, Y = 0, Z = 0}
		
		if mBound < 1200 then
			if mob.Monster.X > m.X then newPos.X = m.X + 100 else newPos.X = m.X - 100 end
			if mob.Monster.Y > m.Y then newPos.Y = m.Y + 100 else newPos.Y = m.Y - 100 end
		
			if newPos.X ~= nil then
				m.X = newPos.X
				m.Y = newPos.Y
			end
		end
		::succSkip::
	end
	return
end

function poisonDamage()
	if next(poisonedMobs) == nil then return end
	for index,k in pairs(poisonedMobs) do
		local m = k.mob
		local now = Game.Time
		local poisonTime = k.curTime
		local s = k.s
		local resist = k.r
		local damage = k.d
		local length = k.l
		if m == nil or not m or m.Monster.HP <= 0 then table.remove(poisonedMobs, index) goto done end
		if(now - poisonTime >= math.ceil(length*const.Minute)) then -- Break timer
			table.remove(poisonedMobs, index)
			Game.ShowStatusText(tostring(Game.MonstersTxt[m.Monster.Id].Name) .. " is no longer poisoned.", 5)
			return false
		else 
			Sleep(0)			
			if m.Monster.HP > damage then
				m.Monster.HP = m.Monster.HP - damage 				-- Deal damage
				Game.ShowStatusText(tostring(Game.MonstersTxt[m.Monster.Id].Name) .. " has taken " .. tostring(damage) .. " points of poison damage.", 5)
			else
				if m.Monster.HP > 0 then
					m.Monster.HP = 0								-- Kill if you deal more than remaining hp
					m.Monster.HitPoints = 0									
					m.Monster.AIState = 4
					Game.ShowStatusText(tostring(Game.MonstersTxt[m.Monster.Id].Name) .. " has died to poison damage.", 5)
					mem.call(0x42694B, 1, Game.MonstersTxt[m.Monster.Id].Experience)
				end
				table.remove(poisonedMobs, index)
			end
		end
	end
	::done::
end

function wasFromMonster(mob)
	local from = {X = mob.X, Y = mob.Y, Z = mob.Z}
	
	for i,m in Game.Map.Monsters do 
		if m.X == from.X and m.Y == from.Y and m.Z == from.Z then
			return true
		end
	end
	return
end

function findNextMonster(mob)
	if mob == nil or mob.Monster == nil or hasCast then hasCast = false if spell.Spell == 18 then chainLightningCount = 0 end return false end
	local closest = mob.Monster
	local pos = {X = mob.Monster.X, Y = mob.Monster.Y, Z = mob.Monster.Z}
	local partyPos = {X = Party.X, Y = Party.Y, Z = Party.Z}
	local closestBounds = 0
	local requiredRoll = {95,90,85,75}
	local canHitTwice = math.random(0,100) > requiredRoll[spell.Mastery]
	
	for _,m in Game.Map.Monsters do
		if m.HostileType == 0 or (canHitTwice and m == mob.Monster) or (m.AIState == 4 or m.AIState == 5 or AIState == 11) then goto skipper end
		if m.X == partyPos.X and m.Y == partyPos.Y and m.Z == partyPos.Z then goto skipper end
		
		local mBound = math.sqrt((pos.X - m.X)^2 + (pos.Y - m.Y)^2 + (pos.Z - m.Z)^2)
		
		if closestBounds < mBound then 
			closestBounds = mBound
			closest = m
		end
		::skipper::
	end
	
	if closest ~= nil then
		if (closestBounds < 4000 and closestBounds > -4000) and closest.HostileType ~= 2 then
			if canHitTwice then
				Game.ShowStatusText("Double " .. tostring(Game.SpellsTxt[spell.Spell].Name) .. " was cast on " .. tostring(Game.MonstersTxt[mob.Monster.Id].Name), 5)
			end
			evt.CastSpell(spell.Spell,spell.Mastery,spell.Skill,pos.X + movePos[spell.Spell][1],pos.Y + movePos[spell.Spell][2],pos.Z + movePos[spell.Spell][3],closest.X,closest.Y,closest.Z)
		end
	end
	if spell.Spell == 2 then hasCast = true end
	if spell.Spell == 18 then
		chainLightningCount = chainLightningCount + 1
		if chainLightningCount < 4 then
			if math.random(1,100) < 80 then hasCast = true end end
		else
			chainLightningCount = 0
			hasCast = true
		end
	return
end

function events.CalcSpellDamage(t)
	if spell and table.find({24, 29, 90}, spell.Spell) then
		poisonTime = Game.Time
	else
		currentTime = Game.Time
	end
	Timer(eraseSpell, const.Minute/3, true)
	spell = t
end

function events.CalcDamageToMonster(t)
	if spell ~= nil then
		if spell.Spell == 34 then												-- Stun
			if math.random(1,100) > ( chance[spell.Spell][spell.Mastery] + (t.Monster.EarthResistance - spell.Skill) ) then
				local Buff = t.Monster.SpellBuffs[const.MonsterBuff.Paralyze]
				Buff.ExpireTime = math.max(Game.Time + ((const.Minute*spell.Skill)/spell.Mastery), Buff.ExpireTime)
			end
		elseif spell.Spell == 2 or spell.Spell == 18 then						-- Fire Bolt / Lightning Bolt
			if fromScript == true then
				if t.Monster.HP < t.Result then 
					mem.call(0x42694B, 1, Game.MonstersTxt[t.Monster.Id].Experience)
					fromScript = false
					findNextMonster(t)
					return
				end
				findNextMonster(t)
			else
				if spell.Spell == 18 then
					if spell.Mastery ~= 4 then return end						-- GM Lightning Bolt -> Chain Lightning
				end
				findNextMonster(t)
			end
			if spell and spell.Spell ~= 18 then spell = nil end
		elseif spell.Spell == 37 or spell.Spell == 39 then						-- Blades / Rock Blast
			if math.random(1,100) > chance[spell.Spell][spell.Mastery] + (t.Monster.EarthResistance - spell.Skill) then
				if wasFromMonster(t.Monster) then return end
				local Buff = t.Monster.SpellBuffs[const.MonsterBuff.Slow]
				Buff.ExpireTime = math.max(Game.Time + const.Minute*spell.Skill, Buff.ExpireTime)
			end
		elseif table.find({24, 29, 90}, spell.Spell) then	-- Poison Spray / Acid Burst / Toxic Cloud
			if t.Player == -1 then return end
			local chances = {82,76,70,65}
			local cutSkill = spell.Skill / 4
			local roll = math.random(1,140)
			local resist = t.Monster.WaterResistance
			local addOn = {0,spell.Skill,spell.Skill + 1,spell.Skill + 2}
			local damage = math.floor(math.random(spell.Mastery, math.ceil(t.Result / 7)) + addOn[tonumber(spell.Mastery)]) - resist
			
			local resists = {2,1.5,1.2,1}
			roll = (roll + 5) - math.floor(resist * resists[tonumber(spell.Mastery)])
			
			roll = math.ceil(roll * chance[spell.Spell].Pull)
			
			if roll > chance[spell.Spell].Roll[spell.Mastery] + resist and damage > 0 then
				local length = 1
				if cutSkill > 1 then
					length = math.random(1,cutSkill) 	
				else
					length = 1
				end	
				if damage > 0 then
					local pData = {mob = t, curTime = Game.Time, s = spell, r = resist, d = damage, l = length}
					table.insert(poisonedMobs, pData)
				end
			else 												
				Game.ShowStatusText(tostring(Game.MonstersTxt[t.Monster.Id].Name) .. " resisted being poisoned.", 5)
			end 
		elseif spell.Spell == 11 then 							-- Incinerate
			if math.random(1,100) > chance[spell.Spell][spell.Mastery] + (t.Monster.FireResistance - spell.Skill) then
				local Buff = t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved]
				Buff.ExpireTime = math.max(Game.Time + const.Minute*spell.Skill, Buff.ExpireTime)
			end
		elseif spell.Spell == 20 then							-- Implosion
			succMonstersTo(t)
		elseif spell.Spell == 76 or spell.Spell == 70 then		-- Flying Fist / Harm
			pushBack(t)
		elseif spell.Spell == 7 then							-- Fire Spike
			aoe(t)
		elseif spell.Spell == 22 then							-- Starburst
			extraBurst(t)
		elseif spell.Spell == 26 or spell.Spell == 32 then		-- Ice Bolt / Ice Blast
			if math.random(1,100) > chance[spell.Spell][spell.Mastery] + (t.Monster.WaterResistance - spell.Skill) then
				local buffs = {[26] = const.MonsterBuff.Slow, [32] = const.MonsterBuff.Paralyze}
				local Buff = t.Monster.SpellBuffs[buffs[spell.Spell]]
				Buff.ExpireTime = math.max(Game.Time + const.Minute*spell.Skill, Buff.ExpireTime)
			end
		end
		if spell and not table.find({24, 29, 90}, spell.Spell) then spell = nil end
	else
		if t.Monster.Hostile ~= true then return end
		if fromParty == false or player == -1 or player == nil then return end
		RemoveTimer(setWasAttack)
		if t.DamageKind == const.Damage.Phys then
			local playerHitEnemy = false
			for key,pl in Party do
				if t.Monster.LastAttacker == pl then playerHitEnemy = true break end
			end
			if not playerHitEnemy then return end
			
			local multiplier, mastery, skill
			local idMultiply = {1.15,1.25,1.35,1.50}
			local uMultiply = {1.06,1.08,1.11,1.18}
			local chances = {75,65,60,55}
			
			mastery = 1
			multiplier = 1
			
			local l,m = SplitSkill(player.Skills[const.Skills.Unarmed])
			if m ~= nil then
				if mastery < m then 
					mastery = m 
					multiplier = uMultiply[m]
				end
			end
			
			if player.ItemMainHand ~= 0 or player.ItemExtraHand ~= 0 or (Game.ItemsTxt[player.ItemMainHand].Id == const.ItemType.Staff and mastery ~= const.GM) then goto noUnarmed end
			
			t.Result = math.ceil(t.Result * multiplier)
			::noUnarmed::
			
			mastery = 1
			multiplier = 1
			skill = 0
			
			for _,p in Party do
				local l,m = SplitSkill(p.Skills[const.Skills.IdentifyMonster])
				if l ~= 0 and m ~= nil then
					if mastery < m then 
						mastery = m 
						multiplier = idMultiply[m]
						skill = l
					end
				end
			end
			if skill == 0 then goto IDMSkip end
			if math.random(1,100) > chances[mastery] then
				t.Result = math.ceil(t.Result * multiplier)
				if t.Result > t.Monster.HP then
					t.Monster.HP = 0									
					t.Monster.HitPoints = 0									
					t.Monster.AIState = 4
					mem.call(0x42694B, 1, Game.MonstersTxt[t.Monster.Id].Experience)
					Game.ShowStatusText("Critical! " .. tostring(player.Name) .. " dealt " .. tostring(t.Result) .. " damage to " .. tostring(Game.MonstersTxt[t.Monster.Id].Name .. ", killing them!"),5)
				else 
					t.Monster.HP = t.Monster.HP - t.Result
					Game.ShowStatusText("Critical! " .. tostring(player.Name) .. " dealt " .. tostring(t.Result) .. " damage to " .. tostring(Game.MonstersTxt[t.Monster.Id].Name),5)
				end
				fromParty = false
				return
			end
			::IDMSkip::
		end
	end
end

function events.CalcDamageToPlayer(t) t.Result = math.ceil(t.Result * 0.9) end
