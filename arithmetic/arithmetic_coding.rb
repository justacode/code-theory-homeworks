require_relative 'probability'

class ArithmeticCodingAlgorithm
  attr_accessor :filename, :similars

  def initialize(filename)
    @filename = filename
    @similars = '0.'
    @data = File.open("./test/#{filename}.txt", 'r').read
  end

  def encode
    span = [0, 1]

    @data.each_char do |c|
      interval = order_intervals(span)[c]
      span = [interval[:right], interval[:left]]
    end

    print_info(determine_span(span))
  end

  private

  def print_info(span)
    code = code_formition(span)
    puts "Range is #{span.inspect}"
    puts "Symbols amount is #{@data.size}"
    puts "Code length is #{code.length}"

    write_answer(code)
  end

  def code_formition(span)
    code = (rand * (span.last - span.first) + span.first).to_s
    similars << code[2..code.length]
  end

  def write_answer(code)
    out = File.new('arithmetic_coding_algorithm.bin', 'w')
    out.write(binary_code(code))
    puts "Rate: #{(out.size * 8 / @data.size.to_f)}"
  end

  def order_intervals(span)
    right, left = determine_span(span)
    length = left - right
    intervals = {}

    probabilities.each do |key, value|
      left = right + length * value
      intervals[key] = { right: right, left: left }
      right = left
    end

    intervals
  end

  def determine_span(span)
    right, left = span

    return span unless (left * 10).to_i == (right * 10).to_i
    determine_span(recalculate_span(left, right))
  end

  def recalculate_span(left, right)
    similar = (left * 10).to_i
    similars << similar.to_s

    [right * 10 - similar, left * 10 - similar]
  end

  def probabilities
    @probabilities ||= probability.symbols_probabilities
  end

  def probability
    @probability ||= Probability.new(filename)
  end

  def binary_code(code)
    [code[2..-1].to_i.to_s(2)].pack('B*')
  end
end

ArithmeticCodingAlgorithm.new('josephanton').encode
