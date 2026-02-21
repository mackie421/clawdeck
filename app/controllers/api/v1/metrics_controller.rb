module Api
  module V1
    class MetricsController < BaseController
      before_action :set_metric, only: [ :show, :update, :destroy ]

      # GET /api/v1/metrics
      def index
        @metrics = current_user.metrics

        if params[:category].present? && Metric::CATEGORIES.include?(params[:category])
          @metrics = @metrics.by_category(params[:category])
        end

        if params[:name].present?
          @metrics = @metrics.by_name(params[:name])
        end

        if params[:platform].present? && Metric::PLATFORMS.include?(params[:platform])
          @metrics = @metrics.by_platform(params[:platform])
        end

        if params[:source].present? && Metric::SOURCES.include?(params[:source])
          @metrics = @metrics.where(source: params[:source])
        end

        if params[:from].present? && params[:to].present?
          @metrics = @metrics.in_period(params[:from], params[:to])
        end

        @metrics = @metrics.order(created_at: :desc)

        render json: @metrics.map { |metric| metric_json(metric) }
      end

      # POST /api/v1/metrics
      def create
        @metric = current_user.metrics.new(metric_params)

        if @metric.save
          render json: metric_json(@metric), status: :created
        else
          render json: { error: @metric.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/metrics/:id
      def show
        render json: metric_json(@metric)
      end

      # PATCH /api/v1/metrics/:id
      def update
        if @metric.update(metric_params)
          render json: metric_json(@metric)
        else
          render json: { error: @metric.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/metrics/:id
      def destroy
        @metric.destroy!
        head :no_content
      end

      private

      def set_metric
        @metric = current_user.metrics.find(params[:id])
      end

      def metric_params
        params.require(:metric).permit(:category, :name, :value, :platform,
          :period_start, :period_end, :source, :metadata)
      end

      def metric_json(metric)
        {
          id: metric.id,
          category: metric.category,
          name: metric.name,
          value: metric.value.to_f,
          platform: metric.platform,
          period_start: metric.period_start&.iso8601,
          period_end: metric.period_end&.iso8601,
          source: metric.source,
          metadata: metric.metadata || {},
          created_at: metric.created_at.iso8601,
          updated_at: metric.updated_at.iso8601
        }
      end
    end
  end
end
