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

class Shoe < Shoes
  require 'loader'
  require 'socks'
  
  url '/', :load
  url '/options', :options
  url '/netoptions', :netpath
  url '/netlogin', :netlogin
  url '/confirm', :confirm
  url '/execution', :execution
  
  def load
    layout
    @title.replace 'Loading'
    @display.replace 'Please wait while I load your settings'
    @loader = Loader.new
    @loader.destination && ( clear && confirm) || (!alert("You dont have a destination Folder!\nPlease define one in the option page.") && (clear && options)) 
  end
  
  def options
    layout do
      flow do
        colorContent('Project File Extension: ', red)
        @ext = list_box :items => [".ptf", ".npr", "none"],
          :margin => 15,
          :width => 120,
          :choose => @loader.extension do |list|
            @loader.extension = list.text
          end
      end
      flow do
        colorContent('Backup Type: ', red)
        @type = list_box :items => ["local", "network"],
          :margin => 15,
          :width => 120,
          :choose => @loader.type do |list|
            @loader.type = list.text
            toggleDest
          end
      end
      
      @netDest = stack do
        flow do
          colorContent('Network backup path: ', red)
          colorContent("//#{@loader.server}/#{@loader.share}", white)
        end
        @setNetDir = button('Set Network Path', :margin => 15) { clear; netpath }
        flow do
          colorContent("user: ", red)
          colorContent("#{@loader.user}", white)
        end
        flow do
          colorContent("pass: ", red)
          colorContent("#{@loader.password}", white)
        end
        @setAccess = button('Set User and Password', :margin => 15) { clear; netlogin }
      end
      
      @localDest = stack do
        colorContent("Local backup destination path: ", red)
        @destination = colorContent("#{@loader.destination}", white)
        button('set destination folder', :margin => 15) {@loader.destination = ask_open_folder; @destination.replace "\t#{@loader.destination}" }
      end
      
      toggleDest
      button('OK', :align => 'right', :margin => 15) { @loader.write; clear; confirm}
    end
    @title.replace 'Options'
    @display.replace 'Please set properly:'
  end
  
  def netpath
    layout do
      flow do
        colorContent('server name or IP adress:', red)
        @server = edit_line(@loader.server, :margin => 15)
      end
      flow do
        colorContent('share name or IP adress:', red)
        @share = edit_line(@loader.share, :margin => 15)
      end
      flow do
        button('cancel', :margin => 15) { clear; options }
        button('Done', :margin => 15) {@loader.server = @server.text; @loader.share = @share.text; clear; options}
      end
    end
    @title.replace 'Backup Server'
    @display.replace 'Please write the server path for backup'
  end
  
  def netlogin
    layout do
      flow do
        colorContent('user: ', red)
        @user = edit_line(@loader.user, :margin => 15)
      end
      flow do
        colorContent('password: ', red)
        @pass = edit_line(@loader.password, :margin => 15)
      end
      flow do
        button('cancel', :margin => 15) { clear; options }
        button('Done', :margin => 15) {@loader.user = @user.text; @loader.password = @pass.text; clear; options}
      end
    end
    @title.replace 'Login'
    @display.replace 'Please enter User and password for server login'
  end
  
  def confirm
    layout do
      colorContent('Source: ', red)
      colorContent("#{@loader.source}", white)
      colorContent('Destination: ', red)
      colorContent("#{@loader.destination}", white) if @loader.type == 'local'
      colorContent("//#{@loader.server}/#{@loader.share}", white) if @loader.type == 'network'
      flow do
        button("backup!", :margin => 15) { clear; execution}
        button("Change options", :margin => 15) { clear; options}
      end
    end
    @title.replace 'Settings'
    @display.replace 'Please check your settings and press BACKUP!'
  end
  
  def execution
    layout do
      @progress = progress :width => 300
    end
    @title.replace 'Backuping:'
    @sock = Socks.new(self, {:progress => @progress, :display => @display})
    @display.replace "scanning your backup forder"
    @sock.lace(@loader.source,@loader.destination)
    @sock.timeFreeze(@loader.extension)
    @sock.walk
    @sock.saveData
    @sock.printDebug('IOOOI')
  end
  
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
    stack do
      @display = para( '',
        :size => 14, 
        :align => "center", 
        :font => "Trebuchet MS", 
        :stroke => pink
      )
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
  
  
  def toggleDest
    if @loader.type == 'network'
      @localDest.hide
      @netDest.show 
    else
      @localDest.show
      @netDest.hide
    end
  end
  
  
  
end

Shoes.app :title => 'Session Safety', :width => 500, :height => 600
