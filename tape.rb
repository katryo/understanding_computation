class Tape < Struct.new(:left, :middle, :right, :blank)
  def inspect
    "#<Tape #{left.join}(#{middle})#{right.join}>"
  end

  def write(character)
    Tape.new(left, character, right, blank)
  end

  def move_head_left
    Tape.new(left[0..-2], left.last || blank, [middle] + right, blank)
  end

  def move_head_right
    Tape.new(left + [middle], right.first || blank, right.drop(1), blank)
  end
end

class TMConfiguration < Struct.new(:state, :tape)

end

class TMRule < Struct.new(:state, :character, :next_state, :write_character, :direction)
  def applies_to?(configuration)
    state == configuration.state && character == configuration.tape.middle
  end

  def follow(configuration)
    TMConfiguration.new(next_state, next_tape(configuration))
  end

  def next_tape(configuration)
    written_tape = configuration.tape.write(write_character)

    case direction
    when :left
      written_tape.move_head_left
    when :right
      written_tape.move_head_right
    end
  end
end

class DTMRulebook < Struct.new(:rules)
  def next_configuration(configuration)
    rule_for(configuration).follow(configuration)
  end

  def rule_for(configuration)
    rules.detect { |rule| rule.applies_to?(configuration) }
  end

  def applies_to?(configuration)
    !rule_for(configuration).nil?
  end
end

class DTM < Struct.new(:current_configuration, :accept_states, :rulebook)
  def accepting?
    accept_states.include?(current_configuration.state)
  end

  def step
    self.current_configuration = rulebook.next_configuration(current_configuration)
  end

  def run
    step until accepting? || stuck?
  end

  def stuck?
    !accepting? && !rulebook.applies_to?(current_configuration)
  end
end

class MyClass
  def self.dtm_rulebook
    DTMRulebook.new([
                        TMRule.new(1, 'X', 1, 'X', :right),
                        TMRule.new(1, 'a', 2, 'X', :right),
                        TMRule.new(1, '_', 6, '_', :left),
                        TMRule.new(2, 'a', 2, 'a', :right),
                        TMRule.new(2, 'X', 2, 'X', :right),
                        TMRule.new(2, 'b', 3, 'X', :right),
                        TMRule.new(3, 'b', 3, 'b', :right),
                        TMRule.new(3, 'X', 3, 'X', :right),
                        TMRule.new(3, 'c', 4, 'X', :right),
                        TMRule.new(4, 'c', 4, 'c', :right),
                        TMRule.new(4, '_', 5, '_', :left),
                        TMRule.new(5, 'a', 5, 'a', :left),
                        TMRule.new(5, 'b', 5, 'b', :left),
                        TMRule.new(5, 'c', 5, 'c', :left),
                        TMRule.new(5, 'X', 5, 'X', :left),
                        TMRule.new(5, '_', 1, '_', :right)
                    ])
  end

  def self.dtm_rulebook_with_storage
    DTMRulebook.new([
      TMRule.new(1, 'a', 2, 'a', :right),
      TMRule.new(1, 'b', 3, 'b', :right),
      TMRule.new(1, 'c', 4, 'c', :right),

      TMRule.new(2, 'a', 2, 'a', :right),
      TMRule.new(2, 'b', 2, 'b', :right),
      TMRule.new(2, 'c', 2, 'c', :right),
      TMRule.new(2, '_', 5, 'a', :right),

      TMRule.new(3, 'a', 3, 'a', :right),
      TMRule.new(3, 'b', 3, 'b', :right),
      TMRule.new(3, 'c', 3, 'c', :right),
      TMRule.new(3, '_', 5, 'b', :right),

      TMRule.new(4, 'a', 4, 'a', :right),
      TMRule.new(4, 'b', 4, 'b', :right),
      TMRule.new(4, 'c', 4, 'c', :left),
      TMRule.new(4, '_', 5, 'c', :left),
                           ])
  end
end

def increment_rules(start_state, return_state)
  incrementing = start_state
  finishing = Object.new
  finished = return_state

  [
      TMRule.new(incrementing, '0', finishing, '1', :right),
      TMRule.new(incrementing, '1', incrementing, '0', :left),
      TMRule.new(incrementing, '_', finishing, '1', :right),
      TMRule.new(finishing, '0', finishing, '0', :right),
      TMRule.new(finishing, '1', finishing, '1', :right),
      TMRule.new(finishing, '_', finished, '_', :left),
  ]
end
















