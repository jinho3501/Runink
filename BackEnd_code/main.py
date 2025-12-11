from fastapi import FastAPI, File, UploadFile, Form
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from haversine import haversine
import pymysql
import json
from fastapi.responses import JSONResponse
import shutil
import os
from typing import Optional
import uuid
import time
# python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080

# ====================================================================================

app = FastAPI()
app.mount("/data", StaticFiles(directory="data"), name="data")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# ====================================================================================
# DB연결
def get_db_connection():
    try:
        conn = pymysql.connect(
            host='runink.c3om8wy2ed7d.ap-northeast-2.rds.amazonaws.com',
            user='admin',
            password='runink1011^^',
            database='runink',
            cursorclass=pymysql.cursors.DictCursor)
        return conn
    except pymysql.Error as e:
        print(f"데이터베이스 연결 오류: {e}")
        return None
# # ====================================================================================
# 기존 모델들
class Location(BaseModel):
    latitude: float
    longitude: float

# 새로운 로그인 모델
class LoginRequest(BaseModel):
    email: str
    password: str

# 새로운 userid 모델
class UserRequest(BaseModel):
    userId: str
# ====================================================================================


    
@app.post("/login")
async def login(login_data: LoginRequest):    
    return {"status": "success", 
            "name": "tjddlf", 
            "profile_image":"https://newsimg-hams.hankookilbo.com/2024/07/28/cf547e45-fb5d-4eb3-ba48-c0d318d0983d.jpg"}
    
# =================================== 프로필 조회 =====================================
    
@app.post("/user")
async def user(data:UserRequest):    
    print(data.userId)
    print(f"DB건들기 - userId: {data.userId}")
    
    conn = get_db_connection()
    if not conn:
        print("데이터베이스 연결 실패")
    try:
        cursor = conn.cursor()
        query = """select 
U.email,
U.name,
U.profile_image,
sum(R.distance) as total_distance
from run R 
left join user U
on R.user_id = U.user_id
group by U.user_id
having U.email=%s"""
        cursor.execute(query,(data.userId))
        user_exist = cursor.fetchone()
        conn.commit()
        print("데이터 받아오기 성공")
        print(user_exist)
    except pymysql.Error as e:
        print(f"데이터베이스 오류: {e}")
    finally:
        conn.close()
        
    print(user_exist.get("name", "None"))
    print(user_exist.get("profile_image", "None"))
    print(user_exist.get("total_distance", "None"))
    # path = "https://runink-bucket.s3.ap-northeast-2.amazonaws.com/mil_img_2.jpg"

    return {"status": "success", 
            "name": f'{user_exist.get("name")}', 
            "profile_image":f"{user_exist.get('profile_image')}",
            "total_distance":f"{user_exist.get('total_distance')}",
            }
    
# ========================================== 유저정보 받아오기 (회원가입) ====================================================

class UserCreate(BaseModel):
    email: str
    name: str
    birth_date: str
    gender: str    


@app.post("/signin")
async def signin(user: UserCreate):
    print(user)
    conn = get_db_connection()
    if not conn:
        print("데이터베이스 연결 실패")
    try:
        cursor = conn.cursor()
        
        nowtime = time.strftime('%Y-%m-%d %H:%M:%S')
        cursor.execute("INSERT INTO user (email, pw, name, birthday, gender) VALUES (%s, %s, %s, %s, %s)",
                    (user.email, nowtime ,user.name, user.birth_date, user.gender))
        conn.commit()
        cursor.execute("select * from user where email = %s",(user.email))
        user_id = cursor.fetchone()
        conn.commit()
        uidf = user_id.get("user_id")  
        cursor.execute("INSERT INTO run (user_id, route_id, distance) VALUES (%s,%s,%s)", (uidf,1,0))
        conn.commit()

        print("success!")

    except pymysql.Error as e:
        print(f"데이터베이스 오류: {e}")
    finally:
        conn.close()
            
        
    return {
        "email": user.email,
        "name": user.name,
        "birth_date": user.birth_date,
        "gender": user.gender
    }

# ================================================ 경로만들기 =============================================

import default_shape
import course_search
 
 

class Message(BaseModel):
    content: str
    location: Location

