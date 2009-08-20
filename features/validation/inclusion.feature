@completed
Feature: Validation: validates_inclusion_of
  The validates_inclusion_of validation specifies that an
  attribute must be one of a predefined set
  
  Background:
    Given the following document definition:
      """
      class User < Recliner::Document
        property :gender, String
        validates_inclusion_of :gender, :in => [ 'Male', 'Female' ]
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "User"
    And I set its gender to "Male"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "User"
    And I set its gender to "Other"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
