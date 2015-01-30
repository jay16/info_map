#encoding: utf-8
module Utils
  module ActionLogger
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def base_logger(panel, model, action, detail)
        _action = {
          "create"          => "创建",
          "update"          => "更新",
          "destroy"         => "删除",
          "trash#soft"      => "删除",
          "trash#hard"      => "从回收站删除",
          "trash#normal"    => "从回收站还原",
          "trash#clear"     => "清空回收站"
        }.fetch(action, action)

        user = case model.human_name
         when "用户" then model
         when "商品" then model.order.user
         else model.user
         end
        ::ActionLog.create({
          :panel      => panel,
          :user_id    => user.id,
          :model_name => model.class.name,
          :model_id   => model.id,
          :action     => action,
          :human      => "%s %s" % [_action, model.human_name],
          :detail     => detail
        })
      end

      def action_logger(model, action, detail)
        base_logger("model", model, action, detail)
      end
      def account_logger(model, action, detail="")
        base_logger("account", model, action, detail)
      end
      def cpanel_logger(model, action, detail="")
        base_logger("cpanel", model, action, detail)
      end
    end
  end
end
