module Blacklight::Marc
  module Archives
    extend ActiveSupport::Concern

    included do
        blacklight_config.add_show_tools_partial(:archives, if: :render_archives_action?, modal: false, path: :single_archives_archives_path, define_method: false)
        blacklight_config.add_show_tools_partial(:endnote_archives, if: :render_archives_endnote_action?, modal: false, path: :single_archives_archives_path, define_method: false)
        blacklight_config.add_show_tools_partial(:ris_archives, if: :render_archives_ris_action?, modal: false, path: :single_archives_archives_path, define_method: false)
    end

    #grabs a bunch of reworks documents

    def archives
        @response, @documents = search_service.fetch(Array(params[:id]))# unless !params[:id].to_s.include?("repositories")
        respond_to do |format|
            format.refworks_archives { render :layout => false }
        end
    end

    def endnote_archives
        @response, @documents = search_service.fetch(Array(params[:id]))# unless !params[:id].to_s.include?("repositories")
        respond_to do |format|
            format.endnote_archives { render :layout => false }
        end
    end

    def ris_archives
        @response, @documents = search_service.fetch(Array(params[:id]))# unless !params[:id].to_s.include?("repositories")
        respond_to do |format|
            format.ris_archives { render :layout => false }
        end
    end



    private


    def render_archives_action? config, options = {}
        options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:refworks_archives )
    end

    def render_archives_endnote_action? config, options = {}
        options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:endnote_archives )
    end


    def render_archives_ris_control? config, options = {}
        options[:document] && options[:document].respond_to?(:export_formats) && options[:document].export_formats.keys.include?(:ris_archives )
    end

  end
end
