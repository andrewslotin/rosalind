require '../sequence'

FASTAReader.read(STDIN).map { |name, seq| [name, seq.gc_content * 100] }.max { |a, b| a[1] <=> b[1] }.tap do |name, gc_content|
	puts "#{name}\n%0.2f%%" % gc_content
end