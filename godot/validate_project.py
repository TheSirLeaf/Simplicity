#!/usr/bin/env python3
"""
Script para validar a estrutura do projeto Godot antes de abrir no editor.
Verifica se os arquivos essenciais existem e têm sintaxe básica correta.
"""

import os
import sys

PROJECT_ROOT = r"C:\Users\patri\Desktop\Projects\Simplicity\godot"

ESSENTIAL_FILES = [
    "project.godot",
    "icon.svg",
    "README.md",
    "core/planet_math.gd",
    "core/chunk_data.gd",
    "systems/chunk_loader.gd",
    "systems/global_mega_structures.gd",
    "scenes/main.tscn",
    "scenes/main.gd",
    "scenes/orbital/OrbitalView.tscn",
    "scenes/orbital/OrbitalView.gd",
    "scenes/local/LocalView.tscn",
    "scenes/local/LocalView.gd",
    "scenes/ui/CubeMapView.tscn",
    "scenes/ui/CubeMapView.gd",
    "resources/shaders/planet_shader.gdshader",
    "resources/environment.tres",
    "resources/textures/tile_atlas.png",
]

GDSCRIPT_KEYWORDS = ["extends", "class_name", "func", "var", "const", "signal", "static"]

def check_file_exists(path):
    return os.path.exists(os.path.join(PROJECT_ROOT, path))

def check_gdscript_basic_syntax(path):
    """Verifica sintaxe básica de arquivos .gd"""
    full_path = os.path.join(PROJECT_ROOT, path)
    try:
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Verificações básicas
        issues = []
        
        # Deve ter extends
        if not any(line.strip().startswith("extends ") for line in content.split('\n')):
            issues.append("Missing 'extends'")
        
        # Deve ter class_name (para autoloads e classes)
        if "class_name" not in content:
            issues.append("Missing 'class_name'")
        
        # Verifica parênteses balanceados (básico)
        open_paren = content.count('(')
        close_paren = content.count(')')
        if open_paren != close_paren:
            issues.append(f"Unbalanced parentheses: {open_paren} open, {close_paren} close")
        
        # Verifica colchetes balanceados
        open_bracket = content.count('[')
        close_bracket = content.count(']')
        if open_bracket != close_bracket:
            issues.append(f"Unbalanced brackets: {open_bracket} open, {close_bracket} close")
        
        # Verifica chaves balanceadas
        open_brace = content.count('{')
        close_brace = content.count('}')
        if open_brace != close_brace:
            issues.append(f"Unbalanced braces: {open_brace} open, {close_brace} close")
        
        return issues
    except Exception as e:
        return [f"Error reading file: {e}"]

def check_tscn_basic(path):
    """Verifica estrutura básica de .tscn"""
    full_path = os.path.join(PROJECT_ROOT, path)
    try:
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        issues = []
        
        if not content.startswith("[gd_scene"):
            issues.append("Missing [gd_scene header]")
        
        if "ExtResource" not in content and "SubResource" not in content:
            issues.append("No resources referenced")
        
        return issues
    except Exception as e:
        return [f"Error reading file: {e}"]

def main():
    print("=" * 60)
    print("VALIDAÇÃO DO PROJETO GODOT - SIMPLICITY")
    print("=" * 60)
    
    all_ok = True
    
    print("\n1. Verificando existência dos arquivos essenciais...")
    for f in ESSENTIAL_FILES:
        exists = check_file_exists(f)
        status = "[OK]" if exists else "[MISSING]"
        print(f"  {status} {f}")
        if not exists:
            all_ok = False
    
    print("\n2. Verificando sintaxe básica dos scripts .gd...")
    gd_files = [f for f in ESSENTIAL_FILES if f.endswith('.gd')]
    for f in gd_files:
        issues = check_gdscript_basic_syntax(f)
        if issues:
            print(f"  [FAIL] {f}:")
            for issue in issues:
                print(f"    - {issue}")
            all_ok = False
        else:
            print(f"  [OK] {f}")
    
    print("\n3. Verificando estrutura básica das cenas .tscn...")
    tscn_files = [f for f in ESSENTIAL_FILES if f.endswith('.tscn')]
    for f in tscn_files:
        issues = check_tscn_basic(f)
        if issues:
            print(f"  [FAIL] {f}:")
            for issue in issues:
                print(f"    - {issue}")
            all_ok = False
        else:
            print(f"  [OK] {f}")
    
    print("\n" + "=" * 60)
    if all_ok:
        print("[OK] TODAS AS VERIFICACOES PASSARAM")
        print("O projeto deve abrir no Godot 4.7+ sem erros de parse.")
    else:
        print("[FAIL] ALGUMAS VERIFICACOES FALHARAM")
        print("Corrija os problemas acima antes de abrir no Godot.")
    print("=" * 60)
    
    return 0 if all_ok else 1

if __name__ == "__main__":
    sys.exit(main())