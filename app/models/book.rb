class Book < ApplicationRecord
  validates :title, presence: true

  after_create_commit :fetch_book_data

  def thumbnail_url
    payload.first["thumbnail"]
  end

  has_many_attached :pdfs
  has_many_attached :audios

  private

  def fetch_book_data
    data = ::GoogleBookService.search_books(title)
    update(payload: data)
  end
end
