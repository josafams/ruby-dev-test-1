FactoryBot.define do
  factory :file_content do
    association :file_system_node, factory: :file_node
    content_type { 'text/plain' }
    storage_type { 'blob' }
    blob_data { 'Test content' }

    trait :blob_storage do
      storage_type { 'blob' }
      blob_data { 'Blob content' }
      s3_key { nil }
      file_path { nil }
    end

    trait :s3_storage do
      storage_type { 's3' }
      s3_key { 'test/file.txt' }
      blob_data { nil }
      file_path { nil }
      content_size { 100 }
      checksum { 'dummy_checksum' }
    end

    trait :disk_storage do
      storage_type { 'disk' }
      file_path { '/tmp/test_file.txt' }
      blob_data { nil }
      s3_key { nil }
      content_size { 100 }
      checksum { 'dummy_checksum' }
    end

    trait :large_file do
      blob_data { 'x' * 1024 * 1024 } # 1MB
    end

    trait :empty do
      blob_data { '' }
    end
  end
end
