@completed
Feature: Validation: validates_numericality_of
  The validates_numericality_of validation specifies that
  a numerical field must meet certain constraints
  
  Scenario Outline: validation requirements met
    Given the following document definition:
      """
      class Booking < Recliner::Document
        property :number_of_people, Integer
        validates_numericality_of :number_of_people, <options>
      end
      """
      
    When I create an instance of "Booking"
    And I set its number_of_people to "<number>"
    Then the instance should be valid
    
    Examples:
      | options                           | number |
      | :even => true                     | 6      |
      | :odd => true                      | 5      |
      | :only_integer => true             | 2      |
      | :greater_than => 100              | 101    |
      | :greater_than_or_equal_to => 100  | 101    |
      | :greater_than_or_equal_to => 100  | 100    |
      | :less_than => 100                 | 99     |
      | :less_than_or_equal_to => 100     | 99     |
      | :less_than_or_equal_to => 100     | 100    |
      | :equal_to => 10                   | 10     |
      | :equal_to => 10                   | 10.0   |
  
  Scenario Outline: validation requirements failing
    Given the following document definition:
      """
      class Booking < Recliner::Document
        property :number_of_people, Integer
        validates_numericality_of :number_of_people, <options>
      end
      """
      
    When I create an instance of "Booking"
    And I set its number_of_people to "<number>"
    Then the instance should not be valid
    And its errors should include "<error>"
  
    Examples:
      | options                           | number | error                                                 |
      | :odd => true                      | 6      | Number of people must be odd                          |
      | :even => true                     | 5      | Number of people must be even                         |
      | :only_integer => true             | 2.5    | Number of people is not a number                      |
      | :greater_than => 100              | 50     | Number of people must be greater than 100             |
      | :greater_than => 100              | 100    | Number of people must be greater than 100             |
      | :greater_than_or_equal_to => 100  | 99     | Number of people must be greater than or equal to 100 |
      | :less_than => 100                 | 101    | Number of people must be less than 100                |
      | :less_than => 100                 | 100    | Number of people must be less than 100                |
      | :less_than_or_equal_to => 100     | 101    | Number of people must be less than or equal to 100    |
      | :equal_to => 10                   | 9      | Number of people must be equal to 10                  |
      | :equal_to => 10                   | 10.001 | Number of people must be equal to 10                  |
      