"""Loading helpers for the Seoul commercial-district (상권분석서비스) raw files."""
from pathlib import Path

import pandas as pd

# Code columns must stay strings so leading zeros are not lost.
CODE_DTYPES = {"기준_년분기_코드": str, "상권_코드": str, "자치구_코드": str, "행정동_코드": str}


def load_yearly_csv(raw_dir: Path, pattern: str, rename_cols: dict[str, str] | None = None) -> pd.DataFrame:
    """Read every yearly CSV matching `pattern`, align column names and concatenate.

    Prints each file's name and shape so the row counts can be checked against the source.
    """
    frames = []
    for path in sorted(raw_dir.glob(pattern)):
        frame = pd.read_csv(path, encoding="cp949", dtype=CODE_DTYPES)
        print(path.name, frame.shape)
        frames.append(frame.rename(columns=rename_cols or {}))
    return pd.concat(frames, ignore_index=True)
