module Api
  module V1
    class ResearchEntriesController < BaseController
      before_action :set_research_entry, only: [ :show, :update, :destroy ]

      # GET /api/v1/research_entries
      def index
        @entries = current_user.research_entries

        if params[:research_type].present? && ResearchEntry::RESEARCH_TYPES.include?(params[:research_type])
          @entries = @entries.by_type(params[:research_type])
        end

        if params[:source].present? && ResearchEntry::SOURCES.include?(params[:source])
          @entries = @entries.by_source(params[:source])
        end

        if params[:tag].present?
          @entries = @entries.where("? = ANY(tags)", params[:tag])
        end

        if params[:min_relevance].present?
          @entries = @entries.where("relevance_score >= ?", params[:min_relevance].to_f)
        end

        @entries = @entries.order(created_at: :desc)

        render json: @entries.map { |entry| entry_json(entry) }
      end

      # POST /api/v1/research_entries
      def create
        @entry = current_user.research_entries.new(entry_params)

        if @entry.save
          render json: entry_json(@entry), status: :created
        else
          render json: { error: @entry.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/research_entries/:id
      def show
        render json: entry_json(@entry)
      end

      # PATCH /api/v1/research_entries/:id
      def update
        if @entry.update(entry_params)
          render json: entry_json(@entry)
        else
          render json: { error: @entry.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/research_entries/:id
      def destroy
        @entry.destroy!
        head :no_content
      end

      private

      def set_research_entry
        @entry = current_user.research_entries.find(params[:id])
      end

      def entry_params
        params.require(:research_entry).permit(:title, :body, :research_type, :source,
          :relevance_score, :metadata, tags: [])
      end

      def entry_json(entry)
        {
          id: entry.id,
          title: entry.title,
          body: entry.body,
          research_type: entry.research_type,
          source: entry.source,
          tags: entry.tags || [],
          relevance_score: entry.relevance_score&.to_f,
          metadata: entry.metadata || {},
          created_at: entry.created_at.iso8601,
          updated_at: entry.updated_at.iso8601
        }
      end
    end
  end
end
