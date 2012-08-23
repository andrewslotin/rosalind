module Sequences
	class Base < String
		def initialize(sequence)
			super sequence.upcase.gsub(Regexp.new("[^#{alphabet}]"), "")
		end

		def hamming_distance_from(s)
			(0...[self.length, s.length].min).map { |i| self[i].ord == s[i].ord ? 0 : 1 }.inject(:+)
		end

		protected

		def alphabet ; end
	end

	class NA < Base
		def ==(s)
			comparee = s.is_a?(self.class) ? s : self.class.new(s)
			super(comparee) || super(comparee.reverse_complement)
		end

		def reverse_complement
			self.class.new(self.tr(alphabet, alphabet.reverse).reverse)
		end

		def reverse_palindrome?
			self.to_s == self.reverse_complement.to_s
		end

		def gc_content
			self.tr("ACGT", "0110").split("").map { |n| n.to_i }.inject(:+).to_f / self.length
		end
	end

	class DNA < NA
		def to_rna
			Sequences::RNA.new(self.gsub("T", "U"))
		end

		protected

		def alphabet
			"ACGT"
		end
	end

	class RNA < NA
		CODON_TABLE = {
			"UUU" => "F", "CUU" => "L", "AUU" => "I", "GUU" => "V",
			"UUC" => "F", "CUC" => "L", "AUC" => "I", "GUC" => "V",
			"UUA" => "L", "CUA" => "L", "AUA" => "I", "GUA" => "V",
			"UUG" => "L", "CUG" => "L", "AUG" => "M", "GUG" => "V",
			"UCU" => "S", "CCU" => "P", "ACU" => "T", "GCU" => "A",
			"UCC" => "S", "CCC" => "P", "ACC" => "T", "GCC" => "A",
			"UCA" => "S", "CCA" => "P", "ACA" => "T", "GCA" => "A",
			"UCG" => "S", "CCG" => "P", "ACG" => "T", "GCG" => "A",
			"UAU" => "Y", "CAU" => "H", "AAU" => "N", "GAU" => "D",
			"UAC" => "Y", "CAC" => "H", "AAC" => "N", "GAC" => "D",
			"UAA" => nil, "CAA" => "Q", "AAA" => "K", "GAA" => "E",
			"UAG" => nil, "CAG" => "Q", "AAG" => "K", "GAG" => "E",
			"UGU" => "C", "CGU" => "R", "AGU" => "S", "GGU" => "G",
			"UGC" => "C", "CGC" => "R", "AGC" => "S", "GGC" => "G",
			"UGA" => nil, "CGA" => "R", "AGA" => "R", "GGA" => "G",
			"UGG" => "W", "CGG" => "R", "AGG" => "R", "GGG" => "G"
		}.freeze

		def to_dna
			Sequences::DNA.new(self.gsub("U", "T"))
		end

		def to_protein
			Protein.new(self[/AUG(?:.{3})*(?:UAA|UAG|UGA)/].scan(/.{3}/).map { |codon| CODON_TABLE[codon] if CODON_TABLE[codon] }.join)
		end

		protected

		def alphabet
			"ACGU"
		end
	end

	class Protein < Base
		protected

		def alphabet
			(("A".."Z").to_a - %w{B J O U X Z}).join
		end
	end
end

class ProfileMatrix
	NUCLEOTIDES = %W{A C G T}

	def initialize(a, c, g, t)
		@matrix = [a, c, g, t].transpose
	end

	def [](key)
		k = key.to_s.upcase
		if NUCLEOTIDES.include? k
			@matrix.transpose[NUCLEOTIDES.index k]
		end
	end

	def consensus
		Sequences::DNA.new(@matrix.map { |stats| NUCLEOTIDES[stats.index stats.max] }.join(""))
	end

	def to_s
		NUCLEOTIDES.map do |n|
			"#{n}: #{self[n].join(" ")}"
		end.join("\n")
	end
end

class SequenceMatrix
	def initialize(sequences)
		@matrix = sequences.to_a.map { |seq| seq.split("") }.transpose
	end

	def to_profile_matrix
		stats = []
		@matrix.each do |column|
			stats << Hash[ProfileMatrix::NUCLEOTIDES.map { |n| [n, 0] }].tap do |column_stats|
				column.each do |nucleotide|
					column_stats[nucleotide] += 1
				end
			end.values_at(*ProfileMatrix::NUCLEOTIDES)
		end
		ProfileMatrix.new(*stats.transpose)
	end

	def consensus
		to_profile_matrix.consensus
	end

	def to_s
		@matrix.transpose.map { |seq_array| seq_array.join(" ") }.join("\n")
	end
end

class FASTAReader
	def self.read(io, &block)
		name = nil
		sequence = ""
		sequences = {}

		block = lambda { |name, seq| sequences[name] = seq } unless block_given?

		io.each_line do |line|
			line.strip!

			if line[/^>/]
				block.call name, Sequences::DNA.new(sequence) if name && sequence.length > 0
				name = line.sub(/^>/, "")
				sequence = ""
			else
				sequence += line
			end
		end

		block.call name, Sequences::DNA.new(sequence) if name && sequence.length > 0

		sequences unless block_given?
	end
end	