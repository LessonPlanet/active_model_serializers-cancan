module ActiveModel
  class Serializer
    module CanCan
      module Abilities
        extend ActiveSupport::Concern

        module ClassMethods
          def abilities(*actions)
            class_attribute :cancan_actions
            self.cancan_actions = expand_cancan_actions(actions)
            cancan_actions.each do |action|
              method = "can_#{action}?".to_sym
              unless method_defined?(method)
                define_method method do
                  can? action, object
                end
              end
            end
            attributes :abilities
          end

          private
          def expand_cancan_actions(actions)
            if actions.include? :crud
              actions.delete :crud
              actions |= [:index, :show, :new, :create, :edit, :update, :delete]
            end
            actions
          end
        end

        def abilities
          cancan_actions.inject({}) do |hash, action|
            hash[action] = send("can_#{action}?")
            hash
          end
        end
      end
    end
  end
end

ActiveModel::Serializer.send :include, ActiveModel::Serializer::CanCan::Abilities
