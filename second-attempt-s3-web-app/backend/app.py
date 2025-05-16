from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return "Welcome to Connecting The Dots!"

@app.route('/contact')
def contact():
    return "Contact Page"

@app.route('/dashboard')
def dashboard():
    return "Dashboard Page"

@app.route('/submit_contact', methods=['POST'])
def submit_contact():
    # Get form data
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    email = request.form['email']
    message = request.form['message']
    
    # Print out form submission (later can be stored in DynamoDB)
    print(f"Received contact form: {first_name} {last_name}, {email}, {message}")
    
    return jsonify({"status": "success", "message": "Form submitted successfully!"})

if __name__ == '__main__':
    app.run(debug=True)
