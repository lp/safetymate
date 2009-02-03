module ShoeHelpers
	
	def quit
		layout
    @title.replace 'Quitting...'
    @display.replace 'Have a nice day!'
		@quit.remove
		timer(2) { Hashfs.close; exit }
	end
	
end