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
  gem 'abundance'
  gem 'sambala'
end
class Shoe < Shoes
	require 'logger'
  require 'loader'
  require 'shoe_load'
  require 'shoe_options'
  require 'shoe_netpath'
  require 'shoe_netlogin'
  require 'shoe_confirm'
  require 'shoe_execution'
  include ShoeHelpers
  
	$log = Logger.new('safetymate.log', 'weekly'); $log.level = Logger::DEBUG

  url '/', :load
  url '/options', :options
  url '/netoptions', :netpath
  url '/netlogin', :netlogin
  url '/confirm', :confirm
  url '/execution', :execution
  
  private
  
  def layout
    background black
    stack do
      @title = title( '', 
        :align => "center",
        :font => "Trebuchet MS",
        :stroke => pink
      )
    end
    stack(:margin => 20) do
      stack(:height => 100) do
        @display = para( '',
          :size => 14, 
          :align => "center", 
          :font => "Trebuchet MS", 
          :stroke => pink
        )
      end
      yield if block_given?
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

Shoes.app :title => 'Session Safety', :width => 500, :height => 800
