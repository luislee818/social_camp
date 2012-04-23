module EventsHelper
	def format_datetime(datetime)
		if datetime.year == Time.now.year
			datetime.strftime("%A, %b %d - %H:%M")
		else
			datetime.strftime("%B %d %Y - %H:%M")
		end
		
	end
end
