"""노트북에서 함께 쓰는 시각화 도우미 함수."""
import sys

import matplotlib.pyplot as plt


def set_korean_font() -> None:
    """한글 시스템 글꼴(macOS는 AppleGothic, Windows는 맑은 고딕)을 쓰고 마이너스 기호가 깨지지 않게 함."""
    plt.rcParams["font.family"] = "AppleGothic" if sys.platform == "darwin" else "Malgun Gothic"
    plt.rcParams["axes.unicode_minus"] = False


def quarter_label(quarter: str) -> str:
    """'20231' 같은 분기 코드를 '23.1Q' 같은 축 레이블로 바꿈."""
    return f"{quarter[2:4]}.{quarter[4]}Q"
