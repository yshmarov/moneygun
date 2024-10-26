class Accounts::InboxesController < Accounts::BaseController
  before_action :set_inbox, only: %i[ show edit update destroy ]

  # GET /inboxes or /inboxes.json
  def index
    @inboxes = @account.inboxes
    authorize @account, policy_class: InboxPolicy
  end

  # GET /inboxes/1 or /inboxes/1.json
  def show
  end

  # GET /inboxes/new
  def new
    @inbox = @account.inboxes.new
    authorize @inbox
  end

  # GET /inboxes/1/edit
  def edit
  end

  # POST /inboxes or /inboxes.json
  def create
    @inbox = @account.inboxes.new(inbox_params)
    authorize @inbox

    respond_to do |format|
      if @inbox.save
        format.html { redirect_to account_inbox_url(@account, @inbox), notice: "Inbox was successfully created." }
        format.json { render :show, status: :created, location: @inbox }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @inbox.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inboxes/1 or /inboxes/1.json
  def update
    respond_to do |format|
      if @inbox.update(inbox_params)
        format.html { redirect_to account_inbox_url(@account, @inbox), notice: "Inbox was successfully updated." }
        format.json { render :show, status: :ok, location: @inbox }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @inbox.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inboxes/1 or /inboxes/1.json
  def destroy
    @inbox.destroy!

    respond_to do |format|
      format.html { redirect_to account_inboxes_url(@account), notice: "Inbox was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inbox
      @inbox = @account.inboxes.find(params[:id])
      authorize @inbox
    end

    # Only allow a list of trusted parameters through.
    def inbox_params
      params.require(:inbox).permit(:name)
    end
end
