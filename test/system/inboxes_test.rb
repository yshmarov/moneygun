require "application_system_test_case"

class InboxesTest < ApplicationSystemTestCase
  setup do
    @inbox = inboxes(:one)
  end

  test "visiting the index" do
    visit inboxes_url
    assert_selector "h1", text: "Inboxes"
  end

  test "should create inbox" do
    visit inboxes_url
    click_on "New inbox"

    fill_in "Account", with: @inbox.account_id
    fill_in "Name", with: @inbox.name
    click_on "Create Inbox"

    assert_text "Inbox was successfully created"
    click_on "Back"
  end

  test "should update Inbox" do
    visit inbox_url(@inbox)
    click_on "Edit this inbox", match: :first

    fill_in "Account", with: @inbox.account_id
    fill_in "Name", with: @inbox.name
    click_on "Update Inbox"

    assert_text "Inbox was successfully updated"
    click_on "Back"
  end

  test "should destroy Inbox" do
    visit inbox_url(@inbox)
    click_on "Destroy this inbox", match: :first

    assert_text "Inbox was successfully destroyed"
  end
end
