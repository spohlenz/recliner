@completed
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
      class User < Recliner::Document
        property :name, String
      end
      """

  Scenario: Loading a document
    Given a document exists at "http://localhost:5984/recliner-test/existing-user" with:
      """
      {
        :class => 'User',
        :name => 'Test User'
      }
      """
    When I load the "User" instance with id "existing-user"
    Then the instance should not be a new record
    And the instance should have id "existing-user"
    And the instance should have name "Test User"

  Scenario: Loading a missing document
    Given no document exists at "http://localhost:5984/recliner-test/missing-user"
    When I load the "User" instance with id "missing-user"
    Then the instance should be nil

  Scenario: Loading a document with load!
    Given a document exists at "http://localhost:5984/recliner-test/existing-user" with:
      """
      {
        :class => 'User',
        :name => 'Test User'
      }
      """
    When I load! the "User" instance with id "existing-user"
    Then the instance should not be a new record
    And the instance should have id "existing-user"
    And the instance should have name "Test User"

  Scenario: Loading a missing document with load!
    Given no document exists at "http://localhost:5984/recliner-test/missing-user"
    When I load! the "User" instance with id "missing-user"
    Then a "Recliner::DocumentNotFound" exception should be raised

  Scenario: Loading multiple documents
    Given a "User" document exists at "http://localhost:5984/recliner-test/user-1"
    And a "User" document exists at "http://localhost:5984/recliner-test/user-2"
    When I load the "User" instances with ids "user-1, user-2"
    Then instance 1 should not be a new record
    And instance 1 should have id "user-1"
    And instance 2 should not be a new record
    And instance 2 should have id "user-2"
  
  Scenario: Loading multiple documents (some missing)
    Given a "User" document exists at "http://localhost:5984/recliner-test/user-1"
    And no document exists at "http://localhost:5984/recliner-test/missing-user"
    When I load the "User" instances with ids "user-1, missing-user"
    Then instance 1 should not be a new record
    And instance 1 should have id "user-1"
    And instance 2 should be nil
  
  Scenario: Loading multiple documents with load!
    Given a "User" document exists at "http://localhost:5984/recliner-test/user-1"
    And a "User" document exists at "http://localhost:5984/recliner-test/user-2"
    When I load! the "User" instances with ids "user-1, user-2"
    Then instance 1 should not be a new record
    And instance 1 should have id "user-1"
    And instance 2 should not be a new record
    And instance 2 should have id "user-2"
  
  Scenario: Loading multiple documents with load! (some missing)
    Given a "User" document exists at "http://localhost:5984/recliner-test/user-1"
    And no document exists at "http://localhost:5984/recliner-test/missing-document"
    When I load! the "User" instances with ids "user-1, missing-document"
    Then a "Recliner::DocumentNotFound" exception should be raised
  