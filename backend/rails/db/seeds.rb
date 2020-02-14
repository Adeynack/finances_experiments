# frozen_string_literal: true

joe = User.create! id: "54332d2f-2a60-4e34-b4a7-72fb7167e1a0",
                   email: "joe@example.com",
                   display_name: "Joe",
                   password: "foobar"

Book.create! id: "238bfbb1-55f6-4614-8d7f-26edde264525",
             name: "Joe's Book",
             owner: joe
