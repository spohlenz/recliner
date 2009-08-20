Feature: Document validations
  As a developer
  I want to define validations
  So that invalid data cannot be saved
  
  Scenario: validates_presence_of (requirements met)
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title
      end
      """
    When I create an instance of "Article"
    And I set its title to "Article title"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validates_presence_of (requirements failing)
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_presence_of :title
      end
      """
    When I create an instance of "Article"
    Then the instance should not be valid
    And the instance should not save
    
    When I save! the instance
    Then a "Recliner::DocumentInvalid" exception should be raised
  
  @pending
  Scenario: validates_uniqueness_of (requirements met)
  
  @pending
  Scenario: validates_uniqueness_of (requirements failing)
  