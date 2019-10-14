require 'spec_helper'

describe BlacklightMarcHelper do
  let(:one) { SolrDocument.new }
  let(:two) { SolrDocument.new }
  describe "render_refworks_texts" do
    before do
      allow(one).to receive_messages(export_as_refworks_marc_txt: 'one')
      allow(two).to receive_messages(export_as_refworks_marc_txt: 'two')
    end
    it "should render_refworks_texts" do
      expect(helper.render_refworks_texts([one, two])).to eq "one\ntwo\n"

    end
  end

  describe "render_endnote_texts" do
    before do
      allow(one).to receive_messages(export_as_endnote: 'one')
      allow(two).to receive_messages(export_as_endnote: 'two')
    end
    it "should render_endnote_texts" do
      expect(helper.render_endnote_texts([one, two])).to eq "one\ntwo\n"
    end
  end
  require 'spec_helper'

  describe '#document_action_path' do
    before do
      allow(helper).to receive_messages(controller_name: 'catalog')
    end

    let(:document_action_config) { Blacklight::Configuration::ToolConfig.new(tool_config) }
    let(:document) { SolrDocument.new(id: '123') }

    subject { helper.document_action_path(document_action_config, id: document) }

    context "for endnote" do
      let(:tool_config) { { if: :render_refworks_action?, partial: "document_action",
        name: :endnote, key: :endnote, path: :single_endnote_catalog_path } }

      it { is_expected.to eq '/catalog/123.endnote' }
    end
  end

  describe "#refworks_export_url" do
    it "should use https" do
      expect(helper.refworks_export_url(:vendor=>"test", :filter => 'filter_test', :url => 'http://library.yale.edu')).to \
        match /^https:\/\//
    end
    it "should return correct url" do
      expect(helper.refworks_export_url(:vendor=>"test", :filter => 'filter_test', :url => 'http://library.yale.edu')).to \
        eq 'https://www.refworks.com/express/expressimport.asp?vendor=test&filter=filter_test&encoding=65001&url=http%3A%2F%2Flibrary.yale.edu'
      expect(helper.refworks_export_url(:vendor=>"test vendor space", :filter => 'filter_test;filter2', :url => 'https://library.yale.edu')).to \
        eq 'https://www.refworks.com/express/expressimport.asp?vendor=test+vendor+space&filter=filter_test%3Bfilter2&encoding=65001&url=https%3A%2F%2Flibrary.yale.edu'
    end
    it 'should use application_name when no vendor is provided' do
      allow(helper).to receive_messages(application_name: 'AppName')
      expect(helper.refworks_export_url(:filter => 'filter_test;filter2', :url => 'https://library.yale.edu')).to \
        eq 'https://www.refworks.com/express/expressimport.asp?vendor=AppName&filter=filter_test%3Bfilter2&encoding=65001&url=https%3A%2F%2Flibrary.yale.edu'
    end
  end

end
