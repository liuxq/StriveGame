
SkillBox = {
	skills = {},
	dictSkillDisplay = {},
};

local this = SkillBox;

function SkillBox.Pull( )
	this.Clear();
	local player = KBEngineLua.player();
	if player ~= nil then
		player:cellCall({"requestPull"});
	end
end

function SkillBox.Clear( )
	this.skills = {};
end

function SkillBox.Add( skill )
	for i = 1, #this.skills do
		if this.skills[i].id == skill.id then
			log("SkillBox::add: " .. skill.id  .. " is exist!")
		end
	end
	table.insert(this.skills, skill);
end

function SkillBox.Remove( skillId )
	for i = 1, #this.skills do
		if this.skills[i].id == skillId then
			table.remove(this.skills, i);
			break;
		end
	end
end

function SkillBox.Get( skillId )
	for i = 1, #this.skills do
		if this.skills[i].id == skillId then
			return this.skills[i];
		end
	end
	return nil;
end