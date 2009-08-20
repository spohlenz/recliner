@completed
Feature: Validation: validates_format_of
  The validates_format_of validation specifies that a given
  attribute must match a certain regular expression
  
  Background:
    Given the following document definition:
      """
      class Person < Recliner::Document
        property :dna, String
        validates_format_of :dna, :with => /^[ACTG]+$/
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "Person"
    And I set its dna to "ACGACACTGATGTCAT"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "Person"
    And I set its dna to "ABCDEFGHIJKLMNOP"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
