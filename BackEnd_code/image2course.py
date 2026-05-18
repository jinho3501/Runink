import cv2
import numpy as np
import geopandas as gpd
from shapely.geometry import Point

# im_read = cv2.imread("/home/sungil/Byte-King/라미의_공간/image/lg_logo.png")
# plt.imshow(cv2.cvtColor(im_read, cv2.COLOR_BGR2RGB))
# plt.show()

def draw_contour_on_map(image, lat_start=37.555795, lon_start=126.948345, size_km=2.5, epsilon_factor=0.01):
    """
    이미지의 외곽선을 추출하고 주요 점들만 위경도 좌표로 변환합니다.
    
    Args:
        image: 입력 이미지
        lat_start: 시작 위도
        lon_start: 시작 경도
        size_km: 이미지가 나타내는 실제 크기(km)
        epsilon_factor: 외곽선 단순화 정도 (0.01 = 1%)
    
    Returns:
        list: (위도, 경도) 튜플의 리스트
    """
    # 1. 이미지 로드 및 외곽선 추출
    edges = cv2.Canny(image, 100, 200)
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if not contours:
        return []
    
    # 가장 큰 외곽선 선택
    main_contour = max(contours, key=cv2.contourArea)
    
    # 2. 외곽선 단순화
    epsilon = epsilon_factor * cv2.arcLength(main_contour, True)
    simplified_contour = cv2.approxPolyDP(main_contour, epsilon, True)
    
    # 3. 바운딩 박스 계산
    x, y, w, h = cv2.boundingRect(simplified_contour)
    
    # 4. 위경도와 이미지 픽셀 간 변환을 위한 설정
    pixel_size = max(w, h)
    km_per_pixel = size_km / pixel_size
    
    # 픽셀에서 각 위경도 거리 계산
    lat_step = km_per_pixel / 111
    lon_step = km_per_pixel / (111 * np.cos(np.radians(lat_start)))
    
    # 5. 단순화된 외곽선 점들을 위경도로 변환
    coordinates = []
    for point in simplified_contour:
        px, py = point[0]
        # 바운딩 박스 기준으로 상대적 위치 계산
        rel_x = px - x
        rel_y = py - y
        
        # y축 방향 반전: h에서 rel_y를 빼서 좌표계 방향 전환
        lat = lat_start + ((h - rel_y) * lat_step)  # 수정된 부분
        lon = lon_start + (rel_x * lon_step)
        coordinates.append((lat, lon))
    
    return coordinates














