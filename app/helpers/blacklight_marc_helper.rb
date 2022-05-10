module BlacklightMarcHelper

  # This method should move to BlacklightMarc in Blacklight 6.x
  def refworks_export_url params = {}, *_
    "https://www.refworks.com/express/expressimport.asp?vendor=#{CGI.escape(params[:vendor] || application_name)}&filter=#{CGI.escape(params[:filter] || "MARC Format")}&encoding=65001" + (("&url=#{CGI.escape(params[:url])}" if params[:url]) || "")
  end

  # The URL of the archives refworks
  def archives_export_url params = {}, *_
    "https://www.refworks.com/express/expressimport.asp?vendor=YUL&filter=RefWorks%20Tagged%20Format&encoding=65001"+ (("&url=#{CGI.escape(params[:url])}" if params[:url]) || "") #RIS
  end

  def refworks_solr_document_path opts = {}, *_
    if opts[:id]
      #refworks_export_url(url: solr_document_url(opts[:id], format: :refworks_marc_txt))
      if opts[:id].include? "repositories"
        archives_export_url(url: solr_document_url(opts[:id], format: :refworks_archives))
      else
        refworks_export_url(url: solr_document_url(opts[:id], format: :refworks_marc_txt))
      end
    end
  end

  # For exporting a single endnote document. (endnote_catalog_path is defined by blacklight-marc and it is used for multiple document export)
  def single_endnote_catalog_path opts = {}, *_
    solr_document_path(opts.merge(format: 'endnote'))
  end

# For exporting a single refworks  document. (refworks_catalog_path is defined by blacklight-marc and it is used for multiple document export)
  def single_refworks_catalog_path opts = {}, *_
    if opts[:id].include? "repositories"
      solr_document_path(opts.merge(format: 'refworks_archives'))
    else
      solr_document_path(opts.merge(format: 'refworks_marc_txt'))
    end
  end

  def single_archives_catalog_path opts = {}, *_
      solr_document_path(opts.merge(format: 'refworks_archives'))
  end

  def single_archives_endnote_catalog_path opts = {}, *_
    solr_document_path(opts.merge(format: 'endnote_archives'))
  end

  def single_archives_ris_catalog_path opts = {}, *_
    solr_document_path(opts.merge(format: 'ris_archives'))
  end


  # puts together a collection of documents into one refworks export string
  def render_refworks_texts(documents)
    val = ''
    documents.each do |doc|
      if doc.exports_as? :refworks_marc_txt
        val += doc.export_as(:refworks_marc_txt) + "\n"
      elsif doc.exports_as? :refworks_archives
        val += doc.export_as(:refworks_archives) + "\n"
      end
    end
    val
  end

  # puts together a collection of documents into one endnote export string
  def render_endnote_texts(documents)
    val = ''
    documents.each do |doc|
      if doc.exports_as? :endnote
        endnote = doc.export_as(:endnote)
        val += "#{endnote}\n" if endnote
      end
    end
    val
  end

  # puts together a collection of documents into one archives endnote export string
  def render_archives_endnote_texts(documents)
    val = ''
    documents.each do |doc|
      archives_endnote = {
          "%0"  => "Archives or Manuscripts",
          "%A" => doc['author_display'].present? ? doc['author_display'][0].to_s : doc['author_display'].to_s,
          "%I"=> doc['found_in_labels_ss'].to_s,
          "%V"=> doc['container_display'].present? ? doc['container_display'][0].to_s : doc['container_display'].to_s, #Volume container
          "%T"=> doc['title_display'].present? ? doc['title_display'][0].to_s : doc['title_display'].to_s,
          "%U"=> "https://archives.yale.edu/#{doc['archive_space_uri_s'].to_s}",
          "%O"=> Date.today
      }
      archives_endnote.each {|key|
        j_value = key[1].kind_of?(Array)? key[1][0].to_s : key[1].to_s
        val << "#{key[0].to_s} #{j_value}\n" }
      val << "\n"
    end
    val
  end

  # puts together a collection of documents into one archives refworks export string
  def render_archives_texts(documents)

    val = ''
    documents.each do |doc|
      archives = {
          "RT" => "Archives or Manuscripts",
          "A1" => doc['author_display'].present? ? doc['author_display'][0].to_s : doc['author_display'].to_s,
          "JF"=> doc['found_in_labels_ss'].to_s,
          "VO"=> doc['container_display'].present? ? doc['container_display'][0].to_s : doc['container_display'].to_s, #Volume container
          "T1"=> doc['title_display'].present? ? doc['title_display'][0].to_s : doc['title_display'].to_s,
          "UL"=> "https://archives.yale.edu/#{doc['archive_space_uri_s'].to_s}",
          "RD"=> Date.today
      }
      archives.each {|key|
        j_value = key[1].kind_of?(Array)? key[1][0].to_s : key[1].to_s
        val << "#{key[0].to_s} #{j_value}\n" }
      val << "\n"
    end
    val
  end

  # puts together a collection of documents into one archives ris export string
  def render_archives_ris_texts(documents)
    val = ''
    documents.each do |doc|
      archives = {
          "TY" => "Archives or Manuscripts",
          "AU" => doc['author_display'].present? ? doc['author_display'][0].to_s : doc['author_display'].to_s,
          "PB"=> doc['found_in_labels_ss'].to_s,
          "VL"=> doc['container_display'].present? ? doc['container_display'][0].to_s : doc['container_display'].to_s, #Volume container
          "T1"=> doc['title_display'].present? ? doc['title_display'][0].to_s : doc['title_display'].to_s,
          "UR"=> "https://archives.yale.edu/#{doc['archive_space_uri_s'].to_s}",
          "Y2"=> Date.today
      }
      archives.each {|key|
        j_value = key[1].kind_of?(Array)? key[1][0].to_s : key[1].to_s
        val << "#{key[0].to_s} - #{j_value}\n" }
      val << "\n"
    end
    val
  end
end
