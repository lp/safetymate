module ShoeHelpers
  
  def execution
    layout do
      @progress = progress :width => 300
    end
    @title.replace 'Backuping:'
    @sock = Socks.new(self, @loader, {:progress => @progress, :display => @display})
    @display.replace "scanning your backup forder"
    @sock.lace
    @sock.timeFreeze(@loader.extension)
    @sock.walk
    @sock.saveData
    @sock.printDebug('IOOOI')
  end
  
end