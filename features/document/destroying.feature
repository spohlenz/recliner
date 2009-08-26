@completed
Feature: Destroying documents
  Destroying a Recliner::Document removes it from the database
  It also runs any before/after_destroy callbacks that are defined
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-features"
    And the database "http://localhost:5984/recliner-features" exists
    And the following document definition:
      """
      class Article < Recliner::Document
      end
      """
      
  Scenario: Destroy a new document
    When I create an instance of "Article"
    And I destroy the instance
    Then the instance should be read only
  
  Scenario: Destroying an existing document
    Given I have a saved instance of "Article" with id "article-1"
    When I destroy the instance
    Then the instance should be read only
    And there should be no document at "http://localhost:5984/recliner-features/article-1"
    
  Scenario: Destroying a document with an out-of-date revision
    Given I have a saved instance of "Article" with id "article-1"
    And the "Article" with id "article-1" is updated elsewhere
    When I destroy the instance
    Then a "Recliner::StaleRevisionError" exception should be raised
    
  Scenario: Destroying an already deleted document
    Given I have a saved instance of "Article" with id "article-1"
    But no document exists at "http://localhost:5984/recliner-features/article-1"
    When I destroy the instance
    Then no exception should be raised
    And the instance should be read only
    And there should be no document at "http://localhost:5984/recliner-features/article-1"
  