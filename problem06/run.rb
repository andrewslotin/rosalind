require '../sequence'

sequences = STDIN.readlines.map(&:strip)

sm = SequenceMatrix.new(sequences)
pm = sm.to_profile_matrix
puts pm.consensus
puts pm