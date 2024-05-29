TScript is generated from TScriptTemplate (passing final title, description, attributes ...)


TScriptTemplate.GenerateFinalDescription()
	return templateVariables.ReplacePlaceholders(description)


TScript
	description = TScript._ReplacePlaceholders(script.description)

TScript._ReplacePlaceholders:TLocalizedString(text:TLocalizedString, useTime:Long = 0)
	For Local langID:Int = EachIn text.GetLanguageIDs()
		Local value:String = text.Get(langID)
		Local placeHolders:String[] = StringHelper.ExtractPlaceholdersCombined(value, True)
		'-> ["SOMEVARIABLE", "ANTOTHERVAR", ".if:1:~qhello~q:~qworld~q"]

		If Not replaced Then replaced = ReplaceTextWithGameInformation(placeHolder, replacement, useTime)
		If Not replaced Then replaced = ReplaceTextWithScriptExpression(placeHolder, replacement)

		If replaced Then TTemplateVariables.ReplacePlaceholderInText(value, placeHolder, replacement)
	Next
	result.Set(value, langID)


Function ReplaceTextWithScriptExpression:int(text:string, replacement:string var)
	local expressionResult:string = GetScriptExpression().EvalString(text)
	'if no error...
	replacement = expressionResult


'replace "placeholder" with "replacement" in the given text/string
TTemplateVariables.ReplacePlaceholderInText:String(text:String var, placeholder:String, replacement:String)
		text = text.replace("%"+placeholder+"%", replacement)
		text = text.replace("${"+placeholder+"}", replacement)


'replace all placeholders in the given TLocalizedString
(Method!)
TTemplateVariables.ReplacePlaceholders:TLocalizedString(text:TLocalizedString, useTime:Long = 0)
		'for each defined language we check for existent placeholders
		'which then get replaced by a random string stored in the
		'variable with the same name

		'do it 20 times, this allows for placeholder definitions within
		'placeholders (at least some of them)!
		For local langID:int = eachIn languageIDs 'text.GetLanguageIDs()
		...
			local placeholders:string[] = StringHelper.ExtractPlaceholdersCombined(value, True)
			for local placeholder:string = EachIn placeholders
				'check if there is already a placeholder variable stored
				replacement = GetPlaceholderVariableString(placeholder, "", False)
				'check if the variable is defined (this leaves global
				'placeholders like %ACTOR% intact even without further
				'variable definition)
				if not replacement then replacement = GetVariableString(placeholder, "", False)
				'only use ONE option out of the group ("option1|option2|option3")
				if replacement
					replacement = GetRandomFromLocalizedString( replacement )

					'if the parent stores this variable (too) then save
					'the placeholder there instead of the children
					'so other children could use the same placeholders
					'(if there is no parent then "self" is returned)
					local parent:TTemplateVariables = GetParentTemplateVariables()
					if parent and parent.GetVariableString(placeholder, "", False)
						parent.AddPlaceHolderVariable(placeholder, replacement)
					else
						AddPlaceHolderVariable(placeholder, replacement)
					endif
					'store the replacement in the value
					ReplacePlaceholderInText(value, placeholder, replacement.Get(langID))
