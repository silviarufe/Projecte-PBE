#   -------- NO ES LA VERSIO DEFINITIVA --------

require 'gtk3'
require 'json'
require 'net/http'
require 'uri'

# Direccio del servidor
BASE_URL = 'http://192.168.68.110:3000'

# Realitzar sol-licituds HTTP GET
def fetch_data(path, params = {})
  uri = URI("#{BASE_URL}#{path}")
  uri.query = URI.encode_www_form(params) unless params.empty?
  begin
    response = Net::HTTP.get_response(uri)
    if response.code.to_i == 200
      JSON.parse(response.body)  # Ja processem la resposta JSON
    else
      { error: "Error del servidor: #{response.code} - #{response.body}" }
    end
  rescue StandardError => e
    { error: "Error al connectar amb el servidor: #{e.message}" }
  end
end

# Aplicacio amb GTK3
class SimpleClientApp
  def initialize
    @window = Gtk::Window.new('Client Atenea')
    @window.set_size_request(600, 400)
    @window.signal_connect('destroy') { Gtk.main_quit }

    # Contenidor vertical
    @vbox = Gtk::Box.new(:vertical, 10)
    @vbox.margin = 10
    @window.add(@vbox)

    # Inicialitza la interfÃ­cie inicial
    show_authentication_screen

    @window.show_all
  end

  def show_authentication_screen
    @vbox.children.each(&:destroy) # Neteja la interfÃ­cie

    # Etiqueta de benvinguda inicial
    label = Gtk::Label.new('Introdueix el teu UID per autenticar-te')
    @vbox.pack_start(label, expand: false, fill: false, padding: 10)

    # Entrada de text per UID
    entry = Gtk::Entry.new
    @vbox.pack_start(entry, expand: false, fill: false, padding: 10)

    # Boto per autenticar-se
    auth_button = Gtk::Button.new(label: 'Autentica')
    auth_button.signal_connect('clicked') do
      uid = entry.text.strip
      authenticate_user(uid)
    end
    @vbox.pack_start(auth_button, expand: false, fill: false, padding: 10)

    @window.show_all
  end

  def show_main_interface(name)
    @vbox.children.each(&:destroy) # Neteja la interfÃ­cie

    # Etiqueta de benvinguda
    welcome_label = Gtk::Label.new("Benvingut/da, #{name}!")
    @vbox.pack_start(welcome_label, expand: false, fill: false, padding: 10)

    # Boto de logout
    logout_button = Gtk::Button.new(label: 'Tanca Sessio')
    logout_button.signal_connect('clicked') do
      logout
    end
    @vbox.pack_start(logout_button, expand: false, fill: false, padding: 10)

    # Area de text per mostrar els resultats
    @result_view = Gtk::TextView.new
    @result_view.editable = false
    @result_view.cursor_visible = false
    @vbox.pack_start(@result_view, expand: true, fill: true, padding: 10)

    # Boto per fer consultes
    query_button = Gtk::Button.new(label: 'Consulta Taula')
    query_button.signal_connect('clicked') { query_table }
    @vbox.pack_start(query_button, expand: false, fill: false, padding: 10)

    @window.show_all
  end

  def authenticate_user(uid)
    result = fetch_data('/authenticate', { uid: uid })

    if result['name']
      show_main_interface(result['name'])
    else
      dialog = Gtk::MessageDialog.new(
        parent: @window,
        flags: :destroy_with_parent,
        type: :error,
        buttons: :close,
        message: 'Error d\'autenticacio. Torna-ho a intentar.'
      )
      dialog.run
      dialog.destroy
      show_authentication_screen
    end
  end

def query_table
  table = prompt("Introdueix el nom de la taula (tasks, timetables, marks):")
  return unless table

  # Permet filtres
  filter_string = prompt("Introdueix els filtres (exemple: subject=Math&date[gte]=2023-01-01):")
  filters = parse_filters(filter_string)

  # Construir els parametres de la sol.licitud
  params = { table: table }.merge(filters)

  result = fetch_data('/query', params)

  if result.is_a?(Array) && !result.empty?
    header = result.first.keys.join(" | ")
    result_lines = result.map { |item| item.values.join(" | ") }.join("\n")
    result_text = "#{header}\n#{result_lines}"
    update_result_view(result_text)
  elsif result.is_a?(Array) && result.empty?
    update_result_view("No hi ha dades disponibles per a la taula #{table}")
  else
    update_result_view("Error: resposta inesperada")
  end
end

# Parseja la cadena de filtres en un hash usable
def parse_filters(filter_string)
  return {} if filter_string.nil? || filter_string.empty?

  filters = {}
  filter_string.split('&').each do |filter|
    key, value = filter.split('=')
    filters[key.strip] = value.strip if key && value
  end
  filters
end


def update_result_view(text)
  @result_view.buffer.text = text
end


def update_result_view(text)
  @result_view.buffer.text = text
end


  def logout
    result = fetch_data('/logout')
    if result['message']
      show_authentication_screen
    else
      update_result_view("Error en el logout: #{result['error']}")
    end
  end

  def update_result_view(text)
    @result_view.buffer.text = text
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




