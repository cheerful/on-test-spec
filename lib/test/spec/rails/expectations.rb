module Test
  module Spec
    module Rails
      module ShouldExpectations
        # Test that we were redirected somewhere:
        #   should.redirect
        #
        # Test that we were redirected to a specific url:
        #   should.redirect :controller => 'foo', :action => 'bar'
        # or:
        #   should.be.redirected foo_url(@foo)
        # or:
        #   should.redirect_to :controller => 'foo', :action => 'bar', :secure => true
        # or:
        #   should.be.redirected foo_url, :secure => true
        def redirect(*args)
          if args.empty?
            assert_response @object.response.redirected_to, :redirect
          else
            options = args.extract_options!
            if secure = options.delete(:secure)
              unless secure == true or secure == false
                raise ArgumentError, ":secure option should be a boolean"
              end
            end
            
            @object.instance_eval { assert_redirected_to *args }
            if secure == true
              assert @object.response.redirected_to.starts_with?('https:')
            elsif secure == false
              assert @object.response.redirected_to.starts_with?('http:')
            end
          end
        end
        alias :redirect_to :redirect
        
        # Test that the object is valid
        def validate
          assert_valid @object
        end
      end
      module ShouldNotExpectations
        
        # Test that an object is not valid
        def validate
          assert !@object.valid?
        end
      end
    end
  end
end

Test::Spec::Should.send(:include, Test::Spec::Rails::ShouldExpectations)
Test::Spec::ShouldNot.send(:include, Test::Spec::Rails::ShouldNotExpectations)