from flask import Flask, jsonify, make_response
# from serverless_wsgi import handle_request  # Disabling serverless_wsgi import for static site setup
import boto3

app = Flask(__name__)

# Health check with CORS headers (Useful for backend health checks)
@app.route("/ping")
def ping():
    response = make_response(jsonify({"status": "alive"}))
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

# Handle contact form submission (If you're using the contact form, enable this route)
# @app.route("/submit_contact", methods=["POST"])
# def submit_contact():
#     try:
#         first_name = request.form.get("first_name")
#         last_name = request.form.get("last_name")
#         job_title = request.form.get("job_title")
#         phone_number = request.form.get("phone_number")
#         email = request.form.get("email")
#         company = request.form.get("company")
#
#         if not first_name or not last_name or not email:
#             return jsonify({"error": "Required fields are missing"}), 400
#
#         dynamodb = boto3.resource("dynamodb")
#         table = dynamodb.Table("ConnectingTheDotsDBTable")
#
#         table.put_item(Item={
#             "email": email,
#             "first_name": first_name,
#             "last_name": last_name,
#             "job_title": job_title,
#             "phone_number": phone_number,
#             "company": company
#         })
#
#         return redirect("/contact")
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500

# AWS Lambda handler for serverless deployment (Disabling Lambda function for now)
# def handler(event, context):
#     return handle_request(app, event, context)

if __name__ == "__main__":
    app.run(debug=True)
