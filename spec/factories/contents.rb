FactoryBot.define do
  factory :content do
    title { "Content Title" }
    body { "This is the content body." }
    association :user
  end
end
