import cv2
import numpy as np
import requests
from urllib.parse import urlparse
import os

def read_image_from_url(url):
    try:
        # URL에서 파일명 추출
        parsed_url = urlparse(url)
        filename = os.path.basename(parsed_url.path)
        
        # 이미지 다운로드
        response = requests.get(url)
        if response.status_code != 200:
            raise Exception(f"이미지 다운로드 실패. 상태 코드: {response.status_code}")
            
        # 바이트 데이터를 numpy 배열로 변환
        image_array = np.asarray(bytearray(response.content), dtype=np.uint8)
        
        # numpy 배열을 OpenCV 이미지로 디코딩
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
        
        if image is None:
            raise Exception("이미지 디코딩 실패")
            
        return image
        
    except Exception as e:
        print(f"에러 발생: {str(e)}")
        return None