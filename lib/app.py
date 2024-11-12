from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, create_access_token, jwt_required
import os

basedir = os.path.abspath(os.path.dirname(__name__))

app = Flask(__name__)
CORS(app) # 防止跨域报错

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir,'user.db')  # 使用 SQLite 数据库
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
        
        return response
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

# 启动服务器
if __name__ == '__main__':
    app.run(debug=True)