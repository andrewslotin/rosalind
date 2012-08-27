n = STDIN.gets.to_i
permutations = (1..n).to_a.permutation.to_a
puts permutations.size
puts permutations.map { |p| p.join(" ") }.join("\n")