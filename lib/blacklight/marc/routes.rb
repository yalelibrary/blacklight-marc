# -*- encoding : utf-8 -*-
module Blacklight::Marc
  class Routes

    def initialize(router, options)
      @router = router
      @options = options
    end

    def draw
      route_sets.each do |r|
        self.send(r)
      end
    end

    protected

    def add_routes &blk
      @router.instance_exec(@options, &blk)
    end

    def route_sets
      (@options[:only] || default_route_sets) - (@options[:except] || [])
    end

    def default_route_sets
      [:catalog]
    end

    module RouteSets
      def catalog
        add_routes do |options|
          # Catalog stuff.
          get 'catalog/:id/librarian_view', :to => "catalog#librarian_view", :as => "librarian_view_solr_document"
          get "catalog/endnote", :as => "endnote_solr_document"
	        get "catalog/refworks", :as => "refworks_solr_document"
          get "catalog/archives", :as => "archives_solr_document"
          get "catalog/ris_archives", :as => "archives_ris_solr_document"
          get "catalog/endnote_archives", :as => "archives_endnote_solr_document"
          get "catalog/dcs", :as => "dcs_solr_document"
          get "catalog/ris_dcs", :as => "dcs_ris_solr_document"
          get "catalog/endnote_dcs", :as => "dcs_endnote_solr_document"
        end
      end
      def archives
        add_routes do |options|
          get "archives/archives", :as => "archives_solr_document"
        end
      end

   end
   
  include RouteSets
  end
end
