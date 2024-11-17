# require "rbconfig"
# RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ # windows

module Unicode
  class DisplayWidth
    module EmojiSupport
      # Tries to find out which terminal emulator is used to
      # set emoji: config to best suiting value
      #
      # Please note: Many terminals do not set any ENV vars
      def self.recommended
        if ENV["CI"]
          return :rqi_uqe
        end

        case ENV["TERM_PROGRAM"]
        when "Apple_Terminal", "iTerm.app"
          return :all
        when "WezTerm"
          return :all_no_vs16
        end

        case ENV["TERM"]
        when "contour","foot"
          # konsole: all, how to detect?
          return :all
        when /kitty/
          return :basic
        end

        # As of last time checked: gnome-terminal, vscode, alacritty
        :none
      end

      # Maybe: Implement something like https://github.com/jquast/ucs-detect
      #        which uses the terminal cursor to check for best support level
      #        at runtime
      # def self.detect!
      # end
    end
  end
end
