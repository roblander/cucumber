require 'cucumber/core/events'

module Cucumber
  module Events

    # Event fired after each step definition has been registered
    class StepDefinitionRegistered < Core::Event.new(:step_definition)


      #_The step definition that was just registered.
      #
      # @return [Cucumber::Core::Test::Case]
      attr_reader :step_definition

      #_@private
      def initialize(step_definition)
        @step_definition = step_definition
      end

    end

  end
end
