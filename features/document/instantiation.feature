@completed
Feature: New document instantiation
  Recliner::Document models can be instantiated with or without attributes
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-test"
    And the database "http://localhost:5984/recliner-test" exists
    And the following document definition:
      """
      class BasicDocument < Recliner::Document
      end
      """
  
  Scenario: New document instance
    When I create an instance of "BasicDocument"
    Then the instance should be a new record
    And the instance should autogenerate an id
    And the instance should not have a revision
  
  Scenario: New document instance with attributes
    When I create an instance of "BasicDocument" with:
      | id | custom-id |
    Then the instance should be a new record
    And the instance should have id "custom-id"
    And the instance should not have a revision
    