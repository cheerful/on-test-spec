require 'test/spec'

require 'active_support'
require 'active_support/test_case'

require 'active_record'
require 'active_record/test_case'

require 'action_controller'
require 'action_controller/test_case'

require 'action_view'
require 'action_view/test_case'

module Test
  module Spec
    module Rails
    end
  end
end

require 'test/spec/rails/test_spec_ext'
require 'test/spec/rails/spec_responder'
require 'test/spec/rails/expectations'

require 'test/spec/rails/request_helpers'
require 'test/spec/rails/response_helpers'
require 'test/spec/rails/controller_helpers'


module Test::Spec::Rails
  # Returns the test class for a definition line in a spec.
  #
  #   extract_test_case_args(["A", User, "concerning validation"]) # => ActiveRecord::TestCase
  def self.extract_test_case_args(args)
    class_to_test = args.find { |a| a.is_a?(Module) }
    superclass    = test_case_for_class(class_to_test)

    args.delete(class_to_test) if superclass == class_to_test
    name          = args.map { |a| a.to_s }.join(' ')

    [name, class_to_test, superclass]
  end

  # Returns the test class for a class
  #
  #   extract_test_case_for_class(UsersController) # => ActionController::TestCase
  def self.test_case_for_class(klass)
    if klass
      if klass.ancestors.include?(ActiveRecord::Base)
        ActiveRecord::TestCase
      elsif klass.ancestors.include?(ActionController::Base)
        ActionController::TestCase
      elsif klass.ancestors.include?(ActiveSupport::TestCase)
        klass
      elsif !klass.is_a?(Class) && klass.to_s.ends_with?('Helper')
        ActionView::TestCase
      end
    end || ActiveSupport::TestCase
  end
end

module Kernel
  alias :context_before_on_test_spec :context
  alias :xcontext_before_on_test_spec :xcontext
  
  # Creates a new test case.
  #
  # The description of the test case, can consist from strings and/or the class
  # that's to be tested.
  #
  # If the class inherits from ActiveRecord::Base, ActiveRecord::TestCase will
  # be used as the test case superclass. In the case of a class which inherits
  # from ActionController::Base, ActionController::TestCase will be used. And
  # when given a module which name ends with “Helper”, ActionView::TestCase
  # will be used. In the latter two cases, the test case will be setup for the
  # class that's to be tested.
  #
  # If the class inherits from ActiveSupport::TestCase, it will be used as both
  # the class to be tested and as the test case superclass (this is how test-spec
  # works without on-test-spec).
  #
  # In all other cases the test case superclass will be ActiveSupport::TestCase.
  #
  # Examples:
  #
  #   describe Member do # "Member"
  #     ...
  #   end
  #
  #   describe 'On a', MembersController do # "On a MembersController"
  #     ...
  #   end
  #
  #   describe 'The', MembersHelper, ', concerning dates' do # "The MembersHelper, concerning dates"
  #     ...
  #   end
  #
  #   describe 'Creating an account and posting a comment', ActiveSupport::IntegrationTest do # Creating an account and posting a comment ActionController::IntegrationTest
  #     ...
  #   end
  def context(*args, &block)
    name, class_to_test, superclass = Test::Spec::Rails.extract_test_case_args(args)
    spec = context_before_on_test_spec(name, superclass) { tests class_to_test if respond_to?(:tests) }
    spec.testcase.class_eval(&block)
    spec
  end

  def xcontext(*args, &block)
    name, _, superclass = Test::Spec::Rails.extract_test_case_args(args)
    xcontext_before_on_test_spec(name, superclass, &block)
  end

  private :context, :xcontext
  
  alias :describe :context
  alias :xdescribe :xcontext
end
