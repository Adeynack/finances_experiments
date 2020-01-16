require "rails_helper"

RSpec.describe API::V1::BooksController do
  let(:user) { create :user }
  let(:other_user) { create :user }
  let!(:book) { Book.create! owner: user, name: "Book of #{user.display_name}" }

  describe "GET /api/v1/books" do
    let(:user2) { create :user }
    let(:user3) { create :user }

    it "returns all books" do
      create_list :book, 10, owner: user2
      create_list :book, 15, owner: user3
      get api_v1_books_path
      expect(response).to have_http_status :ok
      expect(json.length).to eq Book.all.length
      expect(json.map(&:id)).to include book.id
    end
  end

  describe "GET /api/v1/books/{book_id}" do
    it "returns all books" do
      get api_v1_book_path(book.id)
      expect(response).to have_http_status :ok
      expect(json.id).to eq book.id
      expect(json.name).to eq book.name
      expect(json.owner.id).to eq book.owner.id
      expect(json.owner.display_name).to eq book.owner.display_name
    end
  end

  describe "POST /api/v1/books" do
    it "creates a new book" do
      new_book = {
        name: "Second book of #{user.display_name}",
        owner_id: user.id
      }
      post api_v1_books_path params: new_book
      expect(response).to have_http_status :created
      expect(json.id).not_to be_empty
      expect(json.owner.id).to eq user.id
      expect(json.owner.display_name).to eq user.display_name
      expect(json.name).to eq "Second book of #{user.display_name}"
    end
  end

  describe "PATCH /api/v1/books/{book_id}" do
    it "updates the name of an existing book" do
      book_update = {
        name: "A whole new name"
      }
      patch api_v1_book_path(book.id), params: book_update
      expect(response).to have_http_status :ok
      expect(json.id).to eq book.id
      expect(json.owner.id).to eq user.id
      expect(json.owner.display_name).to eq user.display_name
      expect(json.name).to eq "A whole new name"
    end

    it "changes the owner of an existing book" do
      book_update = {
        owner_id: other_user.id
      }
      patch api_v1_book_path(book.id), params: book_update
      expect(response).to have_http_status :ok
      expect(json.id).to eq book.id
      expect(json.owner.id).to eq other_user.id
      expect(json.owner.display_name).to eq other_user.display_name
      expect(json.name).to eq book.name
    end
  end

  describe "DELETE /api/v1/books/{book_id}" do
    it "destroys an existing book" do
      expect(Book.find(book.id)).not_to be_nil
      delete api_v1_book_path(book.id)
      expect(response).to have_http_status :no_content
      expect(Book.find_by(id: book.id)).to be_nil
    end
  end
end
