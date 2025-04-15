require 'pg'

class DatabasePersistence
  attr_reader :db
  
  def initialize()
    @db = PG.connect(dbname: 'todos')
  end

  # Lists
  def lists
    result = db.exec("SELECT * FROM lists;")
    result.map { |row| row_to_hash(row) }
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = db.exec_params(sql, [id])
    row_to_hash(result.first)
  end

  private 

  # Convert PG::Result rows to application-friendly Hash rows
  def row_to_hash(row)
    { id: row['id'].to_i, name: row['name'], todos: [] }  
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

  def delete_list(id)
  #   session[:lists].reject! { |list| list[:id] == id }
  end

  # # Todos
  def create_todo(list_id, todo_name)
  #   list = find_list(list_id)
  #   id = next_element_id(list[:todos])
  #   list[:todos] << { id: id, name: todo_name, completed: false }
  end

  def find_todo(list_id, todo_id)
  #   list = find_list(list_id)
  #   list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def delete_todo(list_id, todo_id)
  #   list = find_list(list_id)
  #   list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, completion_status)
  #   todo = find_todo(list_id, todo_id)
  #   todo[:completed] = completion_status
  end

  def complete_all_todos(list_id)
  #   list = find_list(list_id)
  #   list[:todos].each { |todo| todo[:completed] = true }
  end
end