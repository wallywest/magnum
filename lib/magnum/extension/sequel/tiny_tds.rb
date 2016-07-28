module Magnum
  module Sequel
    module TinyTDS

      def self.included(base)
        base.class_eval do

          #exact copy of existing sequel tiny_tds gem with patch in the ensure block
          #
          def patched_execute(sql, opts=OPTS)
            synchronize(opts[:server]) do |c|
              begin
                m = opts[:return]
                r = nil
                if (args = opts[:arguments]) && !args.empty?
                  types = []
                  values = []
                  args.each_with_index do |(k, v), i|
                    v, type = ps_arg_type(v)
                    types << "@#{k} #{type}"
                    values << "@#{k} = #{v}"
                  end
                  case m
                  when :do
                    sql = "#{sql}; SELECT @@ROWCOUNT AS AffectedRows"
                    single_value = true
                  when :insert
                    sql = "#{sql}; SELECT CAST(SCOPE_IDENTITY() AS bigint) AS Ident"
                    single_value = true
                  end
                  sql = "EXEC sp_executesql N'#{c.escape(sql)}', N'#{c.escape(types.join(', '))}', #{values.join(', ')}"
                  log_yield(sql) do
                    r = c.execute(sql)
                    r.each{|row| return row.values.first} if single_value
                  end
                else
                  log_yield(sql) do
                    r = c.execute(sql)
                    return r.send(m) if m
                  end
                end
                yield(r) if block_given?
              rescue TinyTds::Error => e
                raise_error(e, :disconnect=>!c.active?)
              ensure
                #this is the one line that changes
                r.cancel if r && c.sqlsent? && c.active?
              end
            end
          end

          alias_method :execute, :patched_execute
        end
      end

    end
  end
end

Sequel::Database.load_adapter(:tinytds).include(Magnum::Sequel::TinyTDS)
