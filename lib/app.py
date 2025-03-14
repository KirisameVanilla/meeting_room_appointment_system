from flask import Flask, request, jsonify
from flask_cors import CORS
import json
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, create_access_token, jwt_required
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

basedir = os.path.abspath(os.path.dirname(__name__))

app = Flask(__name__)
CORS(app) # 防止跨域报错

BOOKED_SLOTS_FILE = 'booked_slots.json'
if not os.path.exists(BOOKED_SLOTS_FILE):
    with open(BOOKED_SLOTS_FILE, 'w') as f:
        json.dump({}, f)

SUBSCRIBED_SLOTS_FILE = 'subscribed_slots.json'
if not os.path.exists(SUBSCRIBED_SLOTS_FILE):
    with open(SUBSCRIBED_SLOTS_FILE, 'w') as f:
        json.dump({}, f)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir,'db/user.db')  # 使用 SQLite 数据库
app.config['JWT_SECRET_KEY'] = 'your_jwt_secret'  # 设置 JWT 密钥
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)

# 用户模型
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)

# 创建数据库
with app.app_context():
    db.create_all()

# 用户注册
@app.route('/register', methods=['POST', 'OPTIONS'])
def register():
    if request.method == 'OPTIONS':
        response = jsonify({"message": "CORS Preflight"})
        response.headers.add('Access-Control-Allow-Origin', '*')  # 或指定源
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return response, 200
    try:
        data = request.get_json()
        if User.query.filter_by(email=data['email']).first():
            return jsonify({"message": "Email already exists"}), 400
        
        hashed_password = bcrypt.generate_password_hash(data['password']).decode('utf-8')
        new_user = User(email=data['email'], password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        # 添加 CORS 响应头
        response = jsonify({"message": "User registered successfully"})
        response.headers.add('Access-Control-Allow-Origin', '*')  # 或指定源
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        
        return response, 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500  # 返回详细错误信息

# 用户登录
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()
    if user and bcrypt.check_password_hash(user.password, data['password']):
        access_token = create_access_token(identity={'email': user.email})
        return jsonify(access_token=access_token), 200
    return jsonify({"message": "Invalid credentials"}), 401

# 受保护的路由示例
@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    return jsonify({"message": "This is a protected route"}), 200

@app.route('/save_slots', methods=['POST'])
def save_slots():
    try:
        # 获取前端发送的数据
        data = request.json  # Expecting JSON payload
        # 保存到本地文件
        with open(BOOKED_SLOTS_FILE, 'r') as file:
            old_data = json.load(file)
        if not detect_and_prevent_change(old_data, data):
            return jsonify({'error: conflict'}), 500
        else:
            with open(BOOKED_SLOTS_FILE, 'w') as file:
                json.dump(data, file)
        return jsonify({'message': 'Slots saved successfully!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def detect_and_prevent_change(data, new_data):
    for room_index, room in enumerate(data):
        for day_index, day in enumerate(room):
            for time_slot, value in day.items():
                original_value = value
                new_value = new_data[room_index][day_index][time_slot]
                if original_value and original_value != new_value and new_value:
                    # 互斥提示
                    return False
    return True

@app.route('/get_slots', methods=['GET'])
def get_slots():
    try:
        # 从文件中读取数据
        with open(BOOKED_SLOTS_FILE, 'r') as file:
            data = json.load(file)
        return jsonify(data), 200
    except FileNotFoundError:
        return jsonify({'message': 'No data found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@app.route('/subscribe_slots', methods=['POST'])
def subscribe_slots():
    try:
        # 获取前端发送的数据
        data = request.json  # Expecting JSON payload
        # 保存到本地文件
        with open(SUBSCRIBED_SLOTS_FILE, 'w') as file:
            json.dump(data, file)
        return jsonify({'message': 'Slots subscribed successfully!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/get_subscription', methods=['GET'])
def get_subscription():
    try:
        # 从文件中读取数据
        with open(SUBSCRIBED_SLOTS_FILE, 'r') as file:
            data = json.load(file)
        return jsonify(data), 200
    except FileNotFoundError:
        return jsonify({'message': 'No data found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

@app.route('/send_cancellation_emails', methods=['POST'])
def send_cancellation_emails():
    data = request.json
    emails = data.get('emails', [])
    slot = data.get('slot', '')

    if not emails or not slot:
        return jsonify({'error': 'Missing email addresses or time slot'}), 400

    # 邮件发送逻辑
    for email in emails:
        send_email(email, slot)
    
    return jsonify({'message': 'Emails sent successfully'}), 200

def send_email(to_email, slot):
    from_email = "1834576129@qq.com"
    password = "mjisawnszjgyddjc"
    
    subject = "Booking Cancellation Notification"
    body = f"Booking for the time slot {slot} has been cancelled."

    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    try:
        server = smtplib.SMTP_SSL('smtp.qq.com',465)
        server.login(from_email, password)
        server.sendmail(from_email, to_email, msg.as_string())
        server.close()
        print(f"Email sent to {to_email}")
    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")

# 启动服务器
if __name__ == '__main__':
    app.run(debug=True)