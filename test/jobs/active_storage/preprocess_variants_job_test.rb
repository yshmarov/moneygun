# frozen_string_literal: true

require "test_helper"

class ActiveStorage::PreprocessVariantsJobTest < ActiveJob::TestCase
  test "avatar changes enqueue variant preprocessing" do
    user = users(:one)

    assert_enqueued_with(job: ActiveStorage::PreprocessVariantsJob) do
      user.update!(
        avatar: {
          io: Rails.root.join("test/fixtures/files/avo-logo.png").open,
          filename: "avatar.png",
          content_type: "image/png"
        }
      )
    end
  end
end
