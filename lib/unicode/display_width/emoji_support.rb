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
        when "iTerm.app", "WezTerm"
          return :all
        when "Apple_Terminal"
          return :rgi_uqe
        end

        case ENV["TERM"]
        when "contour"
          return :rgi_uqe
        when /kitty/
          return :rgi_fqe
        end

        # As of last time checked: gnome-terminal, vscode, alacritty, konsole
        :basic
      end

      # Maybe: Implement something like https://github.com/jquast/ucs-detect
      #        which uses the terminal cursor to check for best support level
      #        at runtime
      # def self.detect!
      # end
    end
  end
end
