# frozen_string_literal: true

class API::V1::BooksController < API::V1::APIController
  def index
    render json: Book.all.includes(:owner)
  end

  def show
    render json: Book.includes(:owner).find(params[:id])
  end

  def create
    # TODO: Owner of the created book is the user of the current session.
    book = Book.create! books_params
    render json: book, status: :created
  end

  def update
    book = Book.find(params[:id])
    book.update! books_params
    render json: book
  end

  def destroy
    Book.find(params[:id]).destroy
    head :no_content
  end

  private

  def books_params
    params.permit(:name, :owner_id)
  end
end
