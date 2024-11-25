# -------- VERSIO DEFINITIVA ---------

require 'gtk3'
require 'json'
require 'net/http'
require 'uri'
require 'i2c/drivers/lcd'
require_relative 'puzzle1'

# Retiro la variable lcd de la part global i la defino dins de la classe

BASE_URL = 'http://192.168.137.1:3000'

def fetch_data(path, params = {})
  uri = URI("#{BASE_URL}#{path}")
  uri.query = URI.encode_www_form(params) unless params.empty?
  begin
    response = Net::HTTP.get_response(uri)
    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      puts "Error del servidor: #{response.code} - #{response.body}"
      nil
    end
  rescue StandardError => e
    puts "Error al connectar amb el servidor: #{e.message}"
    nil
  end
end

class SimpleClientApp
  def initialize
    @window = Gtk::Window.new('Client Atenea')
    @window.set_size_request(800, 600)
    @window.signal_connect('destroy') { Gtk.main_quit }

    @vbox = Gtk::Box.new(:vertical, 10)
    @vbox.margin = 10
    @window.add(@vbox)

    # Crear la instància de la pantalla LCD dins de la classe
    @lcd = I2C::Drivers::LCD::Display.new('/dev/i2c-1', 0x27, rows=4, cols=20)

    # Carregar els estils des d'un fitxer CSS extern
    load_css_from_file('styles.css')

    # Mostrar la pantalla d'autenticació
    show_authentication_screen

    @window.show_all
  end

   def show_authentication_screen
  @vbox.children.each(&:destroy) # Limpia la interfaz

  # Etiqueta de bienvenida inicial
  label = Gtk::Label.new('Acerque su tarjeta NFC para autenticarse')
  @vbox.pack_start(label, expand: false, fill: false, padding: 10)

  # Botón para iniciar la lectura NFC
  nfc_button = Gtk::Button.new(label: 'Leer NFC')
  nfc_button.signal_connect('clicked') do
    uid = read_uid
    if uid
      authenticate_user(uid)
    else
      show_error('No se pudo leer el UID. Intente nuevamente.')
    end
  end
  @vbox.pack_start(nfc_button, expand: false, fill: false, padding: 10)

  @window.show_all
end

def read_uid
    begin
      reader = Rfid.new
      uid = reader.read_uid
      puts "UID leído: #{uid}" # Debugging opcional
      uid
    rescue StandardError => e
      puts "Error leyendo NFC: #{e.message}"
      nil
    end
  end

  def show_main_interface(name)
    @vbox.children.each(&:destroy)

    # Crear un contenidor horitzontal per al text de benvinguda i el botó de logout
    header_box = Gtk::Box.new(:horizontal, 5)

    # Mostrar un missatge de benvinguda a la pantalla LCD
    @lcd.clear
    @lcd.text('    Welcome', 1)
    @lcd.text("#{name}!", 2)

    welcome_label = Gtk::Label.new("Benvingut/da, #{name}!")
    header_box.pack_start(welcome_label, expand: true, fill: true, padding: 10)

    logout_button = Gtk::Button.new(label: 'Tanca Sessio')
    logout_button.set_name('logout_button')
    logout_button.signal_connect('clicked') { logout }
    header_box.pack_start(logout_button, expand: false, fill: false, padding: 10)

    @vbox.pack_start(header_box, expand: false, fill: false, padding: 10)

    @text_views_box = Gtk::Box.new(:vertical, 2)
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.add(@text_views_box)
    scrolled_window.set_policy(:automatic, :automatic)
    @vbox.pack_start(scrolled_window, expand: true, fill: true, padding: 10)

    query_button = Gtk::Button.new(label: 'Consulta Taula')
    query_button.set_name('query_button')
    query_button.signal_connect('clicked') { query_table }
    @vbox.pack_start(query_button, expand: false, fill: false, padding: 10)

    @window.show_all
  end

  def authenticate_user(uid)
    result = fetch_data('/authenticate', { uid: uid })
    if result && result['name']
      show_main_interface(result['name'])
    else
      show_error_dialog('Error d\'autenticacio. Torna-ho a intentar.')
    end
  end

  def query_table
    table = prompt('Introdueix el nom de la taula (tasks, timetables, marks):')
    return unless table

    filter_string = prompt('Introdueix els filtres (exemple: subject=Math&date[gte]=2023-01-01):')
    filters = parse_filters(filter_string)

    params = { table: table }.merge(filters)
    result = fetch_data('/query', params)

    if result.is_a?(Array) && !result.empty?
      populate_text_views(result)
    elsif result.is_a?(Array) && result.empty?
      show_error_dialog("No hi ha dades disponibles per a la taula #{table}")
    else
      show_error_dialog('Error: resposta inesperada')
    end
  end

  def populate_text_views(data)
    @text_views_box.children.each(&:destroy)

    # Càlcul de longitud màxima per columna
    columns = data.first.keys
    column_widths = columns.map { |col| [col.to_s.length, *data.map { |row| row[col].to_s.length }].max }

    # Afegir capçaleres com el primer TextView
    headers = columns.each_with_index.map { |col, i| col.to_s.ljust(column_widths[i]) }.join("\t\t")
    add_text_view(headers, 'header', 0)

    # Afegir les dades fila a fila
    data.each_with_index do |row, index|
      row_data = columns.each_with_index.map { |col, i| row[col].to_s.ljust(column_widths[i]) }.join("\t\t")
      style_class = index.even? ? 'row_even' : 'row_odd'
      add_text_view(row_data, style_class, index + 1)
    end

    @window.show_all
  end

  def add_text_view(text, style_class, row_index)
    buffer = Gtk::TextBuffer.new
    buffer.text = text

    text_view = Gtk::TextView.new
    text_view.buffer = buffer
    text_view.editable = false
    text_view.cursor_visible = false
    text_view.set_name(style_class)
    @text_views_box.pack_start(text_view, expand: false, fill: false, padding: 2)
  end

  def parse_filters(filter_string)
    return {} if filter_string.nil? || filter_string.empty?

    filters = {}
    filter_string.split('&').each do |filter|
      key, value = filter.split('=')
      filters[key.strip] = value.strip if key && value
    end
    filters
  end

  def show_error_dialog(message)
    dialog = Gtk::MessageDialog.new(
      parent: @window,
      flags: :destroy_with_parent,
      type: :error,
      buttons: :close,
      message: message
    )
    dialog.run
    dialog.destroy
  end

  def logout
    show_authentication_screen
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

  def load_css_from_file(file_path)
    return unless File.exist?(file_path)

    provider = Gtk::CssProvider.new
    provider.load_from_path(file_path)
    Gtk::StyleContext.add_provider_for_screen(
      Gdk::Screen.default,
      provider,
      Gtk::StyleProvider::PRIORITY_USER
    )
  end
end

Gtk.init
SimpleClientApp.new
Gtk.main



