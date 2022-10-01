require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { create(:user, name: 'Валера') }
  before do
    assign(:user, user)
    assign(:games, [build_stubbed(:game, id: 1), build_stubbed(:game, id: 2)])
  end

  it 'render nickname' do
    render
    expect(rendered).to match 'Валера'
  end

  it 'render game' do
    stub_template 'users/_game.html.erb' => '<%= game.id %><br/>'
    render
    expect(rendered).to match(/1.*2/m)
  end

  context 'when current user == user' do
    before do
      sign_in user
      render
    end

    it 'render edit profile button' do
      expect(rendered).to match('Сменить имя и пароль')
    end
  end

  context 'when current user != user' do
    it 'does not render edit profile button for guest' do
      render
      expect(rendered).not_to match('Сменить имя и пароль')
    end

    it 'does not render edit profile button for another user' do
      sign_in create(:user, name: 'Петя')
      render

      expect(rendered).not_to match('Сменить имя и пароль')
    end
  end
end
