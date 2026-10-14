import FreeCAD
import Mesh
import os
import sys
import time
import colorsys
import threading
import shutil
from contextlib import contextmanager

# ANSI Color Codes
CYAN = '\033[96m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
MAGENTA = '\033[95m'
BLUE = '\033[94m'
RED = '\033[91m'
RESET = '\033[0m'
BOLD = '\033[1m'

from contextlib import contextmanager
import threading
import time
import colorsys

def rainbow_text(text):
    """Generates a perfectly smooth 24-bit true-color diagonal rainbow gradient"""
    result = ""
    lines = text.split('\n')
    max_w = max((len(l) for l in lines), default=1)
    
    for y, line in enumerate(lines):
        for x, char in enumerate(line):
            if char == ' ':
                result += char
                continue
            # Calculate hue based on x/y coordinates for a sweeping diagonal gradient
            hue = ((x / max_w) + (y / max(len(lines), 1)) * 0.3) % 1.0
            r, g, b = [int(c * 255) for c in colorsys.hsv_to_rgb(hue, 1.0, 1.0)]
            result += f"\033[38;2;{r};{g};{b}m{BOLD}{char}{RESET}"
        if y < len(lines) - 1:
            result += "\n"
    return result

@contextmanager
def silence_freecad():
    """Silences OS-level stdout and stderr to hide FreeCAD C++ spam"""
    old_stdout = os.dup(1)
    old_stderr = os.dup(2)
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, 1)
    os.dup2(devnull, 2)
    try:
        yield
    finally:
        os.dup2(old_stdout, 1)
        os.dup2(old_stderr, 2)
        os.close(devnull)
        os.close(old_stdout)
        os.close(old_stderr)

class FakeProgress:
    def __init__(self, action_text):
        self.action_text = action_text
        self.running = True
        self.t = threading.Thread(target=self._animate)
        self.t.daemon = True
        
    def start(self):
        self.t.start()
        
    def _animate(self):
        bar_length = 40
        # Fast up to 80% (approx 1.6s)
        for i in range(81):
            if not self.running:
                break
            pct = i
            filled = int(bar_length * pct / 100)
            bar = '█' * filled + '-' * (bar_length - filled)
            sys.stdout.write(f"\r{CYAN}{self.action_text.ljust(12)} {YELLOW}[{bar}] {pct}%{RESET}")
            sys.stdout.flush()
            time.sleep(0.02)
            
        # Creep slowly from 80% to 99% if it takes longer
        for i in range(81, 100):
            if not self.running:
                break
            pct = i
            filled = int(bar_length * pct / 100)
            bar = '█' * filled + '-' * (bar_length - filled)
            sys.stdout.write(f"\r{CYAN}{self.action_text.ljust(12)} {YELLOW}[{bar}] {pct}%{RESET}")
            sys.stdout.flush()
            time.sleep(0.2)
            
    def finish(self):
        self.running = False
        bar_length = 40
        bar = '█' * bar_length
        # Ensure we overwrite the whole line
        sys.stdout.write(f"\r{' '*70}\r{CYAN}{self.action_text.ljust(12)} {GREEN}[{bar}] 100%{RESET}\n")
        sys.stdout.flush()

