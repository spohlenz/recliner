@completed
Feature: Validation: validates_inclusion_of
  The validates_inclusion_of validation specifies that an
  attribute must be one of a predefined set
  
  Scenario Outline: validation requirements met
    Given the following document definition:
      """
      class User < Recliner::Document
        property :gender, String
        validates_inclusion_of :gender, :in => [ 'Male', 'Female' ]
      end
      """
      
    When I create an instance of "User"
    And I set its gender to "<gender>"
    Then the instance should be valid
    
    Examples:
      | gender |
      | Male   |
      | Female |
  
  Scenario Outline: validation requirements failing
    Given the following document definition:
      """
      class User < Recliner::Document
        property :gender, String
        validates_inclusion_of :gender, :in => [ 'Male', 'Female' ]
      end
      """
      
    When I create an instance of "User"
    And I set its gender to "<gender>"
    Then the instance should not be valid
    And its errors should include "Gender is not included in the list"
    
    Examples:
      | gender |
      |        |
      | other  |
      | male   |
      | female |

  Scenario: validation requirements met (blank allowed)
    Given the following document definition:
      """
      class User < Recliner::Document
        property :gender, String
        validates_inclusion_of :gender, :in => [ 'Male', 'Female' ], :allow_blank => true
      end
      """

    When I create an instance of "User"
    And I set its gender to ""
    Then the instance should be valid

  Scenario: validation requirements met (nil allowed)
    Given the following document definition:
      """
      class User < Recliner::Document
        property :gender, String
        validates_inclusion_of :gender, :in => [ 'Male', 'Female' ], :allow_nil => true
      end
      """

    When I create an instance of "User"
    Then the instance should be valid
