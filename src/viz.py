"""Plot helpers shared by the notebooks."""
import matplotlib.pyplot as plt


def set_korean_font() -> None:
    """Use Malgun Gothic (Windows) so Korean labels render, and keep the minus sign readable."""
    plt.rcParams["font.family"] = "Malgun Gothic"
    plt.rcParams["axes.unicode_minus"] = False


def quarter_label(quarter: str) -> str:
    """Turn a quarter code such as '20231' into an axis label such as '23.1Q'."""
    return f"{quarter[2:4]}.{quarter[4]}Q"
