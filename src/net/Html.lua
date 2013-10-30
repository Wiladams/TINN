
local Html = {}
 
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

Html.fillTemplate = function(self, template, subs)
    return string.gsub(template, "%<%?(%a+)%?%>", subs)
end

return Html
