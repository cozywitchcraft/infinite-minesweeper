return function(text, parent)
	local heading = script.Heading:Clone()
	heading.Text = text
	heading.Parent = parent
	
	return heading
end