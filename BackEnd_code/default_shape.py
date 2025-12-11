import math
import numpy as np

# =================== 하트 ============================
def generate_heart_coordinates(bottom_lat: float, bottom_lon: float, size_km: float = 1, num_points: int = 20):
    """
    입력된 위경도를 하트 모양의 아래쪽 꼭지점으로 하는 GPS 좌표들을 생성합니다.
    
    Parameters:
    bottom_lat (float): 하트 아래쪽 꼭지점의 위도
    bottom_lon (float): 하트 아래쪽 꼭지점의 경도
    size_km (float): 하트 모양의 크기(km 단위)
    num_points (int): 반환할 점의 개수
    
    Returns:
    list: [(lat1, lon1), (lat2, lon2), ...] 형태의 좌표 리스트
    """
    # 입력값 검증
    if not -90 <= bottom_lat <= 90:
        raise ValueError("위도는 -90에서 90 사이여야 합니다")
    if not -180 <= bottom_lon <= 180:
        raise ValueError("경도는 -180에서 180 사이여야 합니다")
    if size_km <= 0:
        raise ValueError("크기는 0보다 커야 합니다")
    if num_points < 3:
        raise ValueError("좌표점은 최소 3개 이상이어야 합니다")
    
    # t 매개변수 생성
    t = np.linspace(0, 2*np.pi, num_points)
    
    # 하트 모양 방정식
    x = 16 * np.sin(t)**3
    y = 13 * np.cos(t) - 5 * np.cos(2*t) - 2 * np.cos(3*t) - np.cos(4*t)
    
    # 크기 조정
    scale = size_km / max(np.max(np.abs(x)), np.max(np.abs(y)))
    x = x * scale
    y = y * scale
    
    # 하트의 중심점을 아래쪽 꼭지점 기준으로 조정
    # 하트 방정식에서 아래쪽 꼭지점의 y 위치가 약 -15임
    y_offset_to_center = 15 * scale
    
    # 위경도 변환 상수
    KM_PER_LAT_DEGREE = 111.32
    
    # 위경도 변환
    cos_lat = np.cos(np.radians(bottom_lat))
    lat_offset = y / KM_PER_LAT_DEGREE
    lon_offset = x / (KM_PER_LAT_DEGREE * cos_lat)
    
    # 아래쪽 꼭지점 기준으로 좌표 조정
    latitudes = bottom_lat + lat_offset + (y_offset_to_center / KM_PER_LAT_DEGREE)
    longitudes = bottom_lon + lon_offset
    
    # 결과를 (위도, 경도) 쌍의 리스트로 반환
    return list(zip(latitudes, longitudes))


# ===================== 정사각형 ===========================
def generate_square_coordinates(lat, lon, side_km=1.5):
    
    """
    주어진 위경도를 북동쪽 꼭짓점으로 하는 정사각형의 네 꼭짓점 좌표를 계산합니다.
    
    Args:
        lat (float): 기준점의 위도 (도 단위)
        lon (float): 기준점의 경도 (도 단위)
        side_km (float): 정사각형의 한 변의 길이 (킬로미터 단위, 기본값 1km)
    
    Returns:
        dict: 정사각형의 네 꼭짓점 좌표 (북동, 북서, 남서, 남동 순)
    """
    
    # 1도당 거리 계산 (km)
    lat_km_per_degree = 111.0  # 위도 1도당 약 111km
    lon_km_per_degree = 111.0 * abs(math.cos(math.radians(lat)))  # 경도 1도당 거리는 위도에 따라 다름
    
    # 거리를 도(degree) 단위로 변환
    lat_diff = side_km / lat_km_per_degree
    lon_diff = side_km / lon_km_per_degree
    
    # 네 꼭짓점의 좌표 계산
    coordinates = [(lat, lon), (lat, lon - lon_diff), (lat - lat_diff, lon - lon_diff), (lat - lat_diff, lon)]
    
    return coordinates


# ===================== 별 ===========================
def generate_star_coordinates(center_lat, center_lon, size_km=1.5):
    """
    주어진 중심점 위경도를 기준으로 별 모양의 좌표들을 계산합니다.
    
    Args:
        center_lat (float): 중심점의 위도 (도 단위)
        center_lon (float): 중심점의 경도 (도 단위)
        size_km (float): 별의 크기 (중심에서 외곽 꼭짓점까지의 거리, 킬로미터 단위)
    
    Returns:
        list: 별 모양을 이루는 좌표점들의 리스트
    """
    # 1도당 거리 계산 (km)
    lat_km_per_degree = 111.0
    lon_km_per_degree = 111.0 * abs(math.cos(math.radians(center_lat)))
    
    # 별의 각도 계산 (5개의 꼭짓점)
    angles = [math.radians(90 + (i * 72)) for i in range(5)]  # 72도 간격으로 5개의 점
    inner_angles = [math.radians(90 + 36 + (i * 72)) for i in range(5)]  # 내부 점들
    
    # 내부 반지름 계산 (외부 반지름의 약 0.382배 - 황금비율)
    inner_size_km = size_km * 0.382
    
    coordinates = []
    for i in range(5):
        # 외곽 꼭짓점 계산
        outer_lat_diff = size_km * math.cos(angles[i]) / lat_km_per_degree
        outer_lon_diff = size_km * math.sin(angles[i]) / lon_km_per_degree
        coordinates.append((
            center_lat + outer_lat_diff,
            center_lon + outer_lon_diff
        ))
        
        # 내부 꼭짓점 계산
        inner_lat_diff = inner_size_km * math.cos(inner_angles[i]) / lat_km_per_degree
        inner_lon_diff = inner_size_km * math.sin(inner_angles[i]) / lon_km_per_degree
        coordinates.append((
            center_lat + inner_lat_diff,
            center_lon + inner_lon_diff
        ))
    
    # 처음 점으로 다시 돌아가기 위해 첫 번째 점을 마지막에 추가
    coordinates.append(coordinates[0])
    
    return coordinates[:10]

