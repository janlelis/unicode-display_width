require_relative '../display_width' unless defined? Unicode::DisplayWidth

class String
  def display_width(ambiguous = 1, overwrite = {})
    Unicode::DisplayWidth.of(self, ambiguous, overwrite)
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
