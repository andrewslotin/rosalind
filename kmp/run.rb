s = STDIN.gets.strip

failure_fn = [0]
k = 0

(1...s.size).each do |i|
	k = failure_fn[k - 1] while (k > 0) && (s[k] != s[i])
	k += 1 if s[k] == s[i]
	failure_fn[i] = k
end

puts failure_fn.join(" ")