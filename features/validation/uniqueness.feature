@completed
Feature: Validation: validates_uniqueness_of
  The validates_uniqueness_of validation specifies that
  a given attribute must only exist once in the database.
  
  This validation has an inherent race condition that renders
  it unreliable, but should be good enough for most purposes.
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-features"
    And the database "http://localhost:5984/recliner-features" exists
  
  Scenario: validation requirements met
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_uniqueness_of :title
      end
      """
    When I create an instance of "Article"
    And I set its title to "Article title"
    Then the instance should be valid
    And the instance should save
    
    When I create an instance of "Article"
    And I set its title to "Different article title"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements not met
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        validates_uniqueness_of :title
      end
      """
    And I have a saved instance of "Article" with:
      | title | Article title |
    When I create an instance of "Article"
    And I set its title to "Article title"
    Then the instance should not be valid
    And its errors should include "Title has already been taken"
  
  Scenario: validation requirements met (with scope)
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        property :author, String
        validates_uniqueness_of :title, :scope => :author
      end
      """
    When I create an instance of "Article"
    And I set its title to "Article title"
    And I set its author to "Fred"
    Then the instance should be valid
    And the instance should save

    When I create an instance of "Article"
    And I set its title to "Article title"
    And I set its author to "Joe"
    Then the instance should be valid
    And the instance should save
  
  Scenario: validation requirements not met (with scope)
    Given the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        property :author, String
        validates_uniqueness_of :title, :scope => :author
      end
      """
    And I have a saved instance of "Article" with:
      | title  | Article title |
      | author | Fred          |
    When I create an instance of "Article"
    And I set its title to "Article title"
    And I set its author to "Fred"
    Then the instance should not be valid
    And its errors should include "Title has already been taken"
    