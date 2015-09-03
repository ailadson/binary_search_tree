class BinarySearchTree
  attr_reader :data
  attr_accessor :left_child, :right_child, :parent
  
  def self.create_imbalanced_tree
    root = BinarySearchTree.new(1)
    root.insert(2)
    root.insert(3)
    root.insert(4)
    root.insert(5)
    root.insert(6)
    root.insert(7)
    root.insert(8)
    root.insert(9)
    root.insert(10)
    root
  end

  def initialize(data, parent = nil)
    @data = data
    @parent = parent
    @left_child = nil
    @right_child = nil
  end

  def insert(data, parent = nil)
    if (data < @data && @left_child.nil?) || (data > @data && @right_child.nil?)
      add_child(data)
      return
    end

    if data < @data
      @left_child.insert(data)
    elsif data > @data
      @right_child.insert(data)
    end
  end

  def delete(data)
    if @data == data

      if @left_child.nil? && @right_child.nil?
        detach_from_parent
      elsif @left_child.nil?
        left_side = less_than_parent?
        parent = detach_from_parent
        attach_child_to_parent(left_side, @right_child, parent)
        @right_child = nil
      elsif @right_child.nil?
        left_side = less_than_parent?
        parent = detach_from_parent
        attach_child_to_parent(left_side, @left_child, parent)
        @left_child = nil
      else
        child_data = traverse
        self_idx = child_data.index(data)
        next_largest = child_data[self_idx + 1]
        next_largest_child = search(next_largest)
        @data = next_largest
        next_largest_child.delete(next_largest)
      end
      return true
    end

    return false if @left_child.nil? && @right_child.nil?

    if @left_child && @right_child
      @left_child.delete(data) || @right_child.delete(data)
    elsif @right_child.nil?
      @left_child.delete(data)
    else
      @right_child.delete(data)
    end
  end

  def attach_child_to_parent(left_side, child, parent = @parent)
    if left_side
      parent.left_child = child
    else
      parent.right_child = child
    end
    child.parent = parent
  end

  def detach_from_parent
    less_than_parent? ? @parent.left_child = nil : @parent.right_child = nil
    parent = @parent
    @parent = nil
    parent
  end

  def less_than_parent?
    return true if @parent.data > @data
  end

  def add_child(data)
    if data < @data
      @left_child = BinarySearchTree.new(data, self)
    elsif data > @data
      @right_child = BinarySearchTree.new(data, self)
    end
  end

  def traverse(small_to_big = true)
    left = @left_child ? @left_child.traverse : []
    right = @right_child ? @right_child.traverse : []

    if small_to_big
      left.concat([@data]).concat(right)
    else
      right.concat([@data]).concat(left)
    end
  end

  def find_min
    return self if @left_child.nil?
    @left_child.find_min
  end

  def find_max
    return self if @right_child.nil?
    @right_child.find_min
  end

  def display(depth=0)
    puts (("    " * depth) + "|" + "Node: #{data}")
    if @left_child
      puts (("    " * depth) + "|---" + "->LEFT CHILD")
      @left_child.display(depth+1)
    end
    if @right_child
      puts (("    " * depth) + "|---" +  "->RIGHT CHILD")
      @right_child.display(depth+1)
    end
  end

  def search(data)
    return self if @data == data

    if @left_child && data < @data
      return @left_child.search(data)
    elsif @right_child && data > @data.to_i
      return @right_child.search(data)
    end

    nil
  end
  
  def balance(new_tree_data = traverse)
    pivot = new_tree_data.length/2
    @data = new_tree_data[pivot]
    left_data = new_tree_data[0...pivot]
    right_data = new_tree_data[(pivot+1)..-1]
    data_idx = 0
    delete_children
    display
    while data_idx < left_data.length || data_idx < right_data.length
      p "#{left_data[left_data.length - 1 - data_idx]}"
      p "#{right_data[data_idx]}"
      insert(left_data[left_data.length - 1 - data_idx]) if left_data[left_data.length - 1 - data_idx]
      insert(right_data[data_idx]) if right_data[data_idx]
      display
      data_idx += 1
    end
    
    self
  end
  
  def delete_children
    traverse.each{ |d| delete(d) unless d == @data }
    @right_child = nil
    @left_child = nil
  end
end
