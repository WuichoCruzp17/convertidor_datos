require 'csv'
require 'builder'
require 'json'
require 'nokogiri'
class ConvertidorCsvController < ApplicationController
  def index
  end

  def upload
    element ={}
    data =[]
    if params[:csv_file].present?
      # Verifica si el archivo es un archivo  CSV
      uploaded_file = params[:csv_file]
      if File.extname(uploaded_file.original_filename).casecmp('.csv') == 0
        columnas =[]
        columnas = getColumnas(uploaded_file)
        if !columnas.empty?
          columnas.each do |col|
            element[col]=''
          end
          data = getData(uploaded_file,columnas)
          csv_data = CSV.read(uploaded_file, headers: true)

          #data["xml"] = xmlConvert(csv_data)
          obj ={
            "tabla" =>data,
            "xml" => csv_to_xml(csv_data)
          }
          render json: obj
        end
      end
    end
  end

  #Función que regresa las columnas de un csv
  def getColumnas(archivo)
    columnas = []
    # Abre el archivo CSV y lee sus datos
    CSV.foreach(archivo, headers: true) do |row|
      # Itera a través de las columnas
      row.headers.each do |column_name|
        # Si la columna no existe en el arreglo, agrégala
        columnas << column_name unless columnas.include?(column_name)
      end
    end
    return columnas
  end

 # Función que obtiene la información del CSV
 def getData(archivo, columnas)
  data = []
  CSV.foreach(archivo, headers: true) do |row|
    elemento = {}
    columnas.each do |col|
      elemento[col] = row[col]
    end
    data << elemento
  end
  return data
end

def csv_to_xml(csv_content)
  begin
    # Parsea el contenido del CSV
    #csv = CSV.parse(csv_content, headers: true)

    # Crea un objeto Builder para generar el XML
    xml = Builder::XmlMarkup.new(indent: 2)

    # Instrucción XML (ubicada fuera del bloque data)
    xml.instruct!

    xml.data do
      csv_content.each do |row|
        xml.row do
          row.headers.each do |header|
            xml.tag!(header, row[header])
          end
        end
      end
    end

    # Convierte el documento XML en una cadena
    doc = Nokogiri::XML(xml.target!)
    return doc.to_s
  rescue => e
    puts "Error al convertir datos a XML: #{e.message}"
    return nil
  end
end

end
