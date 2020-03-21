# frozen_string_literal: true

DatabaseCleaner.clean_with :truncation if Rails.env.development?

joe = User.create! email: "joe@example.com",
                   display_name: "Joe",
                   password: "foobar"

Book.create! id: "238bfbb1-55f6-4614-8d7f-26edde264525",
             name: "Joe's Book",
             owner: joe
