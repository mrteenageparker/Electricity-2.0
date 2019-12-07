local ssl = require('openssl')

local ts, tn, fmt = tostring, tonumber, string.format
local classType = discordia.class.type

function getIdFromStr(str)
	if not str then return end
	local fs = str:find('<')
	local fe = str:find('>')
	if not fs or not fe then return end
	return str:sub(fs + 2, fe - 1)
end

resolver = {}

function resolver:guild(var)
	local guild
	if not var then
		return nil, 'No ID/name/message provided. Cannot resolve guild.'
	end
	if type(var) == 'table' then
		if classType(var) == 'Guild' then
			guild = var
		elseif classType(g) == 'Channel' or classType(g) == 'Message' then
			guild = var.guild
		end
	else
		guild = client:getGuild(ts(var))
	end
	if guild then
		return guild, guild.id
	else
		return nil, 'Guild could not be resolved.'
	end
end

function resolver:channel(guild, name)
	local guild, text = self:guild(guild)
	if not guild then
		return nil, text
	end
	local c = getIdFromStr(name)
	local voice, chan = false
	if c then
		chan = guild:getChannel(name)
	else
		chan = guild.textChannels:find(function(ch)
			return ch.name == name or ch.id == name
		end)
	end
	if chan then
		return chan
	else
		return nil, 'Channel could not be resolved.'
	end
end

function resolver:role(guild, name)
	local guild, text = self:guild(guild)
	if not guild then
		return nil, text
	end
	local r = getIdFromStr(name)
	local role
	if r then
		role = guild:getRole(name)
	else
		role = guild.roles:find(function(ro)
			return ro.name == name or ro.id == name
		end)
	end
	if role then
		return role
	else
		return nil, 'Role could not be resolved.'
	end
end

idMaker = {}

function idMaker:generate()
	local rands = {
		ssl.base64(ssl.random(6)),
		ssl.base64(ssl.random(4)),
		ssl.base64(ssl.random(8))
	}
	return rands[1] .. '-' .. rands[2] .. '-' .. rands[3]
end

function initGuild(guild)
	if database._cache then
		
	end
end

function sendMessage(obj, content)
	local continue, newContent, msg
	if type(content) == 'string' then
		if #content >= 1999 then
			continue = true
			newContent = content:sub(1983)
			content = content:sub(1, 1982) .. ' [CONTINUED]'
		end
	end
	
	if classType(obj) == 'Message' then
		msg = obj:reply(content)
	elseif classType(obj) == 'PrivateChannel' then
		msg = obj:send(content)
	elseif classType(obj) == 'GuildTextChannel' then
		msg = obj:send(content)
	end
	
	if continue then
		sendMessage(obj, newContent)
	end
	
	return msg
end