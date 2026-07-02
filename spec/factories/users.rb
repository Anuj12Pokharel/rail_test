FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email) { |n| "user#{n}@email.com" }
    password { "complex_password" }
    country { "USA" }
  end
end
