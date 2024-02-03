class XmlController < ApplicationController


  def upload
    if params[:xml_file].present?
      uploaded_file = params[:xml_file]
      if File.extname(uploaded_file.original_filename).casecmp('.xml') == 0
        xml_data = File.read(uploaded_file)
        csv_data = xml_to_csv(xml_data)
        puts "CSV ->#{csv_data}"
        #render plain: csv_data
      end
    end
  end

  def xml_to_csv(xml_data)
    begin
      doc = Nokogiri::XML(xml_data)
      rows = []
      headers = []

      doc.root.traverse do |node|
        if node.element?
          headers << node.name unless headers.include?(node.name)
        end
      end

      rows << headers.to_csv
      puts "Elemento 0 -> #{doc.root.xpath('/*')[0]}"
      doc.root.xpath('/*').each do |row|
        row_data = []
        headers.each do |header|
          row_data << row.at(header)&.text
        end
        rows << row_data.to_csv
      end

      return rows.join
    rescue => e
      puts "Error al convertir datos XML a CSV: #{e.message}"
      return nil
    end
  end
end
