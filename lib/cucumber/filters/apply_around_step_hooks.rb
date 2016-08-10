require 'cucumber/core/filter'

module Cucumber
  module Filters
    class ApplyAroundStepHooks < Core::Filter.new(:hooks)
      def test_case(test_case)
        around_step_hooks = hooks.find_around_step_hooks(test_case)
        test_case.with_around_step_hooks(around_step_hooks).describe_to(receiver)
      end
    end
  end
end
