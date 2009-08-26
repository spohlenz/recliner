@completed
Feature: Validation: validates_length_of
  The validates_length_of validation specifies that the length of
  an attribute must meet certain requirements
  
  Scenario Outline: validation requirements met
    Given the following document definition:
      """
      class User < Recliner::Document
        @@word_tokenizer = lambda { |str| str.scan(/\w+/) }
      
        property :login, String
        validates_length_of :login, <options>
      end
      """
    
    When I create an instance of "User"
    And I set its login to "<login>"
    Then the instance should be valid
    
    Examples:
      | options                                  | login     |
      | :minimum => 4                            | valid     |
      | :maximum => 6                            | okay      |
      | :maximum => 8                            | tothemax  |
      | :is => 8                                 | exactly8  |
      | :within => 4..8                          | four      |
      | :within => 4..8                          | inside    |
      | :within => 4..8                          | eightchs  |
      | :in => 4..8                              | four      |
      | :in => 4..8                              | inside    |
      | :in => 4..8                              | eightchs  |
      | :is => 2, :tokenizer => @@word_tokenizer | two words |
  
  Scenario Outline: validation requirements failing
    Given the following document definition:
      """
      class User < Recliner::Document
        @@word_tokenizer = lambda { |str| str.scan(/\w+/) }
        
        property :login, String
        validates_length_of :login, <options>
      end
      """
      
    When I create an instance of "User"
    And I set its login to "<login>"
    Then the instance should not be valid
    And its errors should include "<error>"
    
    Examples:
      | options                                  | login               | error                                              |
      | :minimum => 4                            | abc                 | Login is too short (minimum is 4 characters)       |
      | :maximum => 6                            | toolong             | Login is too long (maximum is 6 characters)        |
      | :is => 8                                 | abcdefg             | Login is the wrong length (should be 8 characters) |
      | :is => 8                                 | abcdefghi           | Login is the wrong length (should be 8 characters) |
      | :within => 6..9                          | short               | Login is too short (minimum is 6 characters)       |
      | :within => 6..9                          | waytoolong          | Login is too long (maximum is 9 characters)        |
      | :in => 6..9                              | short               | Login is too short (minimum is 6 characters)       |
      | :in => 6..9                              | waytoolong          | Login is too long (maximum is 9 characters)        |
      | :is => 2, :tokenizer => @@word_tokenizer | more than two words | Login is the wrong length (should be 2 characters) |
      
  Scenario Outline: validation requirements failing with custom messages
    Given the following document definition:
      """
      class User < Recliner::Document
        property :login, String
        validates_length_of :login, <options>, <messages>
      end
      """

    When I create an instance of "User"
    And I set its login to "<login>"
    Then the instance should not be valid
    And its errors should include "<error>"

    Examples:
      | options     | messages                                | login   | error                      |
      | :in => 4..6 | :too_short => "has gotta be longer"     | abc     | Login has gotta be longer  |
      | :in => 4..6 | :too_long => "is just too long"         | toolong | Login is just too long     |
      | :is => 5    | :wrong_length => "must be 5 characters" | abc     | Login must be 5 characters |
      | :is => 5    | :message => "isn't right yet"           | abc     | Login isn't right yet      |
