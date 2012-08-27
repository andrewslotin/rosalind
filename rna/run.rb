require '../sequence'

dna_seq = Sequences::DNA.new(STDIN.gets.strip)
puts dna_seq.to_rna