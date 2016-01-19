module Sneakers
  class Railtie < ::Rails::Railtie
    initializer "sneakers.request_validator" do |app|
      ActiveSupport.on_load(:action_controller) do
        class_eval do
          private

          def validate_signature
            unless verified_payload.authentic?(signature)
              render json: {errors: "Invalid signature"},
                     status: :unprocessable_entity and return
            end
          end

          def signature
            request.headers["X-Signature"]
          end

          def verified_payload
            Sneakers::VerifiedPayload.new(payload)
          end

          def payload
            JSON.parse(request.body.read)
          end
        end
      end
    end
  end
end
