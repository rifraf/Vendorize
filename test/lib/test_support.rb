# Test helpers
require 'fileutils'

module VendorizeTestSupport

  Vendorize_location = File.expand_path("./lib/vendorize.rb")

  def vendorize_file(name, &blk)
      output = `#{Ruby.exe} -w -r#{Vendorize_location} #{name}`
      begin
        blk.call(output) if block_given?
      ensure
        if File.exists?(Vendorize.root_folder)
          if ENV['keep_folder']
            FileUtils.cp_r(Vendorize.root_folder, ENV['keep_folder'])
          end
          FileUtils.rm_r Vendorize.root_folder
        end
      end
  end

  def vendorize_testfile(name, &blk)
    Dir.chdir("./test/testfiles") { |path|
      vendorize_file(name, &blk)
    }
  end

  def files_in_cache
    Dir["#{Vendorize.root_folder}/**/*"].select {|f| File.file?(f)}
  end

  def files_reported_cached(text)
    text.scan(/'.*?' cached to /)
  end
end
