@completed
Feature: Validation: validates_exclusion_of
  The validates_inclusion_of validation specifies that an
  attribute must not be one of a predefined set
  
  Background:
    Given the following document definition:
      """
      class User < Recliner::Document
        property :age, Integer
        validates_exclusion_of :age, :in => 13..18
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "User"
    And I set its age to "42"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "User"
    And I set its age to "16"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
