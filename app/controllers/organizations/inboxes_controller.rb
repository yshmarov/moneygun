class Organizations::InboxesController < Organizations::BaseController
  before_action :set_inbox, only: %i[ show edit update destroy ]

  # GET /organizations/1/inboxes
  def index
    @inboxes = @organization.inboxes
    authorize! @organization, with: InboxPolicy
  end

  # GET /organizations/1/inboxes/1
  def show
  end

  # GET /organizations/1/inboxes/new
  def new
    @inbox = @organization.inboxes.new
    authorize! @inbox
  end

  # GET /organizations/1/inboxes/1/edit
  def edit
  end

  # POST /organizations/1/inboxes
  def create
    @inbox = @organization.inboxes.new(inbox_params)
    authorize! @inbox

    if @inbox.save
      redirect_to organization_inbox_url(@organization, @inbox), notice: "Inbox was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1/inboxes/1
  def update
    if @inbox.update(inbox_params)
      redirect_to organization_inbox_url(@organization, @inbox), notice: "Inbox was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1/inboxes/1
  def destroy
    @inbox.destroy!

    redirect_to organization_inboxes_url(@organization), notice: "Inbox was successfully destroyed."
  end

  private
    def set_inbox
      @inbox = @organization.inboxes.find(params[:id])
      binding.b
      authorize! @inbox
    end

    def inbox_params
      params.require(:inbox).permit(:name)
    end
end
