# Puzzle 1 -Lector NFC- necessari per poder utilitzar el lector


require 'ruby-nfc'

class Rfid

  def read_uid

	nfc = NFC::Reader.all

  	nfc[0].poll(Mifare::Classic::Tag) do |tag|
		return uid_hex.upcase
  	
	end
  end
end

if __FILE__ == $0
  rf = Rfid.new
  uid = rf.read_uid
  puts uid
end
