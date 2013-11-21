
 
local HtmlTemplate = {}
setmetatable(HtmlTemplate, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

HtmlTemplate_mt = {
	__index = HtmlTemplate;
}



HtmlTemplate.init = function(self, content, subs)
	local obj = {
		Content = content,
		Substitutions = subs,
	}
	setmetatable(obj, HtmlTemplate_mt)

	return obj;
end

HtmlTemplate.create = function(self, content, subs)
	return self:init(content, subs)
end


--[[
	fillTemplate()

	Description: 
		Fill an html template string with values.
		The template is normal html.  Where substitutions are to be made, 
		<html>
		  <head>
		  <title><?title?></title>
		  </head>
		  <body>
		  <?body?>
		  </body>
		</html>

    Wherever there is a combination of <?content?>, whatever is in the content
    field will be replaced by the content that is in the substitution table with 
    the same name.

    example
    local subs = {
      ["authority"]     = request:GetHeader("host"),
      ["hostip"] 		= net:GetLocalAddress(),
      ["httpbase"]      = request:GetHeader("x-bhut-http-url-base"),
      ["websocketbase"] = request:GetHeader("x-bhut-ws-url-base"),
      ["serviceport"]   = serviceport,
    }
--]]
HtmlTemplate.fillTemplate = function(self, subs)
	subs = subs or self.Substitutions;

	-- if there are no substitutions, then just
	-- return the content unchanged.
	if not subs then 
		return self.Content 
	end

	-- do the substitution thing
    return string.gsub(self.Content, "%<%?(%a+)%?%>", subs)
end


return HtmlTemplate
