class String
	def hamming_distance_from(s)
		(0..[self.length, s.length].max).map do |i|
			self[i] == s[i] ? 0 : 1
		end.inject(:+)
	end
end

puts STDIN.gets.strip.hamming_distance_from(STDIN.gets.strip)