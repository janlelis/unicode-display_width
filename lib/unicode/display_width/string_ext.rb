# frozen_string_literal: true

require_relative "../display_width"

class String
  def display_width(ambiguous = 1, overwrite = {}, options = { emoji: Unicode::DisplayWidth::DEFAULT_EMOJI_SET })
    Unicode::DisplayWidth.of(self, ambiguous, overwrite, options)
  end
end
