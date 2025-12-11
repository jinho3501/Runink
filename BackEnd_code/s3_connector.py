import os
from mimetypes import guess_type
from uuid import uuid4
from datetime import datetime
import boto3
from botocore.exceptions import ClientError, NoCredentialsError, CredentialRetrievalError

def get_s3_connection():
    try:
        s3 = boto3.client(
            "s3",
            aws_access_key_id="AKIAYRH5M3YSPACG64F6",
            aws_secret_access_key="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",
        )
        # 연결 테스트
        s3.list_buckets()
        return s3
        
    except (NoCredentialsError, CredentialRetrievalError, ClientError, Exception) as e:
        print(f"S3 연결 오류: {str(e)}")
        return None


s3 = get_s3_connection()

def upload_img(img_path, bucket_name="runink-bucket"):
    try:
        # 원본 파일의 확장자 추출
        _, ext = os.path.splitext(img_path)
        
        # 새로운 파일명 생성 (UUID + 타임스탬프)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_id = str(uuid4())[:8]  # UUID 앞 8자리만 사용
        new_filename = f"img_{timestamp}_{unique_id}{ext}"
        
        # Content-Type 감지
        content_type, _ = guess_type(img_path)
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

        # 이미지 업로드
        s3.upload_file(
            img_path,
            bucket_name,
            new_filename,
            ExtraArgs={'ContentType': content_type}
        )
        print(f"이미지 업로드 성공: {new_filename}")
        print(f"Content-Type: {content_type}")
        
        # 업로드된 이미지의 URL 반환
        url = f"https://{bucket_name}.s3.ap-northeast-2.amazonaws.com/{new_filename}"
        print(f"이미지 URL: {url}")
        
        # 파일 정보 반환
        return {
            'url': url,
            'filename': new_filename,
            'content_type': content_type,
            'size': os.path.getsize(img_path)
        }

    except FileNotFoundError:
        print(f"파일을 찾을 수 없습니다: {img_path}")
        return None
        
    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', 'Unknown')
        if error_code == 'NoSuchBucket':
            print(f"버킷을 찾을 수 없습니다: {bucket_name}")
        elif error_code == 'AccessDenied':
            print("버킷에 접근 권한이 없습니다.")
        else:
            print(f"업로드 중 오류 발생: {str(e)}")
        return None
        
    except Exception as e:
        print(f"예상치 못한 오류 발생: {str(e)}")
        return None
