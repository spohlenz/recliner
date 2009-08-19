@pending
Feature: Document loading
  Recliner offers two ways of loading documents:
    load  => does not raise exceptions for missing documents
    load! => does raise exceptions for missing documents
  
  Either individual or multiple documents can be loaded at once
  
  Background:
    Given the default Recliner::Document database is set to "http://localhost:5984/recliner-test"
    And the database "http://localhost:5984/recliner-test" exists
    And the following document definition:
      """
      class BasicDocument < Recliner::Document
      end
      """

  Scenario: Loading a document
    Given a document exists at "http://localhost:5984/recliner-test/document-exists" with:
      """
      { :class => 'BasicDocument' }
      """
    When I load the "BasicDocument" instance with id "document-exists"
    Then the instance should not be a new record
    And the instance should have id "document-exists"

  Scenario: Loading a missing document
    Given no document exists at "http://localhost:5984/recliner-test/missing-document"
    When I load the "BasicDocument" instance with id "missing-document"
    Then the instance should be nil

  Scenario: Loading a document with load!
    Given a document exists at "http://localhost:5984/recliner-test/document-exists" with:
      """
      { :class => 'BasicDocument' }
      """
    When I load! the "BasicDocument" instance with id "document-exists"
    Then the instance should not be a new record
    And the instance should have id "document-exists"

  Scenario: Loading a missing document with load!
    Given no document exists at "http://localhost:5984/recliner-test/missing-document"
    When I load! the "BasicDocument" instance with id "missing-document"
    Then a "Recliner::DocumentNotFound" exception should be raised

  Scenario: Loading multiple documents
    Given a "BasicDocument" document exists at "http://localhost:5984/recliner-test/document-1"
    And a "BasicDocument" document exists at "http://localhost:5984/recliner-test/document-2"
    When I load the "BasicDocument" instances with ids "document-1, document-2"
    Then instance 1 should not be a new record
    And instance 1 should have id "document-1"
    And instance 2 should not be a new record
    And instance 2 should have id "document-2"
  
  Scenario: Loading multiple documents (some missing)
    Given a "BasicDocument" document exists at "http://localhost:5984/recliner-test/document-1"
    And no document exists at "http://localhost:5984/recliner-test/missing-document"
    When I load the "BasicDocument" instances with ids "document-1, missing-document"
    Then instance 1 should not be a new record
    And instance 1 should have id "document-1"
    And instance 2 should be nil
  
  Scenario: Loading multiple documents with load!
    Given a "BasicDocument" document exists at "http://localhost:5984/recliner-test/document-1"
    And a "BasicDocument" document exists at "http://localhost:5984/recliner-test/document-2"
    When I load! the "BasicDocument" instances with ids "document-1, document-2"
    Then instance 1 should not be a new record
    And instance 1 should have id "document-1"
    And instance 2 should not be a new record
    And instance 2 should have id "document-2"
  
  Scenario: Loading multiple documents with load! (some missing)
    Given a "BasicDocument" document exists at "http://localhost:5984/recliner-test/document-1"
    And no document exists at "http://localhost:5984/recliner-test/missing-document"
    When I load! the "BasicDocument" instances with ids "document-1, missing-document"
    Then a "Recliner::DocumentNotFound" exception should be raised
  