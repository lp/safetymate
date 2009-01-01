module ShoeHelpers
  
  def load
    layout
    @title.replace 'Loading'
    @display.replace 'Please wait while I load your settings'
    @loader = Loader.new
    @loader.destination && ( clear && confirm) || (!alert("You dont have a destination Folder!\nPlease define one in the option page.") && (clear && options)) 
  end
  
end