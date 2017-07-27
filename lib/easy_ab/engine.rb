module EasyAb
  class Engine < ::Rails::Engine
    isolate_namespace EasyAb

    # prevents conflict with field_test method in views
    engine_name "easy_ab_engine"
  end
end
