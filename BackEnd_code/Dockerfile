# Python 3.10 베이스 이미지 사용
FROM python:3.10-slim

# 작업 디렉토리 설정
WORKDIR /app

# OpenCV 및 필요한 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt 파일만 먼저 복사
COPY requirements.txt .

# pip 업그레이드
RUN pip install --upgrade pip

# 파이썬 패키지 설치
RUN pip install --no-cache-dir -r requirements.txt

# 나머지 프로젝트 파일 복사
COPY . .

# FastAPI 서버 포트 노출
EXPOSE 8000

# 서버 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]