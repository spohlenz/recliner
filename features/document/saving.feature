Feature: Saving documents
  Recliner offers two ways of saving documents:
    save  => does not raise exception if document cannot be saved
    save! => raises exception if document cannot be saved
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-test"
    And the database "http://localhost:5984/recliner-test" exists
    And the following document definition:
      """
      class BasicDocument < Recliner::Document
      end
      """
  
  Scenario: Saving a new document
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

  Scenario: Saving a new document with save!
    When I create an instance of "BasicDocument"
    And I set its id to "basic-document-1"
    And I save! the instance
    Then the instance should not be a new record
    And the instance should have a revision matching "^1-"
    And there should be a document at "http://localhost:5984/recliner-test/basic-document-1" with:
      """
      {
        '_id'   => 'basic-document-1',
        'class' => 'BasicDocument'
      }
      """