# # #
# Get gemspec info

gemspec_file = Dir['*.gemspec'].first
gemspec = eval File.read(gemspec_file), binding, gemspec_file
info = "#{gemspec.name} | #{gemspec.version} | " \
       "#{gemspec.runtime_dependencies.size} dependencies | " \
       "#{gemspec.files.size} files"


# # #
# Gem build and install task

desc info
task :gem do
  puts info + "\n\n"
  print "  "; sh "gem build #{gemspec_file}"
  FileUtils.mkdir_p 'pkg'
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", 'pkg'
  puts; sh %{gem install --no-document pkg/#{gemspec.name}-#{gemspec.version}.gem}
end


# # #
# Start an IRB session with the gem loaded

desc "#{gemspec.name} | IRB"
task :irb do
  sh "irb -I ./lib -r #{gemspec.name.gsub '-','/'}"
end

# # #
# Run all specs


desc "#{gemspec.name} | Test"
task :test do
  sh "rspec spec"
end
task :default => :test

# # #
# Update index table

namespace :update do
  desc "#{gemspec.name} | Update index"
  task :index do
    require File.dirname(__FILE__) + '/lib/unicode/display_width'

    data = File.open Unicode::DisplayWidth::EAST_ASIAN_WIDTH_DATA_FILENAME
    data.rewind
    Dir.mkdir(Unicode::DisplayWidth::DATA_DIR) unless Dir.exists?(Unicode::DisplayWidth::DATA_DIR)
    east_asian_width_table = {}
    general_category_width_table = {}
    zero_width_category = "Mn"

    data.each_line{ |line|
      line =~ /^(\S+?);(\S+)\s+#\s(\S+).*$/
      if $1 && $2
        cps, width, category = $1, $2, $3
        if cps['..']
          Range.new(*cps.split('..').map{ |cp| cp.to_i(16) }).each{ |cp|
            east_asian_width_table[cp] = width.to_sym
            general_category_width_table[cp] = 0 if category == zero_width_category
          }
        else
          east_asian_width_table[cps.to_i(16)] = width.to_sym
          general_category_width_table[cps.to_i(16)] = 0 if category == zero_width_category
        end
      end
    }
    File.open(Unicode::DisplayWidth::EAST_ASIAN_WIDTH_INDEX_FILENAME, 'wb') { |f| Marshal.dump(east_asian_width_table, f) }
    File.open(Unicode::DisplayWidth::GENERAL_CATEGORY_WIDTH_INDEX_FILENAME, 'wb') { |f| Marshal.dump(general_category_width_table, f) }
  end
end

# # #
# Update data file

namespace :update do
  desc "#{gemspec.name} | Update unicode data"
  task :data do
    require File.dirname(__FILE__) + '/lib/unicode/display_width'
    require 'open-uri'
    open("http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt") { |f|
      File.write(Unicode::DisplayWidth::EAST_ASIAN_WIDTH_DATA_FILENAME, f.read)
    }
  end
end

