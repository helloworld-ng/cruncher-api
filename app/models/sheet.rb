class Sheet < ActiveRecord::Base
	before_create :randomize_id
	has_many :rows
	self.primary_key = 'token'

	private
	def randomize_id
	  begin
	    self.token = SecureRandom.hex(15)
	  end while Sheet.where(token: self.token).exists?
	end
end
