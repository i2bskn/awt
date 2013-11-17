module Awt
  module DSL
    $AWT_TASKS = {}
    $AWT_TARGETS = []
    
    def task(name, &block)
      task = Task.new &block
      $AWT_TASKS.store(name.to_sym, task)
    end

    def server(host, user: nil, port: 22, key: "~/.ssh/id_rsa")
      $AWT_TARGETS << Awt::Server.new(host: host, user: user, port: port, key: key)
    end

    def task_find(path = File.expand_path("."))
      task_file = "Awtfile"
      file = File.join(path, task_file)

      if File.exists?(file)
        file
      else
        if path == "/"
          file = File.join(ENV["HOME"], task_file)
          File.exists?(file) ? file : nil
        else
          task_find(File.expand_path("..", path))
        end
      end
    end
  end
end