@app.post("/message")
async def receive_message(message: Message):    
    _currentP = (message.location.latitude, message.location.longitude)
    print(_currentP)
    
    with open("data/heart_5.json", "rb") as f:
        heart = json.load(f)
    
    with open("data/square.json", "rb") as f: 
        square = json.load(f)
    
    with open("data/star.json", "rb") as f:
        star = json.load(f)    
    # heart_coords = default_shape.generate_heart_coordinates(bottom_lat=_currentP[0],bottom_lon=_currentP[1])    
    # heart_full_route, heart_distance = course_search.get_full_route(heart_coords)
    # heart_full_route_json = {"heart_routes":[[{"lat":y,"lng":x} for x,y in heart_full_route]]}
    
    # square_coords = default_shape.generate_square_coordinates(lat=_currentP[0],lon=_currentP[1])    
    # square_full_route, square_distance = course_search.get_full_route(square_coords)
    # square_full_route_json = {"square_routes":[[{"lat":y,"lng":x} for x,y in square_full_route]]}

    # star_coords = default_shape.generate_star_coordinates(center_lat=_currentP[0],center_lon=_currentP[1])    
    # star_full_route, star_distance = course_search.get_full_route(star_coords)
    # star_full_route_json = {"star_routes":[[{"lat":y,"lng":x} for x,y in star_full_route]]}
    
    return {"status": "success", 
            "heart_route":heart, 
            "square_route":square,
            "star_route":star,
            "distance":{"heart_distance":"6.56", 
                        "square_distance":"5.54", 
                        "star_distance":"11.0"}} 






@app.post("/center")
async def receive_message(message: Message):    
    _currentP = (message.location.latitude, message.location.longitude)
    print(_currentP)
    
    return {"status": "success"}


@app.post("/road_network")
async def load_road_network():
    road_size = default_shape.get_size()
    return {"road_size":f"{road_size}"}

# ===================================== 이미지 로드 ============================================
import img_load_s3
import image2course

class ImageLoad(BaseModel):
    url: str

@app.post("/load_image")
async def load_road_network(message: Message):
    print(message)
    # lg_imgload="https://runink-bucket.s3.ap-northeast-2.amazonaws.com/img_20241119_141554_b92e3b3d.png"
    # lg_image = img_load_s3.read_image_from_url(lg_imgload)
    
    # nike_imgload="https://runink-bucket.s3.ap-northeast-2.amazonaws.com/img_20241120_170319_462093ec.png"
    # nike_image = img_load_s3.read_image_from_url(nike_imgload)
    
    # _currentP = (message.location.latitude, message.location.longitude)
    
    # lg_coords = image2course.draw_contour_on_map(lg_image, lat_start=_currentP[0], lon_start=_currentP[1])
    # nike_coords = image2course.draw_contour_on_map(nike_image, lat_start=_currentP[0], lon_start=_currentP[1])
    
    # lg_full_route, lg_distance = course_search.get_full_route(lg_coords)
    # lg_full_route_json = {"lg_routes":[[{"lat":y,"lng":x} for x,y in lg_full_route]]}
    # nike_full_route, nike_distance = course_search.get_full_route(nike_coords)
    # nike_full_route_json = {"nike_routes":[[{"lat":y,"lng":x} for x,y in nike_full_route]]}
    
    
    with open("data/apple_final.json", "rb") as f:
        apple = json.load(f)
    
    with open("data/lglogo_final.json", "rb") as f:
        lglogo = json.load(f)
     
     
    
    return {"status": "success", 
            "lg_route":lglogo,
            "apple_route":apple,
            "distance":{"lg_distance":round(21.223,1),
                        "apple_distance":round(12.876,1)}}

@app.post("/ann")
async def ann(message: Message):
    print(message)

    with open("data/tree_final.json", "rb") as f:
        tree = json.load(f)
    
    with open("data/korea_final.json", "rb") as f:
        korea = json.load(f)
    
    print(korea)
    
    return {"status": "success", 
            "tree_route":tree, 
            "korea_route":korea,
            "distance":{"tree_distance":round(21.223,1),
                        "korea_distance":round(12.876,1)}}

@app.post("/local")
async def local(message: Message):
    print(message)

    with open("data/sungsu_final.json", "rb") as f:
        sungsu = json.load(f)
    
    with open("data/snu_final.json", "rb") as f:
        snu = json.load(f)

    with open("data/my_final.json", "rb") as f:
        my = json.load(f)
    
    
    return {"status": "success", 
            "sungsu_route":sungsu, 
            "snu_route":snu,
            "my_route":my,
            "distance":{"sungsu_distance":round(14.223,1),
                        "snu_distance":round(14.223,1),
                        "my_distance":round(12.876,1)}}


# ================================= 이미지 받아오기 ================================

