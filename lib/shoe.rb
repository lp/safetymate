# This Shoes loop is part of the Safety program,
# it uses the Setn library for permanent configuration options,
# and Socks for hooks to the Hashfs File System comparison lib.
# The actual loop is not invoked directly, but through an invocator script,
# Invoked from the source directory to backup
# 
# Author:: l-p
# Copyright:: Spiralix 2008 under same License as Ruby
# 
# :title:Safety v1.0
Shoes.setup do
	gem 'globalog'
  gem 'abundance'
  gem 'sambala'
end
class Shoe < Shoes
	require 'logger'
  require File.join( File.dirname( File.expand_path(__FILE__)), 'loader')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_load')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_options')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_netpath')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_netlogin')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_confirm')
  require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_execution')
	require File.join( File.dirname( File.expand_path(__FILE__)), 'shoe', 'shoe_quit')
  include ShoeHelpers
	require File.join( File.dirname( File.expand_path(__FILE__)), 'hashfs')
  
	$log = Logger.new('safetymate.log', 'weekly'); $log.level = Logger::DEBUG

  url '/', :load
  url '/options', :options
  url '/netoptions', :netpath
  url '/netlogin', :netlogin
  url '/confirm', :confirm
  url '/execution', :execution
	url '/quit', :quit
  
  private
  
  def layout
    background black
		stack(:height => 150) do
    	stack(:margin => 10) do
	      @title = title( '', 
	        :align => "center",
	        :font => "Trebuchet MS",
	        :stroke => pink
	      )
	    end
	    stack(:margin => 20) do
	        @display = para( '',
	          :size => 14, 
	          :align => "center", 
	          :font => "Trebuchet MS", 
	          :stroke => pink
	        )
			end
		end
		stack(:margin => 20) do
      yield if block_given?
			@quit = button('quit', :margin => 10) { clear; quit}
    end
  end
  
  def colorContent(text,color)
    return para( text,
      :size => 12,
      :align => 'left',
      :margin => 15,
      :font => "Trebuchet MS",
      :stroke => color
    )
  end
  
end

Shoes.app :title => 'Backup Folder', :width => 500, :height => 700
