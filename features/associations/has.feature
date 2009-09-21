Feature: has association
  
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-features"
    And the database "http://localhost:5984/recliner-features" exists
    And the following document definitions:
      """
      class User < Recliner::Document
      end
      
      class Article < Recliner::Document
        has :author
      end
      """
  
  Scenario: assigning instance to association
    Given I have a saved instance of "User" with id "user-1"
    And I have a saved instance of "Article" with id "article-1"
    When I set its author to the "User" with id "user-1"
    Then its "author" should be the "User" with id "user-1"
  
  Scenario: assigning id to association
    Given I have a saved instance of "User" with id "user-1"
    And I have a saved instance of "Article" with id "article-1"
    When I set its author_id to "user-1"
    Then its "author" should be the "User" with id "user-1"
  
  Scenario: loading association
    Given I have a saved instance of "User" with id "user-1"
    And I have a saved instance of "Article" with attributes:
      | id        | article-1 |
      | author_id | user-1    |
    When I load the "Article" instance with id "article-1"
    Then its "author" should be the "User" with id "user-1"
    