"""PostgreSQL connection helper. Credentials come from the project .env file."""
import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import URL, Engine, create_engine


def get_engine(env_path: Path) -> Engine:
    """Create a SQLAlchemy engine from PGUSER/PGPASSWORD/PGHOST/PGPORT/PGDATABASE in `env_path`."""
    load_dotenv(env_path, override=True)
    return create_engine(URL.create(
        "postgresql+psycopg2",
        username=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
        host=os.environ["PGHOST"],
        port=int(os.environ["PGPORT"]),
        database=os.environ["PGDATABASE"],
    ))