import s3_connector
import io
from mimetypes import guess_type
from uuid import uuid4
import rotate_points

s3 = s3_connector.get_s3_connection()

@app.get("/s3_bucket")
def s3_bucket():
    return {"bkt":s3.list_buckets()['Buckets']}



@app.post("/upload_image")
async def upload_image(
    file: UploadFile = File(...),
    content: str = Form(...),
    lat: float = Form(...),
    lng: float = Form(...)):
    print(content, lat, lng)
    bucket_name = "runink-bucket"(37.557195,126.976003) # 용산
    _currentP = (37.557195,126.976003) # 용산
    try:
        # 파일 확장자 추출
        ext = '.' + (file.filename.split('.')[-1] if '.' in file.filename else '')(37.557195,126.976003) # 용산
        
        # 새로운 파일명 생성
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_id = str(uuid4())[:8]
        new_filename = f"img_{timestamp}_{unique_id}{ext}"
        
        # Content-Type 감지
        content_type, _ = guess_type(file.filename)
        if not content_type:
            content_type_map = {
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.png': 'image/png',
                '.gif': 'image/gif',
                '.bmp': 'image/bmp',
                '.webp': 'image/webp',
                '.svg': 'image/svg+xml'
            }
            content_type = content_type_map.get(ext.lower(), 'application/octet-stream')
        
        # 파일 내용 읽기
        file_content = await file.read()
        
        # S3에 업로드
        s3.upload_fileobj(
            io.BytesIO(file_content),
            bucket_name,
            new_filename,
            ExtraArgs={'ContentType': content_type}
        )
        
        # 업로드된 이미지의 URL 생성
        url = f"https://{bucket_name}.s3.ap-northeast-2.amazonaws.com/{new_filename}"
        
        print(url)
        
        image = img_load_s3.read_image_from_url(url)
        
        coords = image2course.draw_contour_on_map(image, lat_start=_currentP[0], lon_start=_currentP[1])
        coords = rotate_points.rotate_coordinates(coords, 12)
        full_route, distance = course_search.get_full_route(coords)
        full_route_json = {"routes":[[{"lat":y,"lng":x} for x,y in full_route]]}

        print(full_route)
        
        return {"status": "success", 
        "url":url,
        "route":full_route_json,
        "distance":{"route_distance":round(distance/1000,1)}}

        
        

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                'status': 'error',
                'message': str(e)
            }
        )


################################################## Ranking & rofile_image

@app.post("/rankings")
async def rankings():
    
    return {"myrank":int(22),
            "crewrank":int(11)}




# 엔드포인트 수정
@app.post("/set_profile_img")
async def set_profile_img(
    userId: str = Form(...),  # Form 필드로 변경
    file: UploadFile = File(...),
    bucket_name: str = "runink-bucket"
):
    try:
        # 파일 확장자 추출
        ext = '.' + (file.filename.split('.')[-1] if '.' in file.filename else '')
        
        # 새로운 파일명 생성
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_id = str(uuid4())[:8]
        new_filename = f"img_{timestamp}_{unique_id}{ext}"
        
        # Content-Type 감지
        content_type, _ = guess_type(file.filename)
        if not content_type:
            content_type_map = {
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.png': 'image/png',
                '.gif': 'image/gif',
                '.bmp': 'image/bmp',
                '.webp': 'image/webp',
                '.svg': 'image/svg+xml'
            }
            content_type = content_type_map.get(ext.lower(), 'application/octet-stream')
        
        # 파일 내용 읽기
        file_content = await file.read()
        
        # S3에 업로드
        s3.upload_fileobj(
            io.BytesIO(file_content),
            bucket_name,
            new_filename,
            ExtraArgs={'ContentType': content_type}
        )
        
        # 업로드된 이미지의 URL 생성
        url = f"https://{bucket_name}.s3.ap-northeast-2.amazonaws.com/{new_filename}"
        print(url)
        print("이미지 업로드 성공")
        
        conn = get_db_connection()
        if not conn:
            print("데이터베이스 연결 실패")
            return {"status": "error", "message": "Database connection failed"}

        try:
            cursor = conn.cursor()
            cursor.execute("UPDATE user SET profile_image = %s WHERE email = %s", (url, userId))
            conn.commit()
            print("success!")
            return {"status": "success", "url": url}

        except pymysql.Error as e:
            print(f"데이터베이스 오류: {e}")
            return {"status": "error", "message": str(e)}
        finally:
            conn.close()

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                'status': 'error',
                'message': str(e)
            }
        )