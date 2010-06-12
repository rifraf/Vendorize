# My test PC doesn't always have ruby on the path...
unless ENV['path'] =~ /ruby/i
  if ENV['COMPUTERNAME'] == 'DELL-QUAD'
    ENV['path'] = 'v:\\Play\\ruby187_mingw\\bin;' + ENV['path']
  end
end

class RubyVersion

  attr_reader :version, :exe

  def initialize
    @version = nil
    @exe = 'ruby.exe'
    begin
      ver = `#{@exe} -v`
      puts ver
      case ver
      when /1\.8\.5.*mswin32/ then @version = :mri185
      when /1\.8\.6.*mingw32/ then @version = :mingw186
      when /1\.8\.7.*mingw32/ then @version = :mingw187
      when /1\.9\.1.*mingw32/ then @version = :mingw191
      end
    rescue
      puts "not #{@exe}"
      @exe = 'jruby.exe'
      @version = :jruby
      begin
        ver = `#{@exe} -v`
        puts ver
      rescue
        puts "not #{@exe}"
        @exe = 'ir.exe'
        @version = :ironruby
        begin
        ver = `#{@exe} -v`
        puts ver
        rescue => e
          puts "** Unknown Ruby version **"
          exit(1)
        end
      end
    end
  end

end

Ruby = RubyVersion.new