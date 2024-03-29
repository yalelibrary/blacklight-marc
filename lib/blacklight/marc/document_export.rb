# -*- encoding : utf-8 -*-
# -*- coding: utf-8 -*-
# Written for use with Blacklight::Solr::Document::Marc, but you can use
# it for your own custom Blacklight document Marc extension too -- just
# include this module in any document extension (or any other class)
# that provides a #to_marc returning a ruby-marc object.  This module will add
# in export_as translation methods for a variety of formats. 
module Blacklight::Marc::DocumentExport

    def self.register_export_formats(document)
        document.will_export_as(:xml)
        document.will_export_as(:marc, "application/marc")
        # marcxml content type:
        # http://tools.ietf.org/html/draft-denenberg-mods-etc-media-types-00
        document.will_export_as(:marcxml, "application/marcxml+xml")
        document.will_export_as(:openurl_ctx_kev, "application/x-openurl-ctx-kev")
        document.will_export_as(:refworks_marc_txt, "text/plain")
        document.will_export_as(:endnote, "application/x-endnote-refer")
        #document.will_export_as(:endnote, "application/endnote")
        document.will_export_as(:ris, "application/ris")
        document.will_export_as(:refworks_archives, "text/plain")
        document.will_export_as(:ris_archives, "application/ris")
        document.will_export_as(:endnote_archives, "application/endnote")
    end


    def export_as_marc
        to_marc.to_marc
    end

    def export_as_marcxml
        to_marc.to_xml.to_s
    end

    alias_method :export_as_xml, :export_as_marcxml

    def export_as_archives
        archives_doc
    end

    # TODO This exporting as formatted citation thing should be re-thought
    # redesigned at some point to be more general purpose, but this
    # is in-line with what we had before, but at least now attached
    # to the document extension where it belongs.
    def export_as_apa_citation_txt
        apa_citation(to_marc)
    end

    def export_as_mla_citation_txt
        mla_citation(to_marc)
    end

    def export_as_chicago_citation_txt
        chicago_citation(to_marc)
    end

    # Exports as an OpenURL KEV (key-encoded value) query string.
    # For use to create COinS, among other things. COinS are
    # for Zotero, among other things. TODO: This is wierd and fragile
    # code, it should use ruby OpenURL gem instead to work a lot
    # more sensibly. The "format" argument was in the old marc.marc.to_zotero
    # call, but didn't neccesarily do what it thought it did anyway. Left in
    # for now for backwards compatibilty, but should be replaced by
    # just ruby OpenURL.
    def export_as_openurl_ctx_kev(format = nil)
        title = to_marc.find {|field| field.tag == '245'}
        author = to_marc.find {|field| field.tag == '100'}
        corp_author = to_marc.find {|field| field.tag == '110'}
        publisher_info = to_marc.find {|field| field.tag == '260'}
        edition = to_marc.find {|field| field.tag == '250'}
        isbn = to_marc.find {|field| field.tag == '020'}
        issn = to_marc.find {|field| field.tag == '022'}
        unless format.nil?
            format.is_a?(Array) ? format = format[0].downcase.strip : format = format.downcase.strip
        end
        export_text = ""
        if format == 'book'
            export_text << "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=book&amp;"
            export_text << "rft.btitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
            export_text << "rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
            export_text << "rft.au=#{(author.nil? or author['a'].nil?) ? "" : CGI::escape(author['a'])}&amp;"
            export_text << "rft.aucorp=#{CGI::escape(corp_author['a']) if corp_author['a']}+#{CGI::escape(corp_author['b']) if corp_author['b']}&amp;" unless corp_author.blank?
            export_text << "rft.date=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&amp;"
            export_text << "rft.place=#{(publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a'])}&amp;"
            export_text << "rft.pub=#{(publisher_info.nil? or publisher_info['b'].nil?) ? "" : CGI::escape(publisher_info['b'])}&amp;"
            export_text << "rft.edition=#{(edition.nil? or edition['a'].nil?) ? "" : CGI::escape(edition['a'])}&amp;"
            export_text << "rft.isbn=#{(isbn.nil? or isbn['a'].nil?) ? "" : isbn['a']}"
        elsif (format =~ /journal/i) # checking using include because institutions may use formats like Journal or Journal/Magazine
            export_text << "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=article&amp;"
            export_text << "rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
            export_text << "rft.atitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
            export_text << "rft.aucorp=#{CGI::escape(corp_author['a']) if corp_author['a']}+#{CGI::escape(corp_author['b']) if corp_author['b']}&amp;" unless corp_author.blank?
            export_text << "rft.date=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&amp;"
            export_text << "rft.issn=#{(issn.nil? or issn['a'].nil?) ? "" : issn['a']}"
        else
            export_text << "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;"
            export_text << "rft.title=" + ((title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a']))
            export_text << ((title.nil? or title['b'].nil?) ? "" : CGI.escape(" ") + CGI::escape(title['b']))
            export_text << "&amp;rft.creator=" + ((author.nil? or author['a'].nil?) ? "" : CGI::escape(author['a']))
            export_text << "&amp;rft.aucorp=#{CGI::escape(corp_author['a']) if corp_author['a']}+#{CGI::escape(corp_author['b']) if corp_author['b']}" unless corp_author.blank?
            export_text << "&amp;rft.date=" + ((publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c']))
            export_text << "&amp;rft.place=" + ((publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a']))
            export_text << "&amp;rft.pub=" + ((publisher_info.nil? or publisher_info['b'].nil?) ? "" : CGI::escape(publisher_info['b']))
            export_text << "&amp;rft.format=" + (format.nil? ? "" : CGI::escape(format))
        end
        export_text.html_safe unless export_text.blank?
    end


    # This format used to be called 'refworks', which wasn't really
    # accurate, sounds more like 'refworks tagged format'. Which this
    # is not, it's instead some weird under-documented Refworks
    # proprietary marc-ish in text/plain format. See
    # http://robotlibrarian.billdueber.com/sending-marcish-data-to-refworks/
    def export_as_refworks_marc_txt
        fields = to_marc.find_all {|f| ('000'..'999') === f.tag}
        text = "LEADER #{to_marc.leader}"
        fields.each do |field|
            unless ["940", "999"].include?(field.tag)
                if field.is_a?(MARC::ControlField)
                    text << "#{field.tag}    #{field.value}\n"
                else
                    text << "#{field.tag} "
                    text << (field.indicator1 ? field.indicator1 : " ")
                    text << (field.indicator2 ? field.indicator2 : " ")
                    text << " "
                    field.each {|s| s.code == 'a' ? text << "#{s.value}" : text << " |#{s.code}#{s.value}"}
                    text << "\n"
                end
            end
        end

        # As of 11 May 2010, Refworks has a problem with UTF-8 if it's decomposed,
        # it seems to want C form normalization, although RefWorks support
        # couldn't tell me that. -jrochkind
        text = text.unicode_normalize(:nfc)

        return text
    end

    # Endnote Import Format. See the EndNote User Guide at:
    # http://www.endnote.com/support/enx3man-terms-win.asp
    # Chapter 7: Importing Reference Data into EndNote / Creating a Tagged “EndNote Import” File
    #
    # Note: This code is copied from what used to be in the previous version
    # in ApplicationHelper#render_to_endnote.  It does NOT produce very good
    # endnote import format; the %0 is likely to be entirely illegal, the
    # rest of the data is barely correct but messy. TODO, a new version of this,
    # or better yet just an export_as_ris instead, which will be more general
    # purpose.
    def export_as_endnote
        end_note_format = {
          "%A" => "author",
          "%C" => "pub_place",
          "%D" => "pub_date",
          "%E" => "add_entry",
          "%I" => "publisher",
          "%@" => "isbn",
          "%_@" => "issn",
          "%S" => "series",
          "%T" => "title",
          "%P" => "num_pages",
          "%U" => "url",
          "%7" => "edition",
          # nowhere to put scale, so use notes in %Z
          "%Z" => "scale",
        }

        # convert marc data to object hash
        doc_object = to_object

        # This is a legacy of the old export_as_endnote left for compatibility
        text = "%0 Generic\n"

        # For each value in our end_note_format hash, iterate through
        # all marc_object fields and put them into string
        # Each marc_object could have 0 or more strings in array

        end_note_format.each do |endnote_key, doc_key|
            doc_object[doc_key].each do |doc_value|
                text << "#{endnote_key} #{doc_value}\n"
            end
        end
        text
    end

    def to_ris_text
        ris_format = {
          "AU" => "author",
          "CY" => "pub_place",
          "PY" => "pub_date",
          "TA" => "add_entry",
          "PB" => "publisher",
          # could be either, not sure if will cause problems
          "SN" => "issn",
          "M1" => "series",
          "T1" => "title",
          "EP" => "num_pages",
          "UR" => "url",
          "ET" => "edition",
          # nowhere to put scale, so use notes in %Z
          "N1" => "scale",
        }

        # convert marc data to object hash
        doc_object = to_object

        # Not sure how to find content type, just use generic
        text = "TY  - GEN\n"

        # For each value in our ris_format hash, iterate through
        # all doc_object fields and put them into string
        # Each doc_object could have 0 or more strings in array

        ris_format.each do |ris_key, obj_key|
            doc_object[obj_key].each do |obj_value|
                text << "#{ris_key}  - #{obj_value}\n"
            end
        end
        # have to end RIS
        text << "ER  -\n"
        text
    end

    def export_as_refworks_archives
        archives_refworks_format = {
          "RT" => "format",
          "A1" => "author",
          # could be either, not sure if will cause problems
          "JF" => "find_in",
          "VO" => "volume", #Volume container
          "T1" => "title",
          "UL" => "url",
          "RD" => "retrieved_day"
        }
        aspace_object = to_aspace
        text = "\n"
        archives_refworks_format.each do |refworks_key, aspace_key|
            aspace_object[aspace_key].each do |aspace_val|
                text << "#{refworks_key}  #{aspace_val}\n"
            end
        end
        text << "\n"
        text
    end

    def to_aspace
        doc = {}
        doc['format'] = "Archives or Manuscripts"
        doc['author'] = export_as_archives['author_display'].to_s
        doc['find_in'] = export_as_archives['found_in_labels_ss'].to_s
        doc['volume'] = export_as_archives['container_display'].to_s
        doc['title'] = export_as_archives['title'].to_s
        doc['url'] = "https://archives.yale.edu/#{export_as_archives['archive_space_uri_ss'].to_s}"
        doc['retrieved_day'] = Date.today
        doc
    end


    protected


    def mla_citation(record)
        text = ''
        authors_final = []

        #setup formatted author list
        authors = get_author_list(record)

        if authors.length < 4
            authors.each do |l|
                if l == authors.first #first
                    authors_final.push(l)
                elsif l == authors.last #last
                    authors_final.push(", and " + name_reverse(l) + ".")
                else #all others
                    authors_final.push(", " + name_reverse(l))
                end
            end
            text += authors_final.join
            unless text.blank?
                if text[-1, 1] != "."
                    text += ". "
                else
                    text += " "
                end
            end
        else
            text += authors.first + ", et al. "
        end
        # setup title
        title = setup_title_info(record)
        if !title.nil?
            text += "<i>" + mla_citation_title(title) + "</i> "
        end

        # Edition
        edition_data = setup_edition(record)
        text += edition_data + " " unless edition_data.nil?

        # Publication
        text += setup_pub_info(record) unless setup_pub_info(record).nil? || !physical_description_sound(record).nil?
        text += physical_description_sound(record) unless physical_description_sound(record).nil?

        # Get Pub Date
        text += + ", " + setup_pub_date(record) unless setup_pub_date(record).empty?
        if text[-1, 1] != "."
            text += "." unless text.nil? or text.blank?
        end
        text
    end

    def apa_citation(record)
        text = ''
        authors_list = []
        authors_list_final = []

        #setup formatted author list
        authors = get_author_list(record)
        authors.each do |l|
            authors_list.push(abbreviate_name(l)) unless l.blank?
        end
        authors_list.each do |l|
            if l == authors_list.first #first
                authors_list_final.push(l.strip)
            elsif l == authors_list.last #last
                authors_list_final.push(", &amp; " + l.strip)
            else #all others
                authors_list_final.push(", " + l.strip)
            end
        end
        text += authors_list_final.join
        unless text.blank?
            if text[-1, 1] != "."
                text += ". "
            else
                text += " "
            end
        end
        # Get Pub Date
        text += "(" + setup_pub_date(record) + "). " unless setup_pub_date(record).empty?

        # setup title info
        title = setup_title_info(record)
        text += "<i>" + title + "</i> " unless title.nil?

        # Edition
        edition_data = setup_edition(record)
        text += edition_data + " " unless edition_data.nil?

        # Publisher info
        text += setup_pub_info(record) unless setup_pub_info(record).nil? || !physical_description_sound(record).nil?
        text += physical_description_sound(record) unless physical_description_sound(record).nil?
        unless text.blank?
            if text[-1, 1] != "."
                text += "."
            end
        end
        text
    end

    # Main method for defining chicago style citation.  If we don't end up converting to using a citation formatting service
    # we should make this receive a semantic document and not MARC so we can use this with other formats.
    #  Notes and Bibliography
    def chicago_citation(record)
        #   more than 10, only the first seven should be listed in the bibliography, followed by et al.
        ## less than four, list all, first author: last name, first name, others first name last name
        #  and before the last author ##
        authors = get_all_authors(record)
        author_text = ""
        unless authors[:primary_authors].blank?
            if authors[:primary_authors].length > 10
                authors[:primary_authors].each_with_index do |author, index|
                    if index < 7
                        if index == 0
                            author_text << "#{author}"
                            if author.ends_with?(",")
                                author_text << " "
                            else
                                author_text << ", "
                            end
                        else
                            author_text << "#{name_reverse(author)}, "
                        end
                    end
                end
                author_text << " et al."
            elsif authors[:primary_authors].length > 1
                authors[:primary_authors].each_with_index do |author, index|
                    if index == 0
                        author_text << "#{author}"
                        if author.ends_with?(",")
                            author_text << " "
                        else
                            author_text << ", "
                        end
                    elsif index + 1 == authors[:primary_authors].length
                        author_text << "and #{name_reverse(author).gsub(/\,.$/, '')}"
                    else
                        author_text << "#{name_reverse(author)}, "
                    end
                end
            else
                author_text << authors[:primary_authors].first.gsub(/\,.$/, '')
            end
        else
            temp_authors = []
            authors[:translators].each do |translator|
                temp_authors << [translator, "trans."]
            end
            authors[:editors].each do |editor|
                temp_authors << [editor, "ed."]
            end
            authors[:compilers].each do |compiler|
                temp_authors << [compiler, "comp."]
            end

            unless temp_authors.blank?
                if temp_authors.length > 10
                    temp_authors.each_with_index do |author, index|
                        if index < 7
                            author_text << "#{author.first} #{author.last} "
                        end
                    end
                    author_text << " et al."
                elsif temp_authors.length > 1
                    temp_authors.each_with_index do |author, index|
                        if index == 0
                            author_text << "#{author.first} #{author.last}, "
                        elsif index + 1 == temp_authors.length
                            author_text << "and #{name_reverse(author.first)} #{author.last}"
                        else
                            author_text << "#{name_reverse(author.first)} #{author.last}, "
                        end
                    end
                else
                    author_text << "#{temp_authors.first.first} #{temp_authors.first.last}"
                end
            end
        end

        unless author_text.blank?
            author_text = author_text.gsub(/\,$/, "")
            if author_text[-1, 1] != "."
                author_text += ". "
            else
                author_text += " "
            end
        end
        # Get Pub Date
        pub_date = setup_pub_date(record) unless setup_pub_date(record).nil?

        # Get volumes

        # setup title info
        title = setup_title_info(record)


        if !authors[:primary_authors].blank? and (!authors[:translators].blank? or !authors[:editors].blank? or !authors[:compilers].blank?)
            additional_title << "Translated by #{authors[:translators].collect {|name| name_reverse(name)}.join(" and ")}. " unless authors[:translators].blank?
            additional_title << "Edited by #{authors[:editors].collect {|name| name_reverse(name)}.join(" and ")}. " unless authors[:editors].blank?
            additional_title << "Compiled by #{authors[:compilers].collect {|name| name_reverse(name)}.join(" and ")}. " unless authors[:compilers].blank?
        end

        edition = ""
        edition << setup_edition(record) unless setup_edition(record).nil?

        pub_info = setup_pub_info(record) unless setup_pub_info(record).nil?


        citation = ""
        citation << "#{author_text}" unless author_text.blank?

        citation << "<i>#{title}</i> " unless title.blank?
        citation << "#{edition} " unless edition.blank?

        # add volumes information if not null
        volumes = volumes_info(record) unless volumes_info(record).blank?
        volumes = volumes.gsub("volumes", "vols. ") unless volumes.nil?
        citation << volumes unless volumes.blank?

        is_sound = is_sound_disc(record)
        sound_info = physical_description_sound(record)


        citation << "#{pub_info}" unless pub_info.blank? || is_sound
        citation << "#{sound_info}" unless sound_info.nil?
        if pub_date.blank? && (!pub_info.blank? || !sound_info.nil?)
            citation << "."
        elsif !pub_date.blank? && (!pub_info.blank? || !sound_info.nil?)
            citation << ", #{pub_date}."
        elsif !pub_date.blank? && pub_info.blank? && sound_info.nil?
            citation << "#{pub_date}."
        end
        unless citation.blank?
            if citation[-1, 1] != "."
                citation += "."
            end
        end
        citation
    end


    def setup_pub_date(record)
        text = pub_date_26x(record, "264").present? ? pub_date_26x(record, "264") : (pub_date_26x(record, "260").present? ? pub_date_26x(record, "260") : "")
        text
    end

    def setup_pub_info(record)
        text = pub_info_26x(record, "264").present? ? pub_info_26x(record, "264") : (pub_info_26x(record, "260").present? ? pub_info_26x(record, "260") : "")
    end

    def pub_date_26x(record, field_26x)
        date_value = ''
        if !record.find {|f| f.tag == field_26x}.nil?
            pub_date = record.find {|f| f.tag == field_26x}
            unless !pub_date.find {|s| s.code == 'c'}
                c_value = pub_date.find {|s| s.code == 'c'}.value unless pub_date.find {|s| s.code == 'c'}.value.blank?
                date_value_twoOrThree = c_value.match(/(\d{2,3}[\-?u|\s]{1,2})/) unless c_value.match(/([\d]{2,3}[\-?u|\s])/).blank?
                date_value_betweenFourDigits = c_value.include? "between"
                date_value_fourDigit = (c_value.match(/$[\d]{4}/) || c_value.match(/[\d]{4}-[\d]{2,4}/) || c_value.match(/[\d]{4}-/)) unless c_value.match(/[\d]{4}/).blank?
                if date_value_fourDigit.present?
                    date_value = date_value_fourDigit unless date_value_fourDigit.blank?
                elsif date_value_betweenFourDigits
                    dates = c_value.scan(/[\d]{4}/)
                    date1 = dates[0].to_s
                    date2 = dates[1].to_s
                    date_value = "[" + date1 + "-" + date2 + "?]"
                elsif date_value_twoOrThree.present?
                    if date_value_twoOrThree[0].length == 5 and (date_value_twoOrThree[0].end_with?('-') || date_value_twoOrThree[0].end_with?('?'))
                        date_value = date_value_twoOrThree[0][0..-2].gsub!(/\D/, '0') unless date_value_twoOrThree.nil?
                    else
                        date_value = date_value_twoOrThree[0].gsub!(/\D/, '0') unless date_value_twoOrThree.nil?
                    end
                    date_value = "[" + date_value + "?]" unless date_value.nil?
                elsif date_value_betweenFourDigits.present?
                    dates = date_value_betweenFourDigits.scan(/[\d]{4}/)
                    date1 = dates[0].to_s
                    date2 = date[1].to_s
                    date_value = "[" + date1 + "-" + date2 + "?]"
                else
                    date_value = c_value.gsub(/[^0-9|n\.d\.]/, "")[0, 4] unless c_value.gsub(/[^0-9|n\.d\.]/, "")[0, 4].blank?
                end
            end
            return nil if date_value.nil?
        end
        clean_end_punctuation(date_value.to_s) if date_value

    end


    def pub_info_26x(record, field_26x)
        text = ''
        pub_info_field = record.find {|f| f.tag == field_26x}
        if !pub_info_field.nil?
            a_pub_info = pub_info_field.find {|s| s.code == 'a'}
            b_pub_info = pub_info_field.find {|s| s.code == 'b'}
            a_pub_info = clean_end_punctuation(a_pub_info.value.strip) unless a_pub_info.nil?
            b_pub_info = b_pub_info.value.strip unless b_pub_info.nil?
            text += a_pub_info.strip unless a_pub_info.nil?
            if !a_pub_info.nil? and !b_pub_info.nil?
                text += ": "
            end
            text += b_pub_info.strip unless b_pub_info.nil?
        end
        return nil if text.strip.blank?
        clean_end_punctuation(text.strip)
    end

    def is_sound_disc(record)
        title_field = record.find {|f| f.tag == '245'}
        if !title_field.nil?
            medium_info = title_field.find {|s| s.code == 'h'}
            medium_info = clean_end_punctuation(medium_info.value.strip) unless medium_info.nil?
        end
        format_field = record.find {|f| f.tag == '300'}
        if !format_field.nil?
            sound_info = format_field.find {|s| s.code == 'a'}
            sound_info = clean_end_punctuation(sound_info.value.strip) unless sound_info.nil?
        end
        medium_info.include?("sound recording") unless medium_info.nil? || sound_info.include?("sound discs") unless sound_info.nil?
    end

    def physical_description_sound(record)
        format_field = record.find {|f| f.tag == '300'}
        if !format_field.nil?
            sound_info = format_field.find {|s| s.code == 'a'}
            sound_info = clean_end_punctuation(sound_info.value.strip) unless sound_info.nil?
        end
        return nil if sound_info.strip.nil? || !is_sound_disc(record)
        clean_end_punctuation(sound_info.strip)
    end

    def volumes_info(record)
        volumes_info_field = record.find {|f| f.tag == '300'}
        if !volumes_info_field.nil?
            volume_info = volumes_info_field.find {|s| s.code == 'a'}
            volumes = volume_info.value.match(/(\d\svolumes)/) unless volume_info.value.match(/(\d\svolumes)/).blank?
        end
        volumes = clean_end_punctuation(volumes.to_s.strip) unless volumes.nil?
    end

    def mla_citation_title(text)
        no_upcase = ["a", "an", "and", "but", "by", "for", "it", "of", "the", "to", "with"]
        new_text = []
        word_parts = text.split(" ")
        word_parts.each do |w|
            if !no_upcase.include? w
                new_text.push(w.capitalize)
            else
                new_text.push(w)
            end
        end
        new_text.join(" ")
    end

    # This will replace the mla_citation_title method with a better understanding of how MLA and Chicago citation titles are formatted.
    # This method will take in a string and capitalize all of the non-prepositions.
    def citation_title(title_text)
        prepositions = ["a", "about", "across", "an", "and", "before", "but", "by", "for", "it", "of", "the", "to", "with", "without"]
        new_text = []
        title_text.split(" ").each_with_index do |word, index|
            if (index == 0 and word != word.upcase) or (word.length > 1 and word != word.upcase and !prepositions.include?(word))
                # the split("-") will handle the capitalization of hyphenated words
                new_text << word.split("-").map! {|w| w.capitalize}.join("-")
            else
                new_text << word
            end
        end
        new_text.join(" ")
    end

    def setup_title_info(record)
        text = ''
        title_info_field = record.find {|f| f.tag == '245'}
        if !title_info_field.nil?
            a_title_info = title_info_field.find {|s| s.code == 'a'}
            b_title_info = title_info_field.find {|s| s.code == 'b'}
            a_title_info = clean_end_punctuation(a_title_info.value.strip) unless a_title_info.nil?
            b_title_info = clean_end_punctuation(b_title_info.value.strip) unless b_title_info.nil?
            text += a_title_info.strip unless a_title_info.nil?
            if !a_title_info.nil? and !b_title_info.nil?
                text += ": "
            end
            text += b_title_info.strip unless b_title_info.nil?
        end
        series_title_field = record.find {|f| f.tag == '490'}
        if !series_title_field.nil?
            series_title_info = series_title_field.find {|s| s.code == 'a'}
            series_title_info = clean_end_punctuation(series_title_info.value.strip) unless series_title_info.nil?
        end
        text += ". " + series_title_info unless series_title_info.nil?
        return nil if text.strip.blank?
        clean_end_punctuation(text.strip) + "."
    end

    def clean_end_punctuation(text)
        if [".", ",", ":", ";", "/"].include? text[-1, 1]
            return text[0, text.length - 1]
        end
        text
    end

    def setup_edition(record)
        edition_field = record.find {|f| f.tag == '250'}
        edition_code = edition_field.find {|s| s.code == 'a'} unless edition_field.nil?
        edition_data = edition_code.value unless edition_code.nil?
        if edition_data.nil? or edition_data == '1st ed.'
            return nil
        else
            return edition_data
        end
    end

    def get_author_list(record)
        author_list = []
        authors_primary = record.find {|f| f.tag == '100'}
        author_primary = authors_primary.find {|s| s.code == 'a'}.value unless authors_primary.nil? rescue ''
        author_list.push(clean_end_punctuation(author_primary)) unless author_primary.nil?
        authors_secondary = record.find_all {|f| ('700') === f.tag}
        if !authors_secondary.nil?
            authors_secondary.each do |l|
                author_list.push(clean_end_punctuation(l.find {|s| s.code == 'a'}.value)) unless l.find {|s| s.code == 'a'}.value.nil?
            end
        end

        author_list.uniq!
        author_list
    end

    # This is a replacement method for the get_author_list method.  This new method will break authors out into primary authors, translators, editors, and compilers
    def get_all_authors(record)
        translator_code = "trl"; editor_code = "edt"; compiler_code = "com"
        primary_authors = []; translators = []; editors = []; compilers = []
        record.find_all {|f| f.tag === "100"}.each do |field|
            primary_authors << field["a"] if field["a"]
        end
        record.find_all {|f| f.tag === "700"}.each do |field|
            if field["a"]
                relators = []
                relators << clean_end_punctuation(field["e"]) if field["e"]
                relators << clean_end_punctuation(field["4"]) if field["4"]
                if relators.include?(translator_code)
                    translators << field["a"]
                elsif relators.include?(editor_code)
                    editors << field["a"]
                elsif relators.include?(compiler_code)
                    compilers << field["a"]
                else
                    primary_authors << field["a"] unless primary_authors.include?(field["a"])
                end
            end
        end
        {:primary_authors => primary_authors, :translators => translators, :editors => editors, :compilers => compilers}
    end

    def abbreviate_name(name)
        name_parts = name.split(", ")
        first_name_parts = name_parts.last.split(" ")
        temp_name = name_parts.first + ", " + first_name_parts.first[0, 1] + "."
        first_name_parts.shift
        temp_name += " " + first_name_parts.join(" ") unless first_name_parts.empty?
        temp_name
    end

    def name_reverse(name)
        name = clean_end_punctuation(name)
        return name unless name =~ /,/
        temp_name = name.split(", ")
        return temp_name.last + " " + temp_name.first
    end

    # This method will turn our marc records into a Hash of arrays
    # Where each key will give 0 or more results
    # Ex: doc['isbn'] will be [] if no results are found
    # Ex: doc['isbn'] could be ['1234', '5678'] of several records found

    def to_object
        doc = {}

        doc['isbn'] = record_to_array('020.a')
        doc['issn'] = record_to_array('022.b')
        doc['author'] = record_to_array('100.a')
        doc['edition'] = record_to_array('250.a')
        doc['scale'] = record_to_array('255.a')
        doc['num_pages'] = record_to_array('300.a')
        doc['cite_as'] = record_to_array('524.a')
        doc['add_entry'] = record_to_array('700.a')
        doc['url'] = record_to_array('856.u')

        # Publisher, title, series could have multiple fields
        # So just join the arrays together

        doc['pub_place'] = record_to_array('260.a') +
          record_to_array('264.a')
        doc['publisher'] = record_to_array('260.b') +
          record_to_array('264.b')
        doc['pub_date'] = record_to_array('260.c') +
          record_to_array('264.c')
        doc['title'] = record_to_array('245.a') +
          record_to_array('245.b')
        doc['series'] = record_to_array('440.a') +
          record_to_array('490.a')

        doc
    end

    # This takes an individual MARC field and turns it into
    # 0 or more members of an array for to_object

    def record_to_array(marc_field)
        record_values = []
        marc_field, sub_field = marc_field.split('.')
        to_marc.find_all {|f| marc_field == f.tag}.each do |entry|
            unless entry[sub_field].nil?
                record_values.push(entry[sub_field])
                # or clean the record first
                # record_values.push(clean_record(entry[sub_field])
            end
        end
        record_values
    end

    # Utility function to clean up trailing data inside record_to_array
    # Before exporting it to a citation document

    def clean_record(record_text)
        record_text.chomp!(',')
        record_text.chomp!(':')
        record_text.chomp!('/')
        record_text.chomp!(';')
        record_text
    end


end
