class CruncherMailer < ApplicationMailer
	def crunched_statement(sheet, email)
		base_url = "http://cruncher.helloworld.ng/#/"
		@sheet = sheet
		@url = base_url + sheet.token + '/transactions'
      	@deleteUrl = base_url + sheet.token + '/delete'
      	
		mail(to: email, subject: 'Your statement has been crunched.')
	end
end
