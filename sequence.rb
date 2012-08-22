module Sequences
	class Base < String
		def hamming_distance_from(s)
			(0...[self.length, s.length].min).map { |i| self[i].ord == s[i].ord ? 0 : 1 }.inject(:+)
		end

		def ==(s)
			comparee = s.is_a?(self.class) ? s : self.class.new(s)
			super(comparee) || super(comparee.reverse_complement)
		end
	end

	class DNA < Base
		def reverse_complement
			self.class.new(self.tr("ACGT", "TGCA").reverse)
		end

		def to_rna
			Sequences::RNA.new(self.gsub("T", "U"))
		end
	end

	class RNA < Base
		def to_dna
			Sequences::DNA.new(self.gsub("U", "T"))
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