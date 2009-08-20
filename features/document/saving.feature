@completed
Feature: Saving documents
  Recliner offers two ways of saving documents:
    save  => does not raise exception if document cannot be saved
    save! => raises exception if document cannot be saved
  
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
  
  Scenario: Saving a new document
    Given I have an unsaved instance of "Article"
    When I set its id to "article-1"
    And I set its title to "Article title"
    And I save the instance
    Then the instance should not be a new record
    And the instance should have a revision matching "^1-"
    And there should be a document at "http://localhost:5984/recliner-features/article-1" with:
      """
      {
        '_id'   => 'article-1',
        'class' => 'Article',
        'title' => 'Article title'
      }
      """

  Scenario: Saving a new document with save!
    Given I have an unsaved instance of "Article"
    And I set its id to "article-1"
    And I set its title to "Article title"
    And I save! the instance
    Then the instance should not be a new record
    And the instance should have a revision matching "^1-"
    And there should be a document at "http://localhost:5984/recliner-features/article-1" with:
      """
      {
        '_id'   => 'article-1',
        'class' => 'Article',
        'title' => 'Article title'
      }
      """

  Scenario: Saving an existing document
    Given I have a saved instance of "Article" with id "article-1"
    When I save the instance
    Then the instance should have a revision matching "^2-"
  
  Scenario: Saving an existing document with save!
    Given I have a saved instance of "Article" with id "article-1"
    When I save! the instance
    Then the instance should have a revision matching "^2-"
  
  Scenario: Saving an existing document with an outdated revision
    Given I have a saved instance of "Article" with:
      | id    | article-1     |
      | title | Article title |
    And I set its revision to "4-123456"
    And I set its title to "New title"
    When I save the instance
    Then there should be a document at "http://localhost:5984/recliner-features/article-1" with:
      """
      {
        'title' => 'Article title'
      }
      """
  
  Scenario: Saving an existing document with save! with an outdated revision
    Given I have a saved instance of "Article" with:
      | id    | article-1     |
      | title | Article title |
    And I set its revision to "4-123456"
    And I set its title to "New title"
    When I save! the instance
    Then a "Recliner::StaleRevisionError" exception should be raised
    And there should be a document at "http://localhost:5984/recliner-features/article-1" with:
      """
      {
        'title' => 'Article title'
      }
      """
      