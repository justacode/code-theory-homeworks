require './node'
require 'json'
require 'pry'
require 'active_support/core_ext/object/try'
require './entropy'

class ShannonFano
  attr_reader :data

  def initialize(filename)
    @filename = filename
    file = File.open("./test/#{@filename}.txt", 'r')
    @data = file.read
    file.close
  end

  def encode
    chars = []
    # frequencies = frequencies(@data)
    frequencies = couples_frequencies(@data)
    frequencies.each { |s| chars << Node.new(s[0], s[1]) }
    @root = to_node(divide(chars))
    @root = build_tree(@root)
    @dictionary = make_dictionary(@root)
    puts @dictionary
    write_dictionary_file(@dictionary)
    # write_compressed_file(@data, @dictionary)
    couples_compressed_file(@data, @dictionary)
  end

  def decode
    dictionary_file = File.read("#{@filename}_dictionary.json")
    @dictionary ||= JSON.parse(dictionary_file)
    s = File.binread("#{@filename}.compressed")
    bits = s.unpack('B*')[0]
    print_info
    write_decompressed_file(bits, @dictionary.invert)
  end

  private

  def divide(chars)
    sum = chars.inject(0) { |sum, s| sum + s.priority }
    half = sum / 2
    left = [chars.shift]
    right = chars

    current_sum = left[0].priority
    element = nil
    while current_sum <= half do
      element = chars.shift
      current_sum += element.priority
      left << element
    end

    prev_sum = current_sum - element.priority
    right.unshift(left.pop) unless (half - current_sum).abs < (half - prev_sum).abs

    if left.size > 2 && right.size > 2
      return [divide(left), divide(right)]
    elsif left.size > 2 && right.size <= 2
      return [divide(left), right]
    elsif left.size <= 2 && right.size > 2
      return [left, divide(right)]
    end
    [left, right]
  end

  def to_node(arr)
    return Node.new(nil, nil, arr[0], arr[1])
  end

  def build_tree(node)
    node.left = to_node(node.left) unless node.try(:left).nil?
    node.right = to_node(node.right) unless node.try(:right).nil?
    build_tree(node.left) if node.left.left.is_a?(Array) || node.left.right.is_a?(Array)
    build_tree(node.right) if node.right.try(:left).is_a?(Array) || node.right.try(:right).is_a?(Array)
    node
  end

  def frequencies(text)
    symbols = Hash.new(0)
    text.each_char { |c| symbols[c] += 1 }
    symbols.sort_by { |_, freq| freq }
  end

  def couples_frequencies(text)
    symbols = Hash.new(0)
    text.scan(/../).each { |c| symbols[c] += 1 }
    result = symbols.sort { |a, b| b[1] <=> a[1] }
    result = result << result.shift
  end

  def make_dictionary(root)
    root.set_binary_values
    dictionary = {}
    root.visit { |node| dictionary[node.symbol] = node.binary_value if node.symbol }
    dictionary
  end

  def couples_compressed_file(data, dictionary)
    bytes = data.scan(/../).inject([]) { |sequence, sym| sequence << dictionary[sym] }
    File.open("#{@filename}.compressed", 'wb') { |output| output.write([bytes.join].pack('B*')) }
  end

  def write_compressed_file(data, dictionary)
    bytes = data.each_char.inject([]) { |sequence, sym| sequence << dictionary[sym] }
    File.open("#{@filename}.compressed", 'wb') { |output| output.write([bytes.join].pack('B*')) }
  end

  def write_dictionary_file(dictionary)
    File.open("#{@filename}_dictionary.json", 'w') { |output| output.write(dictionary.to_json) }
  end

  def print_info
    entropy(@filename)
    compress_rate = File.size("#{@filename}.compressed").to_f * 8 / @data.size
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
end

shannon_fano = ShannonFano.new('josephanton')
shannon_fano.encode
