Feature: RESTful CouchDB access
  As a developer
  I want to bypass the Recliner::Document abstraction
  So that I can implement low-level functionality
  
  Background:
    Given the database "http://localhost:5984/recliner-test" exists
  
  Scenario: GET an existing document
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    When I GET "http://localhost:5984/recliner-test/test-resource"
    Then the result should have "_id" => "test-resource"
  
  Scenario: GET a non-existent document
    Given no document exists at "http://localhost:5984/recliner-test/test-resource"
    When I GET "http://localhost:5984/recliner-test/test-resource"
    Then a "Recliner::DocumentNotFound" exception should be raised
  
  Scenario: GET a document with parameters
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    And the document at "http://localhost:5984/recliner-test/test-resource" has 3 previous revisions
    When I GET "http://localhost:5984/recliner-test/test-resource" with:
      | revs | true |
    Then the result should have key "_revisions"
    
  Scenario: PUT to a new document
    Given no document exists at "http://localhost:5984/recliner-test/test-resource"
    When I PUT to "http://localhost:5984/recliner-test/test-resource"
    Then the result should have "id" => "test-resource"
    And the result should have "rev" matching "^1-"
    When I GET "http://localhost:5984/recliner-test/test-resource"
    Then the result should have "_id" => "test-resource"
  
  Scenario: PUT to an existing document
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    And I know the revision of the document at "http://localhost:5984/recliner-test/test-resource"
    When I PUT to "http://localhost:5984/recliner-test/test-resource" with the revision
    Then the result should have "rev" matching "^2-"
  
  Scenario: PUT to an existing document with an invalid revision
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    When I PUT to "http://localhost:5984/recliner-test/test-resource"
    Then a "Recliner::StaleRevisionError" exception should be raised
  
  Scenario: POST to create a new document
    When I POST to "http://localhost:5984/recliner-test"
    Then the result should have key "id"
    And the result should have "rev" matching "^1-"
  
  Scenario: POST to a view
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    And a map view named "all" exists at "http://localhost:5984/recliner-test/_design/test":
      """
      function(doc) { emit(doc._id, null); }
      """
    When I POST to "http://localhost:5984/recliner-test/_design/test/_view/all" with:
      """
      { :keys => [ 'test-resource' ] }
      """
    Then the result should have "total_rows" => "1"
  
  Scenario: POST to a missing view
    Given no document exists at "http://localhost:5984/recliner-test/_design/test"
    When I POST to "http://localhost:5984/recliner-test/_design/test/_view/all"
    Then a "Recliner::DocumentNotFound" exception should be raised
  
  Scenario: DELETE an existing document
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    And I know the revision of the document at "http://localhost:5984/recliner-test/test-resource"
    When I DELETE "http://localhost:5984/recliner-test/test-resource" with the revision
    Then there should be no document at "http://localhost:5984/recliner-test/test-resource"
  
  Scenario: DELETE a non-existent document
    Given no document exists at "http://localhost:5984/recliner-test/test-resource"
    When I DELETE "http://localhost:5984/recliner-test/test-resource"
    Then a "Recliner::DocumentNotFound" exception should be raised
  
  Scenario: DELETE an existing document with an invalid revision
    Given a document exists at "http://localhost:5984/recliner-test/test-resource"
    When I DELETE "http://localhost:5984/recliner-test/test-resource"
    Then a "Recliner::StaleRevisionError" exception should be raised
    