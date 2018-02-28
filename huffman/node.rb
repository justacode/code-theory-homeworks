class Node
  include Comparable

  attr_accessor :symbol, :priority, :binary_value, :left, :right

  def initialize(symbol, priority, left=nil, right=nil)
    @symbol, @priority, @binary_value, @left, @right = symbol, priority, '', left, right
  end

  def <=>(other)
    other.priority <=> @priority
  end

  def set_binary_values(last_value='')
    [@left, @right].each_with_index do |node, bit_value|
      if node
        node.binary_value = last_value + bit_value.to_s
        node.set_binary_values(node.binary_value)
      end
    end
  end

  def visit(&block)
    @left.visit(&block) if left
    @right.visit(&block) if right
    yield self
  end

  def leaf?
    (not @left and not @right)
  end

  def to_s
    "<SYMB: '#{@symbol}', PRIOR: '#{@priority}', LEFT:{#{@left}}, RIGHT:{#{@right}}>"
  end
end