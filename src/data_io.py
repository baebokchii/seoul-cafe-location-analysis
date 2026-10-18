"""서울시 상권분석서비스 원자료를 읽는 도우미 함수."""
from pathlib import Path

import pandas as pd

# 코드 컬럼은 앞자리 0이 사라지지 않도록 문자열로 읽음
CODE_DTYPES = {"기준_년분기_코드": str, "상권_코드": str, "자치구_코드": str, "행정동_코드": str}


def load_yearly_csv(raw_dir: Path, pattern: str, rename_cols: dict[str, str] | None = None) -> pd.DataFrame:
    """`pattern`에 맞는 연도별 CSV를 모두 읽어 컬럼명을 맞춘 뒤 이어 붙임.

    원자료와 행 수를 대조할 수 있도록 파일마다 이름과 크기를 출력함.
    """
    frames = []
    for path in sorted(raw_dir.glob(pattern)):
        frame = pd.read_csv(path, encoding="cp949", dtype=CODE_DTYPES)
        print(path.name, frame.shape)
        frames.append(frame.rename(columns=rename_cols or {}))
    return pd.concat(frames, ignore_index=True)
