@completed
Feature: Validation: validates_acceptance_of
  The validates_acceptance_of validation specifies that a virtual
  attribute must be set to "1" (i.e. from a HTML checkbox)
  
  Scenario: validation requirements met
    Given the following document definition:
      """
      class User < Recliner::Document
        validates_acceptance_of :terms_and_conditions
      end
      """
      
    When I create an instance of "User"
    And I set its terms_and_conditions to "1"
    Then the instance should be valid
  
  Scenario: validation requirements met (nil allowed)
    Given the following document definition:
      """
      class User < Recliner::Document
        validates_acceptance_of :terms_and_conditions, :allow_nil => true
      end
      """
      
    When I create an instance of "User"
    Then the instance should be valid
  
  Scenario: validation requirements failing
    Given the following document definition:
      """
      
      class User < Recliner::Document
        validates_acceptance_of :terms_and_conditions
      end
      """
    When I create an instance of "User"
    And I set its terms_and_conditions to "0"
    Then the instance should not be valid
    And its errors should include "Terms and conditions must be accepted"
    