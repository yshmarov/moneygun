require "test_helper"

class AccountPolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @account = accounts(:one)
    @account_user = @account.account_users.find_by(user: @user)
  end

  def test_show
    assert AccountPolicy.new(@user, @account).show?
    @account.users.delete(@user)
    assert_not AccountPolicy.new(@user, @account).show?
  end

  def test_edit
    assert AccountPolicy.new(@user, @account).edit?
  end

  def test_update
    assert AccountPolicy.new(@user, @account).show?
  end

  def test_destroy
    assert AccountPolicy.new(@user, @account).show?
  end
end
