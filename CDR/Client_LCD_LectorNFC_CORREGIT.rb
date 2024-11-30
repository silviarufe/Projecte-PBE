# Vesrió Corregida del client

require 'gtk3'
require 'json'
require 'net/http'
require 'uri'
#require 'i2c/drivers/lcd'
require_relative 'puzzle1'

# Retiro la variable lcd de la part global i la defino dins de la classe

BASE_URL = 'http://192.168.1.1:3000'

require 'net/http'
require 'json'

def fetch_data(path, params = {}, on_success: nil, on_error: nil, on_exception: nil)
  uri = URI("#{BASE_URL}#{path}")
  uri.query = URI.encode_www_form(params) unless params.empty?

  begin
    response = Net::HTTP.get_response(uri)

    if response.code.to_i == 200
      data = JSON.parse(response.body)
      on_success&.call(data) if on_success
    else
      if response.code.to_i == 600
        error_message = "Error: #{response.code} - #{response.body}" 
      else
        error_message = "Error del servidor: #{response.code} - #{response.body}"
      end
      on_error&.call(error_message) if on_error
    end
  rescue StandardError => e
    exception_message = "Error al conectar con el servidor: #{e.message}"
    on_exception&.call(exception_message) if on_exception
  end
end

def process_data(data, selected_columns)
  
  resultado = {}
  
  selected_columns.each{ |columna| resultado[columna] = [] }
  
  data.each do |fila|
    selected_columns.each do |columna|
      if columna == 'date'
        date_ok = Date.parse(fila[columna]).strftime('%Y-%m-%d')
        resultado[columna] << date_ok
      else
        resultado[columna] << fila[columna] if fila.key?(columna)
      end
    end
  end
  resultado
end


class SimpleClientApp
  def initialize
    @window = Gtk::Window.new('Client Atenea')
    @window.set_size_request(800, 600)
    @window.signal_connect('destroy') { Gtk.main_quit }

    @vbox = Gtk::Box.new(:vertical, 10)
    @vbox.margin = 10
    @window.add(@vbox)

    # Crear la instÃ ncia de la pantalla LCD dins de la classe
    #@lcd = I2C::Drivers::LCD::Display.new('/dev/i2c-1', 0x27, rows=4, cols=20)

    # Carregar els estils des d'un fitxer CSS extern
    load_css_from_file('styles.css')

    # Mostrar la pantalla d'autenticaciÃ³
    show_authentication_screen

    @window.show_all
  end

   def show_authentication_screen
  @vbox.children.each(&:destroy) # Limpia la interfaz
  
  lector = Rfid.new
  
  
  # Etiqueta de bienvenida inicial
  label = Gtk::Label.new('Acerque su tarjeta NFC para autenticarse')
  @vbox.pack_start(label, expand: false, fill: false, padding: 10)

  Thread.new do
    uid = lector.read_uid
    GLib::Idle.add do
      if uid
        authenticate_user(uid)
        false
      else
        show_error('No se pudo leer el UID. Intente nuevamente.')
      end
    end
  end

  @window.show_all
end


  def show_main_interface(name)
    @vbox.children.each(&:destroy)

    # Crear un contenidor horitzontal per al text de benvinguda i el botÃ³ de logout
    header_box = Gtk::Box.new(:horizontal, 5)

    # Mostrar un missatge de benvinguda a la pantalla LCD
    #@lcd.clear
    #@lcd.text('    Welcome', 1)
    #@lcd.text("#{name}!", 2)

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
    name = nil
    error = nil
    fetch_data('/authenticate', { uid: uid },
              on_success: -> (data) {name = data['name']},
              on_error: -> (error_message) {error = error_message},
              on_exception: -> (exception_message) {})
    if error != nil
      show_error_dialog(error)
    else
      if name != nil
        show_main_interface(name)
      else
        show_error_dialog('Error d\'autenticacio. Torna-ho a intentar.')
      end
    end
  end

  def query_table
    table = prompt('Introdueix el nom de la taula (tasks, timetables, marks):')
    return unless table

    filter_string = prompt('Introdueix els filtres (exemple: subject=Math&date[gte]=2023-01-01):')
    filters = parse_filters(filter_string)
    
    result = nil
    error = nil
    
    params = { table: table }.merge(filters)
    fetch_data('/query', params,
                on_success: -> (data) {result = data},
                on_error: -> (error_message) {error = error_message},
                on_exception: -> (exception_message) {error = exception_message})
    puts error
    if error != nil 
      show_error_dialog(error)
    
    else
      case table
      when 'timetables'    #Aqui les majuscules si que son importants
        data = process_data(result, ['day', 'hour', 'Subject', 'Room'])
      
      when 'tasks'
        data = process_data(result, ['date', 'subject', 'name'])
    
      when 'marks'
        data = process_data(result, ['Subject', 'Name', 'Marks'])
   
      else
        show_error_dialog(error)
      end
    
      if result.is_a?(Array) && !result.empty?
        populate_text_views(data)
      elsif result.is_a?(Array) && result.empty?
        show_error_dialog("No hi ha dades disponibles per a la taula #{table}")
      else
        show_error_dialog('Error: resposta inesperada')
      end
    end
  end

  def populate_text_views(data)
    @text_views_box.children.each(&:destroy)
        
    #Obtenir les columnes (les claus)
    columns = data.keys
    
    #Calcular amplada mxima de cada columna
    column_widths = columns.map do |col|
      #determinar la longitud maxima entre el nom de la columna i els seus valors
      [col.to_s.length, *data[col].map(&:to_s).map(&:length)].max
    end
    
    #afegir capÃ§aleres am el primer Text View
    headers = columns.each_with_index.map{ |col, i| col.to_s.ljust(column_widths[i]) }.join("\t\t")
    add_text_view(headers, 'header', 0)
    
    #determinar el nombre de files
    num_rows = data.values.first.size
    
    #iterar per cada fila segons l'index
    (0...num_rows).each do |row_index|
      #construir la fila accedint als valors per la seva posicio
      row_data = columns.each_with_index.map do |col, i|
        data[col][row_index].to_s.ljust(column_widths[i])
      end.join("\t\t")
      
      #alternem l'estil de cada fila
      style_class = row_index.even? ? 'row_even' : 'row_odd'
      add_text_view(row_data, style_class, row_index+1)
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



