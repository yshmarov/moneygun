class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  # GET /books
  def index
    @books = Book.all

    # Uncomment to authorize with Pundit
    # authorize @books
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new

    # Uncomment to authorize with Pundit
    # authorize @book
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    # Uncomment to authorize with Pundit
    # authorize @book

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Book was successfully updated." }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!
    respond_to do |format|
      format.html { redirect_to books_url, status: :see_other, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @book
  rescue ActiveRecord::RecordNotFound
    redirect_to books_path
  end

  def book_params
    params.require(:book).permit(:title, :payload)

    # Uncomment to use Pundit permitted attributes
    # params.require(:book).permit(policy(@book).permitted_attributes)
  end
end
