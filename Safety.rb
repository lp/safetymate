#!/usr/bin/env ruby
require 'lib/loader'

Loader.new(:write)
exec( "'/Applications/Shoes.app/Contents/MacOS/shoes' '/Volumes/KanDriv/git_repos/safetymate/lib/shoe.rb'" )