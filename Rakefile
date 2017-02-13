require './config/boot'

namespace :db do
  task :create_tables do
    Dir[File.join(SOURCES_DIR, 'models', '**', '*.rb')].each { |f| require f }
    Dynamoid.included_models
      .reject { |m| m.base_class&.name&.blank? }
      .uniq(&:table_name)
      .each do |model|
        if Dynamoid.adapter.list_tables.include?(model.table_name)
          puts "#{model.table_name} already exists"
        else
          model.create_table
          puts "#{model.table_name} created"
        end
      end
  end

  task :drop_tables do
    Dynamoid.adapter.list_tables.each do |table|
      if table =~ /^#{Dynamoid::Config.namespace}/
        Dynamoid.adapter.delete_table(table)
      end
    end
    Dynamoid.adapter.tables.clear
  end
end
