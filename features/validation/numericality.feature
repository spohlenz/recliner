@completed
Feature: Validation: validates_numericality_of
  The validates_numericality_of validation specifies that
  a numerical field must meet certain constraints
  
  Background:
    Given the following document definition:
      """
      class Booking < Recliner::Document
        property :number_of_people, Integer
        validates_numericality_of :number_of_people, :even => true
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "Booking"
    And I set its number_of_people to "8"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "Booking"
    And I set its number_of_people to "5"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
