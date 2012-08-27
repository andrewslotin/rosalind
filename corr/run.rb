require '../sequence'

corrections = Hash.new { |h,k| h[k] = 0 }
STDIN.each_line do |line|
	seq = Sequences::DNA.new(line.strip)

	unless corrections.has_key? seq
		seq = seq.reverse_complement if corrections.has_key? seq.reverse_complement
	end
	corrections[seq] += 1
end

valid = corrections.select { |k, v| v > 1 }.keys
valid_reverse = valid.map { |seq| seq.reverse_complement }

corrections.select { |k, v| v < 2 }.each do |seq, count|
	corrected = valid.select { |s| seq.hamming_distance_from(s) == 1 }.first ||
	            valid_reverse.select { |s| seq.hamming_distance_from(s) == 1 }.first

	puts "#{seq}->#{corrected}" if corrected
end