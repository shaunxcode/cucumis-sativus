quote_chars = ["'", '"']
NL = "__NL"
TAB = "__TAB"

read = (str) ->
	parts = []
	curKWLine = false
	in_comment = false
	in_quote = false
	in_long_quote = false
	quote_char = false
	
	for token in str.replace(/\t/gm, " #{TAB} ").replace(/(\r\n|\n|\r)/gm, " #{NL} ").split(' ')
		if (not in_long_quote) and (not in_comment) and token[0..2] is '"""'
			in_long_quote = []
		
		if in_long_quote
			in_long_quote.push token
			
			if token[-3..-1] is '"""'
				token = ['long_quote', in_long_quote.join(' ')]
				in_long_quote = false
			else
				continue
		
		if (not in_quote) and (not in_comment) and token[0] is "#"
			in_comment = [token[1..-1]]
			continue
		
		if in_comment
			in_comment.push token
			
			if token is NL
				token = ['comment ', in_comment.join(' ')]
				in_comment = false
			else
				continue

		if (not in_quote) and token[0] in quote_chars
			in_quote = []
			quote_char = token[0]
		
		if in_quote 
			in_quote.push token
			
			if token[token.length - 1] is quote_char
				token = in_quote.join(' ')
				in_quote = false
			else 
				continue

		if (not in_quote) and token[token.length - 1] is ":"
			parts.push curKWLine = word: token[0..-2].toLowerCase(), content: []
		else
			if not curKWLine then throw new Error "Must start with a keyword e.g. Feature:"
			curKWLine.content.push token
	parts


parse = (src) ->
	parts = []
	for part in read src
		content = part.content.join(' ').replace(new RegExp(NL, 'g'), "\n").replace(new RegExp(TAB, 'g'), "\t")
		item = word: part.word, content: content
		
		if part.word in ["scenario", "background"] 
			steps = content.split("\n")
			item.content = steps.shift()
			item.steps = []
			for step in steps 
				stepParts = step.trim().split(' ')
				if stepParts.length 
					clause = stepParts.shift().trim()
					if clause.length
						item.steps.push clause: clause, content: stepParts.join(' ')
				
		parts.push item

	parts


module.exports = parse

	

