module ShoeHelpers
  
  def load
    layout
    @title.replace 'Loading'
    @display.replace 'Please wait while I load your settings'
    @loader = Loader.new
    if @loader.type == 'local'
      if @loader.destination == '!!! /choose/a/path/ !!!'
        alert("You dont have a destination Folder!\nPlease define one in the option page.")
        clear; options
      else
        clear; confirm
      end
    else
      if @loader.host == 'hostname' || @loader.share == 'sharename' || @loader.password == ''
        alert("Some Server parameters missing!\nPlease define them in the option page.")
        clear; options
      else
        clear; confirm
      end
    end
  end
  
end