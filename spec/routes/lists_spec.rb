require 'spec_helper'


describe List do

  before :each do
    @potato = Product.create(name: 'potato')
    @tomato = Product.create(name: 'tomato')
  end

  describe 'GET' do

    let (:list) { List.create(name: 'A Shopping List') }

    describe '/lists' do
      it 'responds with success' do
        get '/lists'
        expect(last_response.status).to be 200
      end

      it 'responds with list of lists' do
        add_items_to_list

        get '/lists'
        expect(JSON.parse(last_response.body)).to eq JSON.parse("[#{full_list_body}]")
      end
    end

    describe '/lists/:id' do
      context 'when list does not exist' do
        it 'responds with not found' do
          get '/lists/no_list'
          expect(last_response.status).to be 404
        end

        it 'responds with empty body' do
          get '/lists/no_list'
          expect(last_response.body).to eq ''
        end
      end

      context 'when list exists' do
        it 'responds with success' do
          get "/lists/#{list.id}"

          expect(last_response.status).to be 200
        end

        context 'and is empty' do
          it 'responds with list name and no items' do
            get "/lists/#{list.id}"

            expect(JSON.parse(last_response.body)).to eq JSON.parse('{ "name" : "A Shopping List", "items": [] }')
          end
        end

        context 'and has items' do
          before :each do
            add_items_to_list
          end

          it 'responds with every item' do
            get "/lists/#{list.id}"

            expect(JSON.parse(last_response.body)).to eq JSON.parse(full_list_body)
          end
        end
      end
    end
  end

  describe 'POST /lists' do

    let(:options) { {'CONTENT_TYPE' => 'application/json'} }

    it 'creates a list with name' do
      post '/lists', '{"name": "Lista!"}', options

      expect(List.first.name).to eq 'Lista!'
    end

    it 'has the list location on the response header' do
      post '/lists', '{"name": "Lista!"}', options

      expect(last_response.headers['Location']).to match /\/lists\/#{List.first.id}/
    end

    it 'adds items to the list' do
      post '/lists', full_list_body, options

      expect(List.first.items).to eq ([Item.new(product: @potato, amount: 3, list: List.first, bought: false),
                                       Item.new(product: @tomato, amount: 5, list: List.first, bought: true)])
    end
  end
end

private
def full_list_body
  '{
    "name": "A Shopping List",
    "items": [
      { "name": "potato", "amount": 3, "bought": false },
      { "name": "tomato", "amount": 5, "bought": true }
    ]
  }'
end

def add_items_to_list
  list.add_item(product: @potato, amount: 3)
  list.add_item(product: @tomato, amount: 5, bought: true)
  list.save
end

