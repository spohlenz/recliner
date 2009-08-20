@completed
Feature: Deleting documents
  Deleting a Recliner::Document removes it from the database
  It does not run any callbacks
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-features"
    And the database "http://localhost:5984/recliner-features" exists
    And the following document definition:
      """
      class Article < Recliner::Document
      end
      """
      
  Scenario: Delete a new document
    When I create an instance of "Article"
    And I delete the instance
    Then the instance should be read only
  
  Scenario: Deleting an existing document
    Given I have a saved instance of "Article" with id "article-1"
    When I delete the instance
    Then the instance should be read only
    And there should be no document at "http://localhost:5984/recliner-features/article-1"
    
  Scenario: Deleting a document with an out-of-date revision
    Given I have a saved instance of "Article" with id "article-1"
    And the "Article" with id "article-1" is updated elsewhere
    When I delete the instance
    Then a "Recliner::StaleRevisionError" exception should be raised
    
  Scenario: Deleting an already deleted document
    Given I have a saved instance of "Article" with id "article-1"
    And no document exists at "http://localhost:5984/recliner-features/article-1"
    When I delete the instance
    Then no exception should be raised
    And the instance should be read only
    And there should be no document at "http://localhost:5984/recliner-features/article-1"
    