def animate_intro():
    print(f"\n{CYAN}{BOLD}Initializing Open Brushograph Build System...{RESET}\n")
    
    # Pre-print empty lines so cursor up has space
    sys.stdout.write("\n" * 15)
    canvas = [[" "] * 60 for _ in range(4)]
    
    for slide in range(4):
        is_right = (slide % 2 == 0)
        y = slide
        
        if is_right:
            offsets = range(0, 30, 2)
        else:
            offsets = range(26, -1, -2)
            
        for offset in offsets:
            if is_right:
                if offset > 0:
                    canvas[y][offset+4] = "█"
                    canvas[y][offset+5] = "█"
            else:
                if offset < 28:
                    canvas[y][offset+11] = "█"
                    canvas[y][offset+12] = "█"
                    
            rendered_canvas = []
            for cy in range(4):
                line_str = ""
                for x in range(50):
                    if cy == y and (offset + 6 <= x < offset + 11):
                        brush_char = ".///."[x - (offset + 6)]
                        line_str += f"{MAGENTA}{brush_char}{RESET}"
                    else:
                        char = canvas[cy][x]
                        if char != " ":
                            hue = (x * 0.02 + cy * 0.1) % 1.0
                            r, g, b = [int(c * 255) for c in colorsys.hsv_to_rgb(hue, 1.0, 1.0)]
                            line_str += f"\033[38;2;{r};{g};{b}m{char}\033[0m"
                        else:
                            line_str += " "
                rendered_canvas.append(line_str)
                
            clear_pad = " " * 60
            pad = " " * offset
            carriage = [
                f"{YELLOW}{pad}      |||||{RESET}",
                f"{YELLOW}{pad}      |||||{RESET}",
                f"{CYAN}{pad}    __|||||__{RESET}",
                f"{CYAN}{pad}   /       /|{RESET}",
                f"{CYAN}{pad}  /_______/ |{RESET}",
                f"{CYAN}{pad}  |       | |{RESET}",
                f"{CYAN}{pad}  |  (*)  | |{RESET}",
                f"{CYAN}{pad}  |_______|/{RESET}",
                f"{MAGENTA}_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_/\\_{RESET}",
                f"{MAGENTA}/ / / / / / / / / / / / / / / / / / / / / / / / / / / / /{RESET}"
            ]
            
            frame_lines = []
            for row in range(14):
                if row <= y:
                    frame_lines.append(f"\r{clear_pad}\r{rendered_canvas[row]}")
                elif y < row <= y + 10:
                    c_idx = row - y - 1
                    frame_lines.append(f"\r{clear_pad}\r{carriage[c_idx]}")
                else:
                    frame_lines.append(f"\r{clear_pad}")
                    
            frame = "\n".join(frame_lines)
            sys.stdout.write('\033[14A')
            sys.stdout.write(frame + '\n')
            sys.stdout.flush()
            time.sleep(0.04)

    sys.stdout.write("\n")

def print_image_logo():
    logo = f"""
{YELLOW}               ^    ^{RESET}
{CYAN}             _/\\{YELLOW} \\  / {CYAN}\\_{RESET}
{CYAN}       ____ /{YELLOW}  / \\/ \\  {CYAN}\\ ____{RESET}
{CYAN}      /    \\|{YELLOW} /  /\\  \\ {CYAN}|/    \\{RESET}
{CYAN}      \\____/|{YELLOW}/  /  \\  \\|{CYAN}\\____/{RESET}
{CYAN}            |{YELLOW}  /    \\  {CYAN}|{RESET}
{CYAN}       ____ |{YELLOW} /      \\ {CYAN}| ____{RESET}
{CYAN}      /    \\|{YELLOW}/{CYAN}        {YELLOW}\\|{CYAN}/    \\{RESET}
{CYAN}      \\____/ \\_{YELLOW} /  \\ {CYAN}_/ \\____/{RESET}
{YELLOW}               \\ \\/ /{RESET}
{MAGENTA}             .///..\\\\\\.{RESET}
{MAGENTA}             | ||  || |{RESET}
{MAGENTA}             \\ //  \\\\ /{RESET}
{MAGENTA}              V      V{RESET}
"""
    print(logo)

def print_text_logo():
    raw_logo = r"""
                   ____  ____  _______   __
                  / __ \/ __ \/ ____/ | / /
                 / / / / /_/ / __/ /  |/ /
                / /_/ / ____/ /___/ /|  /
                \____/_/   /_____/_/ |_/
    ____  ____  __  _______ __  ______  __________  ___    ____  __  __
   / __ )/ __ \/ / / / ___// / / / __ \/ ____/ __ \/   |  / __ \/ / / /
  / __  / /_/ / / / /\__ \/ /_/ / / / / / __/ /_/ / /| | / /_/ / /_/ /
 / /_/ / _, _/ /_/ /___/ / __  / /_/ / /_/ / _, _/ ___ |/ ____/ __  /
/_____/_/ |_|\____//____/_/ /_/\____/\____/_/ |_/_/  |_/_/   /_/ /_/
"""
    print(rainbow_text(raw_logo.strip('\n')))
    print(f"{YELLOW}{BOLD}   >>> Bruschologischer Exportierzauberer <<<{RESET}")
    print(f"{MAGENTA}   This wizard automatically manipulates the FreeCAD spreadsheet,")
    print(f"   forces a deep topological geometry recomputation for the selected variant,")
    print(f"   and cleanly exports all resulting parts into ready-to-print STL folders.{RESET}\n")

