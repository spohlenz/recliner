@completed
Feature: Validation: validates_exclusion_of
  The validates_inclusion_of validation specifies that an
  attribute must not be one of a predefined set
  
  Background:
    Given the following document definition:
      """
      class Account < Recliner::Document
        property :subdomain, String
        validates_exclusion_of :subdomain, :in => [ 'www', 'mail', 'ftp' ]
      end
      """
  
  Scenario Outline: validation requirements met
    When I create an instance of "Account"
    And I set its subdomain to "<subdomain>"
    Then the instance should be valid
    And the instance should save
    
    Examples:
      | subdomain |
      | myaccount |
      | www1      |
      | ftpabc    |
  
  Scenario Outline: validation requirements failing
    When I create an instance of "Account"
    And I set its subdomain to "<subdomain>"
    Then the instance should not be valid
    And its errors should include "Subdomain is reserved"
    
    Examples:
      | subdomain |
      | www       |
      | mail      |
      | ftp       |
      