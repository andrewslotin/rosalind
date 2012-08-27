alphabet = %w{A C G U}
stat = Hash.new { |h, k| h[k] = 0 }
STDIN.gets.strip.split("").each { |char| stat[char] += 1 }
STDOUT.puts alphabet.map { |ch| stat[ch] }.join(' ')