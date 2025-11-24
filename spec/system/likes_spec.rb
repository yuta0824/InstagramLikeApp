require 'rails_helper'

RSpec.describe 'Like button', type: :system do
  let(:post_owner) { create(:user) }
  let!(:post) { create(:post, user: post_owner) }
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
    user.follow!(post_owner)
  end

  it 'いいねボタンクリック時に data-liked 属性が切り替わる' do
    visit root_path

    selector = "[data-post-id='#{post.id}'] .js-like-button"
    button = find(selector)
    expect(button[:'data-liked']).to be_nil

    button.click
    expect(page).to have_css("#{selector}[data-liked='true']")

    find("#{selector}[data-liked='true']").click
    expect(page).to have_css("#{selector}:not([data-liked])")
  end
end
