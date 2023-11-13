class XmlController < ApplicationController


  def upload
    if params[:xml_file].present?
      # Accede al archivo cargado
      uploaded_file = params[:xml_file]

      # Verifica si el archivo es un archivo XML
      if File.extname(uploaded_file.original_filename).casecmp('.xml') == 0
        # Lee el contenido del archivo
        xml_content =File.open(uploaded_file) { |f| Nokogiri::XML(f) }

        # Analiza el contenido XML con Nokogiri
        xml_data = []
        xml_data = get_data(xml_content.root)

        # Convierte el objeto Ruby en JSON
        json_data = xml_data.to_json

        # Puedes imprimir el JSON resultante o realizar otras acciones según tus necesidades
        puts json_data
      else
        flash[:error] = 'El archivo no es un archivo XML válido.'
      end
    else
      flash[:error] = 'No se seleccionó ningún archivo.'
    end

    # Redirige a la página anterior u otra página según tus necesidades
    redirect_to request.referrer
  end

  def get_data(element)
    xml_data = {}

    if element.elements.empty?
      xml_data[element.name] = element.text
    else
      xml_data[element.name] = {}
      element.elements.each do |child_element|
        xml_data[element.name][child_element.name] = child_element.text
      end
    end

    xml_data[element.name]["attributes"] = extract_attributes(element)
    return xml_data
  end

  def extract_attributes(element)
    attributes = element.attributes
    atributos = []

    attributes.each do |name, value|
      atributo = { element.name => { "key" => name, "value" => value } }
      atributos.push(atributo)
    end

    element.children.each do |child|
      atributos.concat(extract_attributes(child)) if child.element?
    end

    return atributos
  end

end
