@completed
Feature: Validation: validates_confirmation_of
  The validates_confirmation_of validation specifies that
  a given attribute must be provided twice as confirmation
  
  Background:
    Given the following document definition:
      """
      class User < Recliner::Document
        property :email, String
        validates_confirmation_of :email
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "User"
    And I set its email to "me@example.com"
    And I set its email_confirmation to "me@example.com"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "User"
    And I set its email to "me@example.com"
    And I set its email_confirmation to "me@asmallbutsignificanttypo.com"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
