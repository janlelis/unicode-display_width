require_relative '../display_width'

class String
  def display_width(ambiguous = 1)
    unpack('U*').inject(0){ |total_width, char|
      total_width + case Unicode::DisplayWidth.codepoint(char).to_s
      when 'F', 'W'
        2
      when 'N', 'Na', 'H'
        1
      when 'A'
        ambiguous
      else
        1
      end
    }
  end

  def display_size(*args)
    warn "Deprecation warning: Please use `String#display_width` instead of `String#display_size`"
    display_width(*args)
  end

  def display_length(*args)
    warn "Deprecation warning: Please use `String#display_width` instead of `String#display_length`"
    display_width(*args)
  end
end
