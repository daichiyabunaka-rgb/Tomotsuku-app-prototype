"""ともつく！（総合版）配布用アプリアイコン（1024px）を作るスクリプト。
Pillow でフラットデザインの「ハブ（中心と結ばれた仲間のネットワーク）」を描く。生成物:
  - app/assets/icon/app_icon.png      （flutter_launcher_icons のソース）
"""
from PIL import Image, ImageDraw
import math

SIZE = 1024
BG = (232, 236, 242)        # ライトグレー（シリーズ共通の落ち着いた背景色）
EDGE = (46, 58, 74)         # 影（ダークネイビー）
HUB = (39, 143, 90)         # 中心のハブ（シリーズ緑）
NODE_COLORS = [
    (239, 68, 68),    # 赤
    (245, 158, 11),   # 黄
    (59, 130, 246),   # 青
    (168, 85, 247),   # 紫
    (20, 184, 166),   # ティール
    (236, 72, 153),   # ピンク
]


def rounded(im, radius):
    mask = Image.new("L", im.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=255)
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def draw_hub():
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    # 背景（角丸ライトグレー）
    d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=192, fill=BG + (255,))

    cx, cy = 512, 512
    r_nodes = 300
    hub_r = 128
    node_r = 76

    # 各ノードの位置（6方向）
    positions = []
    for i in range(6):
        a = math.radians(-90 + i * 60)
        positions.append((cx + r_nodes * math.cos(a), cy + r_nodes * math.sin(a)))

    # 影（全体を少し下にずらした同形）
    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ds = ImageDraw.Draw(shadow)
    for (nx, ny) in positions:
        ds.ellipse([nx - node_r, ny - node_r, nx + node_r, ny + node_r], fill=EDGE + (255,))
    for (nx, ny) in positions:
        ds.line([cx, cy, nx, ny], fill=EDGE + (255,), width=44)
    ds.ellipse([cx - hub_r, cy - hub_r, cx + hub_r, cy + hub_r], fill=EDGE + (255,))
    shadow = shadow.resize((SIZE + 40, SIZE + 40)).resize((SIZE, SIZE))
    im.alpha_composite(shadow, (10, 12))

    # 中心へ向かう線（緑）
    for (nx, ny) in positions:
        d.line([cx, cy, nx, ny], fill=HUB + (255,), width=36)

    # 周囲の仲間ノード（趣味の色）
    for (nx, ny), c in zip(positions, NODE_COLORS):
        d.ellipse([nx - node_r + 6, ny - node_r + 6, nx + node_r + 6, ny + node_r + 6], fill=(255, 255, 255, 90))
        d.ellipse([nx - node_r, ny - node_r, nx + node_r, ny + node_r], fill=c + (255,))

    # 中心のハブ（白抜きの緑円）
    d.ellipse([cx - hub_r, cy - hub_r, cx + hub_r, cy + hub_r], fill=HUB + (255,))
    d.ellipse([cx - 62, cy - 62, cx + 62, cy + 62], fill=(250, 250, 250, 255))
    d.ellipse([cx - 26, cy - 26, cx + 26, cy + 26], fill=HUB + (255,))

    return im


if __name__ == "__main__":
    im = draw_hub()
    im = rounded(im, 192)
    out = r"..\app\assets\icon\app_icon.png"
    im.save(out)
    print("saved:", out)
