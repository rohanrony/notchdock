from PIL import Image
import sys

def extract(gif_path, out_path):
    with Image.open(gif_path) as im:
        im.seek(0)
        im.convert('RGB').save(out_path, 'JPEG')

if __name__ == "__main__":
    extract('public/assets/SportsModule.gif', 'sports_frame.jpg')
    extract('public/assets/StocksModule.gif', 'stocks_frame.jpg')
