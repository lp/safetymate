module ShoeHelpers
  
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
          colorContent("//#{@loader.host}/#{@loader.share}", white)
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
  
  private
  
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