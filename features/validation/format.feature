@completed
Feature: Validation: validates_format_of
  The validates_format_of validation specifies that a given
  attribute must match a certain regular expression
  
  Scenario Outline: validation requirements met (using :with)
    Given the following document definition:
      """
      class Sample < Recliner::Document
        property :dna, String
        validates_format_of :dna, :with => /^[ACTG]+$/
      end
      """
      
    When I create an instance of "Sample"
    And I set its dna to "<dna>"
    Then the instance should be valid
    
    Examples:
      | dna              |
      | A                |
      | ACGT             |
      | ACGACACTGATGTCAT |
  
  Scenario Outline: validation requirements failing (using :with)
    Given the following document definition:
      """
      class Sample < Recliner::Document
        property :dna, String
        validates_format_of :dna, :with => /^[ACTG]+$/
      end
      """
      
    When I create an instance of "Sample"
    And I set its dna to "<dna>"
    Then the instance should not be valid
    And its errors should include "Dna is invalid"
    
    Examples:
      | dna              |
      |                  |
      | ABCDEFGHIJKLMNOP |
      | ACTG1            |
  
  Scenario: validation requirements met (blank allowed)
    Given the following document definition:
      """
      class Sample < Recliner::Document
        property :dna, String
        validates_format_of :dna, :with => /^[ACTG]+$/, :allow_blank => true
      end
      """

    When I create an instance of "Sample"
    And I set its dna to ""
    Then the instance should be valid

  Scenario: validation requirements met (nil allowed)
    Given the following document definition:
      """
      class Sample < Recliner::Document
        property :dna, String
        validates_format_of :dna, :with => /^[ACTG]+$/, :allow_nil => true
      end
      """

    When I create an instance of "Sample"
    Then the instance should be valid
  
  Scenario Outline: validation requirements met (using :without)
    Given the following document definition:
      """
      class User < Recliner::Document
        property :login, String
        validates_format_of :login, :without => /\d /
      end
      """
      
    When I create an instance of "User"
    And I set its login to "<login>"
    Then the instance should be valid

    Examples:
      | login      |
      | abc        |
      | test       |
      | Helloworld |
  
  Scenario Outline: validation requirements failing (using :without)
    Given the following document definition:
      """
      class User < Recliner::Document
        property :login, String
        validates_format_of :login, :without => /[\d ]/
      end
      """

    When I create an instance of "User"
    And I set its login to "<login>"
    Then the instance should not be valid
    And its errors should include "Login is invalid"

    Examples:
      | login       |
      | abc1        |
      | 99test      |
      | Hello world |
      