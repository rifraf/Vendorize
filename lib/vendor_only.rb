#
# TODO: absolute or relative paths?
#
$LOAD_PATH.delete_if {true} # Trick to clear a read-only array
$LOAD_PATH.unshift './_vendor_'
def vendor_only?
  true
end

