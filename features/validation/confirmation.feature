@completed
Feature: Validation: validates_confirmation_of
  The validates_confirmation_of validation specifies that
  a given attribute must be provided twice as confirmation
  
  Background:
    Given the following document definition:
      """
      class User < Recliner::Document
        property :email, String
        validates_confirmation_of :email
      end
      """
  
  Scenario Outline: validation requirements met
    When I create an instance of "User"
    And I set its email to "<email>"
    And I set its email_confirmation to "<confirmation>"
    Then the instance should be valid
    
    Examples:
      | email          | confirmation   |
      | me@example.com | me@example.com |
      | test@test.com  | test@test.com  |
      | abc            | abc            |
  
  Scenario Outline: validation requirements failing
    When I create an instance of "User"
    And I set its email to "<email>"
    And I set its email_confirmation to "<confirmation>"
    Then the instance should not be valid
    And its errors should include "Email doesn't match confirmation"
    
    Examples:
      | email           | confirmation    |
      | me1@example.com | me2@example.com |
      | test@test.com   | test@testt.com  |
      | abc             | def             |
  
  Scenario: confirmation not provided
    When I create an instance of "User"
    And I set its email to "myemail"
    Then the instance should be valid
    