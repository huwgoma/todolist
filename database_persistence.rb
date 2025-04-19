require 'pg'

class DatabasePersistence
  attr_reader :db
  
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'todos')
          end

    @logger = logger
  end

  def query(sql, *params)
    @logger.info "#{sql}: #{params}"

    db.exec_params(sql, params)
  end

  # Lists
  def lists
    lists_sql = <<~SQL
      SELECT lists.*, COUNT(todos.id) AS todos_count, COUNT(NULLIF(todos.completed, true)) AS todos_remaining_count
      FROM lists LEFT JOIN todos ON lists.id = todos.list_id
      GROUP BY lists.id
      ORDER BY lists.name;
    SQL

    lists_result = query(lists_sql)

    lists_result.map do |list|
      format_list(list)
    end
  end

  def find_list(id)
    sql = <<~SQL
      SELECT lists.*, COUNT(todos.id) AS todos_count, COUNT(NULLIF(todos.completed, true)) AS todos_remaining_count
      FROM lists LEFT JOIN todos ON lists.id = todos.list_id
      WHERE lists.id = $1
      GROUP BY lists.id
      ORDER BY lists.name;
    SQL

    result = query(sql, id)

    format_list(result.first)
  end

  def create_list(name)
    sql = "INSERT INTO lists(name) VALUES($1);"
    query(sql, name)
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id)
  end

  def update_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, new_name, id)
  end

  # To-Dos
  def load_todos(list_id)
    sql = "SELECT * FROM todos WHERE list_id = $1"
    result = query(sql, list_id)

    result.map { |row| format_todo(row) }
  end

  def create_todo(list_id, name)
    sql = "INSERT INTO todos (name, list_id)
           VALUES ($1, $2)"
    query(sql, name, list_id)
  end

  def update_todo_status(list_id, todo_id, status)
    sql = "UPDATE todos SET completed = $1
           WHERE list_id = $2 AND id = $3"
    query(sql, status, list_id, todo_id)
  end

  def complete_all_todos(list_id)
    sql = "UPDATE todos SET completed = true
           WHERE list_id = $1"
    query(sql, list_id)
  end

  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE list_id = $1 AND id = $2"
    query(sql, list_id, todo_id)
  end

  def disconnect
    @db.close
  end

  private

  def format_list(list)
    { id: list['id'].to_i, name: list['name'],
      todos_count: list['todos_count'].to_i, 
      todos_remaining_count: list['todos_remaining_count'].to_i
    }
  end

  def format_todo(todo_row)
    { id: todo_row['id'].to_i, 
      name: todo_row['name'], 
      completed: todo_row['completed'] == 't'
    }
  end

  # def find_list(id)
  #   session[:lists].find { |list| list[:id] == id }  
  # end

  # def lists
  #   session[:lists]
  # end

  # def create_list(name)
  #   id = next_element_id(session[:lists])
    
  #   session[:lists] << { id: id, name: name, todos: [] }
  # end

  # def update_list_name(id, new_name)
  #   list = find_list(id)
  #   list[:name] = new_name
  # end


  # # Todos
  # def create_todo(list_id, todo_name)
  # #   list = find_list(list_id)
  # #   id = next_element_id(list[:todos])
  # #   list[:todos] << { id: id, name: todo_name, completed: false }
  # end

  # def find_todo(list_id, todo_id)
  # #   list = find_list(list_id)
  # #   list[:todos].find { |todo| todo[:id] == todo_id }
  # end

  # def delete_todo(list_id, todo_id)
  # #   list = find_list(list_id)
  # #   list[:todos].reject! { |todo| todo[:id] == todo_id }
  # end

  # def update_todo_status(list_id, todo_id, completion_status)
  # #   todo = find_todo(list_id, todo_id)
  # #   todo[:completed] = completion_status
  # end

  # def complete_all_todos(list_id)
  # #   list = find_list(list_id)
  # #   list[:todos].each { |todo| todo[:completed] = true }
  # end
end