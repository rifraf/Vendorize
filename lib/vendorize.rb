#
# Copies all required files that can be found to ./_vendor_ 
# TODO: absolute or relative paths
# TODO: tests
# TODO: copy folders? Optionally?
# TODO: skip options
#
def vendorize(wanted_file)
  vendorize('ubygems') if wanted_file =~ /^rubygems$/i
  $LOAD_PATH.each {|location|
    f = File.join(location, wanted_file)
    ['', '.rb', '.so', '.o', '.dll'].each {|ext|
      file = f + ext
      if File.exist?(file) && !File.directory?(file)
        return "Cached" if location =~ /^.\/_vendor_/
        dest = "./_vendor_/#{wanted_file}#{ext}".gsub(/\//,'\\')
        Dir.mkdir File.dirname(dest) unless File.exists? File.dirname(dest)
        cmd = "copy /y " + "\"#{file}\" \"#{dest}\"".gsub(/\//,'\\')
        system cmd
        return file 
      end
    }
  }
  nil
end

alias old_require require
def require(path)
  puts("======================= require > #{path}") 
  loc = vendorize(path)
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
$LOAD_PATH.unshift './_vendor_'

def vendor_only?
  false
end