#encoding: utf-8
require "model-base"
class Constraint
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id, Serial 
    property :data_type,   String # 数据类型
    property :operate,     String # 操作: ><!=
    property :refer_value, String # 参考值
    property :desc,        Text

    belongs_to :campaign, required: false
    # Integer/Float > >= == <= !=
    # String start_with end_with contain equal

    # instance methods
    def human_name
      "约束"
    end
end
