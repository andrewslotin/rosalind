s = STDIN.gets.strip
pattern = Regexp.new(STDIN.gets.strip)

puts [].tap { |offsets|
	offset = 0
	while s[offset..-1][pattern]
		offsets << offsets.last.to_i + Regexp.last_match.offset(0)[0] + 1
		offset = offsets.last
	end
}.join(' ')