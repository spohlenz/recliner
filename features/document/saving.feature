Feature: Saving documents
  So that I can persist my data
  I want to save my models to a CouchDB database
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-test"
    And the database "http://localhost:5984/recliner-test" exists
    And the following document definition:
      """
      class BasicDocument < Recliner::Document
      end
      """
  
  Scenario: Saving a document
    When I create an instance of "BasicDocument"
    And I set its id to "basic-document-1"
    And I save the instance
    Then the instance should not be a new record
    And the instance should have a revision matching "^1-"
    And there should be a document at "http://localhost:5984/recliner-test/basic-document-1" with:
      """
      {
        '_id'   => 'basic-document-1',
        'class' => 'BasicDocument'
      }
      """
