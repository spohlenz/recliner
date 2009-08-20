Feature: Validation: validates_presence_of
  The validates_presence_of validation requires that a given attribute is provided (not blank)
  
  Background:
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title
      end
      """
  
  Scenario: validation requirements met
    When I create an instance of "Article"
    And I set its title to "Article title"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements failing
    When I create an instance of "Article"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
    