#encoding: utf-8
module Utils
  module DataMapper
    module Model
      def self.included(base)
        base.send(:property, :delete_status, ::String, :default => "normal")
        base.send(:property, :ip,            ::String)
        base.send(:property, :browser,       ::DataMapper::Property::Text)
        base.send(:property, :created_at,    ::DateTime)
        base.send(:property, :created_on,    ::Date)
        base.send(:property, :updated_at,    ::DateTime)
        base.send(:property, :updated_on,    ::Date)
        base.send(:include, InstanceMethods)

        #class << base
        #  include ClassMethods
        #  [:all, :get, :first, :last].each do |method|
        #    send(:alias_method_chain, method, :print_sql)
        #  end
        #end
      end

      module InstanceMethods

        # two hash#instances difference
        #
        # new: { column1: "hello", created_at: "2015/01/01 01:01:01" }
        # old: { column1: "world", created_at: "2015/01/01 02:02:02" }
        #
        # return diff: { 
        #         column1: { new: "hello", old: "world" },
        #         created_at: { new: "2015/01/01 01:01:01", old: "2015/01/01 02:02:02"} 
        #       }
        #
        # abbreviation:
        #     h_new => hash new
        #     v_new => value new
        #
        def _hash_difference(h_new, h_old)
          h_old.inject({}) do |difference, array_with_key_and_value|
            key, v_old = array_with_key_and_value
            v_new      = h_new.fetch(key)

            # skip some columns which must be change every time
            if not ["updated_at"].include?(key) and h_new != h_old 
              puts "%s - %s: %s => %s" % [timestamp, key, v_old, v_new]
              difference.merge({ key => { "new" => _new, "old" => _old } })
            end
            difference # reused next loop
          end
        end

        def timestamp
          Time.now.strftime("%Y/%m/%d %H:%M:%S")
        end

        # model#instance convert to hash
        # 
        # $ irb -r ./config/boot.rb
        # irb(main):001:0> User.first
        # => #<User @delete_status="normal" @ip=nil @browser=<not loaded> @created_at=Wed, 24 Dec 2014 17:17:35 +0800 @created_on=Wed, 24 Dec 2014 @updated_at=Wed, 24 Dec 2014 17:17:35 +0800 @updated_on=Wed, 24 Dec 2014 @id=1 @name="junjie" @email="jay_li@intfocus.com" @password="cf2f26202919a23c7d98cadc3a0e8e4d" @weixin=nil>
        # irb(main):002:0> User.first.to_params
        # => {"delete_status"=>"normal", "ip"=>nil, "browser"=>nil, "created_at"=>Wed, 24 Dec 2014 17:17:35 +0800, "created_on"=>Wed, 24 Dec 2014, "updated_at"=>Wed, 24 Dec 2014 17:17:35 +0800, "updated_on"=>Wed, 24 Dec 2014, "id"=>1, "name"=>"junjie", "email"=>"jay_li@intfocus.com", "password"=>"cf2f26202919a23c7d98cadc3a0e8e4d", "weixin"=>nil}
        #
        def to_params
          self.class.properties.map(&:name)
            .reject(&:empty?)
            .inject({}) do |hash, property| 
              hash.merge!({ "%s" % property => self.send(property) })
            end
        end

        # record diffence with update action
        #
        def _update_with_recorder(&block)
          hash_old     = self.to_params
          block_result = yield block
          hash_new     = self.to_params
          difference   = _hash_difference(hash_new, hash_old)
          if difference.has_key?("delete_status")
            action = "trash#%s" % delete_status
          end

          logger_title = "\n\nModel - %s update " % self.class.name
          if self.errors.count.zero?
            puts "%s successfully." % logger_title
            action_logger(self, action || "update", difference.to_s)
          else
            puts "%s failed:" % logger_title
            self.errors.each_pair do |key, value|
              puts "%-15s => %s" % [key, value]
            end
          end
          puts "\n\n"

          return block_result
        end

        # instance methods for model 
        def soft_destroy
          update(delete_status: "soft")
        end
        def soft_destroy_with_recorder
          _update_with_recorder { soft_destroy }
        end
        def hard_destroy
          update(delete_status: "hard")
        end
        def hard_destroy_with_recorder
          _update_with_recorder { hard_destroy }
        end
        def update_with_recorder(params)
          _update_with_recorder { update(params) }
        end
        def delete?
          %w[soft hard].include?(self.delete_status)
        end

        # ´òÓ¡±£´æ×´Ì¬
        # TODO print Colorfully
        def save_with_logger
          _template = "\n\nModel - %s saved" % self.class.name
          if self.save
            puts "%s successfully." % _template
            puts "\n\n"
            #action_logger(self, "create", "")
            return true
          else
            puts "%s failed:" % _template
            self.errors.each_pair do |key, value|
              puts "%-15s => %s" % [key, value]
            end
            puts "\n\n"
            return false
          end
        end
      end

      module ClassMethods
        # default methods to call delete status
        def normals
          all(delete_status: "normal")
        end
        def not_normals
          all(:delete_status.not => "normal")
        end
        def softs
          all(delete_status: "soft")
        end
        def hards
          all(delete_status: "hard")
        end
        
        # print query sql when call methods below.
        #
        # example:
        #   users = User.all
        #   => 
        #   User Load (0ms) ELECT "id", "name", "email" FROM "users"
        #   
        [:all, :get, :first, :last].each do |method|
          with_method, without_method = 
            "%s_with_print_sql" % method.to_s,
            "%s_without_print_sql" % method.to_s
          if method_defined?(method)
            warn "%s - already defiend!" % method
          else
            define_method with_method do |options|
              _t = Time.now.to_f
              # ==== important point!
              #
              #   self.send(without_mothod) 
              #   not 
              #   self.send(method)
              #
              _collection = self.send(without_method, options)
              _sql = ::DataMapper.repository.adapter
                .send(:select_statement,_collection.query).join(" ")
              puts "%s Load (%dms) %s" % [self.name, ((Time.now.to_f - _t)*1000).to_i, _sql]
              return _collection
            end
          end
        end
      end
    end
  end
end
