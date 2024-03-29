require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before do
    assign(:users, [
             build_stubbed(:user, name: 'Alex', balance: 5000),
             build_stubbed(:user, name: 'Valera', balance: 3000)
           ])

    render
  end

  it 'renders player names' do
    expect(rendered).to match 'Alex'
    expect(rendered).to match 'Valera'
  end

  it 'renders player balances' do
    expect(rendered).to include number_to_currency(5000)
    expect(rendered).to include number_to_currency(3000)
  end

  it 'renders player names in right order' do
    expect(rendered).to match(/Alex.*Valera/m)
  end
end
