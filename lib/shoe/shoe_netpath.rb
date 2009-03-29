module ShoeHelpers
  
  def netpath
    layout do
      flow do
        colorContent('host name or IP adress:', red)
        @host = edit_line(@loader.host, :margin => 15)
      end
      flow do
        colorContent('share name or IP adress:', red)
        @share = edit_line(@loader.share, :margin => 15)
      end
			flow do
        colorContent('Domain:', red)
        @domain = edit_line(@loader.domain, :margin => 15)
      end
      flow do
        button('cancel', :margin => 15) { clear; options }
        button('Done', :margin => 15) {@loader.host = @host.text; @loader.share = @share.text
																				@loader.domain = @domain.text; clear; options}
      end
    end
    @title.replace 'Backup Server'
    @display.replace 'Please write the host path for backup'
  end
  
end