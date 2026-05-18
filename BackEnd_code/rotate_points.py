import numpy as np

def rotate_coordinates(coordinates, angle_degrees):
    """
    첫 번째 좌표를 기준으로 나머지 위경도 좌표들을 회전시킵니다.
    
    Args:
        coordinates: (위도, 경도) 튜플의 리스트
        angle_degrees: 회전할 각도 (도 단위, 시계방향 양수)
        
    Returns:
        list: 회전된 (위도, 경도) 튜플의 리스트
    """
    if not coordinates:
        return []
    
    # 기준점 (첫 번째 좌표)
    base_lat, base_lon = coordinates[0]
    
    # 라디안으로 변환
    angle_rad = np.radians(angle_degrees)
    
    # 회전 행렬
    rotation_matrix = np.array([
        [np.cos(angle_rad), -np.sin(angle_rad)],
        [np.sin(angle_rad), np.cos(angle_rad)]
    ])
    
    # 결과 저장을 위한 리스트
    rotated_coordinates = [(base_lat, base_lon)]  # 기준점은 그대로 유지
    
    # 위경도를 km 단위로 변환하기 위한 상수
    lat_to_km = 111  # 위도 1도 = 약 111km
    
    for lat, lon in coordinates[1:]:
        # 1. 기준점으로부터의 상대적 거리를 km 단위로 변환
        lat_diff_km = (lat - base_lat) * lat_to_km
        # 경도 차이는 위도에 따라 거리가 달라지므로 보정
        lon_to_km = 111 * np.cos(np.radians(base_lat))
        lon_diff_km = (lon - base_lon) * lon_to_km
        
        # 2. km 단위의 좌표에 회전 행렬 적용
        point = np.array([lon_diff_km, lat_diff_km])
        rotated_point = rotation_matrix @ point
        
        # 3. 회전된 km 좌표를 다시 위경도로 변환
        new_lat = base_lat + (rotated_point[1] / lat_to_km)
        new_lon = base_lon + (rotated_point[0] / lon_to_km)
        
        rotated_coordinates.append((new_lat, new_lon))
    
    return rotated_coordinates
