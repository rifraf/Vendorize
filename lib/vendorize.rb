#
# Copies all required files that can be found to ENV['_Vendor_'] || './_vendor_'
# TODO: absolute or relative paths
# TODO: tests
# TODO: copy folders? Optionally?
# TODO: skip options
#
module Vendorize
  DEFAULT_FOLDER = './_vendor_'

  def self.root_folder
    ENV['_Vendor_'] || DEFAULT_FOLDER
  end

  def self.vendorize(wanted_file)
    vendorize('ubygems') if wanted_file =~ /^rubygems$/i
    $LOAD_PATH.each {|location|
      f = File.join(location, wanted_file)
      ['', '.rb', '.so', '.o', '.dll'].each {|ext|
        file = f + ext
        if File.exist?(file) && !File.directory?(file)
          return "Cached" if location =~ /^#{root_folder}/
          #dest = "#{root_folder}/#{wanted_file}#{ext}".gsub(/\//,'\\')
          #Dir.mkdir File.dirname(dest) unless File.exists? File.dirname(dest)
          dest = ensure_can_create_file("#{root_folder}/#{wanted_file}#{ext}")
          cmd = "copy /y " + "\"#{file}\" \"#{dest}\"".gsub(/\//,'\\')
          system cmd
          return file
        end
      }
    }
    nil
  end

  # Can't require any files => can't use FileUtils.mkdir_p
  def self.ensure_can_create_file(dest)
    ensure_dir_exists File.dirname(dest)
    return dest
  end

  def self.ensure_dir_exists(dir)
    unless File.exists?(dir)
      ensure_dir_exists(File.dirname(dir))
      Dir.mkdir dir
    end
  end
end

unless ENV['NO_VENDORIZE']  # Testing

  alias old_require require
  def require(path)
    puts("======================= require > #{path}")
    loc = Vendorize.vendorize(path)
    loc ? puts("======================= found   > #{loc}")  : puts("no")

    old_require(path)
    rescue LoadError => load_error
      puts "failed"
      raise load_error
  end
  private :old_require
  private :require

  alias old_load load
  def load(filename, wrap = false)
    puts("======================= load > #{filename}")
    old_load(filename, wrap)
    rescue LoadError => load_error
      puts "failed"
     raise load_error
  end
  private :old_load
  private :load
  $LOAD_PATH.unshift Vendorize.root_folder

  def vendor_only?
    false
  end
end