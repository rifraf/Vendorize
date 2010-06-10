#
# Copies all required files that can be found to ENV['_Vendor_'] || './_vendor_'
# TODO: absolute or relative paths
# TODO: copy folders? Optionally?
# TODO: skip options
#
class Vendorize < File
  DEFAULT_FOLDER = './_vendor_'

  def self.root_folder
    ENV['_Vendor_'] || DEFAULT_FOLDER
  end

  def self.catname(from, to)
    directory?(to) ? join(to.sub(%r([/\\]$), ''), basename(from)) : to
  end

  def self.copyfile(from, to)
    open(from, 'rb') do |r|
      content = r.read
      open(catname(from, to), "wb") {|w| w.write content }
    end
  end

  def self.vendorize(wanted_file)
    vendorize('ubygems') if wanted_file =~ /^rubygems$/i
    $LOAD_PATH.each {|location|
      f = join(location, wanted_file)
      ['', '.rb', '.so', '.o', '.dll'].each {|ext|
        file = f + ext
        if exist?(file) && !directory?(file)
          if location =~ /^#{root_folder}/
            puts "'#{wanted_file}' loaded from cache at #{file}"
          else
            dest = ensure_can_create_file("#{root_folder}/#{wanted_file}#{ext}")
#cmd = "copy /y " + "\"#{file}\" \"#{dest}\" 2>&1".gsub(/\//,'\\')
#`#{cmd}`
            copyfile(file, dest)
            puts "'#{wanted_file}' cached to #{dest} (from '#{file})"
          end
          return
        end
      }
    }
    nil
  end

  # Can't require any files => can't use FileUtils.mkdir_p
  def self.ensure_can_create_file(dest)
    ensure_dir_exists dirname(dest)
    return dest
  end

  def self.ensure_dir_exists(dir)
    unless exists?(dir)
      ensure_dir_exists(dirname(dir))
      Dir.mkdir dir
    end
  end
end

unless ENV['NO_VENDORIZE']  # Cannot do overrides within the tests...

  alias old_require require
  def require(path)
    Vendorize.vendorize(path)
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