class SessionPersistence
  attr_reader :session

  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def find_list(id)
    session[:lists].find { |list| list[:id] == id }  
  end

  def lists
    session[:lists]
  end

  def create_list(name)
    id = next_element_id(session[:lists])
    
    session[:lists] << { id: id, name: name, todos: [] }
  end

  def update_list_name(id, new_name)
    list = find_list(id)
    list[:name] = new_name
  end

  def delete_list(id)
    session[:lists].reject! { |list| list[:id] == id }
  end

  # Todos
  def create_todo(list_id, todo_name)
    list = find_list(list_id)
    id = next_element_id(list[:todos])
    list[:todos] << { id: id, name: todo_name, completed: false }
  end

  def find_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def delete_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, completion_status)
    todo = find_todo(list_id, todo_id)
    todo[:completed] = completion_status
  end

  def complete_all_todos(list_id)
    list = find_list(list_id)
    list[:todos].each { |todo| todo[:completed] = true }
  end

  private

  def next_element_id(elements)
    max = elements.map { |element| element[:id] }.max || 0
    max + 1
  end
end