def export_variant(doc, params_sheet, switcher_val, variant_name, base_file, m3_hole_str):
    print(f"\n{YELLOW}--- Building {variant_name} (Switcher: {switcher_val}, M3: {m3_hole_str}mm) ---{RESET}")
    
    try:
        params_sheet.set('B1', str(switcher_val))
    except Exception as e:
        print(f"{RED}Failed to toggle switcher: {e}{RESET}")
        return
            
    print(f"{BLUE}Forcing full geometry tree recompute...{RESET}")
    prog1 = FakeProgress("Recomputing")
    prog1.start()
    with silence_freecad():
        params_sheet.recompute()
        doc.recompute(None, True, True)
        doc.recompute()
    prog1.finish()

    # A feature that fails to recompute (e.g. a fillet whose edge reference no longer
    # resolves at this variant's size) leaves its body Touched, still holding the
    # previous variant's shape, and Mesh.export writes that stale shape regardless.
    failed = [obj for obj in doc.Objects if "Invalid" in obj.State]
    if failed:
        print(f"{RED}{BOLD}✗ {variant_name} did not recompute cleanly, nothing exported:{RESET}")
        for obj in failed:
            print(f"{RED}  - {obj.Label}: {obj.getStatusString()}{RESET}")
        return None

    doc_name = os.path.splitext(os.path.basename(base_file))[0]
    out_dir = os.path.join("STLs", f"{doc_name}_{variant_name}_M3_{m3_hole_str}mm")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
        
    exported = 0
    prog2 = FakeProgress("Exporting")
    prog2.start()
    with silence_freecad():
        for obj in doc.Objects:
            if obj.isDerivedFrom("App::Part"):
                label = obj.Label.replace("/", "_").replace("\\", "_").replace(" ", "_")
                # Swap the generic word 'part' for the actual variant name
                label = label.replace("part", variant_name)
                out_path = os.path.join(out_dir, f"{label}_M3_{m3_hole_str}mm.stl")
                Mesh.export([obj], out_path)
                exported += 1
    prog2.finish()
    print(f"{GREEN}✓ Exported {exported} items to {out_dir}/{RESET}")
    return out_dir

