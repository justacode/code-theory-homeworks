def entropy(filename)
  my_file = File.open("./test/#{filename}.txt", 'r')
  data = my_file.read
  my_file.close
  puts "Filename: #{filename}"
  puts "Total symbols: #{data.size}"

# ENTROPY FOR ONE SYMBOL
  letters = {}
  h_u1 = 0
  probabs = {}

  data.split('').each {|l| letters[l] = letters[l].to_i + 1}

  letters.keys.each do |l|
    p_ui = letters[l].to_f / data.size
    probabs[l] = p_ui
    h_u1 += p_ui * Math.log2(p_ui)
  end

  puts "H(U): #{h_u1.abs.round(4)}"

# ENTROPY FOR TWO SYMBOLS
  h_u1_u2 = 0
  pairs = {}
  pairs_probabs = {}
  pairs_count = data.size - 1

  data.each_char.each_cons(2) do |pair|
    pairs[pair.join] = pairs[pair.join].to_i + 1
  end

  pairs.keys.each do |pair|
    p_ab = pairs[pair].to_f / pairs_count
    p_b = probabs[pair[1]]
    p_a_if_b = p_ab / p_b
    p_a_b = p_b * p_a_if_b

    pairs_probabs[pair] = p_a_b

    h_u1_u2 += p_a_b * Math.log2(p_a_if_b)
  end

  puts "H(U1,U2): #{h_u1_u2.abs.round(4)}"

# ENTROPY FOR THREE SYMBOLS
  h_u1_u2_u3 = 0
  triplets = {}
  triplets_count = data.size - 2

  data.each_char.each_cons(3) do |triplet|
    triplets[triplet.join] = triplets[triplet.join].to_i + 1
  end

  triplets.keys.each do |triplet|
    p_abc = triplets[triplet].to_f / triplets_count
    p_bc = pairs_probabs["#{triplet[1]}#{triplet[2]}"]
    p_a_if_bc = p_abc / p_bc
    h_u1_u2_u3 += p_abc * Math.log2(p_a_if_bc)
  end

  puts "H(U1,U2, U3): #{h_u1_u2_u3.abs.round(4)}"
end