require "httparty"

# y = GoogleBookService.search_books("Harry Potter", "de")
class GoogleBookService
  include HTTParty
  base_uri "https://www.googleapis.com/books/v1"

  def self.search_books(query)
    params = { q: query }

    response = get("/volumes", query: params)
    return [] unless response.success?

    books = response["items"] || []
    books.map do |book|
      volume_info = book["volumeInfo"]
      {
        title: volume_info["title"],
        authors: volume_info["authors"],
        description: volume_info["description"],
        published_date: volume_info["publishedDate"],
        page_count: volume_info["pageCount"],
        categories: volume_info["categories"],
        average_rating: volume_info["averageRating"],
        ratings_count: volume_info["ratingsCount"],
        thumbnail: volume_info.dig("imageLinks", "thumbnail"),
        preview_link: volume_info["previewLink"],
        info_link: volume_info["infoLink"],
        language: volume_info["language"],
        isbn_13: volume_info["industryIdentifiers"]&.find { |id| id["type"] == "ISBN_13" }&.dig("identifier"),
        isbn_10: volume_info["industryIdentifiers"]&.find { |id| id["type"] == "ISBN_10" }&.dig("identifier")
      }
    end
  end
end
