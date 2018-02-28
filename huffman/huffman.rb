require './priority_queue'
require './node'
require 'json'
require './entropy'

class Huffman
  def initialize(filename)
    @filename = filename
    file = File.open("./test/#{@filename}.txt", 'r')
    @data = file.read
    file.close
  end

  def encode
    symbols = PriorityQueue.new
    frequencies = get_frequencies(@data)
    frequencies.each_key {|sym| symbols << Node.new(sym, frequencies[sym])}
    root = build_huffman_tree(symbols)
    @dictionary = make_dictionary(root)

    write_dictionary_file(@dictionary)
    write_compressed_file(@data, @dictionary)
  end

  def decode
    dictionary_file = File.read("#{@filename}_dictionary.json")
    @dictionary ||= JSON.parse(dictionary_file)
    s = File.binread("#{@filename}.compressed")
    bits = s.unpack("B*")[0]
    print_info
    write_decompressed_file(bits, @dictionary.invert)
  end

  private

  def write_compressed_file(data, dictionary)
    bytes = data.each_char.inject([]) {|sequence, sym| sequence << dictionary[sym]}
    File.open("#{@filename}.compressed", 'wb') {|output| output.write([bytes.join].pack("B*"))}
  end

  def write_dictionary_file(dictionary)
    File.open("#{@filename}_dictionary.json", 'w') {|f| f.write(dictionary.to_json)}
  end

  def build_huffman_tree(symbols)
    until symbols.size == 2
      left, right = symbols.pop, symbols.pop
      parent = Node.new(nil, left.priority + right.priority, left, right)
      symbols << parent
    end

    symbols.pop
  end

  def print_info
    p @dictionary
    entropy(@filename)
    compress_rate = File.size("#{@filename}.compressed").to_f / @dictionary.keys.size
    puts "Rate: #{compress_rate}"
  end

  def write_decompressed_file(bits, dictionary)
    code = ''
    decomp = File.open("#{@filename}_decomp.txt", 'w+')
    bits.each_char do |bit|
      code += bit
      unless dictionary[code].nil?
        decomp.write(dictionary[code])
        code = ''
      end
    end
  end

  def make_dictionary(root)
    root.set_binary_values
    dictionary = {}
    root.visit {|node| dictionary[node.symbol] = node.binary_value if node.symbol}
    dictionary
  end

  def get_frequencies(text)
    count = Hash.new(0)
    text.each_char {|char| count[char] += 1}
    count
  end
end

myhuffman = Huffman.new('josephanton')
myhuffman.encode