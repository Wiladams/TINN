function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

local function split(s, sep)
	local sep = sep or "/"
	local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    
    s:gsub(pattern, function(c) fields[#fields+1] = c end)
	
    return fields
end

local parseparams = function(params)
	if not params then return {} end

	-- first split along ';'
	local fields = split(params, ';')

	-- then split each along '='
	local values = {}
	for _,field in ipairs(fields) do
		local fv = split(field,'=')
		values[fv[1]] = fv[2];
	end
	return values;
end

local countDictionary = function(dict)
	local cnt = 0;
	for k,v in pairs(dict) do
		cnt = cnt + 1
	end
	return cnt
end


local secondsperhour = 60*60;
local secondsperday = secondsperhour * 24;
local secondsperweek = secondsperday * 7;


local TimeFromSeconds = function(seconds)
	local weeks = 0;

	local days = 0;
	local hours = 0;
	local minutes = 0;
  
	-- weeks
	if seconds > secondsperweek then
		weeks = math.floor(seconds / secondsperweek);
	end
	seconds = seconds - weeks * secondsperweek;
	
	-- days
	if seconds > secondsperday then
		days = math.floor(seconds / secondsperday);
	end
	seconds = seconds - days * secondsperday;
	
	-- hours
	if seconds > secondsperhour then
		hours = math.floor(seconds / secondsperhour);
	end
	seconds = seconds - hours * secondsperhour;
  
	-- minutes
	if seconds >= 60 then
		minutes = math.floor(seconds / 60);
	end
	seconds = seconds - minutes*60;

	return {
		weeks = weeks,
		days = days,
		hours = hours,
		minutes = minutes,
		seconds = seconds}
		
end

local SecondsAsTimeString = function(seconds)
	local atime = TimeFromSeconds(seconds)
	
	return string.format("%0d %0d  %02d:%02d:%02.2f", 
		atime.weeks, atime.days, atime.hours, atime.minutes, atime.seconds);
end

return {
    split = split,
    parseparams = parseparams,

    url_encode = url_encode,
    TimeFromSeconds = TimeFromSeconds,
	SecondsAsTimeString = SecondsAsTimeString,

	countDictionary = countDictionary,
}