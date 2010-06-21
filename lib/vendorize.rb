#
# Copies all required/loaded files that are needed to ENV['_Vendor_'] || './_vendor_'
#
def dputs(*args)
  #puts ["??? "] + args
end

class Vendorize < File
  DEFAULT_FOLDER = './_vendor_'

  bootfile = '_boot_.' + $0
  require bootfile if File.exists?(bootfile)
  
  def self.root_folder
    ENV['_Vendor_'] || DEFAULT_FOLDER
  end

  def self.catname(from, to)
    directory?(to) ? join(to.sub(%r([/\\]$), ''), basename(from)) : to
  end

  def self.copyfile(from, to)
    File.open(from, 'rb') do |r|  # 'File.' needed for IronRuby..!?!
      content = r.read
      File.open(catname(from, to), "wb") {|w| w.write content }
    end
  end

  def self.skip?(wanted_file)
    # Absolute or . relative files can't be cached
    wanted_file =~ /^[.~]|^\w:/
  end

  def self.vendorize(wanted_file, possible_extensions)
    dputs "vendorize #{wanted_file}"
    return nil if skip?(wanted_file)
    vendorize('ubygems', possible_extensions) if wanted_file =~ /^rubygems$/i
    $LOAD_PATH.each {|location|
      f = join(location, wanted_file)
      possible_extensions.each {|ext|
        file = f + ext
        if exist?(file) && !directory?(file)
          if location =~ /^#{root_folder}/
            puts "'#{wanted_file}' loaded from cache at #{file}"
          else
            dest = ensure_can_create_file("#{root_folder}/#{wanted_file}#{ext}")
            unless exist?(dest)
              puts "'#{wanted_file}' cached to #{dest} (from '#{file})"
              copyfile(file, dest)
            else
              #dputs "'#{wanted_file}' already in cache at #{dest})"
              unless directory?(dest)
                dputs "'#{wanted_file}' updated cache #{dest}  (from '#{file}))"
                copyfile(file, dest)
              end
            end
          end
          return
        end
      }
    }
    dputs "no #{wanted_file}"
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
  
  module Kernel
    # hide this file from the call chain (mostly to keep Sinatra happy)
    alias vendorize_old_caller caller
    def caller(num = 0)
      callers = vendorize_old_caller(num)
      callers.reject{|f| f =~ /\Wvendorize\.rb:/}
    end

    alias vendorize_old_require require
    def require(path)
      dputs "req #{path}"
      if vendorize_old_require(path)
        Vendorize.vendorize(path, ['', '.rb', '.so', '.o', '.dll'])
        true
      else
        false
      end
      rescue LoadError => load_error
        puts "require of #{path} failed (not necessarily a problem...)"
        dputs $LOAD_PATH
        raise load_error
    end
    private :vendorize_old_require
    private :require

    alias vendorize_old_load load
    def load(filename, wrap = false)
      dputs "load #{filename}"
      vendorize_old_load(filename, wrap)
      Vendorize.vendorize(filename, [''])
      true
      rescue LoadError => load_error
        puts "load of #{filename} failed (not necessarily a problem...)"
        raise load_error
    end
    private :vendorize_old_load
    private :load

    # Does not appear to be patchable..!?! Even just calling the alias
    # knocks out 'autoload?'
    if false
      module_function :autoload
      alias vendorize_old_kautoload autoload
      def autoload(sym, filename)
        dputs "autoload #{filename}"
        Vendorize.vendorize(filename, ['', '.rb', '.so', '.o', '.dll'])
        vendorize_old_kautoload(sym, filename)
      end
      private :vendorize_old_kautoload
      private :autoload
    end
  end

  class Module
    alias vendorize_old_autoload autoload
    def autoload(sym, filename)
      dputs "autoload #{filename}"
      Vendorize.vendorize(filename, ['', '.rb', '.so', '.o', '.dll'])
      vendorize_old_autoload(sym, filename)
    end
    private :vendorize_old_autoload
    private :autoload
  end
  
  def vendor_only?
    false
  end
end
