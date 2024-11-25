# ------- NO ES LA VERSIÓ DEFINITIVA --------

require 'gtk3'
require 'json'
require 'net/http'
require 'uri'

# Direccio del servidor
BASE_URL = 'http://192.168.68.110:3000'

# Realitzar solicituds HTTP GET
def fetch_data(path, params = {})
  uri = URI("#{BASE_URL}#{path}")
  uri.query = URI.encode_www_form(params) unless params.empty?
  begin
    response = Net::HTTP.get_response(uri)
    if response.code.to_i == 200
      JSON.pretty_generate(JSON.parse(response.body))
    else
      "Error del servidor: #{response.code} - #{response.body}"
    end
  rescue StandardError => e
    "Error al connectar amb el servidor: #{e.message}"
  end
end

# Aplicacio amb GTK3
class SimpleClientApp
  def initialize
    @window = Gtk::Window.new('Client Atenea')
    @window.set_size_request(600, 400)
    @window.signal_connect('destroy') { Gtk.main_quit }

    vbox = Gtk::Box.new(:vertical, 10)
    vbox.margin = 10

    # Boto per autenticar-se
    auth_button = Gtk::Button.new(label: 'Autentica')
    auth_button.signal_connect('clicked') { authenticate_user }
    vbox.pack_start(auth_button, expand: false, fill: false, padding: 0)

    # Boto per fer consultes
    query_button = Gtk::Button.new(label: 'Consulta Taula')
    query_button.signal_connect('clicked') { query_table }
    vbox.pack_start(query_button, expand: false, fill: false, padding: 0)

    # Boto per tancar la sessio
    logout_button = Gtk::Button.new(label: 'Tanca Sessio')
    logout_button.signal_connect('clicked') { logout }
    vbox.pack_start(logout_button, expand: false, fill: false, padding: 0)

    # Area de text per mostrar els resultats
    @result_view = Gtk::TextView.new
    @result_view.editable = false
    @result_view.cursor_visible = false
    vbox.pack_start(@result_view, expand: true, fill: true, padding: 0)

    @window.add(vbox)
    @window.show_all
  end

  def update_result_view(text)
    @result_view.buffer.text = text
  end

  def authenticate_user
    uid = prompt("Introdueix el teu UID:")
    return unless uid

    result = fetch_data('/authenticate', { uid: uid })
    update_result_view(result)
  end

  def query_table
    table = prompt("Introdueix el nom de la taula (tasks, timetables, marks):")
    return unless table

    result = fetch_data('/query', { table: table })
    update_result_view(result)
  end

  def logout
    result = fetch_data('/logout')
    update_result_view(result)
  end

  def prompt(message)
    dialog = Gtk::Dialog.new(
      title: message,
      parent: @window,
      flags: :destroy_with_parent,
      buttons: [[Gtk::Stock::OK, :ok], [Gtk::Stock::CANCEL, :cancel]]
    )
    entry = Gtk::Entry.new
    dialog.child.add(entry)
    dialog.child.show_all

    response = dialog.run
    input = entry.text.strip
    dialog.destroy
    response == :ok && !input.empty? ? input : nil
  end
end

# Executar l'aplicacio
Gtk.init
SimpleClientApp.new
Gtk.main


