module ShoeHelpers
	
	def quit
		layout
    @title.replace 'Quitting...'
    @display.replace 'Have a nice day!'
		@quit.remove
		Hashfs.close
		timer(2) { exit }
	end
	
end