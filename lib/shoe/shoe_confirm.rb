module ShoeHelpers
  
  def confirm
    layout do
      colorContent('Source: ', red)
      colorContent("#{@loader.source}", white)
      colorContent('Destination: ', red)
      colorContent("#{@loader.destination}", white) if @loader.type == 'local'
      colorContent("//#{@loader.host}/#{@loader.share}", white) if @loader.type == 'network'
      flow do
        button("backup!", :margin => 10) { clear; execution}
        button("Change options", :margin => 10) { clear; options}
      end
    end
    @title.replace 'Settings'
    @display.replace 'Please check your settings and press BACKUP!'
  end
  
end