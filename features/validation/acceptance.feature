@completed
Feature: Validation: validates_acceptance_of
  The validates_acceptance_of validation specifies that a virtual
  attribute must be set to "1" (i.e. from a HTML checkbox)
  
  Background:
    Given the following document definition:
      """
      class User < Recliner::Document
        validates_acceptance_of :terms_and_conditions
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "User"
    And I set its terms_and_conditions to "1"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "User"
    And I set its terms_and_conditions to "0"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
