FactoryBot.define do
  factory :file_system_node do
    sequence(:name) { |n| "test_node_#{n}" }
    node_type { FileSystemNode::DIRECTORY_TYPE }
    description { 'Nó de teste' }

    trait :directory do
      node_type { FileSystemNode::DIRECTORY_TYPE }
    end

    trait :file do
      node_type { FileSystemNode::FILE_TYPE }
    end

    trait :with_parent do
      association :parent, factory: :file_system_node
    end

    factory :directory, traits: [:directory], class: 'Directory' do
      sequence(:name) { |n| "directory_#{n}" }
    end

    factory :file_node, traits: [:file], class: 'FileNode' do
      sequence(:name) { |n| "file_#{n}.txt" }
    end
  end
end
