@completed
Feature: Validation: validates_length_of
  The validates_length_of validation specifies that the length of
  an attribute must meet certain requirements
  
  Background:
    Given the following document definition:
      """
      class User < Recliner::Document
        property :login, String
        validates_length_of :login, :minimum => 4
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "User"
    And I set its login to "validlogin"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "User"
    And I set its login to "abc"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
