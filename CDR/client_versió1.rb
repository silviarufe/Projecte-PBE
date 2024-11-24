# ----- VERSIÓ PRÈVIA, NO LA DEFINITIVA ----------

require 'gtk3'
require 'json'
require 'net/http'
require 'uri'

BASE_URL = 'http://192.168.68.110:3000'

# Realitzar solicituds HTTP GET en un fil auxiliar
def fetch_data(path, params = {})
  Thread.new do
    begin
      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params) unless params.empty?

      response = Net::HTTP.get_response(uri)
      if response.code.to_i == 200
        JSON.parse(response.body, symbolize_names: true)
      else
        { error: "Error del servidor: #{response.code} - #{response.body}" }
      end
    rescue StandardError => e
      { error: "Error al connectar amb el servidor: #{e.message}" }
    end
  end
end

# Aplicacio Client
class ClientApp
  def initialize
    @window = Gtk::Window.new('Client Atenea')
    @window.set_size_request(600, 400)
    @window.signal_connect('destroy') { Gtk.main_quit }

    vbox = Gtk::Box.new(:vertical, 10)
    vbox.margin = 10

    # Camp d'entrada del UID
    @uid_entry = Gtk::Entry.new
    @uid_entry.placeholder_text = 'Introdueix el teu UID'
    vbox.pack_start(@uid_entry, expand: false, fill: false, padding: 0)

    # Boto per autenticar-se
    auth_button = Gtk::Button.new(label: 'Autentica')
    auth_button.signal_connect('clicked') { authenticate_user }
    vbox.pack_start(auth_button, expand: false, fill: false, padding: 0)

    # Selector de taules
    @table_combo = Gtk::ComboBoxText.new
    @table_combo.append_text('tasks')
    @table_combo.append_text('timetables')
    @table_combo.append_text('marks')
    vbox.pack_start(@table_combo, expand: false, fill: false, padding: 0)

    # Boto per fer consultes
    query_button = Gtk::Button.new(label: 'Consulta')
    query_button.signal_connect('clicked') { query_table }
    vbox.pack_start(query_button, expand: false, fill: false, padding: 0)

    # Boto per tancar la sessio
    logout_button = Gtk::Button.new(label: 'Tanca Sessio')
    logout_button.signal_connect('clicked') { logout }
    vbox.pack_start(logout_button, expand: false, fill: false, padding: 0)

    # Area de resultats
    @result_view = Gtk::TextView.new
    @result_view.editable = false
    @result_view.cursor_visible = false
    vbox.pack_start(@result_view, expand: true, fill: true, padding: 0)

    @window.add(vbox)
    @window.show_all
  end

  def authenticate_user
    uid = @uid_entry.text.strip
    if uid.empty?
      show_message('Error', 'UID no pot estar buit')
      return
    end

    fetch_data('/authenticate', { uid: uid }).then do |response|
      if response[:error]
        show_message('Error', response[:error])
      else
        @user_name = response[:name]
        show_message('Autenticacio correcta', "Benvingut/da, #{@user_name}!")
      end
    end
  end

  def query_table
    table = @table_combo.active_text
    if table.nil?
      show_message('Error', 'Selecciona una taula per consultar')
      return
    end

    fetch_data('/query', { table: table }).then do |response|
      if response[:error]
        show_message('Error', response[:error])
      else
        @result_view.buffer.text = JSON.pretty_generate(response)
      end
    end
  end

  def logout
    fetch_data('/logout').then do |response|
      if response[:error]
        show_message('Error', response[:error])
      else
        show_message('Sessio tancada', 'Sessio tancada correctament')
        @uid_entry.text = ''
        @result_view.buffer.text = ''
      end
    end
  end

  def show_message(title, message)
    dialog = Gtk::MessageDialog.new(
      message: message,
      parent: @window,
      flags: :destroy_with_parent,
      type: :info,
      buttons_type: :close
    )
    dialog.title = title
    dialog.run
    dialog.destroy
  end
end

# Executar l'aplicacio
Gtk.init
ClientApp.new
Gtk.main


