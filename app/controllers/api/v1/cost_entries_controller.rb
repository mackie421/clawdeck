module Api
  module V1
    class CostEntriesController < BaseController
      before_action :set_cost_entry, only: [ :show, :update, :destroy ]

      # GET /api/v1/cost_entries
      def index
        @cost_entries = current_user.cost_entries

        if params[:model_name].present? && CostEntry::MODELS.include?(params[:model_name])
          @cost_entries = @cost_entries.by_model(params[:model_name])
        end

        if params[:provider].present? && CostEntry::PROVIDERS.include?(params[:provider])
          @cost_entries = @cost_entries.by_provider(params[:provider])
        end

        if params[:agent_id].present? && CostEntry::AGENTS.include?(params[:agent_id])
          @cost_entries = @cost_entries.by_agent(params[:agent_id])
        end

        if params[:from].present? && params[:to].present?
          @cost_entries = @cost_entries.in_range(params[:from], params[:to])
        end

        @cost_entries = @cost_entries.order(created_at: :desc)

        render json: @cost_entries.map { |entry| cost_entry_json(entry) }
      end

      # POST /api/v1/cost_entries
      def create
        @cost_entry = current_user.cost_entries.new(cost_entry_params)

        if @cost_entry.save
          render json: cost_entry_json(@cost_entry), status: :created
        else
          render json: { error: @cost_entry.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/cost_entries/:id
      def show
        render json: cost_entry_json(@cost_entry)
      end

      # PATCH /api/v1/cost_entries/:id
      def update
        if @cost_entry.update(cost_entry_params)
          render json: cost_entry_json(@cost_entry)
        else
          render json: { error: @cost_entry.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/cost_entries/:id
      def destroy
        @cost_entry.destroy!
        head :no_content
      end

      # GET /api/v1/cost_entries/summary
      def summary
        entries = current_user.cost_entries

        today_total = entries.today.sum(:cost_usd).to_f
        week_total = entries.this_week.sum(:cost_usd).to_f
        month_total = entries.this_month.sum(:cost_usd).to_f

        # By model breakdown
        by_model = entries.this_month.group(:model_name).sum(:cost_usd).transform_values(&:to_f)

        # By agent breakdown
        by_agent = entries.this_month.group(:agent_id).sum(:cost_usd).transform_values(&:to_f)

        # Daily history (last 30 days)
        daily = entries.where("created_at >= ?", 30.days.ago)
          .group("DATE(created_at)")
          .sum(:cost_usd)
          .transform_keys(&:to_s)
          .transform_values(&:to_f)

        render json: {
          today: today_total,
          this_week: week_total,
          this_month: month_total,
          by_model: by_model,
          by_agent: by_agent,
          daily: daily
        }
      end

      private

      def set_cost_entry
        @cost_entry = current_user.cost_entries.find(params[:id])
      end

      def cost_entry_params
        params.require(:cost_entry).permit(:model_name, :provider, :agent_id,
          :input_tokens, :output_tokens, :cost_usd, :session_id, :metadata)
      end

      def cost_entry_json(entry)
        {
          id: entry.id,
          model_name: entry.model_name,
          provider: entry.provider,
          agent_id: entry.agent_id,
          input_tokens: entry.input_tokens,
          output_tokens: entry.output_tokens,
          cost_usd: entry.cost_usd.to_f,
          session_id: entry.session_id,
          metadata: entry.metadata || {},
          created_at: entry.created_at.iso8601,
          updated_at: entry.updated_at.iso8601
        }
      end
    end
  end
end
