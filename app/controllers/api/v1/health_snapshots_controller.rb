module Api
  module V1
    class HealthSnapshotsController < BaseController
      # GET /api/v1/health_snapshots
      def index
        @snapshot = current_user.health_snapshots.recent.first

        if @snapshot
          render json: snapshot_json(@snapshot)
        else
          render json: { error: "No health snapshots recorded" }, status: :not_found
        end
      end

      # POST /api/v1/health_snapshots
      def create
        @snapshot = current_user.health_snapshots.new(snapshot_params)

        if @snapshot.save
          render json: snapshot_json(@snapshot), status: :created
        else
          render json: { error: @snapshot.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/health_snapshots/history
      def history
        @snapshots = current_user.health_snapshots.recent

        if params[:from].present? && params[:to].present?
          @snapshots = @snapshots.where(created_at: params[:from]..params[:to])
        end

        if params[:source].present? && HealthSnapshot::SOURCES.include?(params[:source])
          @snapshots = @snapshots.by_source(params[:source])
        end

        @snapshots = @snapshots.limit(params[:limit]&.to_i || 100)

        render json: @snapshots.map { |s| snapshot_json(s) }
      end

      private

      def snapshot_params
        params.require(:health_snapshot).permit(:source, :gateway_status, :telegram_status,
          :disk_usage_pct, :memory_usage_pct, :cpu_load, :uptime_seconds,
          :cron_results, :error_entries)
      end

      def snapshot_json(snapshot)
        {
          id: snapshot.id,
          source: snapshot.source,
          gateway_status: snapshot.gateway_status,
          telegram_status: snapshot.telegram_status,
          disk_usage_pct: snapshot.disk_usage_pct&.to_f,
          memory_usage_pct: snapshot.memory_usage_pct&.to_f,
          cpu_load: snapshot.cpu_load&.to_f,
          cron_results: snapshot.cron_results || {},
          uptime_seconds: snapshot.uptime_seconds,
          errors: snapshot.error_entries || [],
          created_at: snapshot.created_at.iso8601,
          updated_at: snapshot.updated_at.iso8601
        }
      end
    end
  end
end
