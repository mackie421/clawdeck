module Api
  module V1
    class LearningsController < BaseController
      before_action :set_learning, only: [ :show, :update, :destroy ]

      # GET /api/v1/learnings
      def index
        @learnings = current_user.learnings

        if params[:type].present? && Learning.learning_types.key?(params[:type])
          @learnings = @learnings.where(learning_type: params[:type])
        end

        if params[:category].present? && Learning.categories.key?(params[:category])
          @learnings = @learnings.where(category: params[:category])
        end

        if params[:status].present? && Learning.statuses.key?(params[:status])
          @learnings = @learnings.where(status: params[:status])
        end

        if params[:severity].present? && Learning.severities.key?(params[:severity])
          @learnings = @learnings.where(severity: params[:severity])
        end

        @learnings = @learnings.order(created_at: :desc)

        render json: @learnings.map { |learning| learning_json(learning) }
      end

      # POST /api/v1/learnings
      def create
        @learning = current_user.learnings.new(learning_params)

        # Similarity detection for corrections
        if @learning.learning_type_correction?
          similar = Learning.find_similar_correction(
            user: current_user,
            category: @learning.category,
            title: @learning.title,
            body: @learning.body
          )

          if similar
            similar.record_repeat!
            # Store link to the repeated entry in metadata
            @learning.metadata = (@learning.metadata || {}).merge(
              "repeated_learning_id" => similar.id,
              "repeat_detected" => true
            )
          end
        end

        if @learning.save
          render json: learning_json(@learning), status: :created
        else
          render json: { error: @learning.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/learnings/:id
      def show
        render json: learning_json(@learning)
      end

      # PATCH /api/v1/learnings/:id
      def update
        if @learning.update(learning_params)
          render json: learning_json(@learning)
        else
          render json: { error: @learning.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/learnings/:id
      def destroy
        @learning.destroy!
        head :no_content
      end

      # GET /api/v1/learnings/patterns
      # Returns grouped learnings with repeat counts
      def patterns
        patterns = current_user.learnings.corrections.repeating
          .group(:category)
          .select("category, COUNT(*) as count, SUM(repeat_count) as total_repeats")

        detailed = patterns.map do |pattern|
          entries = current_user.learnings.corrections.repeating
            .where(category: pattern.category)
            .order(repeat_count: :desc)
            .limit(5)

          {
            category: pattern.category,
            count: pattern.count,
            total_repeats: pattern.total_repeats,
            entries: entries.map { |l| learning_json(l) }
          }
        end

        render json: detailed
      end

      private

      def set_learning
        @learning = current_user.learnings.find(params[:id])
      end

      def learning_params
        params.require(:learning).permit(:title, :body, :learning_type, :category,
          :status, :severity, :source_correction_id, :metadata)
      end

      def learning_json(learning)
        {
          id: learning.id,
          title: learning.title,
          body: learning.body,
          learning_type: learning.learning_type,
          category: learning.category,
          status: learning.status,
          severity: learning.severity,
          repeat_count: learning.repeat_count,
          last_repeated_at: learning.last_repeated_at&.iso8601,
          source_correction_id: learning.source_correction_id,
          metadata: learning.metadata || {},
          created_at: learning.created_at.iso8601,
          updated_at: learning.updated_at.iso8601
        }
      end
    end
  end
end
