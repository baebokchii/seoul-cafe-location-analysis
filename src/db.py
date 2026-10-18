"""PostgreSQL 연결 도우미. 접속 정보는 프로젝트의 .env 파일에서 읽음."""
import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import URL, Engine, create_engine


def get_engine(env_path: Path) -> Engine:
    """`env_path`의 PGUSER/PGPASSWORD/PGHOST/PGPORT/PGDATABASE로 SQLAlchemy 엔진을 만듦."""
    load_dotenv(env_path, override=True)
    return create_engine(URL.create(
        "postgresql+psycopg2",
        username=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
        host=os.environ["PGHOST"],
        port=int(os.environ["PGPORT"]),
        database=os.environ["PGDATABASE"],
    ))
