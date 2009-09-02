@completed
Feature: Basic map views
  CouchDB views can be written at a low-level using map/reduce
  javascript functions when the view is defined.
  
  The function signature (e.g. function(doc) {}) is optional.
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-features"
    And the database "http://localhost:5984/recliner-features" exists
    And the following document definition:
      """
      class User < Recliner::Document
        property :name, String
        
        view :by_name, :map => "if (doc.class == 'User') { emit(doc.name, doc); }"
      end
      """
    And there are 5 users with names:
      | Juliet Hills      |
      | Haskell Rohan     |
      | Christophe Howell |
      | Kacie Fadel       |
      | Celine Little     |
  
  Scenario: fetch all
    When I invoke the "User" view "by_name" with no arguments
    Then the result should be an Array of 5 User instances
    And the user names should equal:
      | Celine Little     |
      | Christophe Howell |
      | Haskell Rohan     |
      | Juliet Hills      |
      | Kacie Fadel       |
  
  Scenario: fetch all in descending order
    When I invoke the "User" view "by_name" with options:
      | descending | true |
    Then the result should be an Array of 5 User instances
    And the user names should equal:
      | Kacie Fadel       |
      | Juliet Hills      |
      | Haskell Rohan     |
      | Christophe Howell |
      | Celine Little     |

  Scenario: fetch individual
    When I invoke the "User" view "by_name" with key "Juliet Hills"
    Then the result should be an Array of 1 User instance
    And the user names should equal:
      | Juliet Hills |
  
  Scenario: fetch multiple
    When I invoke the "User" view "by_name" with keys "Haskell Rohan, Celine Little"
    Then the result should be an Array of 2 User instances
    And the user names should equal:
      | Haskell Rohan |
      | Celine Little |
  
  Scenario: fetch missing
    When I invoke the "User" view "by_name" with "Brandt Gibson"
    Then the result should be empty
    