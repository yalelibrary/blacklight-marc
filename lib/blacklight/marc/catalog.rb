module Blacklight::Marc
  module Catalog
    extend ActiveSupport::Concern

    included do
      blacklight_config.add_show_tools_partial(:librarian_view, if: :render_librarian_view_control?, define_method: false)
      blacklight_config.add_show_tools_partial(:refworks, if: :render_refworks_action?, modal: false, path: :single_refworks_catalog_path, define_method: false)
      blacklight_config.add_show_tools_partial(:endnote, if: :render_endnote_action?, modal: false, path: :single_endnote_catalog_path, define_method: false)
      blacklight_config.add_show_tools_partial(:archives, if: :render_archives_action?, modal: false, path: :single_refworks_catalog_path, define_method: false)
      blacklight_config.add_show_tools_partial(:endnote, if: :render_archives_endnote_action?, modal: false, path: :single_archives_catalog_path, define_method: false)
      blacklight_config.add_show_tools_partial(:ris, if: :render_archives_ris_action?, modal: false, path: :single_archives_catalog_path, define_method: false)
    end

    def librarian_view
      @response, @document = fetch params[:id]

      respond_to do |format|
        format.html
        format.js { render :layout => false }
      end
    end

    def endnote
      @response, _ = search_service.fetch(Array(params[:id]))
      @document = @response.documents
      respond_to do |format|
        format.endnote { render :layout => false }
      end
    end

    #grabs a bunch of reworks documents
   def refworks
      @response, @documents = search_service.fetch(Array(params[:id]))
      respond_to do |format|
        format.refworks_marc_txt { render :layout => false }
      end
   end

   def archives
       @response, @documents = search_service.fetch(Array(params[:id]))
       respond_to do |format|
           format.refworks_archives { render :layout => false }
        end
    end

    def ris_archives
        @response, @documents = search_service.fetch(Array(params[:id]))
        respond_to do |format|
            format.ris { render :layout => false }
        end
    end

    def endnote_archives
        @response, @documents = search_service.fetch(Array(params[:id]))# unless !params[:id].to_s.include?("repositories")
        respond_to do |format|
            format.endnote { render :layout => false }
        end
    end



    private

    def render_refworks_action? config, options = {}
      options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:refworks_marc_txt )
    end

    def render_endnote_action? config, options = {}
      options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:endnote )
    end

    def render_archives_action? config, options = {}
      options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:refworks_archives )
    end

    def render_archives_endnote_action? config, options = {}
        options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:endnote )
    end

    def render_librarian_view_control? config, options = {}
      respond_to? :librarian_view_solr_document_path and options[:document] and options[:document].respond_to?(:to_marc)
    end

    def render_archives_ris_action? config, options = {}
        options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:ris)
    end

  end
end