def main():
    print_image_logo()
    animate_intro()
    print_text_logo()
    
    base_file = None
    for arg in sys.argv:
        if arg.lower().endswith(".fcstd"):
            base_file = arg
            break
            
    if not base_file:
        print(f"{RED}Usage: FreeCADCmd build_versions.py <file.FCStd>{RESET}")
        sys.exit(1)
        
    print(f"{BLUE}Opening {base_file} (Silencing FreeCAD boot noise)...{RESET}")
    prog0 = FakeProgress("Importing")
    prog0.start()
    with silence_freecad():
        doc = FreeCAD.open(base_file)
    prog0.finish()

    # Python-backed features (the gears and racks from the Gears add-on) lose their
    # Proxy when their add-on can't be imported. They then never recompute and keep
    # the shape saved in the file, so every variant gets the saved variant's teeth.
    broken = [obj for obj in doc.Objects if "Proxy" in obj.PropertiesList and obj.Proxy is None]
    if broken:
        print(f"{RED}{BOLD}These objects can't be recomputed, their add-on failed to load:{RESET}")
        for obj in broken:
            print(f"{RED}  - {obj.Label} ({obj.TypeId}){RESET}")
        print(f"{YELLOW}The gears and racks need the 'Gears' workbench (freecad.gears).")
        print(f"Install it with FreeCAD's Addon Manager, then run this again.{RESET}")
        sys.stdout.flush()
        os._exit(1)

    params_sheet = None
    for obj in doc.Objects:
        if obj.isDerivedFrom("Spreadsheet::Sheet") and ("param" in obj.Name.lower() or "param" in obj.Label.lower()):
            params_sheet = obj
            break
            
    if not params_sheet:
        print(f"{RED}Spreadsheet not found!{RESET}")
        sys.exit(1)
        
    variants = []
    # Scan Row 1 starting from Column C (switcher value 1)
    cols = [chr(i) for i in range(ord('C'), ord('Z')+1)]
    for idx, col in enumerate(cols):
        try:
            val = params_sheet.get(f"{col}1")
            if val and isinstance(val, str):
                # Ignore notes or empty columns
                if val.strip().lower() in ["notes", "", "None"]:
                    continue
                # Clean up the "(1) " prefix if the user typed it
                clean_name = val.strip()
                if clean_name.startswith("(") and ")" in clean_name:
                    clean_name = clean_name.split(")", 1)[1].strip()
                    
                # Standardize the spelling to Mikro
                if clean_name.lower() == "micro":
                    clean_name = "Mikro"
                    
                variants.append((idx + 1, clean_name))
        except:
            pass
            
    # Fallback just in case row 1 is completely empty
    if not variants:
        variants = [
            (1, "Mini"),
            (2, "Mini_ins"),
            (3, "Baby_ins"),
            (4, "Mikro")
        ]
    
    while True:
        try:
            m3_hole = params_sheet.get('M3_hole_diameter_3d_printing')
            if isinstance(m3_hole, str) and m3_hole.endswith(" mm"):
                m3_hole = m3_hole[:-3]
        except:
            m3_hole = "Unknown"

        print(f"\n{CYAN}{'='*50}{RESET}")
        print(f"{BOLD}   What would you like to build?{RESET}")
        print(f"{CYAN}{'='*50}{RESET}")
        for val, name in variants:
            print(f"  {GREEN}{val}.{RESET} {name}")
        print(f"  {YELLOW}A.{RESET} Build ALL variants")
        print(f"  {RED}0.{RESET} Exit")
        print(f"{CYAN}{'='*50}{RESET}")
        
        choice = input(f"{BOLD}Select an option:{RESET} ").strip().lower()
        
        if choice == '0':
            print(f"{YELLOW}Exiting...{RESET}")
            break
            
        is_all = (choice == 'a' or choice == 'all')
        matched = None
        
        if not is_all:
            try:
                choice_int = int(choice)
                matched = next((v for v in variants if v[0] == choice_int), None)
            except ValueError:
                pass
                
        if is_all or matched:
            print("")
            new_val = input(f"{BOLD}What size should the M3 hole be? (Press enter to keep current: {m3_hole} mm):{RESET} ").strip()
            
            if new_val:
                try:
                    float_val = float(new_val)
                    params_sheet.set('M3_hole_diameter_3d_printing', f"{float_val} mm")
                    print(f"{GREEN}✓ M3 hole diameter updated to {float_val} mm!{RESET}")
                    m3_hole = str(float_val)
                except ValueError:
                    print(f"{RED}Invalid input. Aborting build.{RESET}")
                    continue
                    
            if is_all:
                print(f"\n{MAGENTA}Building ALL variants...{RESET}")
                failed = [name for val, name in variants
                          if export_variant(doc, params_sheet, val, name, base_file, m3_hole) is None]
                if failed:
                    print(f"\n{RED}{BOLD}✗ Failed: {', '.join(failed)}{RESET}")
                else:
                    print(f"\n{GREEN}{BOLD}✓ All builds complete!{RESET}")
                break
            else:
                if export_variant(doc, params_sheet, matched[0], matched[1], base_file, m3_hole) is None:
                    print(f"\n{RED}{BOLD}✗ Build failed!{RESET}")
                else:
                    print(f"\n{GREEN}{BOLD}✓ Build complete!{RESET}")
                break
        else:
            print(f"{RED}Invalid input. Please enter a valid number or 'A'.{RESET}")

    with silence_freecad():
        FreeCAD.closeDocument(doc.Name)
        
    # Brutally terminate the process at the OS level so FreeCAD doesn't 
    # run its C++ teardown sequence and dump thread definition spam at the very end
    sys.stdout.flush()
    os._exit(0)

main()
