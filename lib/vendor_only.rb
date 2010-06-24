#
# Use files from Vendorized cache instead of from the load path
#
bootfile = '_boot_.' + $0
require bootfile if File.exists?(bootfile)

$LOAD_PATH.delete_if {true} # Trick to clear a read-only array
$LOAD_PATH.unshift(ENV['_Vendor_'] || './_vendor_')

# Prevent rubygems from getting loaded
$" << 'rubygems.rb' << 'rubygems'

def vendor_only?
  true
end

