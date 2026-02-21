module Api
  module V1
    class ContentsController < BaseController
      before_action :set_content, only: [ :show, :update, :destroy ]

      # GET /api/v1/contents
      def index
        @contents = current_user.contents

        if params[:status].present? && Content.statuses.key?(params[:status])
          @contents = @contents.where(status: params[:status])
        end

        if params[:platform].present? && Content.platforms.key?(params[:platform])
          @contents = @contents.where(platform: params[:platform])
        end

        if params[:content_type].present? && Content.content_types.key?(params[:content_type])
          @contents = @contents.where(content_type: params[:content_type])
        end

        if params[:tag].present?
          @contents = @contents.where("? = ANY(tags)", params[:tag])
        end

        @contents = @contents.order(created_at: :desc)

        render json: @contents.map { |content| content_json(content) }
      end

      # POST /api/v1/contents
      def create
        @content = current_user.contents.new(content_params)

        if @content.save
          render json: content_json(@content), status: :created
        else
          render json: { error: @content.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/contents/:id
      def show
        render json: content_json(@content)
      end

      # PATCH /api/v1/contents/:id
      def update
        if @content.update(content_params)
          render json: content_json(@content)
        else
          render json: { error: @content.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/contents/:id
      def destroy
        @content.destroy!
        head :no_content
      end

      private

      def set_content
        @content = current_user.contents.find(params[:id])
      end

      def content_params
        params.require(:content).permit(:title, :body, :platform, :content_type, :status,
          :scheduled_at, :published_at, :source, :board_id, :metadata, tags: [])
      end

      def content_json(content)
        {
          id: content.id,
          title: content.title,
          body: content.body,
          platform: content.platform,
          content_type: content.content_type,
          status: content.status,
          scheduled_at: content.scheduled_at&.iso8601,
          published_at: content.published_at&.iso8601,
          tags: content.tags || [],
          source: content.source,
          metadata: content.metadata || {},
          board_id: content.board_id,
          created_at: content.created_at.iso8601,
          updated_at: content.updated_at.iso8601
        }
      end
    end
  end
end
