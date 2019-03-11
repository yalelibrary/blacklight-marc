module ControllerLevelHelpers
  module ControllerViewHelpers
    include Blacklight::Facet

    def blacklight_config
      controller.blacklight_config
    end

    def search_state
      @search_state ||= Blacklight::SearchState.new(params, blacklight_config)
    end

    def blacklight_configuration_context
      @blacklight_configuration_context ||= Blacklight::Configuration::Context.new(controller)
    end
  end

  def initialize_controller_helpers(helper)
    helper.extend ControllerViewHelpers
  end
end