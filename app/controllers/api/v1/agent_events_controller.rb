module Api
  module V1
    class AgentEventsController < BaseController
      # GET /api/v1/agent_events
      def index
        @events = current_user.agent_events

        if params[:event_type].present? && AgentEvent.event_types.key?(params[:event_type])
          @events = @events.where(event_type: params[:event_type])
        end

        if params[:severity].present? && AgentEvent.severities.key?(params[:severity])
          @events = @events.where(severity: params[:severity])
        end

        if params[:session_id].present?
          @events = @events.for_session(params[:session_id])
        end

        if params[:start_date].present?
          @events = @events.where("created_at >= ?", Time.parse(params[:start_date]))
        end

        if params[:end_date].present?
          @events = @events.where("created_at <= ?", Time.parse(params[:end_date]).end_of_day)
        end

        limit = [ (params[:limit] || 50).to_i, 200 ].min
        offset = (params[:offset] || 0).to_i

        total = @events.count
        @events = @events.recent.limit(limit).offset(offset)

        render json: {
          events: @events.map { |e| event_json(e) },
          pagination: { total: total, limit: limit, offset: offset }
        }
      end

      # POST /api/v1/agent_events
      def create
        @event = current_user.agent_events.new(event_params)

        if @event.save
          render json: event_json(@event), status: :created
        else
          render json: { error: @event.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/agent_events/sessions
      def sessions
        limit = [ (params[:limit] || 20).to_i, 100 ].min
        offset = (params[:offset] || 0).to_i

        # Get distinct sessions ordered by most recent event
        session_ids = current_user.agent_events
          .where.not(session_id: nil)
          .select("session_id, MAX(created_at) as latest")
          .group(:session_id)
          .order("latest DESC")

        total = session_ids.length
        session_ids = session_ids.limit(limit).offset(offset)

        sessions = session_ids.map do |row|
          events = current_user.agent_events
            .for_session(row.session_id)
            .order(created_at: :asc)

          first_event = events.first
          last_event = events.last

          {
            session_id: row.session_id,
            started_at: first_event&.created_at&.iso8601,
            ended_at: last_event&.created_at&.iso8601,
            agent_name: first_event&.agent_name,
            agent_emoji: first_event&.agent_emoji,
            event_count: events.size,
            error_count: events.count { |e| e.severity_error? },
            events: events.map { |e| event_json(e) }
          }
        end

        render json: {
          sessions: sessions,
          pagination: { total: total, limit: limit, offset: offset }
        }
      end

      private

      def event_params
        params.require(:agent_event).permit(:event_type, :agent_name, :agent_emoji,
          :summary, :session_id, :severity, :details)
      end

      def event_json(event)
        {
          id: event.id,
          event_type: event.event_type,
          agent_name: event.agent_name,
          agent_emoji: event.agent_emoji,
          summary: event.summary,
          severity: event.severity,
          session_id: event.session_id,
          details: event.details || {},
          created_at: event.created_at.iso8601
        }
      end
    end
  end
end
