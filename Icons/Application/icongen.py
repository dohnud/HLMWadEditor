import os
import shutil
import subprocess
from wand.image import Image


class Res:
    size : int
    scale : int = 1
    def __init__(self, _size ,_scale=1):
        self.size = _size
        self.scale = _scale

# for the sake of your sanity DO NOT CHANGE THESE UNLESS GODOT ICON STANDARDS CHANGE
WIN_SIZES = [
    Res(256),
    Res(128),
    Res(64),
    Res(48),
    Res(32),
    Res(16),
]
MAC_SIZES = [
    Res(512, 2), Res(512, 1),
    Res(256, 2), Res(256, 1),
    Res(128, 2), Res(128, 1),
    Res(32,  2), Res(32,  1),
    Res(16,  2), Res(16,  1)
]

WIN_EXT = 'ico'
MAC_EXT = 'icns'


def main():
    platform_answer = prompt_valid_platform()
    if platform_answer == 'm':
        src_image_path = prompt_valid_image_path(WIN_EXT)
        gen_mac_icns(src_image_path)
    else:
        src_image_path = prompt_valid_image_path(MAC_EXT)
        gen_win_ico(src_image_path)

def gen_win_ico(src_image_path : str):
    icon_image_path = f'{src_image_path[:-3]}{WIN_EXT}'

    if os.path.exists(icon_image_path):
        print('[!] Removing old icon file:', icon_image_path, '...')
        os.remove(icon_image_path)
    print('[$] Creating new icon at:', icon_image_path, '...')

    with Image(width=WIN_SIZES[0].size, height=WIN_SIZES[0].size, format=WIN_EXT) as icon_image:
        icon_image.sequence.clear()
        with Image(filename=src_image_path) as img:
            if img.size[0] != img.size[1]:
                print('[ERROR] Must use image with 1:1 dimensions (ex: 512x512, 1024x1024')
                quit()
            for res in WIN_SIZES:
                icon = img.convert('png')
                icon.sample(res.size * res.scale, res.size * res.scale)
                icon_image.sequence.append(icon)
        icon_image.save(filename=icon_image_path)
        print(f'[SUCCESS] icon was successfully saved to {icon_image_path}')


def gen_mac_icns(src_image_path : str):
    icon_image_path = f'{src_image_path[:-3]}{MAC_EXT}'
    icon_folder_path = f'{src_image_path[:-3]}iconset'

    if os.path.exists(icon_image_path):
        print('[!] Removing old icon file:', icon_image_path, '...')
        os.remove(icon_image_path)
    if os.path.exists(icon_folder_path):
        print('[!] Removing old iconset:', icon_folder_path, '...')
    else:
        os.mkdir(icon_folder_path)
    print('[$] Creating new icon at:', icon_image_path, '...')

    with Image(width=WIN_SIZES[0].size, height=WIN_SIZES[0].size, format=WIN_EXT) as icon_image:
        icon_image.sequence.clear()
        with Image(filename=src_image_path) as img:
            if img.size[0] != img.size[1]:
                print('[ERROR] Must use image with 1:1 dimensions (ex: 512x512, 1024x1024')
                quit()
            for res in MAC_SIZES:
                icon = img.convert('png')
                icon.sample(res.size * res.scale, res.size * res.scale)
                if res.scale > 1:
                    icon.save(filename=f'{icon_folder_path}/icon_{res.size}x{res.size}@{res.scale}x.png')
                else:
                    icon.save(filename=f'{icon_folder_path}/icon_{res.size}x{res.size}.png')

    result = subprocess.run(
        f'iconutil -c icns {icon_folder_path} -o {icon_image_path}',
        capture_output=True,
        text=True
    )
    # hide the evidence!
    shutil.rmtree(icon_folder_path)
    # quit
    if result.returncode != 0:
        raise SystemExit(" ".join((
            f"[ERROR] iconutil could not generate",
            f"an iconset. {result.stderr.strip()}"
        )))
    else:
        print(
            "[SUCCESS] An iconset was successfully",
            f"generated to {icon_image_path}"
        )
        raise SystemExit(0)

def prompt_valid_platform():
    """Returns 'm' for macOS or 'w' for Windows
    """
    platform_answer = input('[?] macOS icns (m) or Windows ico (w)? ').strip()[0]
    while( not(platform_answer == 'm' or platform_answer == 'w') ):
        print('[!] Answer must start with `m` or `w`')
        platform_answer = input('[?] macOS (m) or Windows (w)? ').strip()[0]
    return platform_answer

def prompt_valid_image_path(EXT):
    _input = input('[?] Path to .png image to generate .'+EXT+' :')
    while( not(os.path.exists(_input)) ):
        print('[!] No such file', _input, '...')
        _input = input('[?] Path to .png image to generate .'+EXT+' :')
    return _input

main()