require '../sequence'

seq = STDIN.gets.strip
offset = 0

result = []

(0..seq.length - 4).each do |offset|
	(2..6).each do |seq_length|
		regexp = "#{seq[offset]}.{#{seq_length}}#{Sequences::DNA.new(seq[offset]).reverse_complement}"
		seq[offset..offset + 8].scan(Regexp.new(regexp)) do |match|
			if Sequences::DNA.new(match).reverse_palindrome?
				matchdata = Regexp.last_match.offset(0)
				result << [matchdata[0] + offset + 1, matchdata[1] - matchdata[0]]
			end
		end
	end
end

puts result.uniq.sort { |a, b| a[0] <=> b[0] }.map { |match| match.join(" ") }.join("\n")