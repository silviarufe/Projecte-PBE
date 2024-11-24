require "gtk3"
require_relative 'puzzle1'

class Finestres
	def create_window(title, label_text, background_color)
		window=Gtk::Window.new(title)	
		window.set_border_width(10)

		vbox = Gtk::VBox.new(:vertical, 5)

		label = Gtk::Label.new 
		label.set_markup("<b>#{label_text}</b>")
		label.override_background_color(:normal, Gdk::RGBA.new(*background_color))
		label.override_color(:normal, Gdk::RGBA.new(1,1,1,1))
		label.set_size_request(300, 50)
		vbox.pack_start(label,expand: true,fill: true , padding: 0);

		button = Gtk::Button.new(:label =>  "Clear")
		button.signal_connect("clicked") do
			window.destroy #cerrar ventana actual
			fin1 #obrir finestra de login
		end
		vbox.pack_start(button, expand: false, fill: false, padding: 10);

		window.add(vbox)

		window.signal_connect("delete-event") { |_widget| Gtk.main_quit }
		window.show_all
		return window #per poderla tancar despres
	end
	
	def fin1
		window1 = create_window("Puzzle 2" , "Please, login with your University card" , [0.4,0.45,1,1])
		lector = Rfid.new
		Thread.new do #crear un nou thread per executar el codi bloquejant
			uid = lector.read_uid
			GLib::Idle.add do #torna al thread grfic per fer actualitzacions de la GUI
				window1.destroy
				fin2(uid)
				false #evitar que la GLib::Idle es repeteixi
			end
		end
	end
	
	def fin2(uid)
		create_window("Puzzle 2" , "uid: #{uid}",[1,0.18,0.35,1])
	end
end

if __FILE__ == $0
  Finestres.new.fin1
  
  Gtk.main
  
end



