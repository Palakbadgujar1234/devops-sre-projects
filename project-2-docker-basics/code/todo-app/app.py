"""
Simple Todo Application with Flask
This is a beginner-friendly example for learning Docker
"""

from flask import Flask, render_template, request, jsonify
import json
import os

# Create Flask application
app = Flask(__name__)

# File to store todos (simple file-based storage)
TODOS_FILE = 'todos.json'


def load_todos():
    """
    Load todos from JSON file
    
    WHAT: Reads todos from file
    WHY: Persist data between requests
    HOW: Opens file, parses JSON, returns list
    """
    if os.path.exists(TODOS_FILE):
        with open(TODOS_FILE, 'r') as f:
            return json.load(f)
    return []


def save_todos(todos):
    """
    Save todos to JSON file
    
    WHAT: Writes todos to file
    WHY: Persist data for future requests
    HOW: Opens file, writes JSON
    """
    with open(TODOS_FILE, 'w') as f:
        json.dump(todos, f, indent=2)


@app.route('/')
def index():
    """
    Serve the main page
    
    WHAT: Returns HTML page
    WHY: User interface for todo app
    HOW: Renders template
    """
    return render_template('index.html')


@app.route('/api/todos', methods=['GET'])
def get_todos():
    """
    Get all todos
    
    WHAT: Returns list of all todos
    WHY: Frontend needs to display todos
    HOW: Loads from file, returns as JSON
    """
    todos = load_todos()
    return jsonify(todos)


@app.route('/api/todos', methods=['POST'])
def add_todo():
    """
    Add a new todo
    
    WHAT: Creates a new todo item
    WHY: User wants to add a task
    HOW: Gets data from request, adds to list, saves
    """
    data = request.get_json()
    todos = load_todos()
    
    # Create new todo with unique ID
    new_todo = {
        'id': len(todos) + 1,
        'text': data['text'],
        'completed': False
    }
    
    todos.append(new_todo)
    save_todos(todos)
    
    return jsonify(new_todo), 201


@app.route('/api/todos/<int:todo_id>', methods=['PUT'])
def update_todo(todo_id):
    """
    Update a todo (mark as complete/incomplete)
    
    WHAT: Updates todo completion status
    WHY: User wants to mark task as done
    HOW: Finds todo by ID, updates, saves
    """
    data = request.get_json()
    todos = load_todos()
    
    for todo in todos:
        if todo['id'] == todo_id:
            todo['completed'] = data['completed']
            save_todos(todos)
            return jsonify(todo)
    
    return jsonify({'error': 'Todo not found'}), 404


@app.route('/api/todos/<int:todo_id>', methods=['DELETE'])
def delete_todo(todo_id):
    """
    Delete a todo
    
    WHAT: Removes a todo from list
    WHY: User wants to remove a task
    HOW: Filters out todo with matching ID, saves
    """
    todos = load_todos()
    todos = [t for t in todos if t['id'] != todo_id]
    save_todos(todos)
    
    return '', 204


@app.route('/health')
def health():
    """
    Health check endpoint
    
    WHAT: Returns health status
    WHY: Docker/Kubernetes can check if app is running
    HOW: Returns simple JSON response
    """
    return jsonify({'status': 'healthy', 'service': 'todo-app'})


if __name__ == '__main__':
    # Run the application
    # host='0.0.0.0' - Listen on all interfaces (important for Docker!)
    # port=5000 - Use port 5000
    # debug=True - Show detailed errors (only for development)
    app.run(host='0.0.0.0', port=5000, debug=True)

# Made with Bob
