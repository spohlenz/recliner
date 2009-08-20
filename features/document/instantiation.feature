@completed
Feature: New document instantiation
  Recliner::Document models can be instantiated with or without attributes
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-features"
    And the database "http://localhost:5984/recliner-features" exists
    And the following document definition:
      """
      class Article < Recliner::Document
        property :title, String
        property :content, String
      end
      """
  
  Scenario: New document instance
    When I create an instance of "Article"
    Then the instance should be a new record
    And the instance should autogenerate an id
    And the instance should not have a revision
  
  Scenario: New document instance with attributes
    When I create an instance of "Article" with:
      | id      | article-id             |
      | title   | Article Title          |
      | content | Content for article... |
    Then the instance should be a new record
    And the instance should have id "article-id"
    And the instance should have title "Article Title"
    And the instance should have content "Content for article..."
    And the instance should not have a revision